//
//  CurrentWeather.m
//  TwoToastersWeather
//
//  Created by Cameron Lockey on 3/5/14.
//  Copyright (c) 2014 Cameron Lockey. All rights reserved.
//

#import "CurrentWeather.h"
#import "UIHelper.h"

@interface CurrentWeather ()

@end

@implementation CurrentWeather

@synthesize currentTempLabel, locationLabel, forecastTableView, tableBorderTop, lastLocation, locationMgr, localWeather;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	// Set Up Location Info
	lastLocation = nil;
	locationMgr = [[CLLocationManager alloc] init];
	locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
	locationMgr.delegate = self;
	[locationMgr startUpdatingLocation];
	
    [super viewDidLoad];
	
	// initialize iVars
	grayDarkest = GRAY_DARKEST;
	
	// Style UI views
	[self.navigationController.navigationBar setTitleTextAttributes:@{
																	  NSFontAttributeName : AVENIR(18.0f),
																	  NSForegroundColorAttributeName : grayDarkest
																	  }];
	currentTempLabel.textColor = grayDarkest;
	locationLabel.textColor = grayDarkest;
	
	
	// Add a top border to define the edge of the scrollable tableView
	tableBorderTop = [[UIView alloc] initWithFrame:CGRectMake(forecastTableView.frame.origin.x, forecastTableView.frame.origin.y-1, forecastTableView.frame.size.width, 1)];
	tableBorderTop.backgroundColor = grayDarkest;
	[self.view addSubview:tableBorderTop];
	
	// hide everything by default
	currentTempLabel.layer.opacity = 0;
	locationLabel.layer.opacity = 0;
	forecastTableView.layer.opacity = 0;
	tableBorderTop.layer.opacity = 0;
	
}

-(void)viewWillAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [localWeather.forecastDays count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ForecastCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	   
	// get the current item
	CLWeatherForecastDay *forecastDay = [localWeather.forecastDays objectAtIndex:indexPath.row];
	
    UILabel *tempLabel = (UILabel*)[cell viewWithTag:1];
	tempLabel.textColor = grayDarkest;
	tempLabel.text = [NSString stringWithFormat:@"%@˚",forecastDay.temperature.stringValue];
	
	
	UILabel *dayLabel = (UILabel*)[cell viewWithTag:2];
	dayLabel.textColor = grayDarkest;
	dayLabel.text = forecastDay.weekday;
	
	if (indexPath.row > 0) {
		UIView *borderTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 1)];
		borderTop.backgroundColor = grayDarkest;
		
		[cell addSubview:borderTop];
	}
    
    return cell;
}

/* !Refresh Methods
 * ---------------------------------------------*/
-(void)updateWeatherForLocation:(CLLocation *)location
{
	// update the current weather and forecast data
	localWeather = [CLLocalWeather weatherForLocation:location Delegate:self];
}

/* !CLLocationManagerDelegate Methods
 * ---------------------------------------------*/
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	if (lastLocation == nil) {
		
		lastLocation = locations.lastObject;
		[self updateWeatherForLocation:lastLocation];
	}
	else
	{
		lastLocation = locations.lastObject;
		[manager stopUpdatingLocation];
	}
}

/* !CLLocalWeatherDelegate Methods
 * ---------------------------------------------*/
-(void)didFinishLoadingCurrentWeather
{
	currentTempLabel.layer.opacity = 0;
	currentTempLabel.text = [NSString stringWithFormat:@"%@˚", localWeather.currentTemp.stringValue];
	[UIView animateWithDuration:1.0 animations:^{
		currentTempLabel.layer.opacity = 1;
	}];
}

-(void)didFinishLoadingForecast
{
	forecastTableView.layer.opacity = 0;
	tableBorderTop.layer.opacity = 0;
	[forecastTableView reloadData];
	
	[UIView animateWithDuration:1.0 animations:^{
		forecastTableView.layer.opacity = 1;
		tableBorderTop.layer.opacity = 1;
	}];
}

-(void)didFinishLoadingLocation
{
	locationLabel.layer.opacity = 0;
	locationLabel.text = [NSString stringWithFormat:@"%@, %@", localWeather.city, localWeather.state];
	
	[UIView animateWithDuration:1.0 animations:^{
		locationLabel.layer.opacity = 1;
	}];
}

@end
