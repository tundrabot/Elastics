//
//  EC2InstanceState.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2InstanceState.h"

@interface EC2InstanceState ()
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, retain) NSString *name;
@end

@implementation EC2InstanceState

@synthesize code = _code;
@synthesize name = _name;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(EC2Type *)parent
{
	self = [super initFromXMLElement:element parent:parent];
	
	if (self) {
		element = element->firstChild;

		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"code"])
				self.code = [[TBXML textForElement:element] integerValue];
			else if ([elementName isEqualToString:@"name"])
				self.name = [TBXML textForElement:element];
			
			element = element->nextSibling;
		}
	}
	
	return self;
}

- (void)dealloc
{
	TB_RELEASE(_name);
	[super dealloc];
}

@end
