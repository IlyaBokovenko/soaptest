#import "GTMSenTestCase.h"

#import "SoapEnveloper.h"
#import "TestObject.h"
#import "TestHeader.h"
#import "ContainerObject.h"
#import "NestedObject.h"
#import "SoapCustomEntity.h"

@interface SoapEnveloperTest : GTMTestCase { 	
}
@end

@implementation SoapEnveloperTest

-(void)testEmptyMessage{
	SoapEnveloper* enveloper = [[SoapEnveloper new] autorelease];
	NSString* result = enveloper.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(result, expected, @"archiving empty message");	
}

-(void)testBody{
	SoapEnveloper* enveloper = [[SoapEnveloper new] autorelease];
	
	TestObject* obj1 = [TestObject testObject];		
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]
									   initWithDateFormat:@"%1d/%1m/%Y" allowNaturalLanguage:NO]autorelease];
	
	obj1.intValue = 10;
	obj1.doubleValue = 10.0;
	obj1.stringValue = @"test1";	
	obj1.dateValue = [dateFormatter dateFromString:@"20/10/1999"];
	
	TestObject* obj2 = [TestObject testObject];	
	
	obj2.intValue = 20;
	obj2.doubleValue = 20.0;
	obj2.stringValue = @"test2";
	obj2.dateValue = [dateFormatter dateFromString:@"20/10/2000"];
	
	[enveloper encodeBodyObject:obj1];
	[enveloper encodeBodyObject:obj2];
	NSString* result = enveloper.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	@"	<Body>\n"
	@"		<TestObject xmlns=\"http://test.com\">\n"
	@"			<intValue>10</intValue>\n"
	@"			<doubleValue>10.000000</doubleValue>\n"
	@"			<stringValue>test1</stringValue>\n"
	@"			<dateValue>1999-10-20</dateValue>\n"
	@"		</TestObject>\n"
	@"		<TestObject xmlns=\"http://test.com\">\n"
	@"			<intValue>20</intValue>\n"
	@"			<doubleValue>20.000000</doubleValue>\n"
	@"			<stringValue>test2</stringValue>\n"
	@"			<dateValue>2000-10-20</dateValue>\n"
	@"		</TestObject>\n"
	@"	</Body>\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(result, expected, @"archiving test object");
}

-(void)testHeader{
	SoapEnveloper* enveloper = [[SoapEnveloper new] autorelease];
	
	TestHeader* header = [[TestHeader new] autorelease];
	header.someData = @"test data";	
	
	[enveloper encodeHeaderObject: header];
	NSString* result = enveloper.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	@"	<Header>\n"
	@"		<TestHeader xmlns=\"http://header.com\">\n"
	@"			<someData>test data</someData>\n"
	@"		</TestHeader>\n"
	@"	</Header>\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(result, expected, @"archiving header");
}

-(void)testHeaderAndBody{
	SoapEnveloper* enveloper = [[SoapEnveloper new] autorelease];
	
	TestHeader* header = [[TestHeader new] autorelease];
	header.someData = @"test data";
	
	TestObject* obj = [TestObject testObject];	
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]
									   initWithDateFormat:@"%1d/%1m/%Y" allowNaturalLanguage:NO]autorelease];
	
	obj.intValue = 10;
	obj.doubleValue = 10.0;
	obj.stringValue = @"test1";	
	obj.dateValue = [dateFormatter dateFromString:@"20/10/1999"];	
	
	[enveloper encodeHeaderObject:header];
	[enveloper encodeBodyObject:obj];
	NSString* result = enveloper.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	@"	<Header>\n"
	@"		<TestHeader xmlns=\"http://header.com\">\n"
	@"			<someData>test data</someData>\n"
	@"		</TestHeader>\n"
	@"	</Header>\n"
	@"	<Body>\n"
	@"		<TestObject xmlns=\"http://test.com\">\n"
	@"			<intValue>10</intValue>\n"
	@"			<doubleValue>10.000000</doubleValue>\n"
	@"			<stringValue>test1</stringValue>\n"
	@"			<dateValue>1999-10-20</dateValue>\n"
	@"		</TestObject>\n"
	@"	</Body>\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(result, expected, @"archiving full message");
}

-(void)testNestedObjects{
	SoapEnveloper* enveloper = [[SoapEnveloper new] autorelease];
	
	NestedObject* nested = [[NestedObject new]autorelease];
	nested.boolProperty = YES;
	ContainerObject* container = [[ContainerObject new]autorelease];
	container.int1 = 10;
	container.nested = nested;
	container.int2 = 20;
	
	[enveloper encodeBodyObject: container];
	NSString* result = enveloper.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	@"	<Body>\n"
	@"		<ContainerObject xmlns=\"http://container.com\">\n"
	@"			<int1>10</int1>\n"
	@"			<myNested xmlns=\"http://nested.com\">\n"
	@"				<boolProperty>true</boolProperty>\n"
	@"			</myNested>\n"
	@"			<int2>20</int2>\n"
	@"		</ContainerObject>\n"
	@"	</Body>\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(result, expected, @"archiving nested objects");	
}

@end
