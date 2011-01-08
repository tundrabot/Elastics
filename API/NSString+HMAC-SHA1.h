//
//  NSString+HMAC-SHA1.h
//  Elastic
//
//  Created by Dmitri Goutnik on 27/11/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HMAC_SHA1)

- (NSString *)stringBySigningWithSecret:(NSString *)secret;

@end
