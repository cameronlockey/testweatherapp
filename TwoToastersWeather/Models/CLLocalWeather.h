//
//  CLWeatherLocation.h
//  TwoToastersWeather
//
//  Created by Cameron Lockey on 3/5/14.
//  Copyright (c) 2014 Cameron Lockey. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@protocol CLLocalWeatherDelegate;

@interface CLLocalWeather : NSObject
{
	BOOL currentTempLoaded;
	BOOL locationLoaded;
	BOOL forecastLoaded;
}

@property (strong, nonatomic) NSString			*city;
@property (strong, nonatomic) NSString			*state;
@property (strong, nonatomic) NSNumber			*currentTemp;
@property (strong, nonatomic) NSArray			*forecastDays;

@property (strong, nonatomic) NSOperationQueue	*queue;

/* !Initialization Methods
 * ---------------------------------------------*/
-(id)init;
+(CLLocalWeather*)weatherForLocation:(CLLocation*)location Delegate:delegate;

/* !Data Retrieval Methods
 * ---------------------------------------------*/
-(void)currentTemperatureForLocation:(CLLocationCoordinate2D)location;
-(void)forecastForLocation:(CLLocationCoordinate2D)location numberOfDays:(int)days;
-(void)cityStateForLocation:(CLLocation*)location;
-(void)checkWeatherFinishedLoading;

/* !Geocoding Callbacks
 * ---------------------------------------------*/
-(void)didFindPlacemark:(CLPlacemark*)placemark;
-(void)didFailFindingPlacemarkWithError:(NSError*)error;

/* !NSURLConnection Callbacks
 * ---------------------------------------------*/
-(void)receivedCurrentWeatherData:(NSData*)data;
-(void)receivedForecastData:(NSData*)data;
-(void)emptyReply;
-(void)timedOut;
-(void)downloadError:(NSError*)error;

/* !Helper Methods
 * ---------------------------------------------*/
+(int)fahrenheitTemperature:(float)kelvin;

/* !CLWeatherLocationDelegate
 * ---------------------------------------------*/
@property (weak,nonatomic) id <CLLocalWeatherDelegate> delegate;

@end

@protocol CLLocalWeatherDelegate <NSObject>

-(void)didFinishLoadingWeather;

@end
