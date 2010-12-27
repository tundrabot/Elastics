//
//  AWSResponse.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSType.h"
#import "AWSError.h"

@interface AWSResponse : AWSType {
@private
	NSArray	*_errors;		// AWSError
}

+ (id)responseWithRootXMLElement:(TBXMLElement *)rootElement;
- (id)initWithRootXMLElement:(TBXMLElement *)rootElement;

- (BOOL)isError;
@property (nonatomic, retain, readonly) NSArray *errors;

// protected

- (void)parseElement:(TBXMLElement *)element;

@end
