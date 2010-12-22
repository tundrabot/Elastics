//
//  EC2Tag.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 02/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2Tag.h"

@interface EC2Tag ()
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;
@end

@implementation EC2Tag

@synthesize key = _key;
@synthesize value = _value;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(EC2Type *)parent
{
	self = [super initFromXMLElement:element parent:parent];
	
	if (self) {
		element = element->firstChild;
		
		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"key"])
				self.key = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"value"])
				self.value = [TBXML textForElement:element];
			else
				NSAssert(FALSE, @"Unable to parse element %@", elementName);

			element = element->nextSibling;
		}
	}
	
	return self;
}

- (void)dealloc
{
	[_key release];
	[_value release];
	[super dealloc];
}

@end
