#import "GTMSenTestCase.h"

#import "SoapArchiver.h"
#import "TestObject.h"
#import "TestHeader.h"
#import "ContainerObject.h"
#import "NestedObject.h"

@interface SoapArchiverTest : GTMTestCase { 	
}
@end

@implementation SoapArchiverTest

-(void)testEmptyMessage{
	SoapArchiver* archiver = [[SoapArchiver new] autorelease];
	NSString* result = archiver.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(result, expected, @"archiving empty message");	
}

-(void)testBody{
	SoapArchiver* archiver = [[SoapArchiver new] autorelease];
	
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
	
	[archiver encodeBodyObject:obj1];
	[archiver encodeBodyObject:obj2];
	NSString* result = archiver.message;
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
	SoapArchiver* archiver = [[SoapArchiver new] autorelease];
	
	TestHeader* header = [[TestHeader new] autorelease];
	header.someData = @"test data";	
	
	[archiver encodeHeaderObject: header];
	NSString* result = archiver.message;
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
	SoapArchiver* archiver = [[SoapArchiver new] autorelease];
	
	TestHeader* header = [[TestHeader new] autorelease];
	header.someData = @"test data";
	
	TestObject* obj = [TestObject testObject];	
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]
									   initWithDateFormat:@"%1d/%1m/%Y" allowNaturalLanguage:NO]autorelease];
	
	obj.intValue = 10;
	obj.doubleValue = 10.0;
	obj.stringValue = @"test1";	
	obj.dateValue = [dateFormatter dateFromString:@"20/10/1999"];	
	
	[archiver encodeHeaderObject:header];
	[archiver encodeBodyObject:obj];
	NSString* result = archiver.message;
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
	SoapArchiver* archiver = [[SoapArchiver new] autorelease];
	
	NestedObject* nested = [[NestedObject new]autorelease];
	nested.boolProperty = YES;
	ContainerObject* container = [[ContainerObject new]autorelease];
	container.int1 = 10;
	container.nested = nested;
	container.int2 = 20;
	
	[archiver encodeBodyObject: container];
	NSString* result = archiver.message;
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
