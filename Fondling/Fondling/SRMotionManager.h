//
//  SRMotionManager.h
//  Fondling
//
//  Created by Louis Tur on 11/15/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class SOMotionDetector,CMAttitude;

@protocol SRMotionManagerDelegate <NSObject>

-(void)attitudeHasUpdatedRoll:(CGFloat)roll withYaw:(CGFloat)yaw andPitch:(CGFloat)pitch;

@end

@interface SRMotionManager : NSObject

@property (strong, nonatomic) id<SRMotionManagerDelegate> delegate;
@property (strong, readonly, nonatomic) SOMotionDetector * sharedSODector;
@property (strong, nonatomic) NSString * currentMotionType;

+(instancetype) sharedFondler;
-(void)updateMotionType:(NSString *)motionType;


@end
