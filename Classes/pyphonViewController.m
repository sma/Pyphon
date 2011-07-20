//
//  PyphonViewController.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 16.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "PyphonViewController.h"
#import "Tester.h"


@implementation PyphonViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	inputView.text = @"print(3+4)";
    
    outputView.text = [Tester run];
    
    mode = 0;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIView *buttonsView = [self.view.subviews objectAtIndex:1];
    UIView *segmentedControlView = [buttonsView.subviews lastObject];
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        inputView.frame = CGRectMake(5, 5, 470, 90);
        buttonsView.frame =CGRectMake(5, 100, 470, 45);
        segmentedControlView.frame = CGRectMake(300, 8, 170, 30);
        outputView.frame = CGRectMake(5, 145, 470, 150);
    } else {
        inputView.frame = CGRectMake(5, 5, 310, 120);
        buttonsView.frame =CGRectMake(40, 130, 240, 75);
        segmentedControlView.frame = CGRectMake(3, 45, 234, 30);
        outputView.frame = CGRectMake(5, 210, 310, 245);
    }
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



#pragma mark -
#pragma mark running Pyphon code

- (void)_appendStringToOutputView:(NSString *)string {
	outputView.text = [outputView.text stringByAppendingFormat:@"%@\n", string];
}

- (IBAction)clearInput:(id)sender {
	inputView.text = @"";
	outputView.text = @"";
}

- (IBAction)evalInput:(id)sender {
	[inputView resignFirstResponder];

	Parser *parser = [[Parser alloc] initWithString:inputView.text];
    Expr *expr;
    @try {
        expr = [parser parse_test];
    }
    @catch (NSException *exception) {
        [self _appendStringToOutputView:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
        return;
    }
    @finally {
    }
    
    if (mode) {
        [self _appendStringToOutputView:[expr description]];
        return;
    }
    
	Frame *frame = [[Pyphon sharedInstance] newInitialFrame];
	[Pyphon sharedInstance].delegate = self;
    @try {
        Value *result = [expr evaluate:frame];
        if (frame.resultType) {
            @throw [NSException exceptionWithName:[result __repr__] reason:nil userInfo:nil];
        }
        [self _appendStringToOutputView:[result __repr__]];
    }
    @catch (NSException *exception) {
        [self _appendStringToOutputView:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
        return;
    }
    @finally {
    }
}

- (IBAction)execInput:(id)sender {
	[inputView resignFirstResponder];
	
	Parser *parser = [[Parser alloc] initWithString:inputView.text];
	Suite *suite;
    @try {
        suite = [parser parse_file];
    }
    @catch (NSException *exception) {
        [self _appendStringToOutputView:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
        return;
    }
    @finally {
    }
    
    if (mode) {
        [self _appendStringToOutputView:[suite description]];
        return;
    }
	
	Frame *frame = [[Pyphon sharedInstance] newInitialFrame];
	[Pyphon sharedInstance].delegate = self;
    @try {
        [suite evaluate:frame];
    }
    @catch (NSException *exception) {
        [self _appendStringToOutputView:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
        return;
    }
    @finally {
    }
}

- (IBAction)segmentedControlChanged:(id)sender {
    mode = ((UISegmentedControl *)sender).selectedSegmentIndex;
}

// PyphonDelegate callback (needs better name)
- (void)print:(NSString *)string {
	[self _appendStringToOutputView:string];
}

@end
