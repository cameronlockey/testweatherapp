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
	
	UIView *borderTop = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-1, cell.frame.size.width, 1)];
	borderTop.backgroundColor = grayDarkest;
	
	[cell addSubview:borderTop];
    
    return cell;
}

#pragma mark -
#pragma mark Refresh methods
-(void)updateWeatherForLocation:(CLLocation *)location
{
	// The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	HUD.labelText = @"Loading Local Weather";
	
	// Show the HUD while the provided method executes in a new thread
	[HUD show:YES];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	// update the current weather and forecast data
	localWeather = [CLLocalWeather weatherForLocation:location Delegate:self];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods
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

#pragma mark -
#pragma mark CLLocalWeatherDelegate methods
-(void)didFinishLoadingWeather
{
	currentTempLabel.layer.opacity = 0;
	forecastTableView.layer.opacity = 0;
	locationLabel.layer.opacity = 0;
	tableBorderTop.layer.opacity = 0;
	
	[forecastTableView reloadData];
	currentTempLabel.text = [NSString stringWithFormat:@"%@˚", localWeather.currentTemp.stringValue];
	locationLabel.text = [NSString stringWithFormat:@"%@, %@", localWeather.city, localWeather.state];
	
	[HUD hide:YES];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[UIView animateWithDuration:1.0 animations:^{
		currentTempLabel.layer.opacity = 1;
		forecastTableView.layer.opacity = 1;
		tableBorderTop.layer.opacity = 1;
		locationLabel.layer.opacity = 1;
	}];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}
@end
