//
//  GGKExiledViewController.m
//  Dictator
//
//  Created by Geoff Hom on 2/4/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKExiledViewController.h"

#import "GGKGameModel.h"

@interface GGKExiledViewController ()
@end

@implementation GGKExiledViewController
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    GGKPlayer *theExiledPlayer = self.gameModel.currentlySelectedPlayer;
    self.exiledPlayerLabel.text = [NSString stringWithFormat:@"%@ was exiled!", theExiledPlayer.name];
    self.exiledRoleLabel.text = [NSString stringWithFormat:@"%@ was %@.", theExiledPlayer.name, theExiledPlayer.role.longNameWithArticle];
}
@end