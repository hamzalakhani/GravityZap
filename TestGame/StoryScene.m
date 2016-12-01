//
//  StoryScene.m
//  TestGame
//
//  Created by Hamza Lakhani on 2016-12-01.
//  Copyright © 2016 Hamza Lakhani. All rights reserved.
//

#import "StoryScene.h"
#import "StartScene.h"
#import "ZLetterGestureRecognizer.h"
@interface StoryScene() <TouchProtocol>

@property ZLetterGestureRecognizer *zLetterGestureRecognizer;

@end


@implementation StoryScene

-(void)didMoveToView:(SKView *)view {
    
    self.zLetterGestureRecognizer = [[ZLetterGestureRecognizer alloc] init];
    [self.view addGestureRecognizer: self.zLetterGestureRecognizer];
    self.zLetterGestureRecognizer.touchDelegate = self;
    
}




-(void)touchStarted:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *startButtonNode = [self nodeAtPoint:location];
    if ([startButtonNode.name  isEqual: @"playGame"]) {
        SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
        SKView *skView = (SKView *)self.view;
        
        StartScene *scene = (StartScene *)[SKScene nodeWithFileNamed:@"StartScene"];
        
        
        //  Optionally, insert code to configure the new scene.
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.scene.view presentScene: scene transition: reveal];
    }
    //    UITouch *touch = [touches anyObject];
    //    CGPoint location = [touch locationInNode:self];
    //    SKNode *startButtonNode = [self nodeAtPoint:location];
    //
    //    if ([startButtonNode.name isEqual:@"StartScene"]) {
    //
    //        myScene* breakoutGameScene = [[myScene alloc] initWithSize:self.size];
    //
    //        [self.view presentScene:breakoutGameScene];
    
    
}
-(void)touchFinished:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
}

@end
