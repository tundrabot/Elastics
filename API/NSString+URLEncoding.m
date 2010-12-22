//
//  NSString+URLEncoding.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 27/11/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "NSString+URLEncoding.h"


static NSString *const kEscapes = @"!*'\"();:@&=+$,/?%#[]% ";


@implementation NSString (URLEncoding)

- (NSString *)stringByURLEncoding
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(
		kCFAllocatorDefault,
        (CFStringRef)self,
        NULL,
        (CFStringRef)kEscapes,
        kCFStringEncodingUTF8);
    
	return [NSMakeCollectable(result) autorelease];
}

@end
