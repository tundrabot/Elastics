//
//  AWSError.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 27/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSError.h"

@interface AWSError ()
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *message;
@end

@implementation AWSError

@synthesize type = _type;
@synthesize code = _code;
@synthesize message = _message;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent
{
	self = [super initFromXMLElement:element parent:parent];
	
	if (self) {
		element = element->firstChild;
		
		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"Type"])
				self.type = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"Code"])
				self.code = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"Message"])
				self.message = [TBXML textForElement:element];
			else
				TB_TRACE(@"Ignoring element %@", elementName);
			
			element = element->nextSibling;
		}
	}
	
	return self;
}

- (void)dealloc
{
	TB_RELEASE(_type);
	TB_RELEASE(_code);
	TB_RELEASE(_message);
	[super dealloc];
}

@end
