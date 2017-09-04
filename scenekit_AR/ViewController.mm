//
//  ViewController.m
//  scenekit_AR
//
//  Created by apple on 04/09/2017.
//  Copyright © 2017 fish. All rights reserved.
//

#import "ViewController.h"
#import "SCNSceneExtension.h"
#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Scene.h"
#import "UIAlertView+Blocks.h"
#define MAX_NODE_COUNT (20)
#define NODE_NAME @"NODE_NAME__"
@interface ViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (nonatomic, strong) dispatch_queue_t serialQueue_;
@property (nonatomic, strong) SCNNode *lightNode;
@property (nonatomic, strong) SCNNode *ambientLightNode;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSOperationQueue *motionQueue;
@property (nonatomic, strong) SCNNode *ship;
@property (nonatomic) NSInteger creationTime;
@end


@implementation ViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.creationTime = 0;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    // Create a new scene
    SCNScene* scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
    self.sceneView.overlaySKScene = [Scene sceneWithSize:self.sceneView.bounds.size];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTrackWithClear) name:RESET_ARKIT_TRACK_FROM_SCENE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseTrack) name:PAUSE_ARKIT_TRACK_FROM_SCENE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeTrack) name:RESUME_ARKIT_TRACK_FROM_SCENE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTouch:) name:TOUCH_EVENT object:nil];
    
    self.motionManager = [CMMotionManager new];
    self.motionManager.accelerometerUpdateInterval = 0.1;
    self.motionQueue = [NSOperationQueue new];
    [self resetTrack];
    
    self.serialQueue_ = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    [self.sceneView.scene enableEnvironmentMapWithIntensity:25 queue: self.serialQueue_];
    
    self.lightNode = [SCNNode node];
    self.lightNode.light = [SCNLight light];
    self.lightNode.light.type = SCNLightTypeOmni;
    self.lightNode.position = SCNVector3Make(0, 10, 10);
    [self.sceneView.scene.rootNode addChildNode:self.lightNode];
    
    // create and add an ambient light to the scene
    self.ambientLightNode = [SCNNode node];
    self.ambientLightNode.light = [SCNLight light];
    self.ambientLightNode.light.type = SCNLightTypeAmbient;
    self.ambientLightNode.light.color = [UIColor darkGrayColor];
    [self.sceneView.scene.rootNode addChildNode:self.ambientLightNode];
    
    /*
    if ([self.motionManager isAccelerometerAvailable])
    {
        [self.motionManager  startAccelerometerUpdatesToQueue:self.motionQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
            /*
             NSLog(@"X = %0.4f, Y = %.04f, Z = %.04f",
             accelerometerData.acceleration.x,
             accelerometerData.acceleration.y,
             accelerometerData.acceleration.z);
     
            if (fabs(accelerometerData.acceleration.z) < 0.3)
            {
                //[self resetTrackWithOption:0];
                //[self.motionManager stopAccelerometerUpdates];
                [(Scene*)self.sceneView.overlaySKScene setDirectionNotifyNodeVisible:NO];
            }
            else
            {
                [(Scene*)self.sceneView.overlaySKScene setDirectionNotifyNodeVisible:YES];
            }
        }];
    }
     */
    self.ship = [scene.rootNode childNodeWithName:@"ship" recursively:YES];
    self.ship.hidden = YES;
}

- (void) resetTrackWithClear
{
    [self resetTrackWithOption:ARSessionRunOptionResetTracking|ARSessionRunOptionRemoveExistingAnchors];
    [(Scene*)self.sceneView.overlaySKScene resetCount];
}

- (void) pauseTrack
{
    [self.sceneView.session pause];
}

- (void) resumeTrack
{
    [self resetTrackWithOption:0];
}

- (void) resetTrack
{
    [self pauseTrack];
    
    [self resetTrackWithOption:0];
}
- (void) resetTrackWithOption:(ARSessionRunOptions)options
{
    
    
    if (ARWorldTrackingConfiguration.isSupported) {
        ARWorldTrackingConfiguration*  configuration = [[ARWorldTrackingConfiguration alloc] init] ;
        configuration.lightEstimationEnabled = YES;
        //configuration.planeDetection = .horizontal
        [self.sceneView.session runWithConfiguration:configuration options:options];
    }
    else{
        AROrientationTrackingConfiguration* configuration = [[AROrientationTrackingConfiguration alloc] init] ;
        configuration.lightEstimationEnabled = YES;
        [self.sceneView.session runWithConfiguration:configuration options:options];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self resetTrack];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self pauseTrack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ARSCNViewDelegate

/*
 // Override to create and configure nodes for anchors added to the view's session.
 - (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
 SCNNode *node = [SCNNode new];
 
 // Add geometry to the node...
 
 return node;
 }
 */
NS_INLINE simd_float4x4 SCNMatrix4TosimdMat4(const SCNMatrix4& m) {
    simd_float4x4 mat;
    mat.columns[0] = (simd_float4){(float)m.m11, (float)m.m12, (float)m.m13, (float)m.m14};
    mat.columns[1] = (simd_float4){(float)m.m21, (float)m.m22, (float)m.m23, (float)m.m24};
    mat.columns[2] = (simd_float4){(float)m.m31, (float)m.m32, (float)m.m33, (float)m.m34};
    mat.columns[3] = (simd_float4){(float)m.m41, (float)m.m42, (float)m.m43, (float)m.m44};
    return mat;
}

float randomFloat(float min, float max) {
    return (((float)(arc4random())) / 0xFFFFFFFF) * (max - min) + min;
}



- (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)currentTime API_AVAILABLE(macos(10.10));
{
    if (currentTime < self.creationTime)
        return;
    if ([(Scene*)self.sceneView.overlaySKScene getCount] > MAX_NODE_COUNT)
        return;
    self.creationTime = currentTime + randomFloat(2.0, 4.0);
    ARFrame* frame = self.sceneView.session.currentFrame;
    ARLightEstimate* lightEstimate = frame.lightEstimate;
    if (lightEstimate != nil){
        [self.sceneView.scene enableEnvironmentMapWithIntensity:lightEstimate.ambientIntensity / 40 queue:self.serialQueue_];
        
        self.ambientLightNode.light.temperature = lightEstimate.ambientColorTemperature;
        self.ambientLightNode.light.intensity = lightEstimate.ambientIntensity;
    }
    else {
        [self.sceneView.scene enableEnvironmentMapWithIntensity:40 queue:self.serialQueue_];
    }
    
    
    
    
    
    
    
    
    // Define 360º in radians
    float _360degrees = 2.0 * M_PI;
    // Create a rotation matrix in the X-axis
    
    float xDegree = randomFloat(0.0, 1.0);
    //xDegree = 0.5;
    simd_float4x4 rotateX =  SCNMatrix4TosimdMat4(SCNMatrix4MakeRotation(_360degrees * xDegree, 1, 0, 0));

    
    // Create a rotation matrix in the Y-axis
    float yDegree = randomFloat(0.2, 0.7);
    simd_float4x4 rotateY = SCNMatrix4TosimdMat4(SCNMatrix4MakeRotation(_360degrees * yDegree, 0, 1, 0));
    
    // Combine both rotation matrices
    simd_float4x4 rotation = simd_mul(rotateX, rotateY);
    //rotation = rotateX;
    // Create a translation matrix in the Z-axis with a value between 1 and 2 meters
    simd_float4x4 translation = matrix_identity_float4x4;
    translation.columns[3].z = -1.5 - randomFloat(0.0, 1.0);
    //translation.columns[3].z = -1.5;
    // Combine the rotation and translation matrices
    simd_float4x4 transform = simd_mul(rotation, translation);
    
    simd_float4x4 rotateXReverse =  SCNMatrix4TosimdMat4(SCNMatrix4MakeRotation(_360degrees * -xDegree, 1, 0, 0));
    simd_float4x4 rotateYReverse =  SCNMatrix4TosimdMat4(SCNMatrix4MakeRotation(_360degrees * -yDegree, 0, 1, 0));
    
    transform = simd_mul(transform, rotateYReverse);
    transform = simd_mul(transform, rotateXReverse);
    
    simd_float4x4 rotateY2 = SCNMatrix4TosimdMat4(SCNMatrix4MakeRotation(_360degrees * randomFloat(0.0, 1.0), 0, 1, 0));
    transform = simd_mul(transform, rotateY2);
    //transform = translation;
    // Create an anchor
    ARAnchor* anchor = [[ARAnchor alloc]initWithTransform:transform];
    
    // Add the anchor
    [self.sceneView.session addAnchor:anchor];
    
    [(Scene*)self.sceneView.overlaySKScene addCount];
    
    
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    [UIAlertView showWithTitle:@"ARKit错误提示" message:error.localizedDescription  cancelButtonTitle:nil otherButtonTitles:@[@"重试"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        [self resetTrackWithClear];
    }];
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    [self resetTrack];
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    [self resetTrack];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (nullable SCNNode *)renderer:(id <SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor;
{
    // Create and configure a node for the anchor added to the view's session.
    SCNNode* node = [self.ship clone];
    node.hidden = NO;
    node.name = NODE_NAME;
    return node;
}
/**
 Called when a new node has been mapped to the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that maps to the anchor.
 @param anchor The added anchor.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    
}

/**
 Called when a node will be updated with data from the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that will be updated.
 @param anchor The anchor that was updated.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    
}

/**
 Called when a node has been updated with data from the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that was updated.
 @param anchor The anchor that was updated.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    
}

/**
 Called when a mapped node has been removed from the scene graph for the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that was removed.
 @param anchor The anchor that was removed.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    
}
-(void)onTouch:(NSNotification*)notification
{
    UITouch* touch = notification.object;
    if (![touch isKindOfClass:[UITouch class]])
        return;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if (touch == nil)
        return;
    
    CGPoint p = [touch locationInView:self.sceneView];
    NSArray *hitResults = [self.sceneView hitTest:p options:nil];
    if([hitResults count] == 0)
        return;
    // retrieved the first clicked object
    SCNHitTestResult *result = [hitResults objectAtIndex:0];
    if ([result.node.name isEqualToString:NODE_NAME])
    {
        int a = 1;
    }
}
@end

