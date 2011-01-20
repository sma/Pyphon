//
//  ast.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 15.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "ast.h"

BOOL nonZero(NSObject *value) {
    return value && [(NSNumber *)value intValue];
}

//
// expressions
//

@implementation Expr

- (NSObject *)evaluate:(Frame *)frame {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)setValue:(NSObject *)value frame:(Frame *)frame {
	[self doesNotRecognizeSelector:_cmd];
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

@end


@implementation OrExpr
@end


@implementation AndExpr
@end


@implementation NotExpr
@end


@implementation LtExpr

- (NSObject *)evaluate:(Frame *)frame {
    NSNumber *leftValue = (NSNumber *)[leftExpr evaluate:frame];
    NSNumber *rightValue = (NSNumber *)[rightExpr evaluate:frame];
    return [NSNumber numberWithBool:[leftValue intValue] < [rightValue intValue]];
}

@end


@implementation GtExpr
@end


@implementation LeExpr
@end


@implementation GeExpr
@end


@implementation EqExpr
@end


@implementation NeExpr
@end


@implementation InExpr
@end


@implementation IsExpr
@end


@implementation AddExpr

- (NSObject *)evaluate:(Frame *)frame {
	NSObject *leftValue = [leftExpr evaluate:frame];
	NSObject *rightValue = [rightExpr evaluate:frame];
	int result = [(NSNumber *)leftValue intValue] + [(NSNumber *)rightValue intValue];
	return [NSNumber numberWithInt:result];
}

@end


@implementation SubExpr
@end


@implementation MulExpr
@end


@implementation DivExpr
@end


@implementation ModExpr
@end


@implementation NegExpr
@end


@implementation PosExpr
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
	NSObject *function = [expr evaluate:frame];
	NSUInteger count = [argumentExprs count];
	NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:count];
	for (NSUInteger i = 0; i < count; i++) {
		[arguments addObject:[[argumentExprs objectAtIndex:i] evaluate:frame]];
	}
	// TODO need to use a protocol here
	NSObject *result = [(Function *)function callWithArray:arguments frame:frame];
	[arguments release];
	return result;
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

- (void)setValue:(NSObject *)value frame:(Frame *)frame {
	[frame setLocalValue:value forName:name];
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
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[exprs count]];
	for (Expr *expr in exprs) {
		[array addObject:[expr evaluate:frame]];
	}
	return [NSArray arrayWithArray:array];
}

- (void)setValue:(NSObject *)value frame:(Frame *)frame {
    NSArray *tuple = (NSArray *)value;
    for (NSUInteger i = 0; i < [exprs count]; i++) {
        [[exprs objectAtIndex:i] setValue:[tuple objectAtIndex:i] frame:frame];
    }
}

@end


@implementation ListExpr
@end


@implementation SetExpr
@end


@implementation DictExpr
@end

//
// statements
//

@implementation Stmt

- (void)execute:(Frame *)frame {
	[self doesNotRecognizeSelector:_cmd];
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

- (void)execute:(Frame *)frame {
	for (Stmt *stmt in stmts) {
		[stmt execute:frame];
	}
}

- (NSObject *)evaluate:(Frame *)frame {
    if ([[stmts lastObject] isKindOfClass:[ExprStmt class]]) {
        for (int i = 0; i < [stmts count] - 1; i++) {
            [[stmts objectAtIndex:i] execute:frame];
        }
        return [(ExprStmt *)[stmts lastObject] evaluate:frame];
    }
    [self execute:frame];
    return nil;
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

- (void)execute:(Frame *)frame {
    if (nonZero([testExpr evaluate:frame])) {
        [thenSuite execute:frame];
    } else {
        [elseSuite execute:frame];
    }
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

- (void)execute:(Frame *)frame {
    while (nonZero([testExpr evaluate:frame])) {
        [whileSuite execute:frame];
    }
    [elseSuite execute:frame];
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

- (void)execute:(Frame *)frame {
	// TODO need to create an iterator
	for (NSObject *value in (id<NSFastEnumeration>)[iterExpr evaluate:frame]) {
		[targetExpr setValue:value frame:frame];
		// TODO implement break
		[forSuite execute:frame];
	}
	[elseSuite execute:frame];
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

@end


@implementation PassStmt

+ (Stmt *)stmt {
	return [[[self alloc] init] autorelease];
}

- (void)execute:(Frame *)frame {
}

@end


@implementation BreakStmt

+ (Stmt *)stmt {
	return [[[self alloc] init] autorelease];
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

- (void)execute:(Frame *)frame {
	[leftExpr setValue:[rightExpr evaluate:frame] frame:frame];
}

@end


@implementation AddAssignStmt
@end


@implementation SubAssignStmt
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

- (void)execute:(Frame *)frame {
	[expr evaluate:frame];
}

- (NSObject *)evaluate:(Frame *)frame {
    return [expr evaluate:frame];
}

@end

