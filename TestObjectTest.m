#import "GTMSenTestCase.h"
#import "TestObject.h"

@interface TestObjectTest : GTMTestCase {
	
}

@end


@implementation TestObjectTest

-(void) testEquality{
	TestObject* obj1 = [TestObject testObject];
	STAssertEqualObjects(obj1, obj1, @"comparing object with self");
	STAssertNotEqualObjects(obj1, (id)nil, @"comparing object with nil");
	
	TestObject* obj2 = [TestObject testObject];
	obj2.intValue = 10;
	obj2.doubleValue = 10.0;
	obj2.stringValue = @"string";
	obj2.dateValue = [NSDate dateWithString:@"2009-10-20 00:00:00 +000"];
	
	STAssertNotEqualObjects(obj1, obj2, nil);
	
	obj1.intValue = 10;
	STAssertNotEqualObjects(obj1, obj2, nil);
	
	obj1.doubleValue = 10.0;
	STAssertNotEqualObjects(obj1, obj2, nil);

	obj1.stringValue = @"string";
	STAssertNotEqualObjects(obj1, obj2, nil);

	obj1.dateValue = [NSDate dateWithString:@"2009-10-20 00:00:00 +000"];
	STAssertEqualObjects(obj1, obj2, @"comparing equal objects");	
}

@end
