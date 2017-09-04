

#import "Scene.h"
#import <simd/types.h>
#import <SceneKit/SceneKit.h>
#import <unordered_map>
#import <string>

#define RESET_BUTTON_NAME @"RESET_BUTTON_NAME"

#define GUESS_Z_POS (100)
#define LABEL_Z_POS (100)


@interface Scene()
{
    SKLabelNode* noticelabel_;
    SKLabelNode* numberLabel_;
    
    SKLabelNode* foundNoticeLabel_;
    SKLabelNode* foundNumberLabel_;
    
    int nodeNumber_;
    //int currentRemainAnchorCount_;
    int successedAnchorCount_;
    SKSpriteNode* resetButton_;
    SKSpriteNode* distanceNotifyNode_;
    SKSpriteNode* directionNotifyNode_;
    

}
@end


@implementation Scene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self != nil)
    {
        noticelabel_ = [SKLabelNode labelNodeWithText:@"剩余个数:"];
        noticelabel_.fontSize = 15;
        noticelabel_.fontName =  [UIFont boldSystemFontOfSize:20.f].fontName;
        noticelabel_.fontColor = UIColor.whiteColor;
        noticelabel_.position = CGPointMake(noticelabel_.frame.size.width*0.5, noticelabel_.fontSize * 0.55);
        noticelabel_.zPosition = LABEL_Z_POS;
        
        numberLabel_ = [SKLabelNode labelNodeWithText:@"0"];
        numberLabel_.fontSize = noticelabel_.fontSize;
        numberLabel_.fontName = noticelabel_.fontName;
        numberLabel_.fontColor = noticelabel_.fontColor;
        numberLabel_.zPosition = LABEL_Z_POS;
        
        foundNoticeLabel_ = [SKLabelNode labelNodeWithText:@"得分:"];
        foundNoticeLabel_.fontSize = noticelabel_.fontSize;
        foundNoticeLabel_.fontName =  noticelabel_.fontName;
        foundNoticeLabel_.fontColor = noticelabel_.fontColor;
        foundNoticeLabel_.zPosition = LABEL_Z_POS;
        
        
        foundNumberLabel_ = [SKLabelNode labelNodeWithText:@"0"];
        foundNumberLabel_.fontSize = noticelabel_.fontSize;
        foundNumberLabel_.fontName =  noticelabel_.fontName;
        foundNumberLabel_.fontColor = noticelabel_.fontColor;
        foundNumberLabel_.zPosition = LABEL_Z_POS;
        
        resetButton_ = [[SKSpriteNode alloc] initWithImageNamed:@"reset.png"];
        resetButton_.size = CGSizeMake(40, 40);
        resetButton_.userInteractionEnabled = false;
        resetButton_.position = CGPointMake([UIScreen mainScreen].bounds.size.width -  resetButton_.size.width*0.6, [UIScreen mainScreen].bounds.size.height -  resetButton_.size.height*0.6);
        resetButton_.name = RESET_BUTTON_NAME;
        resetButton_.zPosition = LABEL_Z_POS;
        
        [self setNodeNumer:0];
        //currentRemainAnchorCount_ = 0;
        [self setSuccessNodeNumer:0];
        
       
        distanceNotifyNode_ = [[SKSpriteNode alloc]initWithImageNamed:@"distance_notify.png"];
        distanceNotifyNode_.xScale = distanceNotifyNode_.yScale = [UIScreen mainScreen].bounds.size.height * 0.05 / distanceNotifyNode_.size.height ;
        distanceNotifyNode_.position = CGPointMake([UIScreen mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height - distanceNotifyNode_.frame.size.height*0.75);
        
        directionNotifyNode_ = [[SKSpriteNode alloc]initWithImageNamed:@"direction_notify.png"];
        directionNotifyNode_.xScale = directionNotifyNode_.yScale = [UIScreen mainScreen].bounds.size.height * 0.05 / directionNotifyNode_.size.height ;
        directionNotifyNode_.position = CGPointMake([UIScreen mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height - directionNotifyNode_.frame.size.height*0.75);
        directionNotifyNode_.hidden = NO;
        
        
    }
    return self;
    
}



- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    [self addChild:noticelabel_];
    [self addChild:numberLabel_];
    [self addChild:foundNoticeLabel_];
    [self addChild:foundNumberLabel_];
    [self addChild:resetButton_];
    [self addChild:distanceNotifyNode_];
    distanceNotifyNode_.alpha = 0;
    [self addChild:directionNotifyNode_];
    
}

- (void)setNodeNumer:(int)number{
    nodeNumber_ = number;
    [self updateLabels];
    
}


- (void)setSuccessNodeNumer:(int)number{
    successedAnchorCount_ = number;
    [self updateLabels];
}

-(void)updateLabels
{
    numberLabel_.text = [NSString stringWithFormat:@"%d", nodeNumber_];
    foundNumberLabel_.text = [NSString stringWithFormat:@"%d", successedAnchorCount_];
    
    numberLabel_.position = CGPointMake(noticelabel_.frame.size.width+noticelabel_.frame.origin.x + 10 + numberLabel_.frame.size.width*0.5, noticelabel_.position.y);
    
    
    foundNoticeLabel_.position = CGPointMake(numberLabel_.frame.size.width+numberLabel_.frame.origin.x + 10 + foundNoticeLabel_.frame.size.width*0.5, noticelabel_.position.y);
    
    foundNumberLabel_.position = CGPointMake(foundNoticeLabel_.frame.size.width+foundNoticeLabel_.frame.origin.x + 10 + foundNumberLabel_.frame.size.width*0.5, noticelabel_.position.y);
}

- (void)update:(CFTimeInterval)currentTime {
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    if (touch == nil)
        return;
    
    CGPoint location = [touch locationInNode:self];
    
    NSArray* hitNodes = [self nodesAtPoint:location];
    if (hitNodes.count == 0)
        return;

}


- (void)showNotifyForDistance
{
    [distanceNotifyNode_ removeAllActions];
    
    NSArray* array = [NSArray arrayWithObjects:[SKAction fadeAlphaTo:1 duration:0.1], [SKAction waitForDuration:1],[SKAction fadeAlphaTo:0 duration:1], nil];
    [distanceNotifyNode_ runAction:[SKAction sequence:array]];
}
- (void) resetTrack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RESET_ARKIT_TRACK_FROM_SCENE object:nil];
}
-(void) resumeTrack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RESUME_ARKIT_TRACK_FROM_SCENE object:nil];
}
-(void) pauseTrack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PAUSE_ARKIT_TRACK_FROM_SCENE object:nil];
}
- (void) resetCount
{
    [self setNodeNumer:0];


}



- (void)dealloc
{

}


- (void)setDirectionNotifyNodeVisible:(BOOL)visible;
{
    directionNotifyNode_.hidden = !visible;
}

- (void)addCount
{
    [self setNodeNumer:nodeNumber_ + 1];
}
- (int)getCount
{
    return nodeNumber_;
}
@end

