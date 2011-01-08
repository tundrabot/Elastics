//
//  NSDate+StringConversions.h
//  Elastic
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (StringConversions)

// format timestamp using current locale
- (NSString *)localizedString;

// format timestamp according to ISO 8601
- (NSString *)iso8601String;

@end
