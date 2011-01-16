//
//  PyphonAppDelegate.h
//  Pyphon
//
//  Created by Stefan Matthias Aust on 16.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PyphonViewController;

@interface PyphonAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PyphonViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PyphonViewController *viewController;

@end

