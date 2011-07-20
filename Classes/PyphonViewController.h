//
//  PyphonViewController.h
//  Pyphon
//
//  Created by Stefan Matthias Aust on 16.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "Parser.h"
#import "Runtime.h"

@interface PyphonViewController : UIViewController <PyphonDelegate> {
	IBOutlet UITextView *inputView;
	IBOutlet UITextView *outputView;
    NSInteger mode;
    Pyphon *pyphon;
}

- (IBAction)clearInput:(id)sender;
- (IBAction)evalInput:(id)sender;
- (IBAction)execInput:(id)sender;
- (IBAction)segmentedControlChanged:(id)sender;

@end

