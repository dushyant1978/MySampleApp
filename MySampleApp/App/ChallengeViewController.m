//
//  ChallengeViewController.m
//  BuddyProject
//
//  Created by Dushyant.gaur on 11/1/15.
//  Copyright © 2015 Amazon. All rights reserved.
//

#import "ChallengeViewController.h"

@interface ChallengeViewController () {
   NSArray* challenges;
   NSInteger index;
}
@property (weak, nonatomic) IBOutlet UILabel *challengeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation ChallengeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
   challenges = [NSArray arrayWithObjects:@"Challenge 1", @"Challenge 2",@"Challenge 3",@"Challenge 4",nil];
   index = 0;
   _challengeLabel.text = [NSString stringWithFormat:@"Challenge them to %@",[challenges objectAtIndex:index]];
   
   if (_selectedTeam) {
      NSString* name = [_selectedTeam objectForKey:@"name"];
      self.navigationItem.title = name;
   }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendChallenge:(id)sender {
   
      [_activityView startAnimating];
      PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
   
      [query whereKey:@"Team" equalTo:_selectedTeam];
      // Final list of objects
      [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (!error) {
            // The find succeeded.
            for (PFObject *anItem in objects) {
               PFUser* user = [anItem objectForKey:@"User"];
               PFQuery *pushQuery = [PFInstallation query];
               [pushQuery whereKey:@"User" equalTo:user];
               // Send push notification to query
               PFPush *push = [[PFPush alloc] init];
               [push setQuery:pushQuery]; // Set our Installation query

               PFUser *currentUser = [PFUser currentUser];
               PFObject* currentTeam = [currentUser objectForKey:@"currentTeam"];
               NSString* name = [currentTeam objectForKey:@"name"];
               
               NSString* string = [NSString stringWithFormat:@"%@ is around and just challenged you.",name];
               
               NSDictionary *data = @{
                                      @"alert" : string,
                                      @"sound" : @"default",
                                      @"sender" :name
                                      };
               [push setData:data];
               [push sendPushInBackground];
               
            }
            [_activityView stopAnimating];
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"BuddyProject" message:NSLocalizedString(@"Challenge sent successfully!",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
            [warningAlert show];
            
         } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
      }];
   
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)leftSwipe:(id)sender {
   //NSLog(@"leftSwipe");
   if (index < [challenges count]-1) {
      index++;
   }
   else {
      index=0;
   }
   _challengeLabel.text = [NSString stringWithFormat:@"Challenge them to %@",[challenges objectAtIndex:index]];
}

- (IBAction)rightSwipe:(id)sender {
   //NSLog(@"rightSwipe");
   if (index > 0) {
      index--;
   }
   else {
      index=[challenges count] -1;
   }
   _challengeLabel.text = [NSString stringWithFormat:@"Challenge them to %@",[challenges objectAtIndex:index]];
   
}

@end
