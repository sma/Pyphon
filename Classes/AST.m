//
//  ast.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 15.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "ast.h"

//
// expressions
//

@implementation Expr

- (NSObject *)eval:(Frame *)frame {
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
	IfExpr *expr = [[[IfExpr alloc] init] autorelease];
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

- (NSObject *)eval:(Frame *)frame {
	NSObject *leftValue = [leftExpr eval:frame];
	NSObject *rightValue = [rightExpr eval:frame];
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
	CallExpr *callExpr = [[[CallExpr alloc] init] autorelease];
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

- (NSObject *)eval:(Frame *)frame {
	NSObject *function = [expr eval:frame];
	NSUInteger count = [argumentExprs count];
	NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:count];
	for (NSUInteger i = 0; i < count; i++) {
		[arguments addObject:[[argumentExprs objectAtIndex:i] eval:frame]];
	}
	// TODO need to use a protocol here
	NSObject *result = [(Function *)function callWithArray:arguments frame:frame];
	[arguments release];
	return result;
}

@end


@implementation IndexExpr

+ (IndexExpr *)withExpr:(Expr *)expr withSubscriptExpr:(Expr *)subscriptExpr {
	IndexExpr *indexExpr = [[[IndexExpr alloc] init] autorelease];
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
	AttrExpr *attrExpr = [[[AttrExpr alloc] init] autorelease];
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
	LiteralExpr *expr = [[[LiteralExpr alloc] init] autorelease];
	if (expr) {
		expr->value = [value copy];
	}
	return expr;
}

- (void)dealloc {
	[value release];
	[super dealloc];
}

- (NSObject *)eval:(Frame *)frame {
	return value;
}

@end


@implementation VariableExpr

+ (Expr *)withName:(NSString *)name {
	VariableExpr *expr = [[[VariableExpr alloc] init] autorelease];
	if (expr) {
		expr->name = [name copy];
	}
	return expr;
}

- (void)dealloc {
	[name release];
	[super dealloc];
}

- (NSObject *)eval:(Frame *)frame {
	return [frame localValueForName:name];
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
	Suite *suite = [[[Suite alloc] init] autorelease];
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

@end


@implementation IfStmt

+ (IfStmt *)withTestExpr:(Expr *)testExpr thenSuite:(Suite *)thenSuite elseSuite:(Suite *)elseSuite {
	IfStmt *stmt = [[[IfStmt alloc] init] autorelease];
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

@end


@implementation WhileStmt

+ (WhileStmt *)withTestExpr:(Expr *)testExpr whileSuite:(Suite *)whileSuite elseSuite:(Suite *)elseSuite {
	WhileStmt *stmt = [[[WhileStmt alloc] init] autorelease];
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

@end


@implementation ForStmt

+ (ForStmt *)withTargetExpr:(Expr *)targetExpr iterExpr:(Expr *)iterExpr forSuite:(Suite *)forSuite elseSuite:(Suite *)elseSuite {
	ForStmt *stmt = [[[ForStmt alloc] init] autorelease];
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

@end


@implementation TryFinallyStmt

+ (TryFinallyStmt *)withTrySuite:(Suite *)trySuite finallySuite:(Suite *)finallySuite {
	TryFinallyStmt *stmt = [[[TryFinallyStmt alloc] init] autorelease];
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
	TryExceptStmt *stmt = [[[TryExceptStmt alloc] init] autorelease];
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
	ExceptClause *clause = [[[ExceptClause alloc] init] autorelease];
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
	DefStmt *stmt = [[[DefStmt alloc] init] autorelease];
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
	ClassStmt *stmt = [[[ClassStmt alloc] init] autorelease];
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
	[expr eval:frame];
}

@end

