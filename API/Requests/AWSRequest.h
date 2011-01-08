//
//  AWSRequest.h
//  Elastic
//
//  Created by Dmitri Goutnik on 27/11/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSConstants.h"
#import "NSDate+StringConversions.h"
#import "AWSResponse.h"
#import "AWSErrorResponse.h"
#import "TBXML.h"

@protocol AWSRequestDelegate;

extern NSString *const kAWSAccessKeyIdOption;
extern NSString *const kAWSSecretAccessKeyOption;
extern NSString *const kAWSRegionOption;
extern NSString *const kAWSServiceOption;
extern NSString *const kAWSPathOption;
extern NSString *const kAWSUseSSLOption;

@interface AWSRequest : NSObject {
@private
	NSMutableDictionary		*_options;
	id<AWSRequestDelegate>	_delegate;
	NSConditionLock			*_connectionLock;
	NSHTTPURLResponse		*_responseInfo;
	NSMutableData			*_responseData;
	TBXML					*_responseParser;
	AWSResponse				*_response;
	AWSErrorResponse		*_errorResponse;
	BOOL					_isRunning;
	NSDate					*_startedAt;
	NSDate					*_completedAt;
}

+ (NSDictionary *)defaultOptions;
+ (void)setDefaultOptions:(NSDictionary *)options;

+ (NSString *)regionTitleForRegion:(NSString *)region;

- (id)initWithOptions:(NSDictionary *)options delegate:(id<AWSRequestDelegate>)delegate;

// Options
@property (nonatomic, copy) NSString *accessKeyId;
@property (nonatomic, copy) NSString *secretAccessKey;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSString *path;
@property (nonatomic) BOOL useSSL;

// Start async request
- (BOOL)start;
- (BOOL)startWithParameters:(NSDictionary *)parameters;

// Request timestamps
- (NSDate *)startedAt;
- (NSDate *)completedAt;

// Responses
- (NSHTTPURLResponse *)responseInfo;
- (NSData *)responseData;
- (TBXML *)responseParser;
- (AWSResponse *)response;
- (AWSErrorResponse *)errorResponse;

// protected

- (NSDictionary *)parameterListFromArray:(NSArray *)array key:(NSString *)key;
- (NSDictionary *)filterListFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dimensionListFromDictionary:(NSDictionary *)dictionary;
- (BOOL)startRequestWithAction:(NSString *)action parameters:(NSDictionary *)parameters;
- (AWSResponse *)parseResponse;
- (AWSErrorResponse *)parseErrorResponse;

@end

@protocol AWSRequestDelegate

- (void)requestDidStartLoading:(AWSRequest *)request;
- (void)requestDidFinishLoading:(AWSRequest *)request;
- (void)request:(AWSRequest *)request didFailWithError:(NSError *)error;

@end
