//
//  ProfileViewController.m
//  BuddyProject
//
//  Created by Dushyant on 30/10/15.
//  Copyright (c) 2015 Dushyant. All rights reserved.
//

#import "CreateTeamViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface CreateTeamViewController () {
   BOOL isImageChanged;
}

@property (weak, nonatomic) IBOutlet UIImageView *mTeamImageView;
@property (weak, nonatomic) IBOutlet UIButton *mAddPictureButton;
@property (weak, nonatomic) IBOutlet UIButton *mDoneButton;
@property (weak, nonatomic) IBOutlet UITextField *mTeamNameField;
-(IBAction)OnDone:(id)sender;
-(IBAction)OnPicEdit:(id)sender;
@end

@implementation CreateTeamViewController

@synthesize mImage;
@synthesize mName;

- (void)viewDidLoad {
   // Do any additional setup after loading the view.
   [_mActivityView stopAnimating];
   isImageChanged = NO;
   [super viewDidLoad];
   self.navigationItem.hidesBackButton = TRUE;
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

-(IBAction)OnDone:(id)sender {
   if(_mTeamNameField.text && [_mTeamNameField.text length] > 0) {
      [_mActivityView startAnimating];
      [_mAddPictureButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
      [_mDoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
      
      _mAddPictureButton.enabled = NO;
      _mDoneButton.enabled = NO;
      
      __block PFObject *teamObject = [PFObject objectWithClassName:@"Teams"];
      teamObject[@"name"] = _mTeamNameField.text;
      
      PFUser *user = [PFUser currentUser];
      if (user) {
         // User's location
         PFGeoPoint *geoPoint = user[@"currentLocation"];
         if(geoPoint) {
            teamObject[@"currentLocation"] = geoPoint;
         }
      }
      
      if (self.mImage && isImageChanged) {
         NSData *imageData = UIImageJPEGRepresentation(self.mImage,0.5);
         NSString* imageName = [NSString stringWithFormat:@"%@-%@.png",_mTeamNameField.text,[PFUser currentUser].username];
         __block PFFile *imageFile = [PFFile fileWithName:imageName data:imageData];
         [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            [teamObject setObject:imageFile forKey:@"teamPic"];
            [teamObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
               __block PFObject *activityObject = [PFObject objectWithClassName:@"Activity"];
               [activityObject setObject:[PFUser currentUser] forKey:@"User"];
               [activityObject setObject:teamObject forKey:@"Team"];
               activityObject[@"Type"] = @"Created";
               [activityObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                  [_mActivityView stopAnimating];
                  PFUser* currentUser = [PFUser currentUser];
                  currentUser[@"currentTeam"] = teamObject;
                  [self.navigationController popViewControllerAnimated:YES];
               }];
            }];
         }];
      }
      else {
         [teamObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            __block PFObject *activityObject = [PFObject objectWithClassName:@"Activity"];
            [activityObject setObject:[PFUser currentUser] forKey:@"User"];
            [activityObject setObject:teamObject forKey:@"Team"];
            activityObject[@"Type"] = @"Created";
            [activityObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
               [_mActivityView stopAnimating];
               PFUser* currentUser = [PFUser currentUser];
               currentUser[@"currentTeam"] = teamObject;
               [self.navigationController popViewControllerAnimated:YES];
            }];
         }];
      }
   }
   else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Give a name to your team to proceed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
      alert = nil;
   }
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}


-(IBAction)OnPicEdit:(id)sender {
   
   ipc = nil;
   ipc = [[UIImagePickerController alloc] init];
   ipc.delegate = self;
   if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
   {
      ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
      ipc.cameraDevice = UIImagePickerControllerCameraDeviceFront;
      if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
         [self presentViewController:ipc animated:YES completion:NULL];
      }
      else
      {
         popover = nil;
         popover=[[UIPopoverController alloc]initWithContentViewController:ipc];
         [popover presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
      }
   }
   else
   {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No Camera Available." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
      [alert show];
      alert = nil;
   }
   

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   [textField resignFirstResponder];
   return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
   
   [UIView beginAnimations:nil context:NULL];
   [UIView setAnimationDuration:0.25];
   CGRect rect = self.view.frame;
   rect.origin.y = rect.origin.y - 70;
   [self.view setFrame:rect];
   [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
   [UIView beginAnimations:nil context:NULL];
   [UIView setAnimationDuration:0.25];
   CGRect rect = self.view.frame;
   rect.origin.y = rect.origin.y + 70;
   [self.view setFrame:rect];
   [UIView commitAnimations];
}



- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
   return YES;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - ImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
      [picker dismissViewControllerAnimated:YES completion:nil];
   } else {
      [popover dismissPopoverAnimated:YES];
   }
   self.mImage = nil;
   self.mImage = [info objectForKey:UIImagePickerControllerOriginalImage];
   isImageChanged = YES;
   _mTeamImageView.image = self.mImage;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
   [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
