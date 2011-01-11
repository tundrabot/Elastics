//
//  TB_DEBUG.h
//
//  Created by Dmitri Goutnik on 02/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#ifdef TB_DEBUG
#	ifdef NS_BLOCK_ASSERTIONS
#		undef NS_BLOCK_ASSERTIONS
#	endif
#	define TBTrace(format, ...) NSLog(@"%@:%d %s %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:@format, ##__VA_ARGS__])
#else
#	ifndef NS_BLOCK_ASSERTIONS
#		define NS_BLOCK_ASSERTIONS
#	endif
#	define TBTrace(format, ...)
#endif

#define TBLog(format, ...) NSLog(@"%@:%d %s %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:@format, ##__VA_ARGS__])


//#define _MDLog(fmt, args...)	{\
//NSString* __DEBUG_STRING_TO_LOG__ = [[NSString alloc] initWithFormat:@fmt, ##args];\
//NSLog(__DEBUG_STRING_TO_LOG__);\
//[__DEBUG_STRING_TO_LOG__ release];\
//}
//
//#if ENABLE_DEBUG_MODE
//#define MDLog(fmt, args...) _MDLog("%s(%i): " fmt, __FUNCTION__, __LINE__, ##args)
//#else
//#define MDLog(fmt, args...) 
//#endif
//
//#define MDLogError(fmt, args...) _MDLog("%s(%i): " fmt, __FUNCTION__, __LINE__, ##args)
