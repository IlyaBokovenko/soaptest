#import "TestHeader.h"


@implementation TestHeader

@synthesize someData;

-(void)dealloc{
	[someData release];
	[super dealloc];
}

#pragma mark SoapEntityProto

-(NSString*) soapName{
	return @"TestHeader";
}

-(NSString*) soapNamespace{
	return @"http://header.com";
}

-(Class)typeForKey: (NSString*)key{
	if([key isEqual:@"someData"]){
		return [NSString class];
	}
	
	return nil;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder{
	someData = [aDecoder decodeObjectForKey:@"someData"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeObject:someData forKey: @"someData"];
}


@end
