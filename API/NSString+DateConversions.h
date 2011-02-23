//
//  NSString+DateConversions.h
//  Elastics
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DateConversions)

// parse timestamp from ISO 8601 string
- (NSDate *)iso8601Date;

@end
