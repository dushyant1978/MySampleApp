//
//  ChallengeViewController.h
//  BuddyProject
//
//  Created by Dushyant.gaur on 11/1/15.
//  Copyright © 2015 Amazon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChallengeViewController : UIViewController
   

@property (strong,nonatomic) PFObject* selectedTeam;
@end
