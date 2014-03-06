//
//  CLWeatherLocation.m
//  TwoToastersWeather
//
//  Created by Cameron Lockey on 3/5/14.
//  Copyright (c) 2014 Cameron Lockey. All rights reserved.
//

#import "CLLocalWeather.h"
#import "CLWeatherForecastDay.h"
#import "SBJson.h"

@implementation CLLocalWeather

@synthesize queue, delegate;

/* !Initialization Methods
 * ---------------------------------------------*/
-(id)init
{
	if (self = [super init])
	{
		self.city = [[NSString alloc] init];
		self.state = [[NSString alloc] init];
		self.currentTemp = [[NSNumber alloc] init];
		self.forecastDays = [[NSArray alloc] init];
		self.queue = [[NSOperationQueue alloc] init];
	}
	
	currentTempLoaded = FALSE;
	locationLoaded = FALSE;
	forecastLoaded = FALSE;
	
	return self;
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"City: %@ | State: %@ | Current Temperature: %@ | Forecast: %@", self.city, self.state, self.currentTemp.stringValue, self.forecastDays];
}

+(CLLocalWeather*)weatherForLocation:(CLLocation*)location Delegate:delegate
{
	// Build a new CLWeatherLocation object with this data and return it to the controller
	CLLocalWeather *localWeather = [[CLLocalWeather alloc] init];
	
	// Set the delegate
	localWeather.delegate = delegate;
	
	// Get the city/state for the location
	[localWeather cityStateForLocation:location];
	
	// Get the current temperature for this location
	[localWeather currentTemperatureForLocation:location.coordinate];
	
	// Get the 5-day forecast for this location
	[localWeather forecastForLocation:location.coordinate numberOfDays:5];
	
	return localWeather;
}

/* !Data Retrieval Methods
 * ---------------------------------------------*/
-(void)currentTemperatureForLocation:(CLLocationCoordinate2D)location
{
	// Create the request URL String
	NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f",location.latitude,location.longitude];
	
	// Setup and start async download
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
	 {
		 if ([data length] > 0 && connectionError == nil)
		 {
			 [self receivedCurrentWeatherData:data];
		 }
		 else if ([data length] == 0 && connectionError == nil)
		 {
			 [self emptyReply];
		 }
		 else if (connectionError != nil && connectionError.code == NSURLErrorTimedOut)
		 {
			 [self timedOut];
		 }
		 else if (connectionError != nil)
		 {
			 [self downloadError:connectionError];
		 }
	 }];
}

-(void)forecastForLocation:(CLLocationCoordinate2D)location numberOfDays:(int)days
{
	// Create the request URL String
	NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=%i&mode=json",location.latitude,location.longitude, days];
	
	// Setup and start async download
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
	 {
		 if ([data length] > 0 && connectionError == nil)
		 {
			 [self receivedForecastData:data];
		 }
		 else if ([data length] == 0 && connectionError == nil)
		 {
			 [self emptyReply];
		 }
		 else if (connectionError != nil && connectionError.code == NSURLErrorTimedOut)
		 {
			 [self timedOut];
		 }
		 else if (connectionError != nil)
		 {
			 [self downloadError:connectionError];
		 }
	 }];
}

-(void)cityStateForLocation:(CLLocation*)location
{
	// get the city/state for the current location
	CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
	[geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		
		if (error || placemarks.count == 0)
		{
			[self didFailFindingPlacemarkWithError:error];
        }
		else
		{
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            [self didFindPlacemark:placemark];
        }
	}];
}

-(void)checkWeatherFinishedLoading
{
	if (currentTempLoaded && locationLoaded && forecastLoaded)
	{
		[delegate didFinishLoadingWeather];
	}
}

/* !Geocoding callbacks
 * ---------------------------------------------*/
-(void)didFindPlacemark:(CLPlacemark *)placemark
{	
	// start parsing dictionary for string
	NSDictionary *placeDict = placemark.addressDictionary;
	
	self.city = [placeDict objectForKey:@"City"];
	self.state = [placeDict objectForKey:@"State"];
	
	locationLoaded = TRUE;
	[self checkWeatherFinishedLoading];
}

-(void)didFailFindingPlacemarkWithError:(NSError *)error
{
	NSLog(@"Failed to find a placemark with error: %@", [error localizedDescription]);
}

/* !NSURLConnection Callbacks
 * ---------------------------------------------*/
-(void)receivedCurrentWeatherData:(NSData *)data
{
	// Parse the data into an NSDictionary
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSError *sbError = [[NSError alloc] init];
	NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *weatherDict = (NSDictionary*) [parser objectWithString:jsonData error:&sbError];
	
	// Save the current temperature
	NSString *kelvinTemp = [[weatherDict objectForKey:@"main"] objectForKey:@"temp"];
	int currentTemp = [CLLocalWeather fahrenheitTemperature:kelvinTemp.floatValue];
	self.currentTemp = [NSNumber numberWithInt:currentTemp];
	
	currentTempLoaded = TRUE;
	
	[self checkWeatherFinishedLoading];
}

-(void)receivedForecastData:(NSData *)data
{
	// Parse the data into an NSDictionary and save the values in an array
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSError *sbError = [[NSError alloc] init];
	NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *forecastDict = (NSDictionary*) [parser objectWithString:jsonData error:&sbError];
	NSDictionary *forecastList = [forecastDict objectForKey:@"list"];
	
	NSMutableArray *forecastDays = [[NSMutableArray alloc] init];
	
	// Convert the NSDictionary values in to an array of CLWeatherForecastDay objects
	for (NSDictionary *day in forecastList)
	{
		NSString *kelvinTempString = [[day objectForKey:@"temp"] objectForKey:@"day"];
		float kelvinTemp = kelvinTempString.floatValue;
		NSNumber *temperature = [NSNumber numberWithInt:[CLLocalWeather fahrenheitTemperature:kelvinTemp]];
		
		NSString *weekdayUnix = [day objectForKey:@"dt"];
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:[weekdayUnix intValue]];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[dateFormatter setDateFormat:@"EEEE"];
		NSString *weekday = [dateFormatter stringFromDate:date];
		CLWeatherForecastDay *forecastDay = [[CLWeatherForecastDay alloc] initWithTemperature:temperature Weekday:weekday];
		
		[forecastDays addObject:forecastDay];
	}
	
	self.forecastDays = [NSArray arrayWithArray:forecastDays];
	
	forecastLoaded = TRUE;
	[self checkWeatherFinishedLoading];
}

-(void)emptyReply
{
	NSLog(@"No data received.");
}

-(void)timedOut
{
	NSLog(@"Request timed out.");
}

-(void)downloadError:(NSError *)error
{
	NSLog(@"Download Error Occurred: %@", [error localizedDescription]);
}

/* !Helper Methods
 * ---------------------------------------------*/
+(int)fahrenheitTemperature:(float)kelvin
{
	return (int) 1.8 * (kelvin - 273) + 32;
}

@end
