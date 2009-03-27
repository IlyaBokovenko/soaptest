#import <Foundation/Foundation.h>

#import "SoapEntityProto.h"

@interface TestObject : NSObject<NSCoding, SoapEntityProto> {
	int intValue;
	double doubleValue;
	NSString* stringValue;
	NSDate* dateValue;
}

@property(assign) int intValue;
@property(assign) double doubleValue;
@property(retain) NSString* stringValue;
@property(retain) NSDate* dateValue;

+(TestObject*) testObject;

-(BOOL) isEqual: (TestObject*)other;
-(NSUInteger) hash;

@end
