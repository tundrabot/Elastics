//
//  MonitoringErrorResponse.m
//  Elastics
//
//  Created by Dmitri Goutnik on 29/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "MonitoringErrorResponse.h"

@implementation MonitoringErrorResponse

- (void)parseElement:(TBXMLElement *)element
{
	element = element->firstChild;
	
	while (element) {
		NSString *elementName = [TBXML elementName:element];
		
		if ([elementName isEqualToString:@"Error"])
			_errors = [[NSArray arrayWithObject:[AWSError typeFromXMLElement:element parent:self]] retain];
		else
			TBTrace(@"ignoring element %@", elementName);
		
		element = element->nextSibling;
	}
}

@end
