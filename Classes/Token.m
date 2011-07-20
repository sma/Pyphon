//
//  Token.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 15.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "Token.h"

#define RE @"(?m)^ *(?:#.*)?\n|#.*$|(^ +|\n|\\d+|\\w+|[()\\[\\]{}:.,;]|[+\\-*/%<>=]=?|!=|'(?:\\\\[n'\"\\\\]|[^'])*'|\"(?:\\\\[n'\"\\\\]|[^\"])*\")"


@implementation Token

+ (NSArray *)tokenizeString:(NSString *)source {
	NSMutableArray *tokens = [NSMutableArray array];
	__block NSInteger cur_indent = 0;
	__block NSInteger new_indent = 0;
	
	// combine lines with trailing backslashes with following lines
	source = [source stringByReplacingOccurrencesOfString:@"\\\n" withString:@""];
	
	// assure that the source ends with a newline
	source = [source stringByAppendingString:@"\n"];
	
	// compile the regular expression to tokenize the source
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:RE options:0 error:nil];
	
	// process matches from source when applying the regular expression
	[regex enumerateMatchesInString:source 
							options:0 
							  range:NSMakeRange(0, [source length]) 
						 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
							 // did we get a match (empty lines and comments are ignored)?
							 NSRange range = [match rangeAtIndex:1];
							 if (range.location != NSNotFound) {
								 unichar ch = [source characterAtIndex:range.location];
								 if (ch == ' ') {
									 // compute new indentation which is applied before the next non-whitespace token
									 new_indent = range.length / 4;
								 } else {
									 if (ch == '\n') {
										 // reset indentation
										 new_indent = 0;
									 } else {
										 // found a non-whitespace token, apply new indentation
										 while (cur_indent < new_indent) {
											 [tokens addObject:[Token indentToken]];
											 cur_indent += 1;
										 }
										 while (cur_indent > new_indent) {
											 [tokens addObject:[Token dedentToken]];
											 cur_indent -= 1;
										 }
									 }
									 // add newline or non-whitespace token to result
                                     Token *token = [[Token alloc] initWithSource:source range:range];
									 [tokens addObject:token];
								 }
							 }
						 }];
	
	// balance pending INDENTs
	while (cur_indent > 0) {
		[tokens addObject:[Token dedentToken]];
		cur_indent -= 1;
	}
	
	// return the tokens
	return [tokens copy];
}

+ (Token *)indentToken {
	static Token *indentToken = nil;
	if (!indentToken) {
		indentToken = [[Token alloc] initWithSource:@"!INDENT" range:NSMakeRange(0, 7)];
	}
	return indentToken;
}

+ (Token *)dedentToken {
	static Token *dedentToken = nil;
	if (!dedentToken) {
		dedentToken = [[Token alloc] initWithSource:@"!DEDENT" range:NSMakeRange(0, 7)];
	}
	return dedentToken;
}

+ (Token *)EOFToken {
	static Token *EOFToken = nil;
	if (!EOFToken) {
		EOFToken = [[Token alloc] initWithSource:@"!EOF" range:NSMakeRange(0, 4)];
	}
	return EOFToken;
}

- (id)initWithSource:(NSString *)source_ range:(NSRange)range_ {
    if ((self = [super init])) {
        self->source = source_;
        self->range = range_;
    }
	return self;
}

- (BOOL)isEqualToString:(NSString *)string {
	return [[self stringValue] isEqualToString:string];
}

- (BOOL)isNumber {
    return isdigit([self firstCharacter]);
}

- (BOOL)isString {
    return '"' == [self firstCharacter] || '\'' == [self firstCharacter];
}

- (NSNumber *)numberValue {
    return [NSNumber numberWithInteger:[[self stringValue] integerValue]];
}

- (NSString *)stringValue {
	return [source substringWithRange:range];
}

- (NSString *)stringByUnescapingStringValue {
    NSUInteger length = range.length - 2;
    NSString *string = [source substringWithRange:NSMakeRange(range.location + 1, length)];
    NSMutableString *buffer = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        unichar c = [string characterAtIndex:i];
        if (c == '\\') {
            c = [string characterAtIndex:++i];
            if (c == 'n') {
                c = '\n';
            }
        }
        [buffer appendFormat:@"%c", c];
    }
    return buffer;
}

- (unichar)firstCharacter {
    return [source characterAtIndex:range.location];
}

- (NSUInteger)lineNumber {
	NSUInteger lineNumber = 1;
	NSUInteger start = 0;
	NSRange r;
	while ((r = [source rangeOfString:@"\n" 
							  options:0 
								range:NSMakeRange(start, [source length] - start)]).location != NSNotFound) {
		start = r.location + r.length;
		if (range.location < start) {
			return lineNumber;
		}
		lineNumber += 1;
	}
	return lineNumber;
}

@end
