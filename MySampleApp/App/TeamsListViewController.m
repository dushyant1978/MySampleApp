//
//  TeamsListViewController.m
//  BuddyProject
//
//  Created by Dushyant.gaur on 10/31/15.
//  Copyright © 2015 Amazon. All rights reserved.
//

#import "TeamsListViewController.h"
#import <Parse/Parse.h>
#import "MainViewController.h"
#import "ChallengeViewController.h"

@interface TeamsListViewController () {
   NSMutableArray* mTeams;
}
@property (strong, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityView;

@end

@implementation TeamsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   [self getTeams];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) getTeams {
   [_mActivityView startAnimating];
   
   PFUser *user = [PFUser currentUser];
   if (user) {
      // User's location
      PFGeoPoint *userGeoPoint = user[@"currentLocation"];
      if(userGeoPoint) {
         // Create a query for places
         PFQuery *query = [PFQuery queryWithClassName:@"Teams"];
         // Interested in locations near user.
         double distanceInMiles = 1.0;
         
         [query whereKey:@"currentLocation" nearGeoPoint:userGeoPoint withinMiles:distanceInMiles];
         // Final list of objects
         [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
               // The find succeeded.
               [self foundTeams:objects];
               [_mActivityView stopAnimating];
            } else {
               // Log details of the failure
               NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
         }];
         
      }
   }
}

- (void)foundTeams:(NSArray*) itemsIDs {

   if (!mTeams) {
      mTeams = [[NSMutableArray alloc] initWithArray:itemsIDs];
   }
   [_mTableView reloadData];
   
   if ([mTeams count] <=0) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"BuddyProject", nil) message:NSLocalizedString(@"Oops!!! There are no teams around at this moment. Be the first to create your own team and start the game.",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
   }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mTeams count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamsCellId" forIndexPath:indexPath];
    
    // Configure the cell...
   if ([mTeams count]>0 && indexPath.row < [mTeams count]) {
      PFObject *anItem = [mTeams objectAtIndex:indexPath.row];
      if (anItem) {
         for(UIView *subview in cell.contentView.subviews)
         {
            if([subview isKindOfClass: [UIImageView class]])
            {
               UIImageView* imageView = (UIImageView*)subview;
               imageView.layer.cornerRadius = imageView.frame.size.width / 2;
               imageView.clipsToBounds = YES;
               PFFile *file = [anItem objectForKey:@"teamPic"];
               if (file) {
                  [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                     if (!error) {
                        UIImage* img = [UIImage imageWithData:data];
                        if(img) {
                           imageView.image = img;
                        }
                     }
                     else {
                        NSLog(@"Pic %@",[error description]);
                        UIImage* img = [UIImage imageNamed:@"gen_contact3.png"];
                        imageView.image = img;
                     }
                  }];
               }
               else {
                  UIImage* img = [UIImage imageNamed:@"gen_contact3.png"];
                  imageView.image = img;
               }
            }
            else if([subview isKindOfClass: [UILabel class]])
            {
               NSString* teamName = nil;
               if (anItem[@"name"]) {
                  teamName = anItem[@"name"];
               }
               else {
                  teamName = NSLocalizedString(@"Unknown",nil);
               }
               
               UILabel* label = (UILabel*)subview;
               label.text = teamName;
            }
         }
      }
   }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
   if ([mTeams count]>0 && indexPath.row < [mTeams count]) {
      PFObject *teamObject = [mTeams objectAtIndex:indexPath.row];
      if(_challengeMode) {
         NSLog(@"ChallengeMode");
         [self performSegueWithIdentifier: @"showChallenge" sender:self];
      }
      else {
         __block PFObject *activityObject = [PFObject objectWithClassName:@"Activity"];
         [activityObject setObject:[PFUser currentUser] forKey:@"User"];
         [activityObject setObject:teamObject forKey:@"Team"];
         activityObject[@"Type"] = @"Joined";
         [_mActivityView startAnimating];
         [activityObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            [_mActivityView stopAnimating];
            PFUser* currentUser = [PFUser currentUser];
            currentUser[@"currentTeam"] = teamObject;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
         }];
      }
   }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   
   if([segue.identifier isEqualToString:@"showChallenge"])
   {
      ChallengeViewController* list = [segue destinationViewController];
      PFObject *teamObject = [mTeams objectAtIndex:[_mTableView indexPathForSelectedRow].row];
      if(teamObject) {
         list.selectedTeam = teamObject;
      }
   }
}


@end
