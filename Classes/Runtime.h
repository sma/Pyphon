//
//  Runtime.h
//  Pyphon
//
//  Created by Stefan Matthias Aust on 16.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Pyphon : NSObject

+ (NSObject *)True;
+ (NSObject *)False;
+ (NSObject *)None;

@end


@protocol PyphonDelegate <NSObject>

- (void)print:(NSString *)string;

@end


@interface Frame : NSObject {
	NSMutableDictionary *locals;
	NSMutableDictionary *globals;
	id<PyphonDelegate> delegate;
}

@property(nonatomic,assign) id<PyphonDelegate> delegate;

+ (Frame *)newInitial;
- (Frame *)initWithLocals:(NSMutableDictionary *)locals globals:(NSMutableDictionary *)globals;
- (NSObject *)localValueForName:(NSString *)name;
- (void)setLocalValue:(NSObject *)value forName:(NSString *)name;
- (NSObject *)globalValueForName:(NSString *)name;
- (void)setGlobalValue:(NSObject *)value forName:(NSString *)name;
- (NSMutableDictionary *)globals;

@end


@class Suite;

@interface Function : NSObject {
	NSString *name;
	NSArray *params;
	Suite *suite;
	NSMutableDictionary *globals;
}

+ (Function *)withName:(NSString *)name params:(NSArray *)params suite:(Suite *)suite globals:(NSMutableDictionary *)globals;

- (NSObject *)callWithArray:(NSArray *)arguments frame:(Frame *)frame;

@end


@interface BuiltinFunction : NSObject {
	SEL selector;
}

+ (BuiltinFunction *)functionWithSelector:(SEL)selector;

- (NSObject *)callWithArray:(NSArray *)arguments frame:(Frame *)frame;

- (NSObject *)printWithArray:(NSArray *)arguments frame:(Frame *)frame;

@end

@interface NSObject (Pyphon)

- (NSString *)__repr__;
- (NSString *)__str__;

@end