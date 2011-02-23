//
//  AWSResponse.m
//  Elastics
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
		[self parseElement:rootElement];
	}
	return self;
}

- (void)parseElement:(TBXMLElement *)element
{
//	TBTrace(@"ignoring element %@", [TBXML elementName:element]);
}

@end
