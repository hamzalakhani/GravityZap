//
//  ZLetterGestureRecognizer.m
//  ZGesture
//
//  Created by Victor Hong on 30/11/2016.
//  Copyright © 2016 Victor Hong. All rights reserved.
//

#import "ZLetterGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@interface ZLetterGestureRecognizer ()

@property (nonatomic)NSUInteger strokePrecision;
@property (nonatomic)NSUInteger strokePart;
@property (nonatomic)CGPoint firstTap;


@end

@implementation ZLetterGestureRecognizer : UIGestureRecognizer

-(id)initWithTarget:(id)target action:(SEL)action{
    if ((self = [super initWithTarget:target action:action])){
        
    }
    return self;
}

- (void)reset
{
    [super reset];
    
    self.strokePart = 0;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event]; // Call the super.
    
    [self.touchDelegate touchStarted:touches withEvent:event];
    
    self.strokePrecision = 10.0; //Points of allowable variation in line direction
    
    if (touches.count > 1) //
    {
        self.state = UIGestureRecognizerStateFailed; //This makes sure there is not a two or more finger touch.  Multiple finger touch is something you can do though!
        return;
    }
    
    self.firstTap = [touches.anyObject locationInView:self.view.superview]; //The first tap location will be set here in touches began.
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event]; // Call the super.
    
    if ((self.state == UIGestureRecognizerStateFailed) || (self.state == UIGestureRecognizerStateRecognized))           //This stops the touches from being observed once the gesture has been recognized
    {
        return;
    }
    
    
    UIView *superView = [self.view superview];     //This allows us to get the points from the same coordinate system of the superview.
    CGPoint currentPoint = [touches.anyObject locationInView:superView];
    CGPoint previousPoint = [touches.anyObject previousLocationInView:superView];
    
    
    if ((self.strokePart == 0) && ((currentPoint.x - self.firstTap.x) > 20.00) && (currentPoint.x > previousPoint.x) && ((currentPoint.y - self.firstTap.y) <= self.strokePrecision))   //This set the fist stroke, a horizontal stroke from left to right.
    {
        self.strokePart = 1;
    }
    else if ((self.strokePart == 1) && (currentPoint.x < previousPoint.x) && (currentPoint.y > previousPoint.y))
    {
        self.strokePart = 2;
    }
    else if ((self.strokePart == 2) && (currentPoint.x > previousPoint.x) && ((currentPoint.y - previousPoint.y) <= self.strokePrecision))   //This set the fist stroke, a horizontal stroke from left to right.
    {
        self.strokePart = 3;
        self.state = UIGestureRecognizerStateRecognized;
        
    }
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event]; // Call the super.
    
    [self.touchDelegate touchFinished:touches withEvent:event];
    
    [self reset];
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    self.state = UIGestureRecognizerStateCancelled;
    
    [self reset];
    
}




@end

