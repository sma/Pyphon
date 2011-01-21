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

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
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
        [parser release];
    }
    
    if (mode) {
        [self _appendStringToOutputView:[expr description]];
        return;
    }
	
	Frame *frame = [Frame newInitial];
	frame.delegate = self;
    @try {
        NSString *result = [[expr evaluate:frame] __repr__];
        [self _appendStringToOutputView:result];
    }
    @catch (NSException *exception) {
        [self _appendStringToOutputView:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
        return;
    }
    @finally {
        [frame release];
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
        [parser release];
    }
    
    if (mode) {
        [self _appendStringToOutputView:[suite description]];
        return;
    }
	
	Frame *frame = [Frame newInitial]; // TODO name does not match objc conventions
	frame.delegate = self;
    @try {
        [suite execute:frame];
    }
    @catch (NSException *exception) {
        [self _appendStringToOutputView:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
        return;
    }
    @finally {
        [frame release];
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
