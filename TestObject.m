#import "TestObject.h"
#import "SoapDeenveloper.h"
#import "SoapEnveloper.h"


@implementation TestObject

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

-(BOOL) isEqual: (TestObject*)other{
	if(self == other)
		return YES;
	
	if(intValue != other.intValue)
		return NO;
	
	if(![[NSNumber numberWithDouble:doubleValue] isEqualToNumber: [NSNumber numberWithDouble: other.doubleValue]])
		return NO;
	
	if(![stringValue isEqual: other.stringValue])
		return NO;
	
	if(![dateValue isEqual:other.dateValue])
		return NO;	
	
	return YES;
}

-(NSUInteger) hash{
	return [NSNumber numberWithInt: intValue].hash ^ [NSNumber numberWithDouble: doubleValue].hash ^ stringValue.hash ^ dateValue.hash;
}


#pragma mark SoapEntityProto

+(NSString*) soapName{
	return @"TestObject";
}

+(NSString*)soapNamespace{
	return @"http://test.com";
}

+(Class) typeForKey: (NSString*)key{
	if([key isEqual: @"stringValue"]){
		return [NSString class];
	}else if([key isEqual: @"dateValue"]){
		return [NSDate class];
	}
			 
	 return nil;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder{
	self.intValue = [aDecoder decodeIntForKey:@"intValue"];
	self.doubleValue = [aDecoder decodeDoubleForKey:@"doubleValue"];
	self.stringValue = [aDecoder decodeObjectForKey:@"stringValue"];
	self.dateValue = [aDecoder decodeObjectForKey:@"dateValue"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeInt:intValue forKey: @"intValue"];	
	[aCoder encodeDouble: doubleValue forKey: @"doubleValue"];
	[aCoder encodeObject: stringValue forKey: @"stringValue"];
	[aCoder encodeObject: dateValue forKey: @"dateValue"];	
}

@end
