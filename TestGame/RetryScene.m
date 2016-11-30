//
//  RetryScene.m
//  TestGame
//
//  Created by Hamza Lakhani on 2016-11-29.
//  Copyright © 2016 Hamza Lakhani. All rights reserved.
//

#import "RetryScene.h"
#import "myScene.h"
@implementation RetryScene
//-(id)initWithSize:(CGSize)size playerWon:(BOOL)isWon {
//    self = [super initWithSize:size];
//    if (self) {
//        SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"caughtDuck"];
//        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
//        [self addChild:background];
//        
//        // 1
//        SKLabelNode* gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
//        gameOverLabel.fontSize = 42;
//        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//        if (isWon) {
//            gameOverLabel.text = @"DAMNNNNN!!!";
//        } else {
//            gameOverLabel.text = @"Tap to retry?";
//        }
//        [self addChild:gameOverLabel];
//    }
//    return self;
//}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *resumeButton = [self nodeAtPoint:location];
    if ([resumeButton.name  isEqual: @"resumeNode"]) {
        SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
        SKView *skView = (SKView *)self.view;
        
        myScene *resumeGameScene = [[myScene alloc] initWithSize: skView.bounds.size];
        
        
        //  Optionally, insert code to configure the new scene.
        resumeGameScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.scene.view presentScene: resumeGameScene transition: reveal];
    }
}
//
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    myScene* retryScene = [[myScene alloc] initWithSize:self.size];
//    // 2
//    [self.view presentScene:retryScene];
//}
@end
