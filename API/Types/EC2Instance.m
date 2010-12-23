//
//  EC2Instance.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "NSString+DateConversions.h"
#import "EC2Instance.h"
#import "EC2InstanceState.h"
#import "EC2Tag.h"

@interface EC2Instance ()
@property (nonatomic, retain) NSString *instanceId;
@property (nonatomic, retain) NSString *imageId;
@property (nonatomic, retain) EC2InstanceState *instanceState;
@property (nonatomic, retain) NSString *dnsName;
@property (nonatomic, retain) NSDate *launchTime;
@property (nonatomic, retain) NSString *privateIpAddress;
@property (nonatomic, retain) NSString *ipAddress;
@property (nonatomic, retain) NSArray *tagSet;
@end

@implementation EC2Instance

@synthesize instanceId = _instanceId;
@synthesize imageId = _imageId;
@synthesize instanceState = _instanceState;
@synthesize dnsName = _dnsName;
@synthesize launchTime = _launchTime;
@synthesize privateIpAddress = _privateIpAddress;
@synthesize ipAddress = _ipAddress;
@synthesize tagSet = _tagSet;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(EC2Type *)parent
{
	self = [super initFromXMLElement:element parent:parent];

	if (self) {
		element = element->firstChild;
		
		while (element) {
			NSString *elementName = [TBXML elementName:element];
			
			if ([elementName isEqualToString:@"instanceId"])
				self.instanceId = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"imageId"])
				self.imageId = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"instanceState"])
				self.instanceState = [EC2InstanceState typeFromXMLElement:element parent:self];
			else if ([elementName isEqualToString:@"dnsName"])
				self.dnsName = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"launchTime"])
				self.launchTime = [[TBXML textForElement:element] iso8601Date];
			else if ([elementName isEqualToString:@"privateIpAddress"])
				self.privateIpAddress = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"ipAddress"])
				self.ipAddress = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"tagSet"])
				self.tagSet = [self _parseXMLElement:element asArrayOf:[EC2Tag class]];
			
			element = element->nextSibling;
		}
	}

	return self;
}

- (void)dealloc
{
	TB_RELEASE(_instanceId);
	TB_RELEASE(_imageId);
	TB_RELEASE(_instanceState);
	TB_RELEASE(_dnsName);
	TB_RELEASE(_launchTime);
	TB_RELEASE(_privateIpAddress);
	TB_RELEASE(_ipAddress);
	TB_RELEASE(_tagSet);
	[super dealloc];
}

- (NSString *)nameTag
{
	static NSString *const kNameTagKey = @"Name";
	__block NSString *nameTagValue = nil;
	
	[_tagSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([[obj key] compare:kNameTagKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			nameTagValue = [obj value];
			*stop = YES;
		}
	}];
	
	return nameTagValue;
}

@end
