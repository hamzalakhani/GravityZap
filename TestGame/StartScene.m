//
//  StartScene.m
//  TestGame
//
//  Created by Hamza Lakhani on 2016-11-29.
//  Copyright © 2016 Hamza Lakhani. All rights reserved.
//

#import "StartScene.h"
#import "myScene.h"
@implementation StartScene




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *startButtonNode = [self nodeAtPoint:location];
    if ([startButtonNode.name  isEqual: @"startButtonNode"]) {
        SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
        SKView *skView = (SKView *)self.view;
        
        myScene *newGameScene = [[myScene alloc] initWithSize: skView.bounds.size];
        
        
        //  Optionally, insert code to configure the new scene.
        newGameScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.scene.view presentScene: newGameScene transition: reveal];
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
@end
