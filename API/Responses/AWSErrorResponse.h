//
//  AWSErrorResponse.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 29/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSResponse.h"
#import "AWSError.h"

@interface AWSErrorResponse : AWSResponse {
@protected
	NSArray	*_errors;		// AWSError
}

@property (nonatomic, retain, readonly) NSArray *errors;

@end
