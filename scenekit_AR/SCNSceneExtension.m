
#import "SCNSceneExtension.h"

@implementation SCNScene (MyExtension)
-(void) enableEnvironmentMapWithIntensity:(float)intensity queue:(dispatch_queue_t)queue {
    
    dispatch_async(queue, ^{
        if (self.lightingEnvironment.contents == nil)
        {
            UIImage* environmentMap = [UIImage imageNamed:@"art.scnassets/sharedImages/environment_blur.exr"];
            if (environmentMap != nil)
            {
                self.lightingEnvironment.contents = environmentMap;
            }
            
        }
        self.lightingEnvironment.intensity = intensity;
    });

}
@end
