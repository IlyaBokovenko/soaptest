#import <Foundation/Foundation.h>
#import "SoapEntityProto.h"

@interface TestHeader : NSObject<SoapEntityProto> {
	NSString* someData;
}

@property(retain) NSString* someData;

@end
