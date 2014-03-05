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

@synthesize currentTempLabel, locationLabel, forecastTableView;

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
    [super viewDidLoad];
	
	/* ---------------------------------------------*/
	// stub out some test data
	/* ---------------------------------------------*/
	NSDictionary *day1 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Thursday"], @"weekday", [NSString stringWithFormat:@"60"], @"temp", nil];
	NSDictionary *day2 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Friday"], @"weekday", [NSString stringWithFormat:@"66"], @"temp", nil];
	NSDictionary *day3 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Saturday"], @"weekday", [NSString stringWithFormat:@"64"], @"temp", nil];
	NSDictionary *day4 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Sunday"], @"weekday", [NSString stringWithFormat:@"62"], @"temp", nil];
	NSDictionary *day5 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Monday"], @"weekday", [NSString stringWithFormat:@"68"], @"temp", nil];
	forecastData = [NSArray arrayWithObjects: day1, day2, day3, day4, day5, nil];
	currentTemp = [NSNumber numberWithInt:72];
	
	currentLocation = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Durham"], @"city", [NSString stringWithFormat:@"NC"], @"state", nil];
	 /* ---------------------------------------------*/
	 /* ---------------------------------------------*/
	
	// initialize iVars
	grayDarkest = GRAY_DARKEST;
	
	// Drop in currentTemp data
	currentTempLabel.text = [NSString stringWithFormat:@"%i˚", currentTemp.intValue];
	locationLabel.text = [NSString stringWithFormat:@"%@, %@", [currentLocation objectForKey:@"city"], [currentLocation objectForKey:@"state"]];
	
	// Style UI views
	[self.navigationController.navigationBar setTitleTextAttributes:@{
																	  NSFontAttributeName : AVENIR(18.0f),
																	  NSForegroundColorAttributeName : grayDarkest
																	  }];
	currentTempLabel.textColor = grayDarkest;
	locationLabel.textColor = grayDarkest;
	
	
	// Add a top border to define the edge of the scrollable tableView
	UIView *tableBorderTop = [[UIView alloc] initWithFrame:CGRectMake(forecastTableView.frame.origin.x, forecastTableView.frame.origin.y-1, forecastTableView.frame.size.width, 1)];
	tableBorderTop.backgroundColor = grayDarkest;
	[self.view addSubview:tableBorderTop];
	
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
    return [forecastData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ForecastCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	   
	// get the current item
	NSDictionary *forecastDay = [forecastData objectAtIndex:indexPath.row];
	
    UILabel *tempLabel = (UILabel*)[cell viewWithTag:1];
	tempLabel.textColor = grayDarkest;
	tempLabel.text = [NSString stringWithFormat:@"%@˚", [forecastDay objectForKey:@"temp"]];
	
	
	UILabel *dayLabel = (UILabel*)[cell viewWithTag:2];
	dayLabel.textColor = grayDarkest;
	dayLabel.text = [forecastDay objectForKey:@"weekday"];
	
	if (indexPath.row > 0) {
		UIView *borderTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 1)];
		borderTop.backgroundColor = grayDarkest;
		
		[cell addSubview:borderTop];
	}
    
    return cell;
}

@end
