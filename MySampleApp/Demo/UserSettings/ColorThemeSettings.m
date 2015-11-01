//
//  ColorThemeSettings.m
//
//
// Copyright 2015 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//

#import <Foundation/Foundation.h>
#import "ColorThemeSettings.h"
#import <AWSCognito/AWSCognitoSyncService.h>
#import "AWSConfiguration.h"
#import "AWSIdentityManager.h"
#import "AWSTask+CheckExceptions.h"

NSString *const ColorThemeSettingsTitleTextColorKey = @"title_text_color";
NSString *const ColorThemeSettingsTitleBarColorKey = @"title_bar_color";
NSString *const ColorThemeSettingsBackgroundColorKey = @"background_color";

int const ColorThemeSettingsDefaultTitleTextColor = 0xFFFFFFFF;
int const ColorThemeSettingsDefaultTitleBarColor = 0xFFF58535;
int const ColorThemeSettingsDefaultBackgroundColor = 0xFFFFFFFF;

@interface ColorThemeSettings ()

@end

@interface AWSTask (AWSTaskSimplified)

- (void)checkException;

@end

@implementation ColorThemeSettings

+ (instancetype)sharedInstance {
    static ColorThemeSettings *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [ColorThemeSettings new];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _theme = [Theme new];
    }
    return self;
}

#pragma mark - User Settings Functions

- (void)loadSettings:(void (^)(ColorThemeSettings *, NSError *))completionBlock {
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *userSettings = [syncClient openOrCreateDataset:@"user_settings"];
    [[userSettings synchronize] continueWithExceptionCheckingBlock:^(id result, NSError *error) {
        if (error) {
            AWSLogError(@"loadSettings AWS task error: %@", [error localizedDescription]);
            if (completionBlock) {
                completionBlock(nil, error);
            }
            return;
        }

        NSString *titleTextColorString = [userSettings stringForKey:ColorThemeSettingsTitleTextColorKey];
        NSString *titleBarColorString = [userSettings stringForKey:ColorThemeSettingsTitleBarColorKey];
        NSString *backgroundColorString = [userSettings stringForKey:ColorThemeSettingsBackgroundColorKey];
        if (titleTextColorString
            && titleBarColorString
            && backgroundColorString) {
            self.theme = [[Theme alloc] initWithTitleTextColor:[titleTextColorString intValue]
                                             withTitleBarColor:[titleBarColorString intValue]
                                           withBackgroundColor:[backgroundColorString intValue]];
        } else {
            self.theme = [Theme new];
        }

        if (completionBlock) {
            completionBlock(self, error);
        }
    }];
}

- (void)saveSettings:(void (^)(ColorThemeSettings *, NSError *))completionBlock {
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *userSettings = [syncClient openOrCreateDataset:@"user_settings"];

    [userSettings setString:[NSString stringWithFormat:@"%d", self.theme.titleTextColor]
                          forKey:ColorThemeSettingsTitleTextColorKey];
    [userSettings setString:[NSString stringWithFormat:@"%d", self.theme.titleBarColor]
                          forKey:ColorThemeSettingsTitleBarColorKey];
    [userSettings setString:[NSString stringWithFormat:@"%d", self.theme.backgroundColor]
                          forKey:ColorThemeSettingsBackgroundColorKey];
    [[userSettings synchronize] continueWithExceptionCheckingBlock:^(id result, NSError *error) {
        if (!result) {
            AWSLogError(@"saveSettings AWS task error: %@", [error localizedDescription]);
        }

        if (completionBlock) {
            completionBlock(self, error);
        }
    }];
}

- (void)wipe {
    [[AWSCognito defaultCognito] wipe];
}

@end

@implementation Theme

- (instancetype)init {
    if (self = [super init]) {
        _titleTextColor = ColorThemeSettingsDefaultTitleTextColor;
        _titleBarColor = ColorThemeSettingsDefaultTitleBarColor;
        _backgroundColor = ColorThemeSettingsDefaultBackgroundColor;
    }

    return self;
}

- (instancetype)initWithTitleTextColor:(int)titleTextColor
                     withTitleBarColor:(int)titleBarColor
                   withBackgroundColor:(int)backgroundColor {
    if (self = [super init]) {
        _titleBarColor = titleBarColor;
        _titleTextColor = titleTextColor;
        _backgroundColor = backgroundColor;
    }
    return self;
}

@end
