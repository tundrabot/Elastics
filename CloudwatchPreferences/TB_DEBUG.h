//
//  TB_DEBUG.h
//
//  Created by Dmitri Goutnik on 02/12/2010.
//  Copyright 2010 Invisible Llama. All rights reserved.
//

#ifdef TB_DEBUG
#	ifdef NS_BLOCK_ASSERTIONS
#		undef NS_BLOCK_ASSERTIONS
#	endif
#	define TB_TRACE(format, ...) NSLog(@"%@:(%d) %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__])
#else
#	define NS_BLOCK_ASSERTIONS
#	define TB_TRACE(format, ...)
#endif

#define TB_LOG(format, ...) NSLog(@"%@:(%d) %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__])
