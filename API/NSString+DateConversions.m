//
//  NSString+DateConversions.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "NSString+DateConversions.h"

@implementation NSString (DateConversions)

- (NSDate *)iso8601Date
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

	// Handle both cases - with second fractions and without...
	// TODO: is there a better way to handle optional fractions ?
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.S'Z'"];
	NSDate *result = [dateFormatter dateFromString:self];
	
	if (result) {
		return result;
	}
	else {
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		return [dateFormatter dateFromString:self];
	}
}

@end
