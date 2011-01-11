//
//  AWSError.m
//  Elastic
//
//  Created by Dmitri Goutnik on 27/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSError.h"

// dictionaryRepresentation dictionary keys
NSString *const kAWSErrorTypeKey = @"AWSErrorType";
NSString *const kAWSErrorCodeKey = @"AWSErrorCode";
NSString *const kAWSErrorMessageKey = @"AWSErrorMessage";

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
				TBTrace("ignoring element %@", elementName);
			
			element = element->nextSibling;
		}
	}
	
	return self;
}

- (void)dealloc
{
	TBRelease(_type);
	TBRelease(_code);
	TBRelease(_message);
	[super dealloc];
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];

	if (_type)
		[result setObject:_type forKey:kAWSErrorTypeKey];
	if (_code)
		[result setObject:_code forKey:kAWSErrorCodeKey];
	if (_message)
		[result setObject:_message forKey:kAWSErrorMessageKey];

	return result;
}

@end
