//
//  Runtime.h
//  Pyphon
//
//  Created by Stefan Matthias Aust on 16.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Suite; // forward declaration
@class Frame; // forward declaration


/**
 * Unique constant that denotes an exceptional return.
 * @see ReturnType
 * @see Frame#returnType
 */
extern NSObject *kReturning;


/**
 * What caused exceptional return.
 */
typedef enum { kReturn, kBreak, kException } ReturnType;


/**
 * 
 */
@protocol PyphonDelegate

- (void)print:(NSString *)string;

@end


/**
 * Beginning of the runtime system.
 * Right now, it only provides some constants.
 */
@interface Pyphon : NSObject {
    id<PyphonDelegate> delegate;
}

@property(nonatomic,assign) id<PyphonDelegate> delegate;

+ (Pyphon *)sharedInstance;

+ (NSObject *)True;
+ (NSObject *)False;
+ (NSObject *)None;

- (Frame *)newInitialFrame;

@end


/**
 * Stores local and global variables.
 */
@interface Frame : NSObject {
	NSMutableDictionary *locals;
	NSMutableDictionary *globals;
    Pyphon *pyphon;
    ReturnType returnType;
    NSObject *returnValue;
}

@property(nonatomic, readonly) NSMutableDictionary *locals;
@property(nonatomic, readonly) NSMutableDictionary *globals;
@property(nonatomic, readonly) Pyphon *pyphon;
@property(nonatomic, assign) ReturnType returnType;
@property(nonatomic, retain) NSObject *returnValue;

- (Frame *)initWithLocals:(NSMutableDictionary *)locals 
                  globals:(NSMutableDictionary *)globals
                   pyphon:(Pyphon *)pyphon;

- (NSObject *)localValueForName:(NSString *)name;
- (void)setLocalValue:(NSObject *)value forName:(NSString *)name;
- (NSObject *)globalValueForName:(NSString *)name;
- (void)setGlobalValue:(NSObject *)value forName:(NSString *)name;

@end


/**
 * Something you can call.
 */
@protocol Callable

- (NSObject *)call:(NSArray *)arguments frame:(Frame *)frame;

@end
 

/**
 * Represents Pyphon function objects.
 */
@interface Function : NSObject <Callable> {
	NSString *name;
	NSArray *params;
	Suite *suite;
	NSMutableDictionary *globals;
}

+ (Function *)withName:(NSString *)name 
                params:(NSArray *)params 
                 suite:(Suite *)suite 
               globals:(NSMutableDictionary *)globals;

- (NSObject *)call:(NSArray *)arguments frame:(Frame *)frame;

@end


@interface BuiltinFunction : NSObject <Callable> {
	SEL selector;
}

+ (BuiltinFunction *)functionWithSelector:(SEL)selector;

- (NSObject *)call:(NSArray *)arguments frame:(Frame *)frame;

- (NSObject *)print:(NSArray *)arguments frame:(Frame *)frame;

@end


/**
 * Provides printing Pyphon objects, the "Python" way.
 */
@interface NSObject (Pyphon)

- (NSString *)__repr__;
- (NSString *)__str__;

@end