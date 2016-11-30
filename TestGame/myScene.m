//
//  myScene.m
//  TestGame
//
//  Created by Hamza Lakhani on 2016-11-26.
//  Copyright © 2016 Hamza Lakhani. All rights reserved.
//

#import "myScene.h"
#import "RetryScene.h"
#import "PausePlay.h"
static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t blueChipCategory        =  0x1 << 1;
static const uint32_t targetCategory        =  0x1 << 1;
static const uint32_t powerUpCategory     =  0x1 << 1;

@interface myScene ()<SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * bulletNode;
@property (nonatomic) SKSpriteNode * superBullet;

@property (nonatomic) SKSpriteNode * leftAmp1;
@property (nonatomic) SKSpriteNode * leftAmp2;
@property (nonatomic) SKSpriteNode * rightAmp1;
@property (nonatomic) SKSpriteNode * rightAmp2;
@property (nonatomic) SKSpriteNode * target;
@property (nonatomic) SKSpriteNode * blueChip;
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
@property (nonatomic) NSMutableArray <SKTexture*>* duck;
@property (nonatomic) NSMutableArray <SKTexture*>* duckPower;

@end

@implementation myScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        self.scoreValue = 0;
        
        self.duck = [[NSMutableArray alloc]init];
        [self setUpTargetActions];
        
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
        self.dogLeft = [SKSpriteNode spriteNodeWithImageNamed:@"dogLeft"];
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
        self.dogRight = [SKSpriteNode spriteNodeWithImageNamed:@"dogRight"];
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
-(void)addMonster {
    
    // Create sprite

    self.target = [SKSpriteNode spriteNodeWithImageNamed:@"ducktarget1"];
    self.target.name = @"target";
    self.target.size = CGSizeMake(80, 80);
    self.target.texture = [SKTexture textureWithImageNamed:@"Target"];
    self.target.physicsBody = [SKPhysicsBody bodyWithTexture:self.target.texture size:self.target.size]; // 1
    self.target.physicsBody.dynamic = YES; // 2
    self.target.physicsBody.categoryBitMask = targetCategory; // 3
    self.target.physicsBody.contactTestBitMask = projectileCategory; // 4
    self.target.physicsBody.collisionBitMask = 0; // 5

    // Determine where to spawn the monster along the Y axis
    int maxY = self.frame.size.height - 20;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    self.target.position = CGPointMake(self.frame.size.width + self.target.size.width, maxY);
    [self addChild:self.target];
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions

    SKAction * actionMove = [SKAction moveTo:CGPointMake(-self.target.size.width/2, maxY) duration:minDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [self.target runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];

    
}

-(void)addBlueChip {
    
    // Create sprite
    self.blueChip = [SKSpriteNode spriteNodeWithImageNamed:@"blueChip"];
    self.blueChip.name = @"blueChip";
    self.blueChip.size = CGSizeMake(80, 80);
    self.blueChip.texture = [SKTexture textureWithImageNamed:@"blueChip"];
    self.blueChip.physicsBody = [SKPhysicsBody bodyWithTexture:self.blueChip.texture size:self.blueChip.size]; // 1
    self.blueChip.physicsBody.dynamic = YES; // 2
    self.blueChip.physicsBody.categoryBitMask = blueChipCategory; // 3
    self.blueChip.physicsBody.contactTestBitMask = projectileCategory; // 4
    self.blueChip.physicsBody.collisionBitMask = 0; // 5
    // Determine where to spawn the monster along the Y axis
    int maxY = self.frame.size.height - 20;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    self.blueChip.position = CGPointMake(self.frame.size.width + self.blueChip.size.width, maxY);
    [self addChild:self.blueChip];
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-self.blueChip.size.width/2, maxY) duration:minDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [self.blueChip runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];

}

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
            SKAction * dogMoveLeft = [SKAction moveTo:CGPointMake(self.frame.size.width - 10, self.frame.size.height/2) duration:0.8];
            SKAction *dogMoveLeftBack = [SKAction moveTo:CGPointMake(self.frame.size.width + 50, self.frame.size.height/2) duration:0.8];
            [self.dogLeft runAction:[SKAction sequence:@[dogMoveLeft, dogMoveLeftBack]]];
        } else {
            
            //Make dog appear from left
            SKAction * dogMoveRight = [SKAction moveTo:CGPointMake(10, self.frame.size.height/2) duration:0.8];
            SKAction *dogMoveRightBack = [SKAction moveTo:CGPointMake(-50, self.frame.size.height/2) duration:0.8];
            [self.dogRight runAction:[SKAction sequence:@[dogMoveRight, dogMoveRightBack]]];
            
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
        if (self.count > randomChip) {
            [self addBlueChip];
            self.count = 0;
        } else {
            [self addMonster];
            self.count += 1;
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
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
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

        }else if ([secondBody.node.name isEqual:@"blueChip"]){
            
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
            
            RetryScene* retryScene = [[RetryScene alloc] initWithSize:self.frame.size playerWon:NO];
            [self.view presentScene:retryScene];
        }
        
    }
    
}
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    for (UITouch *touch in touches){
//       If( PausePlay* pauseScene = [[PausePlay alloc]initWithSize:self.frame.size isOn:YES]);
//        [self.view presentScene:retryScene];
//        CGPoint location = [touch locationInNode:self];
//        if([self.pauseButton containsPoint:location]){
//            self.scene.view.paused = YES;
//
//        }
//    }
//
//
//}

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

-(void) setUpTargetActions {
    SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:@"Duck"];
    
    // Running player animation
    [self.duck addObject:[atlas textureNamed:@"ducktarget1"]];
     [self.duck addObject:[atlas textureNamed:@"ducktarget2"]];
}
//    NSArray * runTexture = @[runTexture1, runTexture2, runTexture3, runTexture4];
//    
//    SKAction* runAnimation = [SKAction animateWithTextures:runTexture timePerFrame:0.06 resize:YES restore:NO];
//    
//    SKSpriteNode * playerNode = (SKSpriteNode *)[self childNodeWithName:@"player"];
//    [playerNode runAction:[SKAction repeatActionForever:runAnimation]];
//}

@end
