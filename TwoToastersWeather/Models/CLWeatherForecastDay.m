//
//  CLWeatherForecastDay.m
//  TwoToastersWeather
//
//  Created by Cameron Lockey on 3/5/14.
//  Copyright (c) 2014 Cameron Lockey. All rights reserved.
//

#import "CLWeatherForecastDay.h"

@implementation CLWeatherForecastDay

-(id)initWithTemperature:(NSNumber*)temperature Weekday:(NSString*)weekday
{
	if (self = [super init]) {
		self.temperature = temperature;
		self.weekday = weekday;
	}
	
	return self;
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"%@ - %@", self.temperature, self.weekday];
}

@end
