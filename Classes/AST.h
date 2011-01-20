//
//  ast.h
//  Pyphon
//
//  Created by Stefan Matthias Aust on 15.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Runtime.h"

//
// expressions
//

@interface Expr : NSObject { /* abstract */
}

- (NSObject *)evaluate:(Frame *)frame;
- (void)setValue:(NSObject *)value frame:(Frame *)frame;

@end


@interface BinaryExpr : Expr { /* abstract */
	Expr *leftExpr;
	Expr *rightExpr;
}

+ (BinaryExpr *)withLeftExpr:(Expr *)leftExpr rightExpr:(Expr *)rightExpr;

@end


@interface UnaryExpr : Expr { /* abstract */
	Expr *expr;
}

+ (UnaryExpr *)withExpr:(Expr *)Expr;

@end


@interface IfExpr : Expr {
	Expr *testExpr;
	Expr *thenExpr;
	Expr *elseExpr;
}

+ (IfExpr *)withTestExpr:(Expr *)testExpr thenExpr:(Expr *)thenExpr elseExpr:(Expr *)elseExpr;

@end


@interface OrExpr : BinaryExpr {
}
@end


@interface AndExpr : BinaryExpr {
}
@end


@interface NotExpr : UnaryExpr {
}
@end


@interface LtExpr : BinaryExpr {
}
@end


@interface GtExpr : BinaryExpr {
}
@end


@interface LeExpr : BinaryExpr {
}
@end


@interface GeExpr : BinaryExpr {
}
@end


@interface EqExpr : BinaryExpr {
}
@end


@interface NeExpr : BinaryExpr {
}
@end


@interface InExpr : BinaryExpr {
}
@end


@interface IsExpr : BinaryExpr {
}
@end


@interface AddExpr : BinaryExpr {
}
@end


@interface SubExpr : BinaryExpr {
}
@end


@interface MulExpr : BinaryExpr {
}
@end


@interface DivExpr : BinaryExpr {
}
@end


@interface ModExpr : BinaryExpr {
}
@end


@interface NegExpr : UnaryExpr {
}
@end


@interface PosExpr : UnaryExpr {
}
@end


@interface CallExpr : Expr {
	Expr *expr;
	NSArray *argumentExprs;
}

+ (CallExpr *)withExpr:(Expr *)expr withArgumentExprs:(NSArray *)argumentExprs;

@end


@interface IndexExpr : Expr {
	Expr *expr;
	Expr *subscriptExpr;
}

+ (IndexExpr *)withExpr:(Expr *)expr withSubscriptExpr:(Expr *)subscriptExpr;

@end


@interface AttrExpr : Expr {
	Expr *expr;
	NSString *name;
}

+ (AttrExpr *)withExpr:(Expr *)expr withName:(NSString *)name;

@end


@interface LiteralExpr : Expr {
	NSObject *value;
}

+ (Expr *)withValue:(NSObject *)value;

@end


@interface VariableExpr : Expr {
	NSString *name;
}

+ (Expr *)withName:(NSString *)name;

@end


@interface TupleExpr : Expr {
	NSArray *exprs;
}

+ (Expr *)withExprs:(NSArray *)exprs;

@end


@interface ListExpr : TupleExpr {
}
@end


@interface SetExpr : TupleExpr {
}
@end


@interface DictExpr : TupleExpr {
}
@end

//
// statements
// 

@interface Stmt : NSObject { /* abstract */
}

- (void)execute:(Frame *)frame;

@end


@interface Suite : NSObject {
	NSArray *stmts;
}

+ (Suite *)withPassStmt;
+ (Suite *)withStmt:(Stmt *)stmt;
+ (Suite *)withStmts:(NSArray *)stmts;

- (void)execute:(Frame *)frame;
- (NSObject *)evaluate:(Frame *)frame;

@end


@interface IfStmt : Stmt {
	Expr *testExpr;
	Suite *thenSuite;
	Suite *elseSuite;
}

+ (IfStmt *)withTestExpr:(Expr *)testExpr thenSuite:(Suite *)thenSuite elseSuite:(Suite *)elseSuite;

@end


@interface WhileStmt : Stmt {
	Expr *testExpr;
	Suite *whileSuite;
	Suite *elseSuite;
}

+ (WhileStmt *)withTestExpr:(Expr *)testExpr whileSuite:(Suite *)whileSuite elseSuite:(Suite *)elseSuite;

@end


@interface ForStmt : Stmt {
	Expr *targetExpr;
	Expr *iterExpr;
	Suite *forSuite;
	Suite *elseSuite;
}

+ (ForStmt *)withTargetExpr:(Expr *)targetExpr iterExpr:(Expr *)iterExpr forSuite:(Suite *)forSuite elseSuite:(Suite *)elseSuite;

@end


@interface TryFinallyStmt : Stmt {
	Suite *trySuite;
	Suite *finallySuite;
}

+ (TryFinallyStmt *)withTrySuite:(Suite *)trySuite finallySuite:(Suite *)finallySuite;

@end


@interface TryExceptStmt : Stmt {
	Suite *trySuite;
	NSArray *exceptClauses;
	Suite *elseSuite;
}

+ (TryExceptStmt *)withTrySuite:(Suite *)trySuite exceptClauses:(NSArray *)exceptClauses elseSuite:(Suite *)elseSuite;

@end


@interface ExceptClause : NSObject {
	Expr *exceptionsExpr;
	NSString *name;
	Suite *suite;
}

+ (ExceptClause *)withExceptionsExpr:(Expr *)exceptionsExpr name:(NSString *)name suite:(Suite *)suite;

@end


@interface DefStmt : Stmt {
	NSString *name;
	NSArray *params;
	Suite *suite;
}

+ (DefStmt *)withName:(NSString *)name params:(NSArray *)params suite:(Suite *)suite;

@end


@interface ClassStmt : Stmt {
	NSString *name;
	Expr *superExpr;
	Suite *suite;
}

+ (ClassStmt *)withName:(NSString *)name superExpr:(Expr *)superExpr suite:(Suite *)suite;

@end


@interface PassStmt : Stmt {
}

+ (Stmt *)stmt;

@end


@interface BreakStmt : Stmt {
}

+ (Stmt *)stmt;

@end


@interface ReturnStmt : Stmt {
	Expr *expr;
}

+ (Stmt *)withExpr:(Expr *)expr;

@end


@interface RaiseStmt : Stmt {
	Expr *expr;
}

+ (Stmt *)withExpr:(Expr *)expr;

@end


@interface AssignStmt : Stmt {
	Expr *leftExpr;
	Expr *rightExpr;
}

+ (Stmt *)withLeftExpr:(Expr *)leftExpr rightExpr:(Expr *)rightExpr;

@end


@interface AddAssignStmt : AssignStmt {
}
@end


@interface SubAssignStmt : AssignStmt {
}
@end


@interface ExprStmt : Stmt {
	Expr *expr;
}

+ (Stmt *)withExpr:(Expr *)expr;

- (NSObject *)evaluate:(Frame *)frame;

@end
