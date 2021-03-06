//
//  GameViewController.m
//  TestGame
//
//  Created by Hamza Lakhani on 2016-11-26.
//  Copyright © 2016 Hamza Lakhani. All rights reserved.
//

#import "GameViewController.h"
#import "StoryScene.h"
@import AVFoundation;

@interface GameViewController ()
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@end
@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load the SKScene from 'GameScene.sks'
    StoryScene *scene = (StoryScene *)[SKScene nodeWithFileNamed:@"StoryScene"];
    
    // Set the scale mode to scale to fit the window
    SKView *skView = (SKView *)self.view;

//    SKScene * scene = [StartScene sceneWithSize:skView.bounds.size];

    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    
    // Present the scene
    [skView presentScene:scene];
    
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}



@end
