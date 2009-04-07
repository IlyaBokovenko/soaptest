#import "ContainerObject.h"
#import "NestedObject.h"

@implementation ContainerObject

@synthesize int1;
@synthesize nested;
@synthesize int2;

-(void)dealloc{
	[nested release];
	[super dealloc];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeInt:int1 forKey:@"int1"];
	[aCoder encodeObject: nested forKey: @"myNested"];
	[aCoder encodeInt:int2 forKey:@"int2"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	if(![super init])
		return nil;
	
	self.int1 = [aDecoder decodeIntForKey:@"int1"];	
	self.nested = [aDecoder decodeObjectForKey:@"myNested"];
	self.int2 = [aDecoder decodeIntForKey:@"int2"];	
	return self;
}

#pragma mark SoapEntityProto

+(NSString*) soapNamespace{
	return @"http://container.com";
}

+(NSString*) soapName{
	return @"ContainerObject";
}

+(Class)typeForKey: (NSString*)key{
	if([key isEqual:@"myNested"]) return [NestedObject class];
	
	return nil;
}

@end
