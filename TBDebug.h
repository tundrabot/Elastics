//
//  TBDebug.h
//
//  Created by Dmitri Goutnik on 02/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#if defined(DEBUG) || defined(TB_DEBUG)
#	ifdef NS_BLOCK_ASSERTIONS
#		undef NS_BLOCK_ASSERTIONS
#	endif
#	define TBTrace(format, ...) NSLog(@"%@:%d %s %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ##__VA_ARGS__])
#else
#	ifndef NS_BLOCK_ASSERTIONS
#		define NS_BLOCK_ASSERTIONS
#	endif
#	define TBTrace(format, ...)
#endif

#define TBLog(format, ...) NSLog(@"%@:%d %s %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ##__VA_ARGS__])
