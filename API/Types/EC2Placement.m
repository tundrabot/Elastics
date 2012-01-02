//
//  EC2Placement.m
//  Elastics
//
//  Created by Dmitri Goutnik on 01/03/2012.
//  Copyright 2012 Invisible Llama. All rights reserved.
//

#import "EC2Placement.h"

@interface EC2Placement ()
@property (nonatomic, retain) NSString *availabilityZone;
@property (nonatomic, retain) NSString *groupName;
@end

@implementation EC2Placement

@synthesize availabilityZone = _availabilityZone;
@synthesize groupName = _groupName;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent
{
	self = [super initFromXMLElement:element parent:parent];
	
	if (self) {
		element = element->firstChild;
		
		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"availabilityZone"])
				self.availabilityZone = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"groupName"])
				self.groupName = [TBXML textForElement:element];
			else
				NSAssert(FALSE, @"Unable to parse element %@", elementName);

			element = element->nextSibling;
		}
	}
	
	return self;
}

- (void)dealloc
{
	[_availabilityZone release];
	[_groupName release];
	[super dealloc];
}

@end
