//
//  MonitoringDatapoint.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "NSString+DateConversions.h"
#import "MonitoringDatapoint.h"

@interface MonitoringDatapoint ()
@property (nonatomic, retain) NSString *unit;
@end

@implementation MonitoringDatapoint

@synthesize timestamp = _timestamp;
@synthesize unit = _unit;
@synthesize minimum = _minimum;
@synthesize maximum = _maximum;
@synthesize average = _average;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent
{
	self = [super initFromXMLElement:element parent:parent];
	
	if (self) {
		element = element->firstChild;
		
		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"Timestamp"])
				_timestamp = [[[TBXML textForElement:element] iso8601Date] timeIntervalSinceReferenceDate];
			else if ([elementName isEqualToString:@"Unit"])
				self.unit = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"Minimum"])
				_minimum = [[TBXML textForElement:element] floatValue];
			else if ([elementName isEqualToString:@"Maximum"])
				_maximum = [[TBXML textForElement:element] floatValue];
			else if ([elementName isEqualToString:@"Average"])
				_average = [[TBXML textForElement:element] floatValue];
			
			element = element->nextSibling;
		}
	}
	
	return self;
}

- (NSComparisonResult)compare:(MonitoringDatapoint *)anotherDatapoint
{
	if (_timestamp < anotherDatapoint.timestamp)
		return NSOrderedAscending;
	else if (_timestamp > anotherDatapoint.timestamp)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@: min:%.2f max:%.2f avg:%.2f", _timestamp, _minimum, _maximum, _average];
}

- (void)dealloc
{
	TB_RELEASE(_unit);
	[super dealloc];
}

@end
