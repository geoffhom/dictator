//
//  GGKNightSummaryViewController.h
//  Dictator
//
//  Created by Geoff Hom on 2/11/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKViewController.h"

@interface GGKNightSummaryViewController : GGKViewController
// Text view for reporting what happened last night.
@property (strong, nonatomic) IBOutlet UITextView *summaryTextView;
// Override.
- (void)viewDidLoad;
@end
