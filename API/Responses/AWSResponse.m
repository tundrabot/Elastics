//
//  AWSResponse.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSResponse.h"

@implementation AWSResponse

+ (id)responseWithRootXMLElement:(TBXMLElement *)rootElement
{
	return [[[self alloc] initWithRootXMLElement:rootElement] autorelease];
}

- (id)initWithRootXMLElement:(TBXMLElement *)rootElement
{
	self = [super init];
	if (self) {
		NSString *elementName = [TBXML elementName:rootElement];
		
		if ([[self _rootElementName] isEqualToString:elementName] == NO) {
			[NSException raise:@"Invalid root element" format:@"got %@, expected %@", elementName, [self _rootElementName]];
			return nil;
		}
	}
	return self;
}

- (NSString *)_rootElementName
{
	NSAssert(FALSE, @"Abstract method call.");
	return nil;
}

- (void)_parseXMLElement:(TBXMLElement *)element
{
	NSAssert(FALSE, @"Abstract method call.");
}

@end
