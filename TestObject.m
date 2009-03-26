#import "TestObject.h"


@implementation TestObject

@dynamic soapNamespace;
@synthesize intValue;
@synthesize doubleValue;
@synthesize stringValue;
@synthesize dateValue;


+(TestObject*) testObject{
	return [[[self class]new]autorelease];
}

-(void)dealloc{
	[stringValue release];
	[dateValue release];
	[super dealloc];
}

#pragma mark SoapEntityProto

-(NSString*)soapNamespace{
	return @"http://test.com";
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder{
	intValue = [aDecoder decodeIntForKey:@"intValue"];
	doubleValue = [aDecoder decodeDoubleForKey:@"doubleValue"];
	stringValue = [aDecoder decodeObjectForKey:@"stringValue"];
	dateValue = [aDecoder decodeObjectForKey:@"dateValue"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeInt:intValue forKey: @"intValue"];	
	[aCoder encodeDouble: doubleValue forKey: @"doubleValue"];
	[aCoder encodeObject: stringValue forKey: @"stringValue"];
	[aCoder encodeObject: dateValue forKey: @"dateValue"];	
}



@end
