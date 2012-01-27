//
//  EC2Group.m
//  Elastics
//
//  Created by Dmitri Goutnik on 27/01/2012.
//  Copyright 2012 Tundra Bot. All rights reserved.
//

#import "EC2Group.h"

@interface EC2Group ()
@property (nonatomic, retain) NSString *groupId;
@end

@implementation EC2Group

@synthesize groupId = _groupId;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent
{
	self = [super initFromXMLElement:element parent:parent];

	if (self) {
		element = element->firstChild;
		
		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"groupId"])
				self.groupId = [TBXML textForElement:element];

			element = element->nextSibling;
		}
	}

	return self;
}

- (void)dealloc
{
	[_groupId release];
	[super dealloc];
}

@end
