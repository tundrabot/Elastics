//
//  EC2Reservation.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSType.h"

@interface EC2Reservation : AWSType {
@private
	NSString	*_reservationId;
	NSArray		*_instancesSet;		// EC2Instance
}

@property (nonatomic, retain, readonly) NSString *reservationId;
@property (nonatomic, retain, readonly) NSArray *instancesSet;

@end
