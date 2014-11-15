//
//  SRMotionManager.h
//  Fondling
//
//  Created by Louis Tur on 11/15/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SOMotionDetector;
@interface SRMotionManager : NSObject

@property (strong, readonly, nonatomic) SOMotionDetector * sharedSODector;
@property (strong, nonatomic) NSString * currentMotionType;

+(instancetype) sharedFondler;
-(void)updateMotionType:(NSString *)motionType;


@end
