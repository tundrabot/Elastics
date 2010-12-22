//
//  EC2Type.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2Type.h"

@implementation EC2Type

@synthesize parent = _parent;

+ (id)typeFromXMLElement:(TBXMLElement *)element parent:(EC2Type *)parent
{
	return [[[self alloc] initFromXMLElement:element parent:parent] autorelease];
}

- (id)initFromXMLElement:(TBXMLElement *)element parent:(EC2Type *)parent
{
	self = [super init];
	if (self) {
		_parent = [parent retain];
	}
	return self;
}

- (void)dealloc
{
	[_parent release];
	[super dealloc];
}

+ (NSString *)stringFromDate:(NSDate *)value
{
	return [NSDateFormatter localizedStringFromDate:value
										  dateStyle:NSDateFormatterMediumStyle
										  timeStyle:NSDateFormatterShortStyle];
	
}

+ (NSString *)stringFromBool:(BOOL)value
{
	return value ? @"Yes" : @"No";
}

+ (NSDate *)dateFromString:(NSString *)dateString
{
	// parse timestamp from ISO 8601 string
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.S'Z'"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	return [dateFormatter dateFromString:dateString];
}

- (NSArray *)_parseXMLElement:(TBXMLElement *)element asArrayOf:(Class)class
{
	NSMutableArray *result = [NSMutableArray array];
	element = element->firstChild;
	
	while (element) {
		NSString *elementName = [TBXML elementName:element];
		
		if ([elementName isEqualToString:@"item"])
			[result addObject:[class typeFromXMLElement:element parent:self]];
		else
			NSAssert(FALSE, @"Unable to parse element %@", elementName);
		
		element = element->nextSibling;
	}
	
	return result;
}

//- (NSArray *)_parseXMLElement:(TBXMLElement *)element asDictionaryOf:(Class)class withKey:(NSString *)key
//{
//	NSMutableDictionary *result = [NSMutableDictionary dictionary];
//	element = element->firstChild;
//	
//	while (element) {
//		NSString *elementName = [TBXML elementName:element];
//		
//		if ([elementName isEqualToString:@"key"])
//			key = [TBXML textForElement:element];
//		else if ([elementName isEqualToString:@"value"])
//			value = [TBXML textForElement:element];
//
//		element = element->nextSibling;
//	}
//
//	return result;
//}

@end
