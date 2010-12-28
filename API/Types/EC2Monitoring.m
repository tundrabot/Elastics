//
//  EC2Monitoring.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Invisible Llama. All rights reserved.
//

#import "EC2Monitoring.h"

@interface EC2Monitoring ()
@property (nonatomic, retain) NSString *state;
@end

@implementation EC2Monitoring

@synthesize state = _state;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent
{
	self = [super initFromXMLElement:element parent:parent];
	
	if (self) {
		element = element->firstChild;
		
		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"state"])
				self.state = [TBXML textForElement:element];
			else
				TBTrace(@"Ignoring element %@", elementName);

			element = element->nextSibling;
		}
	}
	
	return self;
}

- (void)dealloc
{
	[_state release];
	[super dealloc];
}

- (NSString *)monitoringType
{
	return [_state isEqualToString:@"enabled"] ? @"detailed" : @"basic";
}

@end
