#import "GTMSenTestCase.h"
#import "SoapCustomEntity.h"
#import "SoapRequest.h"
#import "RESTService.h"

#import <objc/objc-api.h>
#import <objc/runtime.h>

@interface SoapRequestTest : GTMTestCase {	
	IMP restServicePostMethodImp;
}
@end

@implementation SoapRequestTest

static NSString* g_encoded;
static NSDictionary* g_headers;
static NSString* g_response;

// mock method to be substituted in RESTService
- (id)post:(NSData*)data to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error {
	g_encoded = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];
	g_headers = headers;
	
	return [g_response dataUsingEncoding: NSUTF8StringEncoding];	 
}

-(void) substituteRestServicePostMethodResponseWith: (NSString*)xmlResponse{
	Method original = class_getInstanceMethod([RESTService class], @selector(post:to:headers:error:));	
	Method mock = class_getInstanceMethod([self class], @selector(post:to:headers:error:));	
	IMP mockImp = method_getImplementation(mock);
	restServicePostMethodImp = method_setImplementation(original, mockImp);
	g_response = xmlResponse;
}

-(void) restoreRestServicePostMethod{
	Method original = class_getInstanceMethod([RESTService class], @selector(post:to:headers:error:));	
	method_setImplementation(original, restServicePostMethodImp);
}


-(void)testExecuting{
	SoapRequest* request = [[SoapRequest new]autorelease];
	request.url =  @"http://somehost.com/someservice.asmx";	
	
	SoapCustomEntity* body = [SoapCustomEntity soapCustomEntityNamed:@"SomeRequest" namespace:@"http://request.com"];
	[body setBool:YES forKey:@"boolValue"];	
	request.body = body;
	
	SoapCustomEntityType* responseType = [SoapCustomEntityType soapCustomEntityTypeNamed:@"SomeResponse" namespace:@"http://response.com"];	
	SoapCustomEntityType* innerType = [SoapCustomEntityType soapCustomEntityTypeNamed:@"InnerResponse" namespace:@"http://response.com"];
	[innerType addIntForKey:@"someIntValue"];
	[responseType addObjectOfType:innerType];	
	request.responseType = responseType;	
	request.pathToResult = [NSArray arrayWithObjects: @"InnerResponse", @"someIntValue", nil];	
		
	NSString* mockWebServiceResponse = 
	@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	"	<Body>\n"
	"		<SomeResponse xmlns=\"http://response.com\">\n"
	"			<InnerResponse xmlns=\"http://response.com\">\n"	
	"				<someIntValue>42</someIntValue>\n"
	"			</InnerResponse>\n"	
	"		</SomeResponse>\n"
	"	</Body>\n"
	"</Envelope>\n";
	
	[self substituteRestServicePostMethodResponseWith: mockWebServiceResponse];
	BOOL isOk = [request execute];
	[self restoreRestServicePostMethod];
	
	NSString* expectedEncodedRequest =
	@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	"<Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.w3.org/2003/05/soap-envelope\">\n"
	"	<Body>\n"
	"		<SomeRequest xmlns=\"http://request.com\">\n"
	"			<boolValue>true</boolValue>\n"
	"		</SomeRequest>\n"
	"	</Body>\n"
	"</Envelope>\n";
	STAssertEqualStrings(g_encoded, expectedEncodedRequest, nil);
	NSDictionary* expectedHttpHeaders = [NSDictionary dictionaryWithObject:@"application/soap+xml; charset=utf-8" forKey:@"Content-Type"];
	STAssertEqualObjects(g_headers, expectedHttpHeaders, nil);	
	
	STAssertTrue(isOk, nil);
	STAssertTrue([request.result isKindOfClass:[NSNumber class]], nil);
	STAssertEquals([request.result intValue], 42, nil);
}

@end


