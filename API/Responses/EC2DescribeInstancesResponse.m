//
//  EC2DescribeInstancesResponse.m
//  Elastic
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2DescribeInstancesResponse.h"
#import "EC2Reservation.h"

@interface EC2DescribeInstancesResponse ()
@property (nonatomic, retain) NSArray *reservationSet;
@property (nonatomic, retain) NSArray *instancesSet;
@end

@implementation EC2DescribeInstancesResponse

@synthesize reservationSet = _reservationSet;
@synthesize instancesSet = _instancesSet;

- (void)dealloc
{
	TBRelease(_reservationSet);
	TBRelease(_instancesSet);
	[super dealloc];
}

- (void)parseElement:(TBXMLElement *)element;
{
	NSString *elementName = [TBXML elementName:element];
	
	if ([elementName isEqualToString:@"DescribeInstancesResponse"]) {
		element = element->firstChild;
		
		while (element) {
			elementName = [TBXML elementName:element];

			if ([elementName isEqualToString:@"reservationSet"])
				self.reservationSet = [self parseElement:element asArrayOf:[EC2Reservation class]];
			else
				[super parseElement:element];
			
			element = element->nextSibling;
		}
	}
	else {
		[super parseElement:element];
	}
	
	// collect instances from all reservations for convenient access
	NSMutableArray *instances = [NSMutableArray array];
	for (EC2Reservation *reservation in _reservationSet) {
		[instances addObjectsFromArray:reservation.instancesSet];
	}
	self.instancesSet = instances;
}

@end
