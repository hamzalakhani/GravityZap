//
//  PauseScene.m
//  TestGame
//
//  Created by Hamza Lakhani on 2016-12-01.
//  Copyright © 2016 Hamza Lakhani. All rights reserved.
//

#import "PauseScene.h"
#import "myScene.h"
#import "StartScene.h"
#import "ZLetterGestureRecognizer.h"

@interface PauseScene() <TouchProtocol>

@property ZLetterGestureRecognizer *zLetterGestureRecognizer;

@end

@implementation PauseScene


-(void)didMoveToView:(SKView *)view {
    
    self.zLetterGestureRecognizer = [[ZLetterGestureRecognizer alloc] init];
    [self.view addGestureRecognizer: self.zLetterGestureRecognizer];
    self.zLetterGestureRecognizer.touchDelegate = self;
    
}

-(void)touchStarted:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *pauseMenu = [self nodeAtPoint:location];
    if ([pauseMenu.name  isEqual: @"PlayNode"]) {
        SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
        SKView *skView = (SKView *)self.view;
        
         myScene*resumeGameScene = [[myScene alloc] initWithSize: skView.bounds.size];
        
        
        //  Optionally, insert code to configure the new scene.
        resumeGameScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.scene.view presentScene: resumeGameScene transition: reveal];
    }else if ([pauseMenu.name isEqual:@"QuitNode"]){
        SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
        SKView *skView = (SKView *)self.view;
        
        StartScene *scene = (StartScene *)[SKScene nodeWithFileNamed:@"StartScene"];
        
        
        //  Optionally, insert code to configure the new scene.
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.scene.view presentScene: scene transition: reveal];
    }
    
}

-(void)touchFinished:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
}
@end
