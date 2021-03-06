//
//  GGKDayViewController.m
//  Dictator
//
//  Created by Geoff Hom on 8/23/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//
#import "GGKDayViewController.h"

#import "GGKGameModel.h"
#import "NSDate+GGKAdditions.h"
NSString *MoreTimeButtonTitleString = @"More Time";
NSString *NoDictatorAlertViewTitleString = @"No Dictator";
NSString *TimeIsUpAlertViewTitleString = @"Time's Up!";
@interface GGKDayViewController ()
// This timer goes off each second and serves two purposes: 1) The user can get frequent visual feedback, e.g., for timers she sees. 2) We can track number of seconds passed/remaining.
// Need this property to invalidate the timer later.
@property (nonatomic, strong) NSTimer *countingTimer;
@property (nonatomic, strong) NSArray *electablePlayersArray;
// Alert verifying whether to elect no dictator.
// Need this to dismiss programmatically.
@property (nonatomic, strong) UIAlertView *noDictatorAlertView;
// The number of seconds remaining until the dictator election is skipped.
@property (nonatomic, assign) NSInteger numberOfSecondsToElectDictator;
// Make sure current timer doesn't fire anymore.
- (void)cancelCountingTimer;
// User can see the time remaining to elect dictator.
// The timer fired, so update the time remaining. Check if time is up.
- (void)handleCountingTimerFired;
@end

@implementation GGKDayViewController
- (void)alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)theButtonIndex {
    [super alertView:theAlertView clickedButtonAtIndex:theButtonIndex];
    // If no dictator, go to night. If time up, go to night. If time up but canceled, use a shorter timer.
    if ([theAlertView.title isEqualToString:NoDictatorAlertViewTitleString]) {
        if ([[theAlertView buttonTitleAtIndex:theButtonIndex] isEqualToString:@"OK"]) {
            self.gameModel.currentDictatorPlayer = nil;
            [self performSegueWithIdentifier:@"ShowNightSegue" sender:self];
        }
    } else if ([theAlertView.title isEqualToString:TimeIsUpAlertViewTitleString]) {
        if ([[theAlertView buttonTitleAtIndex:theButtonIndex] isEqualToString:@"OK"]) {
            self.gameModel.currentDictatorPlayer = nil;
            [self performSegueWithIdentifier:@"ShowNightSegue" sender:self];
        } else if ([[theAlertView buttonTitleAtIndex:theButtonIndex] isEqualToString:MoreTimeButtonTitleString]) {
            self.numberOfSecondsToElectDictator = 60;
            self.electDictatorTimerLabel.text = [NSDate ggk_minuteSecondStringForTimeInterval:self.numberOfSecondsToElectDictator];
            NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleCountingTimerFired) userInfo:nil repeats:YES];
            self.countingTimer = aTimer;
        }
    }
}
- (void)cancelCountingTimer {
    [self.countingTimer invalidate];
    self.countingTimer = nil;
}
- (IBAction)electDictator {
    // Selected player is dictator.
    NSIndexPath *anIndexPath = [self.playersTableView indexPathForSelectedRow];
    GGKPlayer *aPlayer = [self.electablePlayersArray objectAtIndex:anIndexPath.row];
    self.gameModel.currentDictatorPlayer = aPlayer;
    self.gameModel.currentPlayer = aPlayer;
    self.gameModel.hermitWasDictator = NO;
    // If Hermit, then Traitors don't get night elimination.
    if ([aPlayer.role.key isEqualToString:GGKHermitKeyString]) {
        self.gameModel.hermitWasDictator = YES;
    }
    [self performSegueWithIdentifier:@"ShowDictatorElectedSegue" sender:self];
}
- (void)handleCountingTimerFired {
    // Update time remaining for election.
    self.numberOfSecondsToElectDictator -= 1;
    self.electDictatorTimerLabel.text = [NSDate ggk_minuteSecondStringForTimeInterval:self.numberOfSecondsToElectDictator];
    // If time is up, ask if no dictator.
    if (self.numberOfSecondsToElectDictator == 0) {
        [self cancelCountingTimer];
        // Dismiss any other alert views so they don't stack.
        [self.noDictatorAlertView dismissWithClickedButtonIndex:0 animated:NO];
        [self.quitGameAlertView dismissWithClickedButtonIndex:0 animated:NO];
        UIAlertView *anAlertView = [[UIAlertView alloc] initWithTitle:TimeIsUpAlertViewTitleString message:@"Skip dictator election and go directly to night phase?" delegate:self cancelButtonTitle:MoreTimeButtonTitleString otherButtonTitles:@"OK", nil];
        [anAlertView show];
    }
}
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath {
    static NSString *PlayerCellIdentifier = @"PlayerNameCell";
    UITableViewCell *aTableViewCell = [theTableView dequeueReusableCellWithIdentifier:PlayerCellIdentifier];
    if (aTableViewCell == nil) {
        aTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PlayerCellIdentifier];
    }
//    GGKPlayer *aPlayer = [self.gameModel.remainingPlayersMutableArray objectAtIndex:theIndexPath.row];
    GGKPlayer *aPlayer = [self.electablePlayersArray objectAtIndex:theIndexPath.row];
    aTableViewCell.textLabel.text = aPlayer.name;
    
    return aTableViewCell;
}
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)theIndexPath {
    self.electDictatorButton.enabled = YES;
}
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)theSection {
    return [self.electablePlayersArray count];
}
- (IBAction)verifyNoDictator {
    UIAlertView *anAlertView = [[UIAlertView alloc] initWithTitle:NoDictatorAlertViewTitleString message:@"Skip election and go directly to night phase?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [anAlertView show];
    self.noDictatorAlertView = anAlertView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.electablePlayersArray = [self.gameModel electablePlayersArray];
    NSInteger theNumberOfPlayersInteger = [self.gameModel.remainingPlayersMutableArray count];
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfPlayersInteger];
    NSInteger theNumberOfVotesNeededInteger = (theNumberOfPlayersInteger / 2) + 1;
    self.numberOfVotesNeededLabel.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfVotesNeededInteger];
    self.noDictatorButton.enabled = YES;
    if (self.gameModel.electionHasTimeLimitBOOL) {
        self.electDictatorTimerLabel.hidden = NO;
        self.numberOfSecondsToElectDictator = 60 * 3;
        self.electDictatorTimerLabel.text = [NSDate ggk_minuteSecondStringForTimeInterval:self.numberOfSecondsToElectDictator];
        // Start counting timer.
        NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleCountingTimerFired) userInfo:nil repeats:YES];
        self.countingTimer = aTimer;
    } else {
        self.electDictatorTimerLabel.hidden = YES;
    }
    self.electDictatorButton.enabled = NO;
    self.navigationItem.hidesBackButton = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancelCountingTimer];
}
@end
