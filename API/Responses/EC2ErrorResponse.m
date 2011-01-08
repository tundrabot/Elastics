//
//  EC2ErrorResponse.m
//  Elastic
//
//  Created by Dmitri Goutnik on 29/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2ErrorResponse.h"

@implementation EC2ErrorResponse

- (void)parseElement:(TBXMLElement *)element
{
	element = element->firstChild;
	
	while (element) {
		NSString *elementName = [TBXML elementName:element];
		
		if ([elementName isEqualToString:@"Errors"])
			_errors = [[self parseElement:element asArrayOf:[AWSError class]] retain];
		else
			TBTrace(@"ignoring element %@", elementName);
		
		element = element->nextSibling;
	}
}

@end
