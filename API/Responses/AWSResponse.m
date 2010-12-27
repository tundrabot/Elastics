//
//  AWSResponse.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSResponse.h"


@interface AWSResponse ()

@property (nonatomic, retain) NSArray *errors;

- (BOOL)isErrorElement:(TBXMLElement *)element;
- (void)parseErrorElement:(TBXMLElement *)element;
@end


@implementation AWSResponse

@synthesize errors = _errors;

+ (id)responseWithRootXMLElement:(TBXMLElement *)rootElement
{
	return [[[self alloc] initWithRootXMLElement:rootElement] autorelease];
}

- (id)initWithRootXMLElement:(TBXMLElement *)rootElement
{
	self = [super init];
	if (self) {
		if ([self isErrorElement:rootElement])
			[self parseErrorElement:rootElement];
		else
			[self parseElement:rootElement];
	}
	return self;
}

- (void)dealloc
{
	TB_RELEASE(_errors);
	[super dealloc];
}

- (BOOL)isError
{
	return [_errors count] > 0;
}

- (BOOL)isErrorElement:(TBXMLElement *)element
{
	NSString *elementName = [TBXML elementName:element];
	return [elementName isEqualToString:@"Response"] || [elementName isEqualToString:@"ErrorResponse"];
}

- (void)parseErrorElement:(TBXMLElement *)element
{
	element = element->firstChild;
	
	while (element) {
		NSString *elementName = [TBXML elementName:element];
		
		if ([elementName isEqualToString:@"Error"])
			self.errors = [NSArray arrayWithObject:[AWSError typeFromXMLElement:element parent:self]];
		else if ([elementName isEqualToString:@"Errors"])
			self.errors = [self parseElement:element asArrayOf:[AWSError class]];
		else
			TB_TRACE(@"%@: parseErrorElement: skipping element %@", NSStringFromClass([self class]), elementName);
		
		element = element->nextSibling;
	}
}

- (void)parseElement:(TBXMLElement *)element
{
	TB_TRACE(@"%@: parseElement: skipping element %@", NSStringFromClass([self class]), [TBXML elementName:element]);
}

@end
