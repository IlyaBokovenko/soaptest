#import <Foundation/Foundation.h>
#import "SoapEntityProto.h"

@class NestedObject;

@interface ContainerObject : NSObject<SoapEntityProto> {
	int int1;
	NestedObject* nested;
	int int2;
}

@property(assign) int int1;
@property(retain) NestedObject* nested;
@property(assign) int int2;

@end
