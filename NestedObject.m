#import "NestedObject.h"


@implementation NestedObject

@synthesize boolProperty;

+(NestedObject*) nestedWithProp: (BOOL)val{
	NestedObject* inst = [[NestedObject new]autorelease];
	inst.boolProperty = val;
	return inst;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeBool:boolProperty forKey:@"boolProperty"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	if(![super init])
		return nil;
	
	self.boolProperty = [aDecoder decodeBoolForKey:@"boolProperty"];	
	return self;
}


#pragma mark SoapEntityProto

+(NSString*) soapNamespace{
	return @"http://nested.com";
}

+(NSString*) soapName{
	return @"NestedObject";
}

@end
