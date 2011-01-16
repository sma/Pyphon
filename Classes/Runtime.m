//
//  Runtime.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 16.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "Runtime.h"


@implementation Frame

@synthesize delegate;

+ (Frame *)newInitial {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	// TODO should be __builtins__
	[dictionary setObject:[BuiltinFunction functionWithSelector:@selector(printWithArray:frame:)] forKey:@"print"];
	
	return [[self alloc] initWithLocals:dictionary globals:dictionary];
}

- (Frame *)initWithLocals:(NSMutableDictionary *)locals_ globals:(NSMutableDictionary *)globals_ {
	if (self = [self init]) {
		locals = [locals_ retain];
		globals = [globals_ retain];
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

+ (Function *)withName:(NSString *)name params:(NSArray *)params suite:(Suite *)suite globals:(NSMutableDictionary *)globals {
	Function *function = [[[self alloc] init] autorelease];
	if (function) {
		function->name = [name copy];
		function->params = [params copy];
		function->suite = [suite retain];
		function->globals = globals; // assign
	}
	return function;
}

- (void)dealloc {
	[name release];
	[params release];
	[suite release];
	[super dealloc];
}

- (NSObject *)callWithArray:(NSArray *)arguments frame:(Frame *)frame {
	NSUInteger count = [arguments count];
	NSMutableDictionary *locals = [NSMutableDictionary dictionaryWithCapacity:count];
	for (NSUInteger i = 0; i < count; i++) {
		[locals setObject:[arguments objectAtIndex:i] forKey:[params objectAtIndex:i]];
	}
	frame = [[Frame alloc] initWithLocals:locals globals:globals];
	frame.delegate = frame.delegate;
	// TODO cannot directly use Suite because I twisted the classes 
	[suite performSelector:@selector(execute:) withObject:frame];
	[frame release];
	return nil; // TODO catch ReturnException etc.
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

- (NSObject *)callWithArray:(NSArray *)arguments frame:(Frame *)frame {
	return [self performSelector:selector withObject:arguments withObject:frame];
}

- (NSObject *)printWithArray:(NSArray *)arguments frame:(Frame *)frame {
	// TODO not only first argument
	[frame.delegate print:[NSString stringWithFormat:@"%@", [arguments objectAtIndex:0]]];
	return nil;
}

@end