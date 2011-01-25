//
//  ast.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 15.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "ast.h"


#pragma mark -
#pragma mark --- helper functions ---


static BOOL nonZero(NSObject *value) {
    return value && [(NSNumber *)value intValue];
}

static NSObject *boolValue(BOOL value) {
    return value ? [Pyphon True] : [Pyphon False];
}

static int asInt(NSObject *value) {
    return [(NSNumber *)value intValue]; // TODO check runtime type
}

static NSObject *intValue(int value) {
    return [[[NSNumber alloc] initWithInt:value] autorelease]; // TODO think about memory management
}

static NSException *exception(NSString *name) {
    return [NSException exceptionWithName:name reason:@"" userInfo:nil];
}

static NSString *op(NSObject *object) {
    NSString *name = NSStringFromClass([object class]);
    return [name substringToIndex:[name length] - 4];
}

static NSString *descriptionForArray(NSArray *array) {
    NSMutableString *buffer = [NSMutableString string];
    [buffer appendString:@"["];
    BOOL first = YES;
    for (NSObject *object in array) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        [buffer appendString:[object description]];
    }
    [buffer appendString:@"]"];
    return buffer;
}


#pragma mark -
#pragma mark --- expression nodes ---


@implementation Expr

- (NSObject *)evaluate:(Frame *)frame {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSObject *)setValue:(NSObject *)value frame:(Frame *)frame {
	[self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end


@implementation BinaryExpr

+ (BinaryExpr *)withLeftExpr:(Expr *)leftExpr rightExpr:(Expr *)rightExpr {
	BinaryExpr *expr = [[[self alloc] init] autorelease];
	if (expr) {
		expr->leftExpr = [leftExpr retain];
		expr->rightExpr = [rightExpr retain];
	}
	return expr;
}

- (void)dealloc {
	[leftExpr release];
	[rightExpr release];
	[super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@, %@)", op(self), leftExpr, rightExpr];
}

@end


@implementation UnaryExpr

+ (UnaryExpr *)withExpr:(Expr *)expr {
	UnaryExpr *unaryExpr = [[[self alloc] init] autorelease];
	if (unaryExpr) {
		unaryExpr->expr = [expr retain];
	}
	return unaryExpr;
}

- (void)dealloc {
	[expr release];
	[super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", op(self), expr];
}

@end


@implementation IfExpr

+ (IfExpr *)withTestExpr:(Expr *)testExpr thenExpr:(Expr *)thenExpr elseExpr:(Expr *)elseExpr {
	IfExpr *expr = [[[self alloc] init] autorelease];
	if (expr) {
		expr->testExpr = [testExpr retain];
		expr->thenExpr = [thenExpr retain];
		expr->elseExpr = [elseExpr retain];
	}
	return expr;
}

- (void)dealloc {
	[testExpr release];
	[thenExpr release];
	[elseExpr release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *test = [testExpr evaluate:frame];
    
    if (test == kReturning) {
        return test;
    }
    
    return [(nonZero(test) ? thenExpr : elseExpr) evaluate:frame];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"If(%@, %@, %@)", testExpr, thenExpr, elseExpr];
}

@end


@implementation OrExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    if (nonZero(left)) {
        return left;
    }
    
    return [rightExpr evaluate:frame];
}

@end


@implementation AndExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    if (nonZero(left)) {
        return [rightExpr evaluate:frame];
    }
    
    return left;
}

@end


@implementation NotExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *value = [expr evaluate:frame];
    
    if (value == kReturning) {
        return value;
    }
    
    return boolValue(!nonZero(value));
}

@end


@implementation LtExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    // TODO can we conform to a protocol instead of casting?
    return boolValue([(NSNumber *)left compare:(NSNumber *)right] == NSOrderedAscending);
}

@end


@implementation GtExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    // TODO can we conform to a protocol instead of casting?
    return boolValue([(NSNumber *)left compare:(NSNumber *)right] == NSOrderedDescending);
}

@end


@implementation LeExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    // TODO can we conform to a protocol instead of casting?
    return boolValue([(NSNumber *)left compare:(NSNumber *)right] != NSOrderedDescending);   
}

@end


@implementation GeExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    // TODO can we conform to a protocol instead of casting?
    return boolValue([(NSNumber *)left compare:(NSNumber *)right] != NSOrderedAscending);
}

@end


@implementation EqExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    return boolValue([left isEqual:right]);
}

@end


@implementation NeExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    return boolValue(![left isEqual:right]);
}

@end


@implementation InExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    if ([right respondsToSelector:@selector(containsObject:)]) {
        return boolValue([(NSArray *)right containsObject:left]);
    }
    if ([right isKindOfClass:[NSString class]]) {
        return boolValue([(NSString *)right rangeOfString:(NSString *)left].location != NSNotFound);
    }
    
    // TODO implement Python Exceptions
    @throw exception(@"TypeError");
}

@end


@implementation IsExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    return boolValue(left == right);
}

@end


@implementation AddExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    return intValue(asInt(left) + asInt(right));
}

@end


@implementation SubExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    return intValue(asInt(left) - asInt(right));
}

@end


@implementation MulExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    return intValue(asInt(left) * asInt(right));

}

@end


@implementation DivExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    return intValue(asInt(left) / asInt(right));

}

@end


@implementation ModExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
    return intValue(asInt(left) % asInt(right));
}

@end


@implementation NegExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *value = [expr evaluate:frame];
    if (value == kReturning) {
        return value;
    }
    return intValue(-asInt(value));
}

@end


@implementation PosExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *value = [expr evaluate:frame];
    if (value == kReturning) {
        return value;
    }
    return intValue(+asInt(value));
}

@end


@implementation CallExpr

+ (CallExpr *)withExpr:(Expr *)expr withArgumentExprs:(NSArray *)argumentExprs {
	CallExpr *callExpr = [[[self alloc] init] autorelease];
	if (callExpr) {
		callExpr->expr = [expr retain];
		callExpr->argumentExprs = [argumentExprs retain];
	}
	return callExpr;
}

- (void)dealloc {
	[expr release];
	[argumentExprs release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
	NSObject *func = [expr evaluate:frame];
    
    if (func == kReturning) {
        return func;
    }
    
	NSUInteger count = [argumentExprs count];
	NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:count];
	for (NSUInteger i = 0; i < count; i++) {
        NSObject *value = [[argumentExprs objectAtIndex:i] evaluate:frame];
        
        if (value == kReturning) {
            return value;
        }
        
		[arguments addObject:value];
	}

	NSObject *result = [(id<Callable>)func call:arguments frame:frame];
	[arguments release];
	return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Call(%@, %@)", expr, descriptionForArray(argumentExprs)];
}

@end


@implementation IndexExpr

+ (IndexExpr *)withExpr:(Expr *)expr withSubscriptExpr:(Expr *)subscriptExpr {
	IndexExpr *indexExpr = [[[self alloc] init] autorelease];
	if (indexExpr) {
		indexExpr->expr = [expr retain];
		indexExpr->subscriptExpr = [subscriptExpr retain];
	}
	return indexExpr;
}

- (void)dealloc {
	[expr release];
	[subscriptExpr release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *target = [expr evaluate:frame];
    
    if (target == kReturning) {
        return target;
    }
    
    NSObject *subscript = [subscriptExpr evaluate:frame];
    
    if (subscript == kReturning) {
        return subscript;
    }
    
    if ([target isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)target;

        int index = asInt(subscript); //TODO could be a slice
        if (index < 0) {
            index += [string length];
        }
        if (index < 0 || index >= [string length]) {
            @throw exception(@"IndexError");
        }
        
        return [string substringWithRange:NSMakeRange(index, 1)];
    }
    
    if ([target respondsToSelector:@selector(objectAtIndex:)]) {
        NSArray *list = (NSArray *)target;
        int index = asInt(subscript); //TODO could be a slice
        if (index < 0) {
            index += [list count];
        }
        if (index < 0 || index >= [list count]) {
            @throw exception(@"IndexError");
        }
        return [list objectAtIndex:index];
    }
    
    if ([target respondsToSelector:@selector(objectForKey:)]) {
        NSDictionary *dict = (NSDictionary *)target;
        return [dict objectForKey:subscript];
    }
    
    // TODO Python Exceptions
    @throw exception(@"TypeError");
}

- (NSObject *)setValue:(NSObject *)value frame:(Frame *)frame {
    NSObject *target = [expr evaluate:frame];
    
    if (target == kReturning) {
        return target;
    }
    
    NSObject *subscript = [subscriptExpr evaluate:frame];
    
    if (subscript == kReturning) {
        return subscript;
    }
    
    if ([target respondsToSelector:@selector(replaceObjectAtIndex:withObject:)]) {
        NSMutableArray *list = (NSMutableArray *)target;
        int index = asInt(subscript);
        if (index < 0) {
            index += [list count];
        }
        if (index < 0 || index >= [list count]) {
            @throw exception(@"IndexError");
        }
        [list replaceObjectAtIndex:index withObject:value];
        return nil;
    }
    
    if ([target respondsToSelector:@selector(setObject:forKey:)]) {
        NSMutableDictionary *dict = (NSMutableDictionary *)target;
        [dict setObject:value forKey:target];
        return nil;
    }
    
    // TODO Python Exceptions
    @throw exception(@"TypeError");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Index(%@, %@)", expr, subscriptExpr];
}

@end


@implementation AttrExpr

+ (AttrExpr *)withExpr:(Expr *)expr withName:(NSString *)name {
	AttrExpr *attrExpr = [[[self alloc] init] autorelease];
	if (attrExpr) {
		attrExpr->expr = [expr retain];
		attrExpr->name = [name copy];
	}
	return attrExpr;
}

- (void)dealloc {
	[expr release];
	[name release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *value = [expr evaluate:frame];
    
    if (value == kReturning) {
        return value;
    }
    
    return [value valueForKey:name];
}

- (NSObject *)setValue:(NSObject *)value frame:(Frame *)frame {
    NSObject *val = [expr evaluate:frame];
    
    if (val == kReturning) {
        return val;
    }
    
    [val setValue:value forKey:name];
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Attr(%@, %@)", expr, name];
}

@end


@implementation LiteralExpr

+ (Expr *)withValue:(NSObject *)value {
	LiteralExpr *expr = [[[self alloc] init] autorelease];
	if (expr) {
		expr->value = [value copy];
	}
	return expr;
}

- (void)dealloc {
	[value release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
	return value;
}

- (NSString *)description {
    return [value __repr__];
}

@end


@implementation VariableExpr

+ (Expr *)withName:(NSString *)name {
	VariableExpr *expr = [[[self alloc] init] autorelease];
	if (expr) {
		expr->name = [name copy];
	}
	return expr;
}

- (void)dealloc {
	[name release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
	return [frame localValueForName:name];
}

- (NSObject *)setValue:(NSObject *)value frame:(Frame *)frame {
	[frame setLocalValue:value forName:name];
    return nil;
}

- (NSString *)description {
    return name;
}

@end


@implementation TupleExpr

+ (Expr *)withExprs:(NSArray *)exprs {
	TupleExpr *expr = [[[self alloc] init] autorelease];
	if (expr) {
		expr->exprs = [exprs copy];
	}
	return expr;
}

- (void)dealloc {
	[exprs release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
	NSMutableArray *tuple = [NSMutableArray arrayWithCapacity:[exprs count]];
    
	for (Expr *expr in exprs) {
        NSObject *value = [expr evaluate:frame];
        
        if (value == kReturning) {
            return value;
        }
        
		[tuple addObject:value];
	}
    
	return [NSArray arrayWithArray:tuple];
}

- (NSObject *)setValue:(NSObject *)value frame:(Frame *)frame {
    NSArray *tuple = (NSArray *)value;
    for (NSUInteger i = 0; i < [exprs count]; i++) {
        NSObject *result = [[exprs objectAtIndex:i] setValue:[tuple objectAtIndex:i] frame:frame];
        if (result == kReturning) {
            return result;
        }
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@)", op(self), descriptionForArray(exprs)];
}

@end


@implementation ListExpr

- (NSObject *)evaluate:(Frame *)frame {
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:[exprs count]];
	for (Expr *expr in exprs) {
		NSObject *value = [expr evaluate:frame];
        
        if (value == kReturning) {
            return value;
        }
        
		[list addObject:value];
	}
	return list;
}

@end


@implementation SetExpr

- (NSObject *)evaluate:(Frame *)frame {
	NSMutableSet *set = [NSMutableSet setWithCapacity:[exprs count]];
	for (Expr *expr in exprs) {
		NSObject *value = [expr evaluate:frame];
        
        if (value == kReturning) {
            return value;
        }
        
		[set addObject:value];
	}
	return set; 
}

@end


@implementation DictExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[exprs count]];
    for (NSArray *pair in exprs) {
        Expr *keyExpr = [pair objectAtIndex:0];
        Expr *valueExpr = [pair objectAtIndex:1];
        NSObject *key = [keyExpr evaluate:frame];
        if (key == kReturning) {
            return key;
        }
        NSObject *value = [valueExpr evaluate:frame];
        if (value == kReturning) {
            return value;
        }
        [dictionary setObject:value forKey:key];
    }
    return dictionary;
}

- (NSString *)description {
    NSMutableString *buffer = [NSMutableString string];
    [buffer appendString:@"Dict("];
    BOOL first = YES;
    for (NSArray *pair in exprs) {
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@", "];
        }
        Expr *keyExpr = [pair objectAtIndex:0];
        Expr *valueExpr = [pair objectAtIndex:1];
        [buffer appendString:[keyExpr description]];
        [buffer appendString:@": "];
        [buffer appendString:[valueExpr description]];
    }
    [buffer appendString:@")"];
    return buffer;
}

@end


#pragma mark -
#pragma mark --- statement nodes ---


@implementation Stmt

- (NSObject *)evaluate:(Frame *)frame {
	[self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end


@implementation Suite

+ (Suite *)withPassStmt {
	return [self withStmt:[PassStmt stmt]];
}

+ (Suite *)withStmt:(Stmt *)stmt {
	return [self withStmts:[NSArray arrayWithObject:stmt]];
}

+ (Suite *)withStmts:(NSArray *)stmts {
	Suite *suite = [[[self alloc] init] autorelease];
	if (suite) {
		suite->stmts = [stmts copy];
	}
	return suite;
}

- (void)dealloc {
	[stmts release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *result = nil;
    for (Stmt *stmt in stmts) {
        result = [stmt evaluate:frame];
        if (result == kReturning) {
            return result;
        }
    }
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Suite%@", descriptionForArray(stmts)];
}

@end


@implementation IfStmt

+ (IfStmt *)withTestExpr:(Expr *)testExpr thenSuite:(Suite *)thenSuite elseSuite:(Suite *)elseSuite {
	IfStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->testExpr = [testExpr retain];
		stmt->thenSuite = [thenSuite retain];
		stmt->elseSuite = [elseSuite retain];
	}
	return stmt;
}

- (void)dealloc {
	[testExpr release];
	[thenSuite release];
	[elseSuite release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *test = [testExpr evaluate:frame];
    
    if (test == kReturning) {
        return test;
    }
    
    if (nonZero(test)) {
        return [thenSuite evaluate:frame];
    } else {
        return [elseSuite evaluate:frame];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"If(%@, %@, %@)", testExpr, thenSuite, elseSuite];
}

@end


@implementation WhileStmt

+ (WhileStmt *)withTestExpr:(Expr *)testExpr whileSuite:(Suite *)whileSuite elseSuite:(Suite *)elseSuite {
	WhileStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->testExpr = [testExpr retain];
		stmt->whileSuite = [whileSuite retain];
		stmt->elseSuite = [elseSuite retain];
	}
	return stmt;
}

- (void)dealloc {
	[testExpr release];
	[whileSuite release];
	[elseSuite release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    while (YES) {
        NSObject *test = [testExpr evaluate:frame];
        if (test == kReturning) {
            return test;
        }
        
        if (!nonZero(test)) {
            break;
        }
        
        NSObject *result = [whileSuite evaluate:frame];
        if (result == kReturning) {
            if (frame.returnType == kBreak) {
                return nil;
            }
            return result;
        }
    }
    
    return [elseSuite evaluate:frame];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"While(%@, %@, %@)", testExpr, whileSuite, elseSuite];
}

@end


@implementation ForStmt

+ (ForStmt *)withTargetExpr:(Expr *)targetExpr iterExpr:(Expr *)iterExpr forSuite:(Suite *)forSuite elseSuite:(Suite *)elseSuite {
	ForStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->targetExpr = [targetExpr retain];
		stmt->iterExpr = [iterExpr retain];
		stmt->forSuite = [forSuite retain];
		stmt->elseSuite = [elseSuite retain];
	}
	return stmt;
}

- (void)dealloc {
	[targetExpr release];
	[iterExpr release];
	[forSuite release];
	[elseSuite release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
	// TODO need to create an iterator
    NSObject *iter = [iterExpr evaluate:frame];
    
    if (iter == kReturning) {
        return iter;
    }
    
	for (NSObject *value in (id<NSFastEnumeration>)iter) {
		NSObject *result;
        
        // should never happen because target of `for` may not be Attr/Index
        result = [targetExpr setValue:value frame:frame];
        if (result == kReturning) {
            return result;
        }
		
        result = [forSuite evaluate:frame];
        if (result == kReturning) {
            if (frame.returnType == kBreak) {
                return nil;
            }
            return result;
        }
	}
	
    return [elseSuite evaluate:frame];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"For(%@, %@, %@, %@)", targetExpr, iterExpr, forSuite, elseSuite];
}

@end


@implementation TryFinallyStmt

+ (TryFinallyStmt *)withTrySuite:(Suite *)trySuite finallySuite:(Suite *)finallySuite {
	TryFinallyStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->trySuite = [trySuite retain];
		stmt->finallySuite = [finallySuite retain];
	}
	return stmt;
}

- (void)dealloc {
	[trySuite release];
	[finallySuite release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *result1 = [trySuite evaluate:frame];
    NSObject *result2 = [finallySuite evaluate:frame];
    
    return result2 == kReturning ? result2 : result1;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TryFinally(%@, %@)", trySuite, finallySuite];
}

@end


@implementation TryExceptStmt

+ (TryExceptStmt *)withTrySuite:(Suite *)trySuite exceptClauses:(NSArray *)exceptClauses elseSuite:(Suite *)elseSuite {
	TryExceptStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->trySuite = [trySuite retain];
		stmt->exceptClauses = [exceptClauses copy];
		stmt->elseSuite = [elseSuite retain];
	}
	return stmt;
}

- (void)dealloc {
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *result = [trySuite evaluate:frame];
    if (result == kReturning) {
        if (frame.returnType == kException) {
            for (ExceptClause *exceptClause in exceptClauses) {
                if ([exceptClause matches:frame]) {
                    return [exceptClause evaluate:frame];
                }
            }
        }
        return result;
    }
    return [elseSuite evaluate:frame];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TryExcept(%@, %@, %@)", trySuite, exceptClauses, elseSuite];
}

@end


@implementation ExceptClause

+ (ExceptClause *)withExceptionsExpr:(Expr *)exceptionsExpr name:(NSString *)name suite:(Suite *)suite {
	ExceptClause *clause = [[[self alloc] init] autorelease];
	if (clause) {
		clause->exceptionsExpr = [exceptionsExpr retain];
		clause->name = [name copy];
		clause->suite = [suite retain];
	}
	return clause;
}

- (void)dealloc {
	[exceptionsExpr release];
	[name release];
	[suite release];
	[super dealloc];
}

- (BOOL)matches:(Frame *)frame {
    return YES; // TODO implement exception matching
}

- (NSObject *)evaluate:(Frame *)frame {
    if (name) {
        [frame setLocalValue:frame.returnValue forName:name];
    }
    return [suite evaluate:frame];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"[%@, %@, %@]", exceptionsExpr, name, suite];
}

@end


@implementation DefStmt

+ (DefStmt *)withName:(NSString *)name params:(NSArray *)params suite:(Suite *)suite {
	DefStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->name = [name copy];
		stmt->params = [params copy];
		stmt->suite = [suite retain];
	}
	return stmt;
}

- (void)dealloc {
	[name release];
	[params release];
	[suite release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    Function *function = [Function withName:name 
                                     params:params 
                                      suite:suite 
                                    globals:[frame globals]];
    [frame setLocalValue:function forName:name];
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Def(%@, %@, %@)", name, descriptionForArray(params), suite];
}

@end


@implementation ClassStmt

+ (ClassStmt *)withName:(NSString *)name superExpr:(Expr *)superExpr suite:(Suite *)suite {
	ClassStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->name = [name copy];
		stmt->superExpr = [superExpr retain];
		stmt->suite = [suite retain];
	}
	return stmt;
}

- (void)dealloc {
	[name release];
	[superExpr release];
	[suite release];
	[super dealloc];
}

// TODO evaluate missing

- (NSString *)description {
    return [NSString stringWithFormat:@"Class(%@, %@, %@)", name, superExpr, suite];
}

@end


@implementation PassStmt

+ (Stmt *)stmt {
	return [[[self alloc] init] autorelease];
}

- (NSObject *)evaluate:(Frame *)frame {
    return nil;
}

- (NSString *)description {
    return @"Pass()";
}

@end


@implementation BreakStmt

+ (Stmt *)stmt {
	return [[[self alloc] init] autorelease];
}

- (NSObject *)evaluate:(Frame *)frame {
    frame.returnType = kBreak;
    return kReturning;
}

- (NSString *)description {
    return @"Break()";
}

@end


@implementation ReturnStmt

+ (Stmt *)withExpr:(Expr *)expr {
	ReturnStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->expr = [expr retain];
	}
	return stmt;
}

- (void)dealloc {
	[expr release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *result = [expr evaluate:frame];
    
    if (result == kReturning) {
        return result;
    }
    
    frame.returnType = kReturn;
    frame.returnValue = result;
    return kReturning;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Return(%@)", expr];
}

@end


@implementation RaiseStmt

+ (Stmt *)withExpr:(Expr *)expr {
	RaiseStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->expr = [expr retain];
	}
	return stmt;
}

- (void)dealloc {
	[expr release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *result = [expr evaluate:frame];
    
    if (result == kReturning) {
        return result;
    }
    
    frame.returnType = kException;
    frame.returnValue = result;
    return kReturning;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Raise(%@)", expr];
}

@end


@implementation AssignStmt

+ (Stmt *)withLeftExpr:(Expr *)leftExpr rightExpr:(Expr *)rightExpr {
	AssignStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->leftExpr = [leftExpr retain];
		stmt->rightExpr = [rightExpr retain];
	}
	return stmt;
}

- (void)dealloc {
	[leftExpr release];
	[rightExpr release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
	return [leftExpr setValue:right frame:frame];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@, %@)", op(self), leftExpr, rightExpr];
}

@end


@implementation AddAssignStmt

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
	return [leftExpr setValue:intValue(asInt(left) + asInt(right)) frame:frame];
}

@end


@implementation SubAssignStmt

- (NSObject *)evaluate:(Frame *)frame {
    NSObject *left = [leftExpr evaluate:frame];
    
    if (left == kReturning) {
        return left;
    }
    
    NSObject *right = [rightExpr evaluate:frame];
    
    if (right == kReturning) {
        return right;
    }
    
	return [leftExpr setValue:intValue(asInt(left) - asInt(right)) frame:frame];
}

@end


@implementation ExprStmt

+ (Stmt *)withExpr:(Expr *)expr {
	ExprStmt *stmt = [[[self alloc] init] autorelease];
	if (stmt) {
		stmt->expr = [expr retain];
	}
	return stmt;
}

- (void)dealloc {
	[expr release];
	[super dealloc];
}

- (NSObject *)evaluate:(Frame *)frame {
	return [expr evaluate:frame];
}

- (NSString *)description {
    return [expr description];
}

@end

