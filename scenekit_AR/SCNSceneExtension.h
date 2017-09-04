
#import <SceneKit/SceneKit.h>
#import <Foundation/Foundation.h>
@interface SCNScene (MyExtension)
-(void) enableEnvironmentMapWithIntensity:(float)intensity queue:(dispatch_queue_t)queue;
@end
