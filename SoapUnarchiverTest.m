#import "GTMSenTestCase.h"

#import "TestObject.h"
#import "SoapUnarchiver.h"

@interface SoapUnarchiverTest : GTMTestCase {
	
}

@end

@implementation SoapUnarchiverTest

-(void)testUnarchiving{
	NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
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
	
	SoapUnarchiver* unarchiver = [SoapUnarchiver soapUnarchiverWithXmlString:xml];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]
									   initWithDateFormat:@"%1d/%1m/%Y" allowNaturalLanguage:NO]autorelease];
	
	TestObject* expected1 = [TestObject testObject];
	expected1.intValue = 10;
	expected1.doubleValue = 10.0; 
	expected1.stringValue = @"test1"; 
	expected1.dateValue = [dateFormatter dateFromString:@"20/10/1999"];

	TestObject* expected2 = [TestObject testObject];
	expected2.intValue = 20; 
	expected2.doubleValue = 20; 
	expected2.stringValue = @"test2"; 
	expected2.dateValue = [dateFormatter dateFromString:@"20/10/2000"];
	
	NSDictionary* mappings = [NSDictionary dictionaryWithObjectsAndKeys:	@"http://schemas.xmlsoap.org/soap/envelope/", @"env",
																			@"http://test.com", @"test",  nil];
	NSArray* result = [unarchiver decodeObjectsOfType: [TestObject class] forXpath:@"env:Envelope/env:Body/test:TestObject" namespaceMappings: mappings];
	NSArray* expected = [NSArray arrayWithObjects:expected1, expected2, nil];
	STAssertEqualObjects(result, expected, nil);	
}

@end
