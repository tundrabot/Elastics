//
//  SshPortValueTransformer.m
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 18/01/12.
//  Copyright (c) 2012 Tundra Bot. All rights reserved.
//

#import "SshPortValueTransformer.h"

@implementation SshPortValueTransformer
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
    return value;
}

- (id)reverseTransformedValue:(id)value
{
    if (![value isKindOfClass:[NSString class]])
        return nil;
    
    NSInteger integerValue = [value integerValue];

    if (integerValue <= 0)
        return nil;
    else
        return [NSNumber numberWithInteger:integerValue];
}

@end
