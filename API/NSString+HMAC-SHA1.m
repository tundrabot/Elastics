//
//  NSString+HMAC-SHA1.m
//  Elastic
//
//  Created by Dmitri Goutnik on 27/11/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "NSString+HMAC-SHA1.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+Base64.h"

@implementation NSString (HMAC_SHA1)

- (NSString *)stringBySigningWithSecret:(NSString *)secret 
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *digestData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
	
    CCHmacContext hmacContext;
    CCHmacInit(&hmacContext, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
    CCHmacUpdate(&hmacContext, data.bytes, data.length);
    CCHmacFinal(&hmacContext, digestData.mutableBytes);
	
	return [digestData base64EncodedString];
}

@end
