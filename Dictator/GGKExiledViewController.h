//
//  GGKExiledViewController.h
//  Dictator
//
//  Created by Geoff Hom on 2/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GGKViewController.h"

@interface GGKExiledViewController : GGKViewController
// Label for showing who was exiled.
@property (strong, nonatomic) IBOutlet UILabel *exiledPlayerLabel;
// For showing the exiled player's role.
@property (weak, nonatomic) IBOutlet UITextView *exiledRoleTextView;
// If game over, end. Else, go to Night phase.
- (IBAction)goToNightOrEnd;
// Override.
- (void)viewDidLoad;
@end
