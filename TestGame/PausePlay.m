//
//  PausePlay.m
//  TestGame
//
//  Created by Hamza Lakhani on 2016-11-30.
//  Copyright © 2016 Hamza Lakhani. All rights reserved.
//

#import "PausePlay.h"
#import "myScene.h"
@import SpriteKit;
@implementation PausePlay

- (instancetype)initWithSize:(CGSize)size isOn:(BOOL)isOn
{
    self = [super init];
    if (self) {
        
        SKSpriteNode* pauseButton = [SKSpriteNode new];
        myScene* scene = [[myScene alloc]init];
        if (isOn){
            
            pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"pause"];
            pauseButton.size = CGSizeMake(50, 50);
            pauseButton.position = CGPointMake( 20, self.frame.size.height - 25);
            [scene addChild:pauseButton];
            
        }else {
            pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"play"];
            pauseButton.size = CGSizeMake(50, 50);
            pauseButton.position = CGPointMake( 20, self.frame.size.height - 25);
            [scene addChild:pauseButton];
        }
    }
    return self;
}
@end
