//
//  Parser.h
//  Pyphon
//
//  Created by Stefan Matthias Aust on 15.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Token.h"
#import "AST.h"

@interface Parser : NSObject {
	NSArray *tokens;
	NSInteger index;
}

- (id)initWithString:(NSString *)source;
- (Token *)token;
- (void)advance;
- (BOOL)at:(NSString *)token;
- (void)expect:(NSString *)token;

- (Expr *)parse_test;
- (Suite *)parse_suite;
- (Suite *)parse_file;

@end
