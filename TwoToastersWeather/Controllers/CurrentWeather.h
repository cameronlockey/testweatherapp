//
//  CurrentWeather.h
//  TwoToastersWeather
//
//  Created by Cameron Lockey on 3/5/14.
//  Copyright (c) 2014 Cameron Lockey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentWeather : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	NSArray *forecastData;
	NSNumber *currentTemp;
	NSDictionary *currentLocation;
	UIColor *grayDarkest;
}

@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITableView *forecastTableView;
@end
