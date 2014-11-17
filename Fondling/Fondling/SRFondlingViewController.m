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
#import <JBChartView/JBLineChartView.h>

@interface SRFondlingViewController ()<JBLineChartViewDataSource, JBLineChartViewDelegate, SRMotionManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *descriptionContainerView;
@property (weak, nonatomic) IBOutlet UILabel *motionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *motionDescriptionLabel_1;
@property (weak, nonatomic) IBOutlet UILabel *mptionDescriptionLabel_2;
@property (weak, nonatomic) IBOutlet UIView *chartView;

@property (strong, nonatomic) SRMotionManager * fondleManager;

@property (strong, nonatomic) JBLineChartView * lineChart;

@property (strong, nonatomic) NSMutableArray *rollValues;
@property (strong, nonatomic) NSMutableArray *yawValues;
@property (strong, nonatomic) NSMutableArray *pitchValues;

@end

@implementation SRFondlingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelsWithMotions:) name:@"fondleChange" object:nil];
    
    self.yawValues = [NSMutableArray array];
    self.rollValues = [NSMutableArray array];
    self.pitchValues = [NSMutableArray array];

    
    [self.motionTitleLabel setAdjustsFontSizeToFitWidth:YES];
    
    self.fondleManager = [SRMotionManager sharedFondler];
    [self.fondleManager.sharedSODector startDetection];
    
    self.fondleManager.delegate = self;
    
    self.lineChart = [[JBLineChartView alloc] initWithFrame:self.chartView.frame];
    self.lineChart.dataSource = self;
    self.lineChart.delegate = self;
    
    [self.lineChart setMinimumValue:0.0];
    [self.lineChart setMaximumValue:2.0];
    
    [self.chartView addSubview:self.lineChart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateLabelsWithMotions:(NSNotification *)sender {
    
    [UIView animateWithDuration:1.0f
                     animations:^{
                         self.motionTitleLabel.text = [sender.userInfo valueForKey:@"motion"];
    } completion:^(BOOL finished) {
    }];

}

// -- SRMotionManager Delegate -- //

-(void)attitudeHasUpdatedRoll:(CGFloat)roll withYaw:(CGFloat)yaw andPitch:(CGFloat)pitch{
    
    [self pruneData];
    
    [self.pitchValues addObject:[NSNumber numberWithFloat: pitch]];
    [self.yawValues addObject:[NSNumber numberWithFloat:yaw]];
    [self.rollValues addObject:[NSNumber numberWithFloat:roll]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.lineChart reloadData];
    }];
    
}
-(void) pruneData{
    
    while ([self.pitchValues count] > 50) {
        [self.pitchValues removeObjectAtIndex:0];
    }
    while ([self.rollValues count] > 50) {
        [self.rollValues removeObjectAtIndex:0];
    }
    while ([self.yawValues count] > 50) {
        [self.yawValues removeObjectAtIndex:0];
    }
    
}

// -- Delegate Methods -- //
-(NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView{
    return 3;
}
-(CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex{
    return 1.2;
}
-(NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex{
    
    return [self.pitchValues count];
}
-(UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex{
    if (lineIndex == 0) {
        return [UIColor redColor];
    }else if (lineIndex == 1){
        return [UIColor blueColor];
    }else{
        return [UIColor orangeColor];
    }
}

// -- DataSource Methods -- //

-(CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex{
    
        
    switch (lineIndex) {
        case 0://roll
            return [self.rollValues[horizontalIndex] floatValue];
        case 1://pitch
            return [self.pitchValues[horizontalIndex] floatValue];
        case 2://yaw
            return [self.yawValues[horizontalIndex] floatValue];
        default:
        {
            NSLog(@"Wrong info!");
            return 0.0;
        }
    }
}

-(BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex{
    return YES;
}
@end
