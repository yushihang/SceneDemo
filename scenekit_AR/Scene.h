#import <SpriteKit/SpriteKit.h>
#import <ARKit/ARKit.h>
#define RESET_ARKIT_TRACK_FROM_SCENE @"RESET_ARKIT_TRACK_FROM_SCENE__1"
#define PAUSE_ARKIT_TRACK_FROM_SCENE @"PAUSE_ARKIT_TRACK_FROM_SCENE__2"
#define RESUME_ARKIT_TRACK_FROM_SCENE @"RESUME_ARKIT_TRACK_FROM_SCENE__3"
@interface Scene : SKScene
- (void) resetCount;
- (void)setDirectionNotifyNodeVisible:(BOOL)visible;
- (void)addCount;
- (int)getCount;
@end

