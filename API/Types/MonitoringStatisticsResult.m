//
//  MonitoringStatisticsResult.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "MonitoringStatisticsResult.h"
#import "MonitoringDatapoint.h"

@interface MonitoringStatisticsResult ()
@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) NSArray *datapoints;
@end

@implementation MonitoringStatisticsResult

@synthesize label = _label;
@synthesize datapoints = _datapoints;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent
{
	self = [super initFromXMLElement:element parent:parent];
	
	if (self) {
		element = element->firstChild;
		
		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"Label"])
				self.label = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"Datapoints"]) {
				// Amazon returns datapoints in the random order. Sort them by timestamp.
				NSArray *unsortedDatapoints = [self parseElement:element asArrayOf:[MonitoringDatapoint class]];
				self.datapoints = [unsortedDatapoints sortedArrayUsingSelector:@selector(compare:)];
			}
			
			element = element->nextSibling;
		}
	}
	return self;
}

- (void)dealloc
{
	TB_RELEASE(_label);
	TB_RELEASE(_datapoints);
	[super dealloc];
}

@end
