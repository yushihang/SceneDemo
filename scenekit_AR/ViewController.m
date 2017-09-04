//
//  ViewController.m
//  scenekit_AR
//
//  Created by apple on 04/09/2017.
//  Copyright © 2017 fish. All rights reserved.
//

#import "ViewController.h"
#import "SCNSceneExtension.h"



@interface ViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (nonatomic, strong) dispatch_queue_t serialQueue_;
@property (nonatomic, strong) SCNNode *lightNode;
@property (nonatomic, strong) SCNNode *ambientLightNode;
@end

    
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    // Create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
    

    
    self.serialQueue_ = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    [self.sceneView.scene enableEnvironmentMapWithIntensity:25 queue: self.serialQueue_];
    
    self.lightNode = [SCNNode node];
    self.lightNode.light = [SCNLight light];
    self.lightNode.light.type = SCNLightTypeOmni;
    self.lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:self.lightNode];
    
    // create and add an ambient light to the scene
    self.ambientLightNode = [SCNNode node];
    self.ambientLightNode.light = [SCNLight light];
    self.ambientLightNode.light.type = SCNLightTypeAmbient;
    self.ambientLightNode.light.color = [UIColor darkGrayColor];
    [scene.rootNode addChildNode:self.ambientLightNode];
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    
    configuration.lightEstimationEnabled = YES;
    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
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

- (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time API_AVAILABLE(macos(10.10));
{
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


}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}



@end
