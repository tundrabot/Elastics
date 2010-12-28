//
//  AWSType.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSType.h"

@implementation AWSType

@synthesize parent = _parent;

+ (id)typeFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent
{
	return [[[self alloc] initFromXMLElement:element parent:parent] autorelease];
}

- (id)initFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent
{
	self = [super init];
	if (self) {
		_parent = [parent retain];
	}
	return self;
}

- (id)init
{
	return [self initFromXMLElement:nil parent:nil];
}

- (void)dealloc
{
	TBRelease(_parent);
	[super dealloc];
}

+ (NSString *)stringFromBool:(BOOL)value
{
	return value ? @"Yes" : @"No";
}

- (NSArray *)parseElement:(TBXMLElement *)element asArrayOf:(Class)class
{
	NSMutableArray *result = [NSMutableArray array];
	element = element->firstChild;
	
	while (element) {
		NSString *elementName = [TBXML elementName:element];
		
		if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"member"] || [elementName isEqualToString:@"Error"])
			[result addObject:[class typeFromXMLElement:element parent:self]];
		else
			TBTrace(@"%@: parseElement:asArrayOf: skipping element %@", NSStringFromClass([self class]), elementName);
		
		element = element->nextSibling;
	}
	
	return result;
}

@end
