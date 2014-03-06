//
//  CurrentWeather.h
//  TwoToastersWeather
//
//  Created by Cameron Lockey on 3/5/14.
//  Copyright (c) 2014 Cameron Lockey. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "CLLocalWeather.h"
#import "CLWeatherForecastDay.h"


@interface CurrentWeather : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, CLLocalWeatherDelegate>
{
	UIColor *grayDarkest;
}

// UI Properties
@property (weak, nonatomic) IBOutlet UILabel		*currentTempLabel;
@property (weak, nonatomic) IBOutlet UILabel		*locationLabel;
@property (weak, nonatomic) IBOutlet UITableView	*forecastTableView;
@property (strong, nonatomic) UIView					*tableBorderTop;

// Location Properties
@property (strong,nonatomic) CLLocationManager		*locationMgr;
@property (strong,nonatomic) CLLocation				*lastLocation;

// Weather Properties
@property (strong,nonatomic) CLLocalWeather		*localWeather;

-(void)updateWeatherForLocation:(CLLocation*)location;

@end


