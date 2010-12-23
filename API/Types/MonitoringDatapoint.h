//
//  MonitoringDatapoint.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EC2Type.h"

@interface MonitoringDatapoint : EC2Type {
@private
	NSDate		*_timestamp;
	NSString	*_unit;
	float		_minimum;
	float		_maximum;
	float		_average;
}

@property (nonatomic, retain, readonly) NSDate *timestamp;
@property (nonatomic, retain, readonly) NSString *unit;
@property (nonatomic, readonly) float minimum;
@property (nonatomic, readonly) float maximum;
@property (nonatomic, readonly) float average;

@end
