//
//  AWSRequest.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 27/11/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSRequest.h"
#import "NSString+HMAC-SHA1.h"
#import "NSString+URLEncoding.h"

// Defaults
#define                AWSApiDefaultRegion		kAWSUSWestRegion
static NSString *const AWSApiDefaultPath		= @"/";
static NSString *const AWSApiDefaultMethod		= @"GET";
static NSString *const AWSApiEC2Version			= @"2010-08-31";
static NSString *const AWSApiMonitoringVersion	= @"2010-08-01";

// Request options keys
NSString *const kAWSAccessKeyIdOption			= @"AWSAccessKeyId";
NSString *const kAWSSecretAccessKeyOption		= @"AWSSecretAccessKey";
NSString *const kAWSRegionOption				= @"AWSRegion";
NSString *const kAWSServiceOption				= @"AWSService";
NSString *const kAWSPathOption					= @"AWSPath";
NSString *const kAWSUseSSLOption				= @"AWSUseSSL";

// Static variables
static NSMutableDictionary *_awsRequestDefaultOptions;

@interface AWSRequest ()
@property (nonatomic, retain, readonly) NSString *host;
@property (nonatomic, retain, readonly) NSString *apiVersion;
@property (nonatomic, retain) NSDate *startedAt;
@property (nonatomic, retain) NSDate *completedAt;
- (NSString *)_queryFromParameters:(NSDictionary *)parameters;
- (NSString *)_signatureForParameters:(NSDictionary *)parameters method:(NSString *)method;
- (NSDictionary *)_parametersForAction:(NSString *)action method:(NSString *)method parameters:(NSDictionary *)parameters;
- (void)_requestThread:(id)object;
- (void)currentConnectionDidFinishLoading;
- (void)currentConnectionDidFailWithError:(NSError *)error;
@end

@implementation AWSRequest

@synthesize responseData = _responseData;
@synthesize startedAt = _startedAt;
@synthesize completedAt = _completedAt;

#pragma mark -
#pragma mark Initialization

+ (void)initialize
{
	if (!_awsRequestDefaultOptions) {
		_awsRequestDefaultOptions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
									 AWSApiDefaultRegion, kAWSRegionOption,
									 AWSApiDefaultPath, kAWSPathOption,
									 [NSNumber numberWithBool:YES], kAWSUseSSLOption,
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

- (id)initWithOptions:(NSDictionary *)options delegate:(id<AWSRequestDelegate>)delegate
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
	TB_RELEASE(_connectionLock);
	TB_RELEASE(_options);
	TB_RELEASE(_responseData);
	TB_RELEASE(_startedAt);
	TB_RELEASE(_completedAt);
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

- (NSString *)accessKeyId
{
	return [_options objectForKey:kAWSAccessKeyIdOption];
}

- (void)setAccessKeyId:(NSString *)value
{
	[_options setObject:[[value copy] autorelease] forKey:kAWSAccessKeyIdOption];
}

- (NSString *)secretAccessKey
{
	return [_options objectForKey:kAWSSecretAccessKeyOption];
}

- (void)setSecretAccessKey:(NSString *)value
{
	[_options setObject:[[value copy] autorelease] forKey:kAWSSecretAccessKeyOption];
}

- (NSString *)region
{
	return [_options objectForKey:kAWSRegionOption];
}

- (void)setRegion:(NSString *)value
{
	[_options setObject:[[value copy] autorelease] forKey:kAWSRegionOption];
}

- (NSString *)service
{
	return [_options objectForKey:kAWSServiceOption];
}

- (void)setService:(NSString *)value
{
	[_options setObject:[[value copy] autorelease] forKey:kAWSServiceOption];
}

- (NSString *)path
{
	return [_options objectForKey:kAWSPathOption];
}

- (void)setPath:(NSString *)value
{
	[_options setObject:[[value copy] autorelease] forKey:kAWSPathOption];
}

- (BOOL)useSSL
{
	return [[_options objectForKey:kAWSUseSSLOption] boolValue];
}

- (void)setUseSSL:(BOOL)value
{
	return [_options setObject:[NSNumber numberWithBool:value] forKey:kAWSUseSSLOption];
}

- (NSString *)host
{
	NSAssert([self.service length] > 0, @"Empty service.");
	NSAssert([self.region length] > 0, @"Empty region.");
	
	return [NSString stringWithFormat:@"%@.%@", self.service, self.region];
}

- (NSString *)apiVersion
{
	if ([self.service isEqualToString:kAWSEC2Service]) {
		return AWSApiEC2Version;
	}
	else if ([self.service isEqualToString:kAWSMonitoringService]) {
		return AWSApiMonitoringVersion;
	}
	else {
		NSAssert(FALSE, @"Unknown service: \"%@\"", self.service);
		return nil;
	}
}

- (void)setResponseData:(NSMutableData *)responseData
{
	if (_responseData != responseData) {
		[_responseData release];
		_responseData = [responseData retain];
	}
}

#pragma mark -
#pragma mark Parameter handling

////
// Given an array ["a", "b", "c"] and key "Value", produces
// {"Value.1 => "a", "Value.2" => "b", "Value.3" => "c"}
//
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

////
// Given dictionary {"Tag" => ["a", "b"], "Status" => [42]}, produces
// {"Filter.1.Name" => "Tag", "Filter.1.Value.1" => "a", "Filter.1.Value.2" => "b", "Filter.2.Name" => "Status", "Filter.2.Value.1" => 42}
- (NSDictionary *)_filterListFromDictionary:(NSDictionary *)dictionary
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	NSUInteger idx = 1;
	
	for (NSString *key in [dictionary allKeys]) {
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
			valueIdx++;
		}
		idx++;
	}
	
	return parameters;
}

- (NSDictionary *)_dimensionListFromDictionary:(NSDictionary *)dictionary
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	NSUInteger idx = 1;
	
	for (NSString *key in [dictionary allKeys]) {
		id value = [dictionary objectForKey:key];
		NSArray *valuesArray = nil;
		
		if ([value isKindOfClass:[NSArray class]]) {
			valuesArray = value;
		}
		else {
			valuesArray = [NSArray arrayWithObject:value];
		}
		
		for (NSString *valueItem in valuesArray) {
			NSString *awsNameKey = [NSString stringWithFormat:@"Dimensions.member.%d.Name", idx];
			[parameters setObject:key forKey:awsNameKey];
			NSString *awsValueKey = [NSString stringWithFormat:@"Dimensions.member.%d.Value", idx];
			[parameters setObject:valueItem forKey:awsValueKey];
			idx++;
		}
	}
	
	return parameters;
}

////
// Generate query string from parameters dictionary, URL-escape names and values as needed
//
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

////
// Generate AWS canonicalized query and calculate its signature
//
- (NSString *)_signatureForParameters:(NSDictionary *)parameters method:(NSString *)method
{
	NSArray *signatureObjects = [NSArray arrayWithObjects:
								 method,
								 self.host,
								 self.path,
								 [self _queryFromParameters:parameters],
								 nil];
	NSString *signatureString = [signatureObjects componentsJoinedByString:@"\n"];
	NSString *signature = [signatureString stringBySigningWithSecret:self.secretAccessKey];
	
	return signature;
}

////
// Append common parameters to action-sepcific parameters, calculate and append signature parameter
//
- (NSDictionary *)_parametersForAction:(NSString *)action method:(NSString *)method parameters:(NSDictionary *)parameters
{
	NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
	
	// add common parameters
	[requestParameters setObject:action forKey:@"Action"];
	[requestParameters setObject:self.accessKeyId forKey:@"AWSAccessKeyId"];
	[requestParameters setObject:@"HmacSHA1" forKey:@"SignatureMethod"];
	[requestParameters setObject:@"2" forKey:@"SignatureVersion"];
	[requestParameters setObject:self.apiVersion forKey:@"Version"];
	[requestParameters setObject:[_startedAt iso8601String] forKey:@"Timestamp"];
	
	// sign query and add signature parameter
	NSString *signature = [self _signatureForParameters:requestParameters method:method];
	[requestParameters setObject:signature forKey:@"Signature"];
	
	return requestParameters;
}

////
// Format NSDate as ISO 8601 string
//
//- (NSString *)_stringFromDate:(NSDate *)date
//{
//	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
//	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//	
//	return [dateFormatter stringFromDate:[NSDate date]];
//}

#pragma mark -
#pragma mark Request handling

- (BOOL)start
{
	return [self startWithParameters:nil];
}

- (BOOL)startWithParameters:(NSDictionary *)parameters
{
	NSAssert(FALSE, @"Abstract method call.");
	return FALSE;
}

- (BOOL)_startRequestWithAction:(NSString *)action parameters:(NSDictionary *)parameters
{
	@synchronized(self) {
		if (_isRunning == NO)
			_isRunning = YES;
		else
			return FALSE;
	}
	
	self.responseData = [NSMutableData data];
	self.startedAt = [NSDate date];
	self.completedAt = nil;

	// Prepare parameters
	NSDictionary *requestParameters = [self _parametersForAction:action method:AWSApiDefaultMethod parameters:parameters];
	
	// Prepare request URL
	NSURL *url = [NSURL URLWithString:
				  [NSString stringWithFormat:@"%@://%@%@?%@",
				   self.useSSL ? @"https" : @"http",
				   self.host,
				   self.path,
				   [self _queryFromParameters:requestParameters],
				   nil]];
	
	// Prepare request
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[request setHTTPMethod:AWSApiDefaultMethod];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	
	// Start connection thread
	[NSThread detachNewThreadSelector:@selector(_requestThread:) toTarget:self withObject:request];
	
	// Notify delegate that request started
	[_delegate requestDidStartLoading:self];
	
	return TRUE;
}

- (void)_parseResponseData
{
	NSAssert(FALSE, @"Abstract method call.");
}

#pragma mark -
#pragma mark Connection thread

#define WAITING_FOR_CONNECTION			0                                                                                                            
#define DONE_WAITING_FOR_CONNECTION		1                                                                                                            

- (void)_requestThread:(id)object
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		_connectionLock = [[NSConditionLock alloc] initWithCondition:WAITING_FOR_CONNECTION];	
		
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:(NSURLRequest *)object delegate:self];
		[connection start];
		
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
			if ([_connectionLock tryLockWhenCondition:DONE_WAITING_FOR_CONNECTION]) {
				[_connectionLock unlock];
				TB_RELEASE(_connectionLock);
				break;
			}
		}
	}
	@finally {
		[_connectionLock unlock];
		TB_RELEASE(_connectionLock);
	}

	[pool release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	@try {
		[self performSelectorOnMainThread:@selector(currentConnectionDidFinishLoading) withObject:nil waitUntilDone:NO];
	}
	@finally {
		[_connectionLock lock];
		[_connectionLock unlockWithCondition:DONE_WAITING_FOR_CONNECTION];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	@try {
		[self performSelectorOnMainThread:@selector(currentConnectionDidFailWithError:) withObject:error waitUntilDone:NO];
	}
	@finally {
		[_connectionLock lock];
		[_connectionLock unlockWithCondition:DONE_WAITING_FOR_CONNECTION];
	}
}

- (void)currentConnectionDidFinishLoading {
#ifdef TB_DEBUG
//	NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
	//TB_TRACE(@"%@", [responseString substringToIndex:MIN([responseString length], 4096)]);
	//	TB_TRACE(@"%@", responseString);
	//[responseString release];
#endif
	
	[self _parseResponseData];

	self.completedAt = [NSDate date];
	[_delegate requestDidFinishLoading:self];
	
	@synchronized(self) {
		_isRunning = NO;
	}
}

- (void)currentConnectionDidFailWithError:(NSError *)error {
	TB_LOG(@"connection:didFailWithError: %@", error);
	
	self.completedAt = [NSDate date];
	[_delegate request:self didFailWithError:error];
	
	@synchronized(self) {
		_isRunning = NO;
	}
}

@end
