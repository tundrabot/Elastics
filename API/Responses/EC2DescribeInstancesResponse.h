//
//  EC2DescribeInstancesResponse.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EC2Response.h"

@interface EC2DescribeInstancesResponse : EC2Response {
	NSArray		*_reservationSet;
	NSArray		*_instancesSet;			// collection of all instances in all reservations for convenience
}

@property (nonatomic, retain, readonly) NSArray *reservationSet;
@property (nonatomic, retain, readonly) NSArray *instancesSet;

@end
