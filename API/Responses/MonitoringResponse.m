//
//  MonitoringResponse.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "MonitoringResponse.h"

@implementation MonitoringResponse

- (id)initWithRootXMLElement:(TBXMLElement *)rootElement
{
	self = [super initWithRootXMLElement:rootElement];
	if (self) {
		TBXMLElement *element = rootElement->firstChild;
		
		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"ResponseMetadata"])
				;	//self.requestId = [TBXML textForElement:element];
			else
				[self _parseXMLElement:element];
			
			element = element->nextSibling;
		}
	}
	return self;
}

@end
