#import "GTMSenTestCase.h"

#import "TestObject.h"
#import "ContainerObject.h"
#import "NestedObject.h"
#import "SoapDeenveloper.h"
#import "SoapCustomEntity.h"

@interface SoapDeenveloperTest : GTMTestCase {	
}
@end

@implementation SoapDeenveloperTest

-(void)testUnarchiving{
	NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	@"	<Header>\n"
	@"		<someData>test data</someData>\n"
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
	SoapDeenveloper* deenveloper = [SoapDeenveloper soapDeenveloperWithXmlString:xml];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]
									   initWithDateFormat:@"%1d/%1m/%Y" allowNaturalLanguage:NO]autorelease];
	
	TestObject* expected = [TestObject testObject];
	expected.intValue = 10;
	expected.doubleValue = 10.0; 
	expected.stringValue = @"test1";
	expected.dateValue = [dateFormatter dateFromString:@"20/10/1999"];

	TestObject* decoded = [deenveloper decodeBodyObjectOfType: [TestObject class] ];
	STAssertEqualObjects(decoded, expected, nil);	
}

-(void)testUnarchivingNestedObject{
	NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
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
	SoapDeenveloper* deenveloper = [SoapDeenveloper soapDeenveloperWithXmlString:xml];
	
	ContainerObject* decoded = [deenveloper decodeBodyObjectOfType: [ContainerObject class]];
	STAssertEqualObjects([decoded class], [ContainerObject class], nil);
	
	STAssertEquals(decoded.int1, 10, nil);
	STAssertEquals(decoded.int2, 20, nil);
	STAssertEqualObjects([decoded.nested class], [NestedObject class], nil);
	STAssertEquals(decoded.nested.boolProperty, YES, nil);
}

-(void)testCustomSoapObject{
	NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	@"	<Body>\n"
	@"		<Custom xmlns=\"http://custom.com\">\n"
	@"			<boolValue>true</boolValue>\n"
	@"			<intValue>10</intValue>\n"
	@"			<doubleValue>20.000000</doubleValue>\n"
	@"			<stringValue>string</stringValue>\n"
	@"			<objectValue xmlns=\"http://nested.com\">\n"
	@"				<boolProperty>true</boolProperty>\n"
	@"			</objectValue>\n"	
	@"			<dateValue>2009-10-20</dateValue>\n"
	@"		</Custom>\n"
	@"	</Body>\n"
	@"</Envelope>\n";	
	
	SoapDeenveloper* deenveloper = [SoapDeenveloper soapDeenveloperWithXmlString:xml];
	
	SoapCustomEntityType* type = [[SoapCustomEntityType new]autorelease];		
	type.name = @"Custom";
	type.namespace = @"http://custom.com";
	[type addBoolForKey: @"boolValue"];
	[type addIntForKey: @"intValue"];	
	[type addDoubleForKey: @"doubleValue"];
	[type addStringForKey: @"stringValue"];
	[type addObjectOfType:[NestedObject class] forKey:@"objectValue"];
	[type addDateForKey: @"dateValue"];
	
	SoapCustomEntity* obj = [deenveloper decodeBodyObjectOfType:type];
	
	STAssertTrue([obj isKindOfClass:[SoapCustomEntity class]], nil);
	STAssertEquals([[obj objectForKey:@"boolValue"] boolValue], YES, nil);
	STAssertEquals([[obj objectForKey:@"intValue"] intValue], 10, nil);
	STAssertEqualsWithAccuracy([[obj objectForKey:@"doubleValue"] doubleValue], 20.0, 0.00001, nil);
	STAssertEqualStrings([obj objectForKey:@"stringValue"], @"string", nil);
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
	[dateFormatter setDateFormat: @"dd-MM-yyyy"];	
	STAssertEqualObjects([obj objectForKey:@"dateValue"], [dateFormatter dateFromString:@"20-10-2009"], nil);
	NestedObject* nested = [obj objectForKey:@"objectValue"];
	STAssertTrue([nested isKindOfClass:[NestedObject class]], nil);
	STAssertEquals(nested.boolProperty, YES, nil);
}

@end
