//
//  Token.h
//  Pyphon
//
//  Created by Stefan Matthias Aust on 15.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Token : NSObject {
	NSString *source;
	NSRange range;
}

+ (NSArray *)tokenizeString:(NSString *)string;
+ (Token *)EOFToken;
+ (Token *)indentToken;
+ (Token *)dedentToken;

- (id)initWithSource:(NSString *)source range:(NSRange)range;
- (BOOL)isEqualToString:(NSString *)string;
- (BOOL)isNumber;
- (BOOL)isString;
- (NSNumber *)numberValue;
- (NSString *)stringValue;
- (NSString *)stringByUnescapingStringValue;
- (unichar)firstCharacter;
- (NSUInteger)lineNumber;

@end
