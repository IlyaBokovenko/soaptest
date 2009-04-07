#import <Foundation/Foundation.h>
#import "SoapEntityProto.h"

@interface NestedObject : NSObject<SoapEntityProto> {
	BOOL boolProperty;
}

@property(assign) BOOL boolProperty;

@end
