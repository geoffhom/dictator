//
//  GGKNightSummaryViewController.m
//  Dictator
//
//  Created by Geoff Hom on 2/11/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKNightSummaryViewController.h"

#import "GGKGameModel.h"

@interface GGKNightSummaryViewController ()
@end

@implementation GGKNightSummaryViewController
- (IBAction)goToDayOrEnd {
    if ([self.gameModel isGameOver]) {
        [self performSegueWithIdentifier:@"ShowGameOverSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"ShowDaySegue" sender:self];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    // Report what happened last night.
    [self.gameModel calculateNightSummary];
    BOOL someoneWasEliminated = NO;
    NSArray *thePlayersEliminatedLastNightArray = self.gameModel.playersEliminatedLastNightArray;
    NSMutableString *theSummaryTextMutableString = [NSMutableString stringWithString:@"Reveal this to all:"
                                                    @"\n\nLast night … "];
    if (self.gameModel.doJudgeExileDictatorBOOL) {
        GGKPlayer *theDictatorPlayer = self.gameModel.currentDictatorPlayer;
        [theSummaryTextMutableString appendFormat:@"\n\nA Judge %@ Dictator %@!"
         "\n%@ was %@.", GGKExiledString, theDictatorPlayer.name, theDictatorPlayer.name, theDictatorPlayer.role.longNameWithArticle];
    }
    if ([thePlayersEliminatedLastNightArray count] >= 1) {
        someoneWasEliminated = YES;
        // If there was a voting tie, note that.
        NSString *theTieTextString = @"";
        if (self.gameModel.thereWasATieBOOL) {
            // "Last night, whispered arguments were heard … and %@ was eliminated!"
            theTieTextString = @"Whispered arguments were heard … and ";
        }
        // For now, assume the Traitors can eliminate only 0 or 1 players.
        GGKPlayer *theEliminatedPlayer = thePlayersEliminatedLastNightArray[0];
        [theSummaryTextMutableString appendFormat:@"\n\n%@%@ was %@!"
                                       "\n%@ was %@.", theTieTextString, theEliminatedPlayer.name, GGKEliminatedString, theEliminatedPlayer.name, theEliminatedPlayer.role.longNameWithArticle];
    }
    NSArray *thePlayersVigilanteEliminatedLastNightArray = self.gameModel.playersVigilanteEliminatedLastNightArray;
    if ([thePlayersVigilanteEliminatedLastNightArray count] >= 1) {
        someoneWasEliminated = YES;
        for (GGKPlayer *anEliminatedPlayer in thePlayersVigilanteEliminatedLastNightArray) {
            [theSummaryTextMutableString appendFormat:@"\n\n%@ was %@ by Vigilantes!"
             "\n%@ was %@.", anEliminatedPlayer.name, GGKEliminatedString, anEliminatedPlayer.name, anEliminatedPlayer.role.longNameWithArticle];
        }
    }
    if (!someoneWasEliminated) {
        [theSummaryTextMutableString appendFormat:@"\n\nNo one was %@….", GGKEliminatedString];
    }
    self.summaryTextView.text = theSummaryTextMutableString;
}
@end
