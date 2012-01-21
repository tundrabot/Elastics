//
//  TBMacros.h
//
//  Created by Dmitri Goutnik on 10/17/2011.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#define TBRelease(x)		([x release], x = nil)
#define TBCFRelease(x)		(x ? (CFRelease(x), x = NULL) : (void)0)

#define TBCFAutorelease(x)	(__typeof(x))[NSMakeCollectable(x) autorelease]

// XXX: obsolete, do not use
#define TBSingleton(classname)											\
																		\
static classname *_shared##classname = nil;								\
																		\
+ (classname *)shared##classname {										\
	@synchronized(self)	{												\
		if (!_shared##classname) {										\
			_shared##classname = [[super allocWithZone:NULL] init];		\
		}																\
	}																	\
	return _shared##classname;											\
}																		\
																		\
+ (id)allocWithZone:(NSZone *)zone {									\
	return [[self shared##classname] retain];							\
}																		\
																		\
- (id)copyWithZone:(NSZone *)zone {										\
	return self;														\
}																		\
																		\
- (id)retain {															\
	return self;														\
}																		\
																		\
- (NSUInteger)retainCount {												\
	return NSUIntegerMax;												\
}																		\
																		\
- (oneway void)release	{												\
}																		\
																		\
- (id)autorelease {														\
	return self;														\
}

// Singleton macos based on http://lukeredpath.co.uk/blog/a-note-on-objective-c-singletons.html
//
// Requires Mac OS X 10.6 and later
// Requires iOS 4.0 and later

// TB_SINGLETON

#define TB_SINGLETON(classname)							\
														\
+ (id)shared##classname									\
{														\
	static dispatch_once_t predicate = 0;				\
	__strong static id _shared##classname = nil;		\
	dispatch_once(&predicate, ^{						\
		_shared##classname = [[self alloc] init];		\
	});													\
	return _shared##classname;							\
}

// TB_SINGLETON_USING_BLOCK

#define TB_SINGLETON_USING_BLOCK(classname, block)		\
														\
+ (id)shared##classname									\
{														\
	static dispatch_once_t predicate = 0;				\
	__strong static id _shared##classname = nil;		\
	dispatch_once(&predicate, ^{						\
		_shared##classname = block();					\
	});													\
	return _shared##classname;							\
}

// TB_VALIDATE_RECEIPT

#ifdef TB_SKIP_RECEIPT_VALIDATION

#warning ***********************************
#warning *** SKIPPING RECEIPT VALIDATION ***
#warning ***********************************

#define TB_VALIDATE_RECEIPT() \
	{ \
		NSLog(@"***********************************"); \
		NSLog(@"*** SKIPPING RECEIPT VALIDATION ***"); \
		NSLog(@"***********************************"); \
	}

#else

#ifdef TB_USE_SAMPLE_RECEIPT
#define __TB_RECEIPT_PATH @"~/Documents/receipt.sample"
#else
#define __TB_RECEIPT_PATH \
	([NSBundle instancesRespondToSelector:@selector(appStoreReceiptURL)] \
		? [[[NSBundle mainBundle] appStoreReceiptURL] path]\
		: [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"])
#endif	// TB_USE_SAMPLE_RECEIPT

#define TB_VALIDATE_RECEIPT() \
	{ \
		NSString *_receiptPath = __TB_RECEIPT_PATH; \
		validateReceiptAtPath(_receiptPath);	\
		NSLog(@"receipt validated successfully"); \
	}

#endif	// TB_SKIP_RECEIPT_VALIDATION

// TB_VALIDATE_EXPIRATION_DATE

#define __TB_EXPIRATION_INTERVAL (60 * 60 * 24 * 3) /* 3 days */

#ifdef TB_USE_EXPIRATION_DATE

#define TB_VALIDATE_EXPIRATION_DATE() \
	{ \
		NSString *_buildDateString = [NSString stringWithCString:__DATE__" "__TIME__ encoding:NSASCIIStringEncoding]; \
		NSDate *_buildDate = [NSDate dateWithNaturalLanguageString:_buildDateString]; \
		if ([[NSDate date] timeIntervalSinceDate:_buildDate] > __TB_EXPIRATION_INTERVAL) { \
			NSLog(@"******************************"); \
			NSLog(@"*** THIS BUILD HAS EXPIRED ***"); \
			NSLog(@"******************************"); \
			NSDictionary *_infoDictionary = [[NSBundle mainBundle] infoDictionary]; \
			NSAlert *_alert = [NSAlert alertWithMessageText:@"Build Expired" \
											  defaultButton:@"OK" \
											alternateButton:nil \
												otherButton:nil \
								  informativeTextWithFormat:@"This pre-release version of %@ has expired.", [_infoDictionary objectForKey:(id)kCFBundleNameKey]]; \
			[_alert runModal]; \
			exit(-1); \
		} \
	}

#else

#define TB_VALIDATE_EXPIRATION_DATE()

#endif	// TB_USE_EXPIRATION_DATE
