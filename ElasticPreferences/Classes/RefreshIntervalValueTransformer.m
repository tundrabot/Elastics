//
//  RefreshIntervalValueTransformer.m
//  ElasticPreferences
//
//  Created by Dmitri Goutnik on 27/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "RefreshIntervalValueTransformer.h"

@implementation RefreshIntervalValueTransformer

+ (Class)transformedValueClass
{
	return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)transformedValue:(id)value
{
	TBTrace("reverseTransformedValue: %@", value);
	
	NSInteger refreshInterval = [value intValue];
	
	if (refreshInterval > 0 && refreshInterval <= 60)				// 1 minute
		return [NSNumber numberWithFloat:0.f];
	if (refreshInterval > 60 && refreshInterval <= 60 * 3)			// 3 minutes
		return [NSNumber numberWithFloat:1.f];
	if (refreshInterval > 60 * 3 && refreshInterval <= 60 * 5)		// 5 minutes
		return [NSNumber numberWithFloat:2.f];
	if (refreshInterval > 60 * 5 && refreshInterval <= 60 * 10)		// 10 minutes
		return [NSNumber numberWithFloat:3.f];
	if (refreshInterval > 60 * 10 && refreshInterval <= 60 * 15)	// 15 minutes
		return [NSNumber numberWithFloat:4.f];
	if (refreshInterval > 60 * 15 && refreshInterval <= 60 * 30)	// 30 minutes
		return [NSNumber numberWithFloat:5.f];
	if (refreshInterval > 60 * 30 && refreshInterval <= 60 * 60)	// 1 hour
		return [NSNumber numberWithFloat:6.f];
	else															// Manually
		return [NSNumber numberWithFloat:7.f];
}

- (id)reverseTransformedValue:(id)value
{
	TBTrace("transformedValue: %@", value);
	
	float sliderValue = [value floatValue];

	if (sliderValue < 1.)							// 1 minute
		return [NSNumber numberWithInt:60];
	if (sliderValue >= 1. && sliderValue < 2.)		// 3 minutes
		return [NSNumber numberWithInt:60 * 3];
	if (sliderValue >= 2. && sliderValue < 3.)		// 5 minutes
		return [NSNumber numberWithInt:60 * 5];
	if (sliderValue >= 3. && sliderValue < 4.)		// 10 minutes
		return [NSNumber numberWithInt:60 * 10];
	if (sliderValue >= 4. && sliderValue < 5.)		// 15 minutes
		return [NSNumber numberWithInt:60 * 15];
	if (sliderValue >= 5. && sliderValue < 6.)		// 30 minutes
		return [NSNumber numberWithInt:60 * 30];
	if (sliderValue >= 6. && sliderValue < 7.)		// 1 hour
		return [NSNumber numberWithInt:60 * 60];
	else											// Manually
		return [NSNumber numberWithInt:0];
}

@end
