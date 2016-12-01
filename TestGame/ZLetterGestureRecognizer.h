//
//  ZLetterGestureRecognizer.h
//  ZGesture
//
//  Created by Victor Hong on 30/11/2016.
//  Copyright © 2016 Victor Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchProtocol <NSObject>

-(void)touchStarted:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchFinished:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface ZLetterGestureRecognizer : UIGestureRecognizer

@property (nonatomic, weak) id<TouchProtocol> touchDelegate;

- (id)initWithTarget:(id)target action:(SEL)action;

@end
