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
									 [tokens addObject:[Token tokenWithSource:source range:range]];
								 }
							 }
						 }];
	
	// balance pending INDENTs
	while (cur_indent > 0) {
		[tokens addObject:[Token dedentToken]];
		cur_indent -= 1;
	}
	
	// return the tokens
	return [[tokens copy] autorelease];
}

+ (Token *)indentToken {
	static Token *indentToken = nil;
	if (!indentToken) {
		indentToken = [[Token tokenWithSource:@"!INDENT" range:NSMakeRange(0, 7)] retain];
	}
	return indentToken;
}

+ (Token *)dedentToken {
	static Token *dedentToken = nil;
	if (!dedentToken) {
		dedentToken = [[Token tokenWithSource:@"!DEDENT" range:NSMakeRange(0, 7)] retain];
	}
	return dedentToken;
}

+ (Token *)EOFToken {
	static Token *EOFToken = nil;
	if (!EOFToken) {
		EOFToken = [[Token tokenWithSource:@"!EOF" range:NSMakeRange(0, 4)] retain];
	}
	return EOFToken;
}

+ (Token *)tokenWithSource:(NSString *)source range:(NSRange)range {
	Token *token = [[[Token alloc] init] autorelease];
	if (token) {
		token->source = source;
		token->range = range;
	}
	return token;
}

- (BOOL)isEqualToString:(NSString *)string {
	return [[self stringValue] isEqualToString:string];
}

- (NSString *)stringValue {
	return [source substringWithRange:range];
}

- (NSString *)stringByUnescapingStringValue {
	NSString *string = [self stringValue];
	string = [string substringWithRange:NSMakeRange(1, [string length] - 2)];
	string = [string stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
	string = [string stringByReplacingOccurrencesOfString:@"\\\'" withString:@"\'"];
	string = [string stringByReplacingOccurrencesOfString:@"\\\n" withString:@"\n"];
	string = [string stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
	return string;
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
