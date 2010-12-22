//
//  EC2DescribeInstancesRequest.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EC2Request.h"
#import "EC2DescribeInstancesResponse.h"	

@interface EC2DescribeInstancesRequest : EC2Request {
	EC2DescribeInstancesResponse	*_response;
}

- (BOOL)startWithParameters:(NSDictionary *)parameters;
@property (nonatomic, retain, readonly) EC2DescribeInstancesResponse *response;

@end
