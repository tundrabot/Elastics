//
//  MonitoringGetMetricStatisticsResponse.m
//  Elastics
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "MonitoringGetMetricStatisticsResponse.h"
#import "MonitoringDatapoint.h"

@interface MonitoringGetMetricStatisticsResponse ()
@property (nonatomic, retain) MonitoringStatisticsResult *result;
@end

@implementation MonitoringGetMetricStatisticsResponse

@synthesize result = _result;

- (void)dealloc
{
	TBRelease(_result);
	[super dealloc];
}

- (void)parseElement:(TBXMLElement *)element;
{
	element = element->firstChild;
	
	while (element) {
		NSString *elementName = [TBXML elementName:element];
	
		if ([elementName isEqualToString:@"GetMetricStatisticsResult"])
			self.result = [MonitoringStatisticsResult typeFromXMLElement:element parent:self];
		else
			[super parseElement:element];
		
		element = element->nextSibling;
	}
}

@end
