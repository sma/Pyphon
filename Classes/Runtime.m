//
//  Runtime.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 16.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "Runtime.h"
#import "AST.h" // resolve forward declaration


NSObject *kReturning = @"Returning";


@implementation Pyphon

@synthesize delegate;

+ (Pyphon *)sharedInstance {
    static Pyphon *instance;
    if (!instance) {
        instance = [[Pyphon alloc] init];
    }
    return instance;
}

+ (NSObject *)True {
    static NSObject *True = nil;
    if (!True) {
        True = [[NSNumber alloc] initWithBool:YES];
    }
    return True;
}

+ (NSObject *)False {
    static NSObject *False = nil;
    if (!False) {
        False = [[NSNumber alloc] initWithBool:NO];
    }
    return False;
}

+ (NSObject *)None {
    static NSObject *None = nil;
    if (!None) {
        None = [[NSNumber alloc] initWithInt:0]; // TODO need a real None object here
    }
    return None;
}

- (Frame *)newInitialFrame {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // TODO should be __builtins__
	[dict setObject:[BuiltinFunction functionWithSelector:@selector(print:frame:)] 
             forKey:@"print"];
    
    return [[Frame alloc] initWithLocals:dict globals:dict pyphon:self];
}

@end


@implementation Frame

@synthesize locals;
@synthesize globals;
@synthesize pyphon;
@synthesize returnType;
@synthesize returnValue;

- (Frame *)initWithLocals:(NSMutableDictionary *)locals_ 
                  globals:(NSMutableDictionary *)globals_
                   pyphon:(Pyphon *)pyphon_ {
	if ((self = [self init])) {
		locals = [locals_ retain];
		globals = [globals_ retain];
        pyphon = pyphon_;
	}
	return self;
}

- (void)dealloc {
	[locals release];
	[globals release];
	[super dealloc];
}

- (NSObject *)localValueForName:(NSString *)name {
	NSObject *value = [locals objectForKey:name];
	if (!value) {
		value = [self globalValueForName:name];
	}
	return value;
}

- (void)setLocalValue:(NSObject *)value forName:(NSString *)name {
	[locals setObject:value forKey:name];
}

- (NSObject *)globalValueForName:(NSString *)name {
	NSObject *value = [globals objectForKey:name];
	if (!value) {
		value = [globals objectForKey:@"__builtins__"];
		if (value) {
			value = [(NSDictionary *)value objectForKey:name];
			if (!value) {
				// TODO raise NameError
				return nil;
			}
		}
	}
	return value;
}
	
- (void)setGlobalValue:(NSObject *)value forName:(NSString *)name {
	[globals setObject:value forKey:name];
}

@end


@implementation Function

+ (Function *)withName:(NSString *)name 
                params:(NSArray *)params 
                 suite:(Suite *)suite 
               globals:(NSMutableDictionary *)globals {
	Function *function = [[[self alloc] init] autorelease];
	if (function) {
		function->name = [name copy];
		function->params = [params copy];
		function->suite = [suite retain];
		function->globals = [globals retain];
	}
	return function;
}

- (void)dealloc {
	[name release];
	[params release];
	[suite release];
    [globals release];
	[super dealloc];
}

- (NSObject *)call:(NSArray *)arguments frame:(Frame *)oldFrame {
    NSUInteger count = [arguments count];
    
	NSMutableDictionary *locals = [[NSMutableDictionary alloc] initWithCapacity:count];
	
    for (NSUInteger i = 0; i < count; i++) {
		[locals setObject:[arguments objectAtIndex:i] forKey:[params objectAtIndex:i]];
	}
    
    Frame *newFrame = [[Frame alloc] initWithLocals:locals globals:globals pyphon:oldFrame.pyphon];
    
    [locals release];
    
    NSObject *result = [(Suite *)suite evaluate:newFrame];
    
    if (result == kReturning) {
        if (newFrame.returnType == kReturn) {
            result = newFrame.returnValue;
        } else {
            oldFrame.returnType = newFrame.returnType;
            oldFrame.returnValue = newFrame.returnValue;
        }
    }
    
    [newFrame release];

    return result;
}

@end


@implementation BuiltinFunction

+ (BuiltinFunction *)functionWithSelector:(SEL)selector {
	BuiltinFunction *bf = [[[self alloc] init] autorelease];
	if (bf) {
		bf->selector = selector;
	}
	return bf;
}

- (NSObject *)call:(NSArray *)arguments frame:(Frame *)frame {
	return [self performSelector:selector withObject:arguments withObject:frame];
}

- (NSObject *)print:(NSArray *)arguments frame:(Frame *)frame {
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    BOOL first = YES;
    for (NSObject *argument in arguments) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@" "];
        }
        [buffer appendString:[argument __str__]];
    }
	[frame.pyphon.delegate print:buffer];
    
    [buffer release];
    
	return nil;
}

@end


@implementation NSObject (Pyphon)

- (NSString *)__repr__ {
    return [self description];
}

- (NSString *)__str__ {
    return [self __repr__];
}

@end


@implementation NSString (Pyphon)

- (NSString *)__repr__ {
    NSString *singleQuote = @"\'";
    NSString *doubleQuote = @"\"";
    
    BOOL useDoubleQuote = [self rangeOfString:singleQuote].location != NSNotFound
        && [self rangeOfString:doubleQuote].location == NSNotFound;
    NSString *quote = useDoubleQuote ? doubleQuote : singleQuote;
    
    NSString *string = self;
    string = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    if (!useDoubleQuote) {
        string = [string stringByReplacingOccurrencesOfString:singleQuote withString:@"\\'"];
    }
    return [NSString stringWithFormat:@"%@%@%@", quote, string, quote];
}

- (NSString *)__str__ {
    return self;
}

@end


@implementation NSArray (Pyphon)

- (NSString *)__repr__ {
    NSMutableString *buffer = [[NSMutableString alloc] init];
    [buffer appendString:@"("];
    BOOL first = YES;
    for (NSObject *value in self) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        [buffer appendString:[value __repr__]];
    }
    if ([self count] == 1) {
        [buffer appendString:@","];
    }
    [buffer appendString:@")"];
    return buffer;
}

@end


@implementation NSMutableArray (Pyphon)

- (NSString *)__repr__ {
    NSMutableString *buffer = [[NSMutableString alloc] init];
    [buffer appendString:@"["];
    BOOL first = YES;
    for (NSObject *value in self) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        [buffer appendString:[value __repr__]];
    }
    [buffer appendString:@"]"];
    return buffer;
}

@end


@implementation NSMutableSet (Pyphon)

- (NSString *)__repr__ {
    if (![self count]) {
        return @"set()";
    }
    NSMutableString *buffer = [[NSMutableString alloc] init];
    [buffer appendString:@"{"];
    BOOL first = YES;
    for (NSObject *value in self) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        [buffer appendString:[value __repr__]];
    }
    [buffer appendString:@"}"];
    return buffer;
}

@end


@implementation NSMutableDictionary (Pyphon)

- (NSString *)__repr__ {
    NSMutableString *buffer = [[NSMutableString alloc] init];
    [buffer appendString:@"{"];
    BOOL first = YES;
    for (NSObject *key in self) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        [buffer appendString:[key __repr__]];
        [buffer appendString:@": "];
        [buffer appendString:[[self objectForKey:key] __repr__]];
    }
    [buffer appendString:@"}"];
    return buffer;
}

@end
