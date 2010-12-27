//
//  MonitoringDatapoint.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSType.h"

@interface MonitoringDatapoint : AWSType {
@private
	NSTimeInterval		_timestamp;
	NSString			*_unit;
	CGFloat				_minimum;
	CGFloat				_maximum;
	CGFloat				_average;
}

@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, retain, readonly) NSString *unit;
@property (nonatomic, readonly) CGFloat minimum;
@property (nonatomic, readonly) CGFloat maximum;
@property (nonatomic, readonly) CGFloat average;

@end
