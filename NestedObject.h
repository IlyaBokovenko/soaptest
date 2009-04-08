#import <Foundation/Foundation.h>
#import "SoapEntityProto.h"

@interface NestedObject : NSObject<SoapEntityProto> {
	BOOL boolProperty;
}

+(NestedObject*) nestedWithProp: (BOOL)val;

@property(assign) BOOL boolProperty;

@end
