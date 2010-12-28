//
//  MonitoringGetMetricStatisticsResponse.m
//  Cloudwatch
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

- (NSString *)_rootElementName
{
	return @"GetMetricStatisticsResponse";
}

- (void)_parseXMLElement:(TBXMLElement *)element;
{
	NSString *elementName = [TBXML elementName:element];
	
	if ([elementName isEqualToString:@"GetMetricStatisticsResult"])
		self.result = [MonitoringStatisticsResult typeFromXMLElement:element parent:self];
}

- (void)dealloc
{
	TBRelease(_result);
	[super dealloc];
}

@end
