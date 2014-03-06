//
//  CLWeatherForecastDay.h
//  TwoToastersWeather
//
//  Created by Cameron Lockey on 3/5/14.
//  Copyright (c) 2014 Cameron Lockey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLWeatherForecastDay : NSObject

@property (strong,nonatomic) NSNumber *temperature;
@property (strong,nonatomic) NSString *weekday;

-(id)initWithTemperature:(NSNumber*)temperature Weekday:(NSString*)weekday;

@end
