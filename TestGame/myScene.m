//
//  myScene.m
//  TestGame
//
//  Created by Hamza Lakhani on 2016-11-26.
//  Copyright © 2016 Hamza Lakhani. All rights reserved.
//

#import "myScene.h"
#import "RetryScene.h"
#import "ZLetterGestureRecognizer.h"
@import UIKit;

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t blueChipCategory        =  0x1 << 1;
static const uint32_t targetCategory        =  0x1 << 1;
static const uint32_t powerUpCategory     =  0x1 << 1;

@interface myScene ()<SKPhysicsContactDelegate, TouchProtocol>
@property (nonatomic) SKSpriteNode * bulletNode;
@property (nonatomic) SKSpriteNode * superBullet;

@property (nonatomic) SKSpriteNode * leftAmp1;
@property (nonatomic) SKSpriteNode * leftAmp2;
@property (nonatomic) SKSpriteNode * rightAmp1;
@property (nonatomic) SKSpriteNode * rightAmp2;
@property (nonatomic) SKSpriteNode * duckExtraNode;
@property (nonatomic) SKSpriteNode * duckTargetNode;
@property (nonatomic) NSTimeInterval lastForceSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastTargetSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) SKSpriteNode * powerUp;
@property (nonatomic) SKSpriteNode * scoreBoard;
@property (nonatomic) int scoreValue;
@property (nonatomic) SKSpriteNode * pauseButton;
@property (nonatomic) int count;
@property (nonatomic) SKSpriteNode * dogRight;
@property (nonatomic) SKSpriteNode * dogLeft;
@property (nonatomic) NSMutableArray <SKTexture *> * dogRightAnimation;
@property (nonatomic) NSMutableArray <SKTexture *> * dogLeftAnimation;
@property (nonatomic) NSMutableArray <SKTexture*>* duckTargetAnimation;
@property (nonatomic) NSMutableArray <SKTexture*>* duckExtraAnimation;
@property (nonatomic) SKSpriteNode * secretDogNode;
@property (nonatomic) bool isSecretLevelActivated;
@property ZLetterGestureRecognizer *zLetterGestureRecognizer;

@end

@implementation myScene

#pragma mark - initialize scene

-(void)didMoveToView:(SKView *)view {
    
    self.zLetterGestureRecognizer = [[ZLetterGestureRecognizer alloc] initWithTarget:self action:@selector(zLetterMade:)];
    [self.view addGestureRecognizer: self.zLetterGestureRecognizer];
    self.zLetterGestureRecognizer.touchDelegate = self;
    
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.scoreValue = 0;
        self.isSecretLevelActivated = NO;
        
        self.dogRightAnimation = [[NSMutableArray alloc] init];
        self.dogLeftAnimation = [[NSMutableArray alloc] init];
        self.duckTargetAnimation = [[NSMutableArray alloc]init];
        self.duckExtraAnimation = [[NSMutableArray alloc] init];
        
        [self initDogRightAnimation];
        [self initDogLeftAnimation];
        [self initDuckTarget];
        [self initDuckExtra];

        self.scoreValue = 0;
        
        // 1 Create a physics body that borders the screen
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        // 2 Set physicsBody of scene to borderBody
        self.physicsBody = borderBody;
        borderBody.node.name = @"wall";
        // 3 Set the friction of that physicsBody to 0
        self.physicsBody.friction = 0.0f;
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // 3
        SKSpriteNode *bgImage = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        [self addChild:bgImage];
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2);
        
        
        //adding the powerup
        self.powerUp = [SKSpriteNode spriteNodeWithImageNamed:@"powerup"];
        self.powerUp.name = @"powerup";
        self.powerUp.position = CGPointMake(self.frame.size.width/3, self.frame.size.height/3);
        [self addChild:self.powerUp];
        self.powerUp.physicsBody.dynamic = YES; // 2
        
        self.powerUp.physicsBody.categoryBitMask = powerUpCategory; // 3
        self.powerUp.physicsBody.contactTestBitMask = projectileCategory; // 4
        self.powerUp.physicsBody.collisionBitMask = 0;
        // 2
        self.powerUp.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.powerUp.frame.size.width/2];
        // 3
        self.powerUp.physicsBody.friction = 0.0f;
        // 4
        self.powerUp.physicsBody.restitution = 1.0f;
        // 5
        self.powerUp.physicsBody.linearDamping = 0.0f;
        // 6
        self.powerUp.physicsBody.allowsRotation = YES;
        [self.powerUp.physicsBody applyImpulse:CGVectorMake(10.0f, -10.0f)];
        
        // 4
        self.bulletNode = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
        self.bulletNode.position = CGPointMake(200, 30);
        self.bulletNode.name = @"bullet";
        [self addChild:self.bulletNode];
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        //        self.leftAmp1 = [SKSpriteNode spriteNodeWithImageNamed:@"electricleft1"];
        //        self.leftAmp1.position = CGPointMake(350, 400);
        //        [self addChild:self.leftAmp1];
        //
        //        self.leftAmp2 = [SKSpriteNode spriteNodeWithImageNamed:@"electricleft2"];
        //        self.leftAmp2.position = CGPointMake(350, 300);
        //        [self addChild:self.leftAmp2];
        //
        //        self.rightAmp1 = [SKSpriteNode spriteNodeWithImageNamed:@"electricright"];
        //        self.rightAmp1.position = CGPointMake(50, 465);
        //        [self addChild:self.rightAmp1];
        //
        //        self.rightAmp2 = [SKSpriteNode spriteNodeWithImageNamed:@"electricright2"];
        //        self.rightAmp2.position = CGPointMake(50, 365);
        //        [self addChild:self.rightAmp2];
        //
        //        self.target = [SKSpriteNode spriteNodeWithImageNamed:@"Target"];
        //        self.target.position = CGPointMake(200, 700);
        //        [self addChild:self.target];
        
        //Add score
        self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score0"];
        self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
        [self addChild:self.scoreBoard];
        
        //Add dogLeft
        self.dogLeft = [SKSpriteNode spriteNodeWithImageNamed:@"dogLeft1"];
        self.dogLeft.size = CGSizeMake(50, 50);
        self.dogLeft.position = CGPointMake(self.frame.size.width + 50, self.frame.size.height/2);
        self.dogLeft.name = @"dogLeft";
        self.dogLeft.texture = [SKTexture textureWithImageNamed:@"dogLeft"];
        self.dogLeft.physicsBody = [SKPhysicsBody bodyWithTexture:self.dogLeft.texture size:self.dogLeft.size]; // 1
        self.dogLeft.physicsBody.dynamic = YES; // 2
        self.dogLeft.physicsBody.categoryBitMask = targetCategory; // 3
        self.dogLeft.physicsBody.contactTestBitMask = projectileCategory; // 4
        self.dogLeft.physicsBody.collisionBitMask = 0; // 5
        [self addChild:self.dogLeft];
        
        //Add dogRight
        self.dogRight = [SKSpriteNode spriteNodeWithImageNamed:@"dogRight1"];
        self.dogRight.size = CGSizeMake(50, 50);
        self.dogRight.position = CGPointMake(-50 , self.frame.size.height/2);
        self.dogRight.name = @"dogRight";
        self.dogRight.texture = [SKTexture textureWithImageNamed:@"dogRight"];
        self.dogRight.physicsBody = [SKPhysicsBody bodyWithTexture:self.dogRight.texture size:self.dogRight.size]; // 1
        self.dogRight.physicsBody.dynamic = YES; // 2
        self.dogRight.physicsBody.categoryBitMask = targetCategory; // 3
        self.dogRight.physicsBody.contactTestBitMask = projectileCategory; // 4
        self.dogRight.physicsBody.collisionBitMask = 0; // 5
        [self addChild:self.dogRight];
        
    }
    
    
    return self;
}

#pragma mark - add duck node

-(void)addDuckExtraNode {
    
    // Create sprite

    self.duckExtraNode = [SKSpriteNode spriteNodeWithImageNamed:@"duckExtra1"];
    self.duckExtraNode.name = @"duckExtra";
    self.duckExtraNode.size = CGSizeMake(50, 50);
    self.duckExtraNode.physicsBody = [SKPhysicsBody bodyWithTexture:self.duckExtraNode.texture size:self.duckExtraNode.size]; // 1
    self.duckExtraNode.physicsBody.dynamic = YES; // 2
    self.duckExtraNode.physicsBody.categoryBitMask = targetCategory; // 3
    self.duckExtraNode.physicsBody.contactTestBitMask = projectileCategory; // 4
    self.duckExtraNode.physicsBody.collisionBitMask = 0; // 5

    // Determine where to spawn the monster along the Y axis
    int maxY = self.frame.size.height - 20;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    self.duckExtraNode.position = CGPointMake(self.frame.size.width + self.duckExtraNode.size.width, maxY - 50);
    [self addChild:self.duckExtraNode];
    
    // Determine speed of the monster
    int minDuration = 1.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    
    SKAction * animateDuckExtra = [SKAction animateWithTextures:self.duckExtraAnimation timePerFrame:0.5];
    SKAction * animateDuckExtraForever = [SKAction repeatAction:animateDuckExtra count:3];
    SKAction * duckExtraMoveAction = [SKAction moveTo:CGPointMake(-self.duckExtraNode.size.width/2, maxY) duration:minDuration];
    SKAction *groupDuckExtraAction = [SKAction group:@[animateDuckExtraForever, duckExtraMoveAction]];
    SKAction * duckExtraRemoveAction = [SKAction removeFromParent];
    [self.duckExtraNode runAction:[SKAction sequence:@[groupDuckExtraAction, duckExtraRemoveAction]]];

}

-(void)addDuckTargetNode {
    
    // Create sprite
    self.duckTargetNode = [SKSpriteNode spriteNodeWithImageNamed:@"duckTarget1"];
    self.duckTargetNode.name = @"duckTarget";
    self.duckTargetNode.size = CGSizeMake(50, 50);
    self.duckTargetNode.physicsBody = [SKPhysicsBody bodyWithTexture:self.duckTargetNode.texture size:self.duckTargetNode.size]; // 1
    self.duckTargetNode.physicsBody.dynamic = YES; // 2
    self.duckTargetNode.physicsBody.categoryBitMask = blueChipCategory; // 3
    self.duckTargetNode.physicsBody.contactTestBitMask = projectileCategory; // 4
    self.duckTargetNode.physicsBody.collisionBitMask = 0; // 5
    // Determine where to spawn the monster along the Y axis
    int maxY = self.frame.size.height - 20;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    self.duckTargetNode.position = CGPointMake(self.frame.size.width + self.duckTargetNode.size.width, maxY - 50);
    [self addChild:self.duckTargetNode];
    
    // Determine speed of the monster
    int minDuration = 1.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    
    SKAction * animateDuckTarget = [SKAction animateWithTextures:self.duckTargetAnimation timePerFrame:0.5];
    SKAction * animateDuckTargetForever = [SKAction repeatAction:animateDuckTarget count:3];
    SKAction * duckTargetMoveAction = [SKAction moveTo:CGPointMake(-self.duckTargetNode.size.width/2, maxY) duration:minDuration];
    SKAction *groupDuckTargetAction = [SKAction group:@[animateDuckTargetForever, duckTargetMoveAction]];
    SKAction * duckTargetRemoveAction = [SKAction removeFromParent];
    [self.duckTargetNode runAction:[SKAction sequence:@[groupDuckTargetAction, duckTargetRemoveAction]]];

}

#pragma mark - time interval methods

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastForceSpawnTimeInterval += timeSinceLast;
    if (self.lastForceSpawnTimeInterval > 2) {
        self.lastForceSpawnTimeInterval = 0;
        
        //apply force to bullet
        int randomXDirection = arc4random_uniform(400) + 0;
        int randomNegative = arc4random_uniform(2) + 1;
        if (randomNegative == 1) {
            
            randomXDirection = randomXDirection * - 1;
            //Make dog appear from right
            SKAction * animateDogLeft = [SKAction animateWithTextures:self.dogLeftAnimation timePerFrame:0.1];
            SKAction * dogMoveLeft = [SKAction moveTo:CGPointMake(self.frame.size.width - 10, self.frame.size.height/2) duration:0.8];
            SKAction *groupDogLeft = [SKAction group:@[animateDogLeft, dogMoveLeft]];
            SKAction *dogMoveLeftBack = [SKAction moveTo:CGPointMake(self.frame.size.width + 50, self.frame.size.height/2) duration:0.8];
            SKAction *groupDogLeftBack = [SKAction group:@[animateDogLeft, dogMoveLeftBack]];
            [self.dogLeft runAction:[SKAction sequence:@[groupDogLeft, groupDogLeftBack]]];
            
        } else {
            
            //Make dog appear from left
            SKAction * animateDogRight = [SKAction animateWithTextures:self.dogRightAnimation timePerFrame:0.1];
            SKAction * dogMoveRight = [SKAction moveTo:CGPointMake(10, self.frame.size.height/2) duration:0.8];
            SKAction *groupDogRight = [SKAction group:@[animateDogRight, dogMoveRight]];
            SKAction *dogMoveRightBack = [SKAction moveTo:CGPointMake(-50, self.frame.size.height/2) duration:0.8];
            SKAction *groupDogRightBack = [SKAction group:@[animateDogRight, dogMoveRightBack]];
            [self.dogRight runAction:[SKAction sequence:@[groupDogRight, groupDogRightBack]]];
            
        }
        
        //Push bullet
        SKAction * actionMove = [SKAction runBlock:^{
            [self.bulletNode.physicsBody applyForce:CGVectorMake(randomXDirection, 0)];
        }];
        [self.bulletNode runAction:[SKAction sequence:@[actionMove]] withKey:@"bullet action"];
        
        //add target
        
    }
    
}

-(void)updateTargetWithTime:(CFTimeInterval)timeSinceLast {
    
    self.lastTargetSpawnTimeInterval += timeSinceLast;
    
    srand48(time(0));
    double randomTime = drand48() + 1;
    
    if (self.lastTargetSpawnTimeInterval > randomTime) {
        self.lastTargetSpawnTimeInterval = 0;
        
        int randomChip = arc4random_uniform(5) + 2;
        //add target
        
        if (self.isSecretLevelActivated) {
            
            [self addSecretDogNode];
            
        }else {
            
            if (self.count > randomChip) {
                [self addDuckTargetNode];
                self.count = 0;
            } else {
                [self addDuckExtraNode];
                self.count += 1;
            }
            
        }
        
    }
    
}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    [self updateTargetWithTime:timeSinceLast];
    
}
//
//static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
//    return CGPointMake(a.x + b.x, a.y + b.y);
//}
//
//static inline CGPoint rwSub(CGPoint a, CGPoint b) {
//    return CGPointMake(a.x - b.x, a.y - b.y);
//}
//
//static inline CGPoint rwMult(CGPoint a, float b) {
//    return CGPointMake(a.x * b, a.y * b);
//}
//
//static inline float rwLength(CGPoint a) {
//    return sqrtf(a.x * a.x + a.y * a.y);
//}
//
//// Makes a vector have a length of 1
//static inline CGPoint rwNormalize(CGPoint a) {
//    float length = rwLength(a);
//    return CGPointMake(a.x / length, a.y / length);
//}

#pragma mark - touch methods

-(void)touchStarted:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches){
        self.pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"pause"];
        
        self.pauseButton.size = CGSizeMake(50, 50);
        self.pauseButton.position = CGPointMake( 20, self.frame.size.height - 25);
        [self addChild:self.pauseButton];
        CGPoint location = [touch locationInNode:self];
        if([self.pauseButton containsPoint:location]){
            RetryScene *scene = (RetryScene *)[SKScene nodeWithFileNamed:@"RetryScene"];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            [self.view presentScene:scene];
        }
    }
    
}

-(void)touchFinished:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 1 - Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    //CGPoint location = [touch locationInNode:self];
    
    // 2 - Set up initial location of projectile
    //    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
    self.bulletNode.position = self.bulletNode.position;
    self.bulletNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.bulletNode.size.width/2];
    self.bulletNode.physicsBody.dynamic = YES;
    self.bulletNode.physicsBody.categoryBitMask = projectileCategory;
    self.bulletNode.physicsBody.contactTestBitMask = targetCategory;
    self.bulletNode.physicsBody.collisionBitMask = 0;
    self.bulletNode.physicsBody.usesPreciseCollisionDetection = YES;
    //    // 3- Determine offset of location to projectile
    //    CGPoint offset = rwSub(location, self.bulletNode.position);
    //
    //    // 4 - Bail out if you are shooting down or backwards
    //    //    if (offset.x <= 0) return;
    //
    //    // 5 - OK to add now - we've double checked position
    //    //[self addChild:self.bulletNode];
    //
    //    // 6 - Get the direction of where to shoot
    //    CGPoint direction = rwNormalize(offset);
    //
    //    // 7 - Make it shoot far enough to be guaranteed off screen
    //    CGPoint shootAmount = rwMult(direction, 1000);
    //
    //    // 8 - Add the shoot amount to the current position
    //    CGPoint realDest = rwAdd(shootAmount, self.bulletNode.position);
    
    // 9 - Create the actions
    //float velocity = 480.0/1.0;
    //float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction runBlock:^{
        [self.bulletNode.physicsBody applyForce:CGVectorMake(0, 4000)];
    }];
    [self.bulletNode runAction:[SKAction sequence:@[actionMove]] withKey:@"bullet action"];
    
}

#pragma mark - collision detection

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
    NSLog(@"Hit");
    
    if ([monster.name isEqual:@"blueChip"]) {
        
        self.count += 1;
        
    }
    
    [self.bulletNode removeFromParent];
    [monster removeFromParent];
    self.bulletNode = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
    self.bulletNode.position = CGPointMake(200, 30);
    [self addChild:self.bulletNode];
    
    
}
//contact with powerup
- (void)thePowerUp:(SKSpriteNode *)thePowerUp didcolideWithPowerUp:(SKSpriteNode *)powerUp {
    NSLog(@"power up!!");
    [self.powerUp removeFromParent];
    [powerUp removeFromParent];
    self.bulletNode = [SKSpriteNode spriteNodeWithImageNamed:@"doublebullet"];
    self.bulletNode.position = CGPointMake(200, 30);
    [self addChild:self.bulletNode];
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & targetCategory) != 0)
    {
        
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
        
        if([secondBody.node.name  isEqual: @"powerup"]){
            [self shrinkAndMoveToPosition:self.view.center];
            
            [self thePowerUp:(SKSpriteNode *)firstBody.node didcolideWithPowerUp:(SKSpriteNode *)secondBody.node];

        }else if ([secondBody.node.name isEqual:@"duckTarget"]){
            
            switch (self.scoreValue) {
                case 1:
                    
                    [self.scoreBoard removeFromParent];
                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score1"];
                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    [self addChild:self.scoreBoard];
                    
                    break;
                case 2:
                    
                    [self.scoreBoard removeFromParent];
                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score2"];
                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    [self addChild:self.scoreBoard];
                    
                    break;
                    
                case 3:
                    
                    [self.scoreBoard removeFromParent];
                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score3"];
                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    [self addChild:self.scoreBoard];
                    
                    break;
                    
                case 4:
                    
                    [self.scoreBoard removeFromParent];
                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score4"];
                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    [self addChild:self.scoreBoard];
                    
                    break;
                    
                case 5:
                    
                    [self.scoreBoard removeFromParent];
                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score5"];
                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    [self addChild:self.scoreBoard];
                    
                    break;
                    
                case 6:
                    
                    [self.scoreBoard removeFromParent];
                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score6"];
                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    [self addChild:self.scoreBoard];
                    
                    break;
                    
                case 7:
                    
                    [self.scoreBoard removeFromParent];
                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score7"];
                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    [self addChild:self.scoreBoard];
                    
                    break;
                    
                case 8:
                    
                    [self.scoreBoard removeFromParent];
                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score8"];
                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    [self addChild:self.scoreBoard];
                    
                    break;
                    
                case 9:
                    
                    [self.scoreBoard removeFromParent];
                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score9"];
                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    [self addChild:self.scoreBoard];
                    
                    break;
                    
                case 10:
                    
                    //NEXT LEVEL
                    //                    [self.scoreBoard removeFromParent];
                    //                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score1"];
                    //                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    //                    [self addChild:self.scoreBoard];
                    
                    break;
                    
                default:
                    
                    self.scoreValue = 0;
                    
                    [self.scoreBoard removeFromParent];
                    self.scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"score1"];
                    self.scoreBoard.position = CGPointMake(self.frame.size.width - 20, self.frame.size.height - 25);
                    [self addChild:self.scoreBoard];
                    
                    break;
            }
            
            
        } else {
            
            RetryScene *scene = (RetryScene *)[SKScene nodeWithFileNamed:@"RetryScene"];
            
            scene.scaleMode = SKSceneScaleModeAspectFill;
            [self.view presentScene:scene];
        }
        
    }
    
}

- (void)shrinkAndMoveToPosition:(CGPoint)position {
    
    SKSpriteNode* superPower = [SKSpriteNode spriteNodeWithImageNamed:@"happyDog"];
    superPower.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addChild:superPower];
    
    
    SKAction *move = [SKAction moveTo:position duration:.5];
    SKAction *scale = [SKAction scaleTo:.3 duration:.5];
    SKAction *moveAndScale = [SKAction group:@[move, scale]];
    [self runAction:moveAndScale completion:^{
        
        
        SKAction *animate = [SKAction scaleBy:0.0 duration:.5];
        
        [superPower runAction:[SKAction repeatActionForever:animate]];
        
    }];
}

#pragma mark - initialize animation texture

-(void)initDogRightAnimation {
    
    SKTextureAtlas *dogAtlas = [SKTextureAtlas atlasNamed:@"dogRight"];
    
    [self.dogRightAnimation addObject:[dogAtlas textureNamed:@"dogRight1"]];
    [self.dogRightAnimation addObject:[dogAtlas textureNamed:@"dogRight2"]];
    [self.dogRightAnimation addObject:[dogAtlas textureNamed:@"dogRight3"]];
    [self.dogRightAnimation addObject:[dogAtlas textureNamed:@"dogRight4"]];
    [self.dogRightAnimation addObject:[dogAtlas textureNamed:@"dogRight5"]];
    
}

-(void)initDogLeftAnimation {
    
    SKTextureAtlas *dogAtlas = [SKTextureAtlas atlasNamed:@"dogLeft"];
    
    [self.dogLeftAnimation addObject:[dogAtlas textureNamed:@"dogLeft1"]];
    [self.dogLeftAnimation addObject:[dogAtlas textureNamed:@"dogLeft2"]];
    [self.dogLeftAnimation addObject:[dogAtlas textureNamed:@"dogLeft3"]];
    [self.dogLeftAnimation addObject:[dogAtlas textureNamed:@"dogLeft4"]];
    [self.dogLeftAnimation addObject:[dogAtlas textureNamed:@"dogLeft5"]];
    
}
-(void) initDuckTarget {
    
    SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:@"duckTarget"];
    
    // Running player animation
    
    [self.duckTargetAnimation addObject:[atlas textureNamed:@"duckTarget1"]];
    [self.duckTargetAnimation addObject:[atlas textureNamed:@"duckTarget2"]];
    
}


-(void) initDuckExtra {
    
    SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:@"duckExtra"];
    
    // Running player animation
    [self.duckExtraAnimation addObject:[atlas textureNamed:@"duckExtra1"]];
    [self.duckExtraAnimation addObject:[atlas textureNamed:@"duckExtra2"]];
    
}

#pragma mark - secret level

-(void)addSecretDogNode {
    
    // Create sprite
    
    self.secretDogNode = [SKSpriteNode spriteNodeWithImageNamed:@"dogLeft1"];
    self.secretDogNode.name = @"duckExtra";
    self.secretDogNode.size = CGSizeMake(50, 50);
    self.secretDogNode.physicsBody = [SKPhysicsBody bodyWithTexture:self.secretDogNode.texture size:self.secretDogNode.size]; // 1
    self.secretDogNode.physicsBody.dynamic = YES; // 2
    self.secretDogNode.physicsBody.categoryBitMask = targetCategory; // 3
    self.secretDogNode.physicsBody.contactTestBitMask = projectileCategory; // 4
    self.secretDogNode.physicsBody.collisionBitMask = 0; // 5
    
    // Determine where to spawn the monster along the Y axis
    int maxY = self.frame.size.height - 20;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    self.secretDogNode.position = CGPointMake(self.frame.size.width + self.secretDogNode.size.width, maxY - 50);
    [self addChild:self.secretDogNode];
    
    // Determine speed of the monster
    int minDuration = 1.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    
    SKAction * animateSecretDog = [SKAction animateWithTextures:self.dogLeftAnimation timePerFrame:0.5];
    SKAction * animateSecretDogForever = [SKAction repeatAction:animateSecretDog count:3];
    SKAction * secretDogMoveAction = [SKAction moveTo:CGPointMake(-self.secretDogNode.size.width/2, maxY) duration:minDuration];
    SKAction *groupSecretDogAction = [SKAction group:@[animateSecretDogForever, secretDogMoveAction]];
    SKAction * secretDogRemoveAction = [SKAction removeFromParent];
    [self.secretDogNode runAction:[SKAction sequence:@[groupSecretDogAction, secretDogRemoveAction]]];
    
}

#pragma mark - Z gesture

-(void)zLetterMade:(ZLetterGestureRecognizer *)zLetterRecognizer {
    
    NSLog(@"Z letter");
    self.isSecretLevelActivated = YES;
    
}
@end
