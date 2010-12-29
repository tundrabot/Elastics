//
//  AWSErrorResponse.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 29/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSErrorResponse.h"

@interface AWSErrorResponse ()
@property (nonatomic, retain) NSArray *errors;
@end

@implementation AWSErrorResponse

@synthesize errors = _errors;

- (void)dealloc
{
	TBRelease(_errors);
	[super dealloc];
}

@end
