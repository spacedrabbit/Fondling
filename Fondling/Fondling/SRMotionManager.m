//
//  SRMotionManager.m
//  Fondling
//
//  Created by Louis Tur on 11/15/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import "SRMotionManager.h"
#import <SOMotionDetector/SOMotionDetector.h>

// -- minimum amount of change needed in attitude deltas to constitute a change -- //
static CGFloat const kDeltaMin = 0.01;

@interface SRMotionManager () <SOMotionDetectorDelegate>

@property (strong, nonatomic) SOMotionDetector * sharedSODector;
@property (strong, nonatomic) NSDictionary * motionReference;
@property (strong, nonatomic) CMAttitude * attitude;

@end

@implementation SRMotionManager

+(instancetype) sharedFondler{

    static SRMotionManager * _sharedFondler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFondler = [[SRMotionManager alloc] init];
    });
    return _sharedFondler;
}
/*
     typedef enum
     {
     MotionTypeNotMoving = 1,
     MotionTypeWalking,
     MotionTypeRunning,
     MotionTypeAutomotive,
     MotionTypeFondling
     } SOMotionType;
    
    @property (nonatomic) BOOL useM7IfAvailable;
    - (void)setMinimumSpeed:(CGFloat)speed;
    - (void)setMaximumWalkingSpeed:(CGFloat)speed;
    - (void)setMaximumRunningSpeed:(CGFloat)speed;
    - (void)setMinimumRunningAcceleration:(CGFloat)acceleration;
 
 */

-(instancetype)init{
    self = [super init];
    if (self) {
        
        self.sharedSODector = [SOMotionDetector sharedInstance];
        self.sharedSODector.delegate = self;
        self.sharedSODector.useM7IfAvailable = YES;
        
        self.motionReference = @{
                                    [NSNumber numberWithInteger:MotionTypeNotMoving]      : @"Not Moving",
                                    [NSNumber numberWithInteger:MotionTypeWalking]        : @"Walking",
                                    [NSNumber numberWithInteger:MotionTypeRunning]        : @"Running",
                                    [NSNumber numberWithInteger:MotionTypeAutomotive]     : @"AutoMotive",
                                    [NSNumber numberWithInteger:MotionTypeFondling]       : @"Fondling Gently",
                                    [NSNumber numberWithInteger:MotionTypeVigorousFondling] : @"Fondling Vigorously"
                                 };
        self.attitude = nil;
        
    }
    return self;
}

-(void)updateMotionType:(NSString *)motionType{
    
    self.currentMotionType = motionType;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"motionChange" object:self];
}

- (void)motionDetector:(SOMotionDetector *)motionDetector motionTypeChanged:(SOMotionType)motionType
{
    NSNumber * motionNumber = [NSNumber numberWithInteger:motionType];
    [self updateMotionType:[self.motionReference objectForKey:motionNumber]];
}
- (void)motionDetector:(SOMotionDetector *)motionDetector locationChanged:(CLLocation *)location
{
    NSLog(@"Location has changed: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
}
- (void)motionDetector:(SOMotionDetector *)motionDetector accelerationChanged:(CMAcceleration)acceleration
{
    //NSLog(@"Your accelerationChanged: X:%f  Y:%f  Z:%f", acceleration.x, acceleration.y, acceleration.z);
}

-(void)fondlerDetector:(SOMotionDetector *)motionDetector attitudeChanged:(CMAttitude *)attitude rotationRate:(CMRotationRate)rotation
{
    if (!self.attitude) {
        self.attitude = attitude;
    }
    //NSLog(@"\n\nThe attitudes: \nroll %f \npitch %f \nyaw %f", attitude.roll, attitude.pitch,attitude.yaw );
    //NSLog(@"Rotation Rate: x: %f  y: %f  z: %f", rotation.x, rotation.y, rotation.z);
    NSString * movementType;
    if ( ![self.attitude isEqual:attitude] ) {
        CGFloat rollDelta = fabs(self.attitude.roll - attitude.roll);
        CGFloat pitchDelta = fabs(self.attitude.pitch - attitude.pitch);
        CGFloat yawDelta = fabs(self.attitude.yaw - attitude.yaw);
        
        if ( rollDelta > kDeltaMin || pitchDelta > kDeltaMin || yawDelta > kDeltaMin ) {
            NSLog(@"Deltas: %.3f  %.3f   %.3f", rollDelta, pitchDelta, yawDelta);
            
            [[NSOperationQueue new] addOperationWithBlock:^{
                [self.delegate attitudeHasUpdatedRoll:rollDelta withYaw:yawDelta andPitch:pitchDelta];
            }];
            
            movementType = @"Fondling Gently";
            if(self.sharedSODector.isShaking){
                movementType = @"Fondling Vigorously";
            }
        }
        else{
            movementType = @"Not Fondling At All";
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fondleChange" object:self userInfo:@{ @"motion": movementType}];
    }
    self.attitude = attitude;
    
}

@end
