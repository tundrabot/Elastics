//
//  NSDate+StringConversions.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "NSDate+StringConversions.h"

@implementation NSDate (StringConversions)

- (NSString *)localizedString
{
	return [NSDateFormatter localizedStringFromDate:self
										  dateStyle:NSDateFormatterMediumStyle
										  timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)iso8601String
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	return [dateFormatter stringFromDate:self];
}

@end
