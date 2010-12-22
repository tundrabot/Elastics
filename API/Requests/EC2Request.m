//
//  EC2Request.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 27/11/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2Request.h"
#import "NSString+HMAC-SHA1.h"
#import "NSString+URLEncoding.h"

// XXX
// static NSString *const AWSApiDefaultHost	= @"ec2.amazonaws.com";
static NSString *const AWSApiDefaultHost	= @"ec2.us-west-1.amazonaws.com";
static NSString *const AWSApiDefaultPath	= @"/";
static NSString *const AWSApiVersion		= @"2010-08-31";
static NSString *const AWSApiDefaultMethod	= @"GET";

NSString *const kAWSAccessKeyIdOption		= @"AWSAccessKeyId";
NSString *const kAWSSecretAccessKeyOption	= @"AWSSecretAccessKey";
NSString *const kAWSUseSSLOption			= @"AWSUseSSL";
NSString *const kAWSHostOption				= @"AWSHost";
NSString *const kAWSPathOption				= @"AWSPath";

@interface EC2Request ()
@property (nonatomic, retain) NSDate *startedAt;
@property (nonatomic, retain) NSDate *completedAt;
- (NSString *)_queryFromParameters:(NSDictionary *)parameters;
- (NSString *)_signatureForParameters:(NSDictionary *)parameters method:(NSString *)method;
- (NSDictionary *)_parametersForAction:(NSString *)action method:(NSString *)method parameters:(NSDictionary *)parameters;
- (NSString *)_stringFromDate:(NSDate *)date;
@end

@implementation EC2Request

@synthesize responseData = _responseData;
@synthesize startedAt = _startedAt;
@synthesize completedAt = _completedAt;

#pragma mark -
#pragma mark Initialization

static NSMutableDictionary *_awsRequestDefaultOptions = nil;

+ (void)initialize
{
	if (!_awsRequestDefaultOptions) {
		_awsRequestDefaultOptions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
									 @"", kAWSAccessKeyIdOption,
									 @"", kAWSSecretAccessKeyOption,
									 [NSNumber numberWithBool:YES], kAWSUseSSLOption,
									 AWSApiDefaultHost, kAWSHostOption,
									 AWSApiDefaultPath, kAWSPathOption,
									 nil];
		
	}
}

+ (NSDictionary *)defaultOptions
{
	return _awsRequestDefaultOptions;
}

+ (void)setDefaultOptions:(NSDictionary *)options
{
	[_awsRequestDefaultOptions addEntriesFromDictionary:options];
}

- (id)initWithOptions:(NSDictionary *)options delegate:(id<EC2RequestDelegate>)delegate
{
	self = [super init];
	if (self) {
		_options = [_awsRequestDefaultOptions mutableCopy];
		[_options addEntriesFromDictionary:options];
		_delegate = delegate;
	}
	return self;
}

- (void)dealloc
{
	[_options release];
	[_responseData release];
	[_startedAt release];
	[_completedAt release];
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

- (void)setResponseData:(NSMutableData *)responseData
{
	if (_responseData != responseData) {
		[_responseData release];
		_responseData = [responseData retain];
	}
}

#pragma mark -
#pragma mark Parameter handling

- (NSDictionary *)_parameterListFromArray:(NSArray *)array key:(NSString *)key
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	NSUInteger idx = 1;
		
	for (id value in array) {
		NSString *awsKey = [NSString stringWithFormat:@"%@.%d", key, idx];
		[parameters setObject:value forKey:awsKey];
	}
	
	return parameters;
}

- (NSDictionary *)_filterListFromDictionary:(NSDictionary *)dictionary
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	NSUInteger idx = 1;
	
	for (id key in [dictionary allKeys]) {
		id value = [dictionary objectForKey:key];
		NSArray *valuesArray = nil;
		NSUInteger valueIdx = 1;
		
		if ([value isKindOfClass:[NSArray class]]) {
			valuesArray = value;
		}
		else {
			valuesArray = [NSArray arrayWithObject:value];
		}

		NSString *awsNameKey = [NSString stringWithFormat:@"Filter.%d.Name", idx];
		[parameters setObject:key forKey:awsNameKey];
		
		for (id valueItem in valuesArray) {
			NSString *awsValueKey = [NSString stringWithFormat:@"Filter.%d.Value.%d", idx, valueIdx];
			[parameters setObject:valueItem forKey:awsValueKey];
		}
	}
	
	return parameters;
}

// Generate query string from parameters dictionary, URL-escape names and values as needed
- (NSString *)_queryFromParameters:(NSDictionary *)parameters
{
	NSArray *queryKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSMutableArray *queryArray = [NSMutableArray array];
	
	for (NSString *key in queryKeys) {
		[queryArray addObject:
		 [NSString stringWithFormat:@"%@=%@",
		  [key stringByURLEncoding], [[parameters valueForKey:key] stringByURLEncoding]]];
	}
	
	return [queryArray componentsJoinedByString:@"&"];
}

// Generate AWS canonicalized query and calculate its signature
- (NSString *)_signatureForParameters:(NSDictionary *)parameters method:(NSString *)method
{
	NSArray *signatureObjects = [NSArray arrayWithObjects:
								 method,
								 [_options valueForKey:kAWSHostOption],
								 [_options valueForKey:kAWSPathOption],
								 [self _queryFromParameters:parameters],
								 nil];
	NSString *signatureString = [signatureObjects componentsJoinedByString:@"\n"];
	NSString *signature = [signatureString stringBySigningWithSecret:[_options valueForKey:kAWSSecretAccessKeyOption]];
	
	return signature;
}

// Append common parameters to action-sepcific parameters, calculate and append signature parameter
- (NSDictionary *)_parametersForAction:(NSString *)action method:(NSString *)method parameters:(NSDictionary *)parameters
{
	NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
	
	// add common parameters
	[requestParameters setObject:action forKey:@"Action"];
	[requestParameters setObject:[_options valueForKey:kAWSAccessKeyIdOption] forKey:@"AWSAccessKeyId"];
	[requestParameters setObject:@"HmacSHA1" forKey:@"SignatureMethod"];
	[requestParameters setObject:@"2" forKey:@"SignatureVersion"];
	[requestParameters setObject:AWSApiVersion forKey:@"Version"];
	[requestParameters setObject:[self _stringFromDate:_startedAt] forKey:@"Timestamp"];
	
	// sign query and add signature parameter
	NSString *signature = [self _signatureForParameters:requestParameters method:method];
	[requestParameters setObject:signature forKey:@"Signature"];
	
	return requestParameters;
}

// Format timestamp as ISO 8601 string
- (NSString *)_stringFromDate:(NSDate *)date
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	return [dateFormatter stringFromDate:[NSDate date]];
}

#pragma mark -
#pragma mark Request handling

- (BOOL)startWithParameters:(NSDictionary *)parameters
{
	NSAssert(FALSE, @"Abstract method call.");
	return FALSE;
}

- (BOOL)_startRequestWithAction:(NSString *)action parameters:(NSDictionary *)parameters
{
	@synchronized(self) {
		if (!_isRunning)
			_isRunning = YES;
		else
			return FALSE;
	}
	
	// prepare parameters
	self.startedAt = [NSDate date];
	self.completedAt = nil;
	NSDictionary *requestParameters = [self _parametersForAction:action method:AWSApiDefaultMethod parameters:parameters];
	
	// prepare request URL
	NSURL *url = [NSURL URLWithString:
				  [NSString stringWithFormat:@"%@://%@%@?%@",
				   [[_options valueForKey:kAWSUseSSLOption] boolValue] ? @"https" : @"http",
				   [_options valueForKey:kAWSHostOption],
				   [_options valueForKey:kAWSPathOption],
				   [self _queryFromParameters:requestParameters],
				   nil]];
	
	// prepare request
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[request setHTTPMethod:AWSApiDefaultMethod];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	
	// start async request
	self.responseData = [NSMutableData data];
	[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];	// NOTE: NSURLConnection does retain its delegate

	// notify delegate
	[_delegate requestDidStartLoading:self];
	
	return TRUE;
}

- (void)_parseResponseData
{
	NSAssert(FALSE, @"Abstract method call.");
}

#pragma mark -
#pragma mark Connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
#ifdef TB_DEBUG
	NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
//	TB_TRACE(@"%@", [responseString substringToIndex:MIN([responseString length], 4096)]);
	TB_TRACE(@"%@", responseString);
	[responseString release];
#endif
	
	[self _parseResponseData];

	self.completedAt = [NSDate date];
	[_delegate requestDidFinishLoading:self];
	
	@synchronized(self) {
		_isRunning = NO;
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	TB_LOG(@"connection:didFailWithError: : %@", error);

	self.completedAt = [NSDate date];
	[_delegate request:self didFailWithError:error];
	
	@synchronized(self) {
		_isRunning = NO;
	}
}

@end
