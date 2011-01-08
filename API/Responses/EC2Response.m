//
//  EC2Response.m
//  Elastic
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2Response.h"

@interface EC2Response ()
@property (nonatomic, retain) NSString *requestId;
@end

@implementation EC2Response

@synthesize requestId = _requestId;

- (void)dealloc
{
	TBRelease(_requestId);
	[super dealloc];
}

- (void)parseElement:(TBXMLElement *)element;
{
	NSString *elementName = [TBXML elementName:element];

	if ([elementName isEqualToString:@"requestId"])
		self.requestId = [TBXML textForElement:element];
	else
		[super parseElement:element];
}

@end
