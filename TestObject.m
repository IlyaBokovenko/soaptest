#import "TestObject.h"
#import "SoapUnarchiver.h"
#import "SoapArchiver.h"


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

-(NSString*) soapName{
	return @"TestObject";
}

-(NSString*)soapNamespace{
	return @"http://test.com";
}

-(Class) typeForKey: (NSString*)key{
	if([key isEqual: @"stringValue"]){
		return [NSString class];
	}else if([key isEqual: @"dateValue"]){
		return [NSDate class];
	}
			 
	 return nil;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder{
	SoapUnarchiver* aSoapDecoder = (SoapUnarchiver*)aDecoder;
	intValue = [aSoapDecoder decodeIntForKey:@"intValue"];
	doubleValue = [aSoapDecoder decodeDoubleForKey:@"doubleValue"];
	stringValue = [aSoapDecoder decodeObjectForKey:@"stringValue"];
	dateValue = [aSoapDecoder decodeObjectForKey:@"dateValue"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	SoapArchiver* aSoapCoder = (SoapArchiver*)aCoder;
	[aSoapCoder encodeInt:intValue forKey: @"intValue"];	
	[aSoapCoder encodeDouble: doubleValue forKey: @"doubleValue"];
	[aSoapCoder encodeObject: stringValue forKey: @"stringValue"];
	[aSoapCoder encodeObject: dateValue forKey: @"dateValue"];	
}

@end
