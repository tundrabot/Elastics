//
//  EC2Request.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 27/11/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSConstants.h"
#import "EC2Response.h"

@protocol EC2RequestDelegate;

extern NSString *const kAWSAccessKeyIdOption;
extern NSString *const kAWSSecretAccessKeyOption;
extern NSString *const kAWSUseSSLOption;
extern NSString *const kAWSHostOption;
extern NSString *const kAWSPathOption;

@interface EC2Request : NSObject {
@private
	NSMutableDictionary		*_options;
	id<EC2RequestDelegate>	_delegate;
	NSMutableData			*_responseData;
	BOOL					_isRunning;
	NSDate					*_startedAt;
	NSDate					*_completedAt;
}

@property (nonatomic, retain, readonly) NSData *responseData;

+ (NSDictionary *)defaultOptions;
+ (void)setDefaultOptions:(NSDictionary *)options;

- (id)initWithOptions:(NSDictionary *)options delegate:(id<EC2RequestDelegate>)delegate;
- (BOOL)startWithParameters:(NSDictionary *)parameters;
@property (nonatomic, retain, readonly) NSDate *startedAt;
@property (nonatomic, retain, readonly) NSDate *completedAt;

// protected

- (NSDictionary *)_parameterListFromArray:(NSArray *)array key:(NSString *)key;
- (NSDictionary *)_filterListFromDictionary:(NSDictionary *)dictionary;
- (BOOL)_startRequestWithAction:(NSString *)action parameters:(NSDictionary *)parameters;
- (void)_parseResponseData;

@end

@protocol EC2RequestDelegate

- (void)requestDidStartLoading:(EC2Request *)request;
- (void)requestDidFinishLoading:(EC2Request *)request;
- (void)request:(EC2Request *)request didFailWithError:(NSError *)error;

@end
