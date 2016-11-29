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
-(id)initWithSize:(CGSize)size playerWon:(BOOL)isWon {
    self = [super initWithSize:size];
    if (self) {
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addChild:background];
        
        // 1
        SKLabelNode* gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        gameOverLabel.fontSize = 42;
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        if (isWon) {
            gameOverLabel.text = @"DAMNNNNN!!!";
        } else {
            gameOverLabel.text = @"Tap to retry?";
        }
        [self addChild:gameOverLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    myScene* breakoutGameScene = [[myScene alloc] initWithSize:self.size];
    // 2
    [self.view presentScene:breakoutGameScene];
}
@end
