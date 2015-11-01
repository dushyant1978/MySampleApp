//
//  ProfileViewController.h
//  BuddyProject
//
//  Created by Dushyant on 30/10/15.
//  Copyright (c) 2015 Dushyant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateTeamViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
   UIImagePickerController *ipc;
   UIPopoverController *popover;
}
@property (nonatomic, unsafe_unretained) IBOutlet UIActivityIndicatorView* mActivityView;
@property (nonatomic,strong) NSString* mName;
@property (nonatomic,strong) UIImage* mImage;
@end
