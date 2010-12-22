//
//  EC2DescribeInstancesResponse.m
//  Cloudwatch
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
	[_reservationSet release];
	[_instancesSet release];
	[super dealloc];
}

- (NSString *)rootElementName
{
	return @"DescribeInstancesResponse";
}

- (void)_parseXMLElement:(TBXMLElement *)element;
{
	NSString *elementName = [TBXML elementName:element];

	if ([elementName isEqualToString:@"reservationSet"])
		self.reservationSet = [self _parseXMLElement:element asArrayOf:[EC2Reservation class]];
	else
		NSAssert(FALSE, @"Unable to parse element %@", elementName);
	
	// collect instances from all reservations for convenient access
	NSMutableArray *instances = [NSMutableArray array];
	for (EC2Reservation *reservation in _reservationSet) {
		[instances addObjectsFromArray:reservation.instancesSet];
	}
	self.instancesSet = instances;
}

@end
