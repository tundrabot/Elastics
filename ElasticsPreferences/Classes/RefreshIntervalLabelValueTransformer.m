//
//  RefreshIntervalValueTransformer.m
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 27/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "RefreshIntervalLabelValueTransformer.h"

@implementation RefreshIntervalLabelValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
//	TBTrace("transformedValue: %@", value);
	
	if (!value)
		return nil;

	NSInteger refreshInterval = [value intValue] / 60;
	
	if (refreshInterval > 0) {
		if (refreshInterval == 1)
			return [NSString stringWithFormat:@"1 minute"];
		if (refreshInterval >= 1 && refreshInterval < 60)
			return [NSString stringWithFormat:@"%zd minutes", refreshInterval];
		else
			return [NSString stringWithFormat:@"%zd hour", refreshInterval / 60];
	}
	else {
		return @"Manually";
	}
}

@end
