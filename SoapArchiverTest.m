#import "GTMSenTestCase.h"

#import "SoapArchiver.h"
#import "TestObject.h"
#import "TestHeader.h"

@interface SoapArchiverTest : SenTestCase {
 	
}
@end


@implementation SoapArchiverTest

-(void)testEmptyMessage{
	SoapArchiver* archiver = [[SoapArchiver new] autorelease];
	NSString* result = archiver.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(result, expected, @"archiving empty message");	
}

-(void)testBody{
	SoapArchiver* archiver = [[SoapArchiver new] autorelease];
	TestObject* obj = [TestObject testObject];	
	STAssertEqualStrings(obj.soapNamespace, @"http://test.com", @"ensuring test object has namespace");
	
	obj.intValue = 10;
	obj.doubleValue = 10.0;
	obj.stringValue = @"test";
	obj.dateValue = [NSDate dateWithString:@"1999-10-20 00:00:00 +000"];
	
	[archiver encodeObject:obj forKey: @"TestObject"];
	NSString* result = archiver.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
	@"	<Body>\n"
	@"		<TestObject xmlns=\"http://test.com\">\n"
	@"			<intValue>10</intValue>\n"
	@"			<doubleValue>10.000000</doubleValue>\n"
	@"			<stringValue>test</stringValue>\n"
	@"			<dateValue>20/10/1999</dateValue>\n"
	@"		</TestObject>\n"
	@"	</Body>\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(result, expected, @"archiving test object");
}

-(void)testHeader{
	SoapArchiver* archiver = [[SoapArchiver new] autorelease];
	TestHeader* header = [[TestHeader new] autorelease];
	header.someData = @"test data";
	STAssertEqualStrings(header.soapNamespace, @"http://header.com", @"ensuring header has namespace");
	
	[archiver encodeHeader: header];
	NSString* result = archiver.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
	@"	<Header xmlns=\"http://header.com\">\n"
	@"		<someData>test data</someData>\n"
	@"	</Header>\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(result, expected, @"archiving header");
}

-(void)testHeaderAndBody{
	SoapArchiver* archiver = [[SoapArchiver new] autorelease];
	
	TestHeader* header = [[TestHeader new] autorelease];
	header.someData = @"test data";
	STAssertEqualStrings(header.soapNamespace, @"http://header.com", @"ensuring header has namespace");	
	
	TestObject* obj1 = [TestObject testObject];	
	STAssertEqualStrings(obj1.soapNamespace, @"http://test.com", @"ensuring test object has namespace");	
	
	obj1.intValue = 10;
	obj1.doubleValue = 10.0;
	obj1.stringValue = @"test1";
	obj1.dateValue = [NSDate dateWithString:@"1999-10-20 00:00:00 +000"];
	
	TestObject* obj2 = [TestObject testObject];	
	STAssertEqualStrings(obj2.soapNamespace, @"http://test.com", @"ensuring test object has namespace");	
	
	obj2.intValue = 20;
	obj2.doubleValue = 20.0;
	obj2.stringValue = @"test2";
	obj2.dateValue = [NSDate dateWithString:@"2000-10-20 00:00:00 +000"];
	
	[archiver encodeHeader:header];
	[archiver encodeObject:obj1 forKey: @"TestObject"];
	[archiver encodeObject:obj2 forKey: @"TestObject"];
	NSString* result = archiver.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
	@"	<Header xmlns=\"http://header.com\">\n"
	@"		<someData>test data</someData>\n"
	@"	</Header>\n"
	@"	<Body>\n"
	@"		<TestObject xmlns=\"http://test.com\">\n"
	@"			<intValue>10</intValue>\n"
	@"			<doubleValue>10.000000</doubleValue>\n"
	@"			<stringValue>test1</stringValue>\n"
	@"			<dateValue>20/10/1999</dateValue>\n"
	@"		</TestObject>\n"
	@"		<TestObject xmlns=\"http://test.com\">\n"
	@"			<intValue>20</intValue>\n"
	@"			<doubleValue>20.000000</doubleValue>\n"
	@"			<stringValue>test2</stringValue>\n"
	@"			<dateValue>20/10/2000</dateValue>\n"
	@"		</TestObject>\n"
	@"	</Body>\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(result, expected, @"archiving full message");
}

@end
