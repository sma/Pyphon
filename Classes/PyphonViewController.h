//
//  PyphonViewController.h
//  Pyphon
//
//  Created by Stefan Matthias Aust on 16.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parser.h"

@interface PyphonViewController : UIViewController <PyphonDelegate> {
	IBOutlet UITextView *inputView;
	IBOutlet UITextView *outputView;
}

- (IBAction)clearInput:(id)sender;
- (IBAction)evalInput:(id)sender;
- (IBAction)execInput:(id)sender;

@end

