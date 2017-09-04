#import <SpriteKit/SpriteKit.h>
#import <ARKit/ARKit.h>
#define RESET_ARKIT_TRACK_FROM_SCENE @"RESET_ARKIT_TRACK_FROM_SCENE__1"
#define PAUSE_ARKIT_TRACK_FROM_SCENE @"PAUSE_ARKIT_TRACK_FROM_SCENE__2"
#define RESUME_ARKIT_TRACK_FROM_SCENE @"RESUME_ARKIT_TRACK_FROM_SCENE__3"
#define TOUCH_EVENT @"TOUCH_EVENT__4"
@interface Scene : SKScene
- (void) resetCount;
- (void)setDirectionNotifyNodeVisible:(BOOL)visible;
- (void)showNotifyForDistance;
- (void)addCount;
- (void)delCount;
- (int)getCount;
- (void)addScore;
@end

