//
//  SRFondlingViewController.m
//  Fondling
//
//  Created by Louis Tur on 11/15/14.
//  Copyright (c) 2014 com.SRLabs. All rights reserved.
//
#import "SRMotionManager.h"
#import <SOMotionDetector/SOMotionDetector.h>
#import "SRFondlingViewController.h"
#import <FontAwesomeKit/FAKFontAwesome.h>

@interface SRFondlingViewController ()
@property (weak, nonatomic) IBOutlet UIView *descriptionContainerView;
@property (weak, nonatomic) IBOutlet UILabel *motionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *motionDescriptionLabel_1;
@property (weak, nonatomic) IBOutlet UILabel *mptionDescriptionLabel_2;

@property (strong, nonatomic) SRMotionManager * fondleManager;

@end

@implementation SRFondlingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelsWithMotions) name:@"motionChange" object:nil];
    
    [self.motionTitleLabel setAdjustsFontSizeToFitWidth:YES];
    
    self.fondleManager = [SRMotionManager sharedFondler];
    [self.fondleManager.sharedSODector startDetection];
    
    self.motionTitleLabel.text = @"Are you fondling?";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateLabelsWithMotions{
    
    [UIView animateWithDuration:1.0f
                     animations:^{
        self.motionTitleLabel.text = self.fondleManager.currentMotionType;
    } completion:^(BOOL finished) {
        NSLog(@"Animation Done");
    }];

    
    
}
@end
