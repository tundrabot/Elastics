//
//  EC2Reservation.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2Reservation.h"
#import "EC2Instance.h"

@interface EC2Reservation ()
@property (nonatomic, retain) NSString *reservationId;
@property (nonatomic, retain) NSArray *instancesSet;
@end

@implementation EC2Reservation

@synthesize reservationId = _reservationId;
@synthesize instancesSet = _instancesSet;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent
{
	self = [super initFromXMLElement:element parent:parent];
	
	if (self) {
		element = element->firstChild;
		
		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"reservationId"])
				self.reservationId = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"instancesSet"])
				self.instancesSet = [self parseElement:element asArrayOf:[EC2Instance class]];

			element = element->nextSibling;
		}
	}
	return self;
}

- (void)dealloc
{
	TBRelease(_reservationId);
	TBRelease(_instancesSet);
	[super dealloc];
}

@end
