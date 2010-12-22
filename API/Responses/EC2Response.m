//
//  EC2Response.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2Response.h"


@interface EC2Response ()
@property (nonatomic, retain) NSString *requestId;
@end

@implementation EC2Response

@synthesize requestId = _requestId;

+ (id)responseWithRootXMLElement:(TBXMLElement *)rootElement
{
	return [[[self alloc] initWithRootXMLElement:rootElement] autorelease];
}

- (id)initWithRootXMLElement:(TBXMLElement *)rootElement
{
	self = [super init];
	if (self) {
		TBXMLElement *element;
		NSString *elementName;
		
		elementName = [TBXML elementName:rootElement];
		
		if ([self.rootElementName isEqualToString:elementName] == NO) {
			[NSException raise:@"Invalid root element" format:@"got %@, expected %@", elementName, [self rootElementName]];
		}
		else {
			element = rootElement->firstChild;
			
			while (element) {
				elementName = [TBXML elementName:element];
				
				if ([elementName isEqualToString:@"requestId"])
					self.requestId = [TBXML textForElement:element];
				else
					[self _parseXMLElement:element];
				
				element = element->nextSibling;
			}
		}
	}
	return self;
}

- (void)dealloc
{
	[_requestId release];
	[super dealloc];
}

- (NSString *)rootElementName
{
	NSAssert(FALSE, @"Abstract method call.");
	return nil;
}

- (void)_parseXMLElement:(TBXMLElement *)element
{
	NSAssert(FALSE, @"Abstract method call.");
}

@end
