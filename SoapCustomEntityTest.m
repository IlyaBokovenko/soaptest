#import "GTMSenTestCase.h"
#import "SoapCustomEntity.h"
#import "SoapEnveloper.h"
#import "SoapDeenveloper.h"
#import "NestedObject.h"


@interface SoapCustomEntityTest : GTMTestCase {	
}
@end

@implementation SoapCustomEntityTest

-(void)testEnveloping{
	SoapEnveloper* enveloper = [[SoapEnveloper new] autorelease];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
	[dateFormatter setDateFormat: @"dd-MM-yyyy"];
	
	SoapCustomEntity* obj = [[SoapCustomEntity new]autorelease];		
	obj.name = @"Custom";
	obj.namespace = @"http://custom.com";
	[obj setBool: YES forKey: @"boolValue"];
	[obj setInt: 10 forKey: @"intValue"];	
	[obj setDouble: 20.0 forKey: @"doubleValue"];
	[obj setString: @"string" forKey: @"stringValue"];
	NestedObject* nested = [[NestedObject new]autorelease];
	nested.boolProperty = YES;
	[obj setObject: nested forKey: @"objectValue"];		
	[obj setDate: [dateFormatter dateFromString: @"20-10-2009"] forKey: @"dateValue"];
	
	[enveloper encodeBodyObject:obj];
	
	NSString* result = enveloper.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
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
	
	STAssertEqualStrings(result, expected, @"archiving custom object");	
}

-(void)testDeenveloping{
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

-(void)testNestedCustomEntity{
	SoapCustomEntity* inner = [[SoapCustomEntity new]autorelease];
	inner.name = @"Inner";
	inner.namespace = @"http://inner.com";
	[inner setInt:100 forKey:@"prop"];
	
	SoapCustomEntity* outer = [[SoapCustomEntity new]autorelease];
	outer.name = @"Outer";
	outer.namespace = @"http://outer.com";
	[outer setObject:inner forKey:@"inner"];
	
	SoapEnveloper* enveloper = [SoapEnveloper soapEnveloper];
	
	[enveloper encodeBodyObject:outer];
	NSString* encoded = enveloper.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	@"	<Body>\n"
	@"		<Outer xmlns=\"http://outer.com\">\n"
	@"			<inner xmlns=\"http://inner.com\">\n"
	@"				<prop>100</prop>\n"
	@"			</inner>\n"
	@"		</Outer>\n"
	@"	</Body>\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(encoded, expected, nil);
	
	SoapDeenveloper* deenveloper = [SoapDeenveloper soapDeenveloperWithXmlString:encoded];
	SoapCustomEntity* decodedOuter = [deenveloper decodeBodyObjectOfType:outer.type];
	STAssertTrue([decodedOuter isKindOfClass:[SoapCustomEntity class]], nil);
	SoapCustomEntity* decodedInner = [decodedOuter objectForKey:@"inner"];
	STAssertTrue([decodedInner isKindOfClass:[SoapCustomEntity class]], nil);
	int decodedProp = [[decodedInner objectForKey:@"prop"]intValue];
	STAssertEquals(decodedProp, 100, nil);
}

-(void)testEnvelopingCollection{
	SoapCustomEntity* container = [[SoapCustomEntity new]autorelease];
	container.name = @"Container";
	container.namespace = @"http://container.com";	

	NSArray* objects = [NSArray arrayWithObjects: [NestedObject nestedWithProp:YES], [NestedObject nestedWithProp:NO], nil];
	[container setManyObjects: objects ofType: [NestedObject class] forKey: @"objects"];	
	
	NSArray* numbers = [NSArray arrayWithObjects: [NSNumber numberWithInt:100], [NSNumber numberWithInt:200], nil];
	[container setManyInt32s: numbers forKey: @"numbers"];	
	
	SoapCustomEntity* custom = [[SoapCustomEntity new]autorelease];
	custom.name = @"Ignored";
	custom.namespace = @"http://custom.com";
	[custom setInt:10 forKey:@"prop"];
	NSArray* customs = [NSArray arrayWithObjects:custom, custom, nil];
	[container setManyObjects:customs ofType:custom.type forKey:@"Custom"];
	
	SoapEnveloper* enveloper = [SoapEnveloper soapEnveloper];	
	[enveloper encodeBodyObject:container];
	NSString* encoded = enveloper.message;
	NSString* expected = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	@"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	@"	<Body>\n"
	@"		<Container xmlns=\"http://container.com\">\n"
	@"			<objects xmlns=\"http://nested.com\">\n"
	@"				<boolProperty>true</boolProperty>\n"
	@"			</objects>\n"
	@"			<objects xmlns=\"http://nested.com\">\n"
	@"				<boolProperty>false</boolProperty>\n"
	@"			</objects>\n"
	@"			<numbers>100</numbers>\n"
	@"			<numbers>200</numbers>\n"
	@"			<Custom xmlns=\"http://custom.com\">\n"
	@"				<prop>10</prop>\n"
	@"			</Custom>\n"
	@"			<Custom xmlns=\"http://custom.com\">\n"
	@"				<prop>10</prop>\n"
	@"			</Custom>\n"
	@"		</Container>\n"
	@"	</Body>\n"
	@"</Envelope>\n";
	
	STAssertEqualStrings(encoded, expected, nil);
	
	SoapDeenveloper* deenveloper = [SoapDeenveloper soapDeenveloperWithXmlString:encoded];
	SoapCustomEntity* decodedContainer = [deenveloper decodeBodyObjectOfType: container.type];
	
	STAssertTrue([decodedContainer isKindOfClass:[SoapCustomEntity class]], nil);
	NSArray* decodedObjects = [decodedContainer objectForKey:@"objects"];
	STAssertTrue([decodedObjects isKindOfClass:[NSArray class]], nil);
	STAssertTrue(decodedObjects.count == 2, nil);
	STAssertTrue([[decodedObjects objectAtIndex:0] isKindOfClass:[NestedObject class]], nil);
	STAssertEquals([[decodedObjects objectAtIndex:0] boolProperty], YES, nil);
	STAssertTrue([[decodedObjects objectAtIndex:1] isKindOfClass:[NestedObject class]], nil);
	STAssertEquals([[decodedObjects objectAtIndex:1] boolProperty], NO, nil);
	NSArray* decodedNumbers = [decodedContainer objectForKey:@"numbers"];
	STAssertEqualObjects(decodedNumbers, numbers, nil);	
	NSArray* decodedCustoms = [decodedContainer objectForKey:@"Custom"];
	STAssertTrue([decodedCustoms isKindOfClass:[NSArray class]], nil);
	STAssertTrue(decodedCustoms.count == 2, nil);
	STAssertTrue([[decodedCustoms objectAtIndex:0] isKindOfClass:[SoapCustomEntity class]], nil);
	STAssertEqualObjects([[decodedCustoms objectAtIndex:0] objectForKey:@"prop"], [NSNumber numberWithInt:10], nil);
	STAssertTrue([[decodedCustoms objectAtIndex:1] isKindOfClass:[SoapCustomEntity class]], nil);
	STAssertEqualObjects([[decodedCustoms objectAtIndex:1] objectForKey:@"prop"], [NSNumber numberWithInt:10], nil);
}



@end
