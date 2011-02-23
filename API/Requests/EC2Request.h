//
//  EC2Request.h
//  Elastics
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSRequest.h"

@interface EC2Request : AWSRequest

- (id)initWithOptions:(NSDictionary *)options delegate:(id<AWSRequestDelegate>)delegate;

@end
