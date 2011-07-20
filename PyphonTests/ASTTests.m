//
//  ASTTests.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 18.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "ASTTests.h"
#import "Parser.h"


#pragma mark Local helper functions

static NSNumber *N(int num) {
    return [NSNumber numberWithInt:num];
}

static LiteralExpr *Lit(NSObject *value) {
    return [LiteralExpr exprWithValue:value];
}

static LiteralExpr *Litn(int num) {
    return Lit(N(num));
}

static VariableExpr *Var(NSString *name) {
    return [VariableExpr exprWithName:name];
}

#pragma mark -
#pragma mark Tests for expressions and statements

@implementation ASTTests

- (void)setUp {
	frame = [[Frame alloc] 
             initWithLocals:[NSMutableDictionary dictionary]
             globals:[NSMutableDictionary dictionary]
             pyphon:[Pyphon sharedInstance]];
}

- (void)tearDown {
}


#pragma mark Testing literals


- (void)testLiteralExpr {
	NSObject *result = [Litn(1) evaluate:frame];
	STAssertEqualObjects(N(1), result, nil);
}


#pragma mark Testing variables


- (void)testVariableExpr1 { // local variable
    [frame setLocalValue:N(1) forName:@"a"];
    NSObject *result = [[VariableExpr exprWithName:@"a"] evaluate:frame];
    STAssertEqualObjects(N(1), result, nil);
}

- (void)testVariableExpr2 { // global variable
    [frame setGlobalValue:N(2) forName:@"b"];
    NSObject *result = [[VariableExpr exprWithName:@"b"] evaluate:frame];
    STAssertEqualObjects(N(2), result, nil);
}

- (void)testVariableExpr3 { // local variable should shadow global variable
    [frame setLocalValue:N(1) forName:@"c"];
    [frame setGlobalValue:N(2) forName:@"c"];
    NSObject *result = [[VariableExpr exprWithName:@"c"] evaluate:frame];
    STAssertEqualObjects(N(1), result, nil);
}

- (void)testVariableExpr4 { // non-existing variable causes an exception
    NSObject *result = [[VariableExpr exprWithName:@"d"] evaluate:frame];
    STAssertTrue(frame.resultType, nil);
    STAssertEqualObjects(@"NameError", result, nil);
}


#pragma mark Testing index operations


- (void)testIndexExpr1 { // string (positive index)
    NSObject *result = [[IndexExpr exprWithExpr:Lit(@"abc") subscriptExpr:Litn(2)] evaluate:frame];
    STAssertEqualObjects(@"c", result, nil);
}

- (void)testIndexExpr2 { // string (negative index)
    NSObject *result = [[IndexExpr exprWithExpr:Lit(@"abc") subscriptExpr:Litn(-1)] evaluate:frame];
    STAssertEqualObjects(@"c", result, nil);
}

- (void)testIndexExpr3 { // string (invalid index)
    NSObject *result = [[IndexExpr exprWithExpr:Lit(@"abc") subscriptExpr:Litn(3)] evaluate:frame];
    STAssertEqualObjects(@"IndexError", result, nil);
}

- (void)testIndexExpr4 { // list (positive index)
    Expr *e = Lit([NSArray arrayWithObjects:N(1), N(2), nil]);
    NSObject *result = [[IndexExpr exprWithExpr:e subscriptExpr:Litn(1)] evaluate:frame];
    STAssertEqualObjects(N(2), result, nil);
}

- (void)testIndexExpr5 { // list (negative index)
    Expr *e = Lit([NSArray arrayWithObjects:N(1), N(2), nil]);
    NSObject *result = [[IndexExpr exprWithExpr:e subscriptExpr:Litn(-2)] evaluate:frame];
    STAssertEqualObjects(N(1), result, nil);
}

- (void)testIndexExpr6 { // list (invalid index)
    Expr *e = Lit([NSArray arrayWithObjects:N(1), N(2), nil]);
    NSObject *result = [[IndexExpr exprWithExpr:e subscriptExpr:Litn(-3)] evaluate:frame];
    STAssertEqualObjects(@"IndexError", result, nil);
}

- (void)testIndexExpr7 { // dict (existing key)
    Expr *e = Lit([NSDictionary dictionaryWithObject:@"v" forKey:@"k"]);
    NSObject *result = [[IndexExpr exprWithExpr:e subscriptExpr:Lit(@"k")] evaluate:frame];
    STAssertEqualObjects(@"v", result, nil);
}

- (void)testIndexExpr8 { // dict (non-existing key)
    Expr *e = Lit([NSDictionary dictionaryWithObject:@"v" forKey:@"k"]);
    NSObject *result = [[IndexExpr exprWithExpr:e subscriptExpr:Lit(@"x")] evaluate:frame];
    STAssertEqualObjects(@"KeyError", result, nil);
}

- (void)testIndexExprSet1 { // set list (positive index)
    NSMutableArray *a = [NSMutableArray arrayWithObjects:N(0), N(0), nil];
    [[IndexExpr exprWithExpr:Lit(a) subscriptExpr:Litn(1)] setValue:N(2) frame:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(N(2), [a objectAtIndex:1], nil);
}

- (void)testIndexExprSet2 { // set list (negative index)
    NSMutableArray *a = [NSMutableArray arrayWithObjects:N(0), N(0), nil];
    [[IndexExpr exprWithExpr:Lit(a) subscriptExpr:Litn(-1)] setValue:N(2) frame:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(N(2), [a objectAtIndex:1], nil);
}

- (void)testIndexExprSet3 { // set list (invalid index)
    NSMutableArray *a = [NSMutableArray arrayWithObjects:N(0), N(0), nil];
    NSObject *result = [[IndexExpr exprWithExpr:Lit(a) subscriptExpr:Litn(3)] setValue:N(2) frame:frame];
    STAssertEquals(kException, frame.resultType, nil);
    STAssertEqualObjects(@"IndexError", result, nil);
}

- (void)testIndexExprSet4 { // set dict
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObject:@"v" forKey:@"k"];
    [[IndexExpr exprWithExpr:Lit(d) subscriptExpr:Lit(@"k")] setValue:N(3) frame:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(N(3), [d objectForKey:@"k"], nil);
}


#pragma mark Testing attribute access


- (void)testAttrExpr1 {
    NSObject *result = [[AttrExpr exprWithExpr:Lit(@"abc") name:@"length"] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(N(3), result, nil);
}

- (void)testAttrExpr2 {
    NSObject *result = [[AttrExpr exprWithExpr:Lit(@"abc") name:@"invalid"] evaluate:frame];
    STAssertTrue(frame.resultType, nil);
    STAssertEqualObjects(@"AttributeError", result, nil);
}

- (void)testAttrExprSet1 {
    NSMutableString *s = [NSMutableString stringWithString:@"42"];
    Expr *e = [LiteralExpr exprWithValue:s];
    [[AttrExpr exprWithExpr:e name:@"string"] setValue:@"7" frame:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(@"7", s, nil);
}

- (void)testAttrExprSet2 {
    NSMutableString *s = [NSMutableString stringWithString:@"42"];
    Expr *e = [LiteralExpr exprWithValue:s];
    NSObject *result = [[AttrExpr exprWithExpr:e name:@"invalid"] setValue:@"7" frame:frame];
    STAssertTrue(frame.resultType, nil);
    STAssertEqualObjects(@"AttributeError", result, nil);
}


#pragma mark Testing constructor operations


- (void)testTupleExpr1 { // ()
    NSObject *result = [[TupleExpr exprWithExprs:[NSArray array]] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(result, [NSArray array], nil);
}

- (void)testTupleExpr2 { // (1, 1)
    NSArray *a = [NSArray arrayWithObjects:Litn(1), Litn(1), nil];
    NSObject *result = [[TupleExpr exprWithExprs:a] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    // () around NSArray required because of macro or parser error?!
    STAssertEqualObjects(result, ([NSArray arrayWithObjects:N(1), N(1), nil]), nil); 
}

- (void)testListExpr1 { // []
    NSObject *result = [[ListExpr exprWithExprs:[NSArray array]] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertTrue([result isKindOfClass:[NSMutableArray class]], nil);
    STAssertEqualObjects(result, [NSMutableArray array], nil);
}

- (void)testListExpr2 { // [1, 2]
    NSArray *a = [NSArray arrayWithObjects:Litn(1), Litn(2), nil];
    NSObject *result = [[ListExpr exprWithExprs:a] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertTrue([result isKindOfClass:[NSMutableArray class]], nil);
    // () around NSArray required because of macro or parser error?!
    STAssertEqualObjects(result, ([NSMutableArray arrayWithObjects:N(1), N(2), nil]), nil); 
}

- (void)testSetExpr1 { // {}
    NSObject *result = [[SetExpr exprWithExprs:[NSArray array]] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(result, [NSMutableSet set], nil);
}

- (void)testSetExpr2 { // {1, 1}
    NSArray *a = [NSArray arrayWithObjects:Litn(1), Litn(1), nil];
    NSObject *result = [[SetExpr exprWithExprs:a] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(result, [NSMutableSet setWithObject:N(1)], nil);
}

- (void)testDictExpr1 { // {}
    NSObject *result = [[DictExpr exprWithExprs:[NSArray array]] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(result, [NSMutableDictionary dictionary], nil);
}

- (void)testDictExpr2 { // {"a": 1}
    NSArray *a = [NSArray arrayWithObjects:[NSArray arrayWithObjects:Lit(@"a"), Litn(1), nil], nil];
    NSObject *result = [[DictExpr exprWithExprs:a] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(result, [NSMutableDictionary dictionaryWithObject:N(1) forKey:@"a"], nil);
}


#pragma mark Testing arithmetic operations

- (void)testPosExpr {
    STAssertEqualObjects(N(+1), [[PosExpr exprWithExpr:Litn(+1)] evaluate:frame], nil);
    STAssertEqualObjects(N(-1), [[PosExpr exprWithExpr:Litn(-1)] evaluate:frame], nil);
}

- (void)testNegExpr {
    STAssertEqualObjects(N(-1), [[NegExpr exprWithExpr:Litn(+1)] evaluate:frame], nil);
    STAssertEqualObjects(N(+1), [[NegExpr exprWithExpr:Litn(-1)] evaluate:frame], nil);
}

- (void)testAddExpr1 { // numbers
    NSObject *result = [[AddExpr exprWithLeftExpr:Litn(3) rightExpr:Litn(4)] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(N(7), result, nil);
}

- (void)testAddExpr2 { // strings
    NSObject *result = [[AddExpr exprWithLeftExpr:Lit(@"3") rightExpr:Lit(@"4")] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(@"34", result, nil);
}

- (void)testAddExpr3 { // lists
    Expr *l1 = Lit([NSArray arrayWithObject:N(1)]);
    Expr *l2 = Lit([NSArray arrayWithObjects: N(2), N(3), nil]);
    NSObject *result = [[AddExpr exprWithLeftExpr:l1 rightExpr:l2] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(([NSArray arrayWithObjects:N(1), N(2), N(3), nil]), result, nil);
}

- (void)testAddExpr4 { // invalid
    [[AddExpr exprWithLeftExpr:Litn(1) rightExpr:Lit(@"2")] evaluate:frame];
    STAssertEquals(kException, frame.resultType, nil);
}

- (void)testSubExpr1 { // numbers
    NSObject *result = [[SubExpr exprWithLeftExpr:Litn(3) rightExpr:Litn(4)] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(N(-1), result, nil);
}

- (void)testSubExpr2 { // invalid
    [[SubExpr exprWithLeftExpr:Litn(1) rightExpr:Lit(@"2")] evaluate:frame];
    STAssertEquals(kException, frame.resultType, nil);
}

- (void)testMulExpr1 { // numbers
    NSObject *result = [[MulExpr exprWithLeftExpr:Litn(3) rightExpr:Litn(4)] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(N(12), result, nil);
}

- (void)testMulExpr2 { // string*number
    NSObject *result = [[MulExpr exprWithLeftExpr:Lit(@"3") rightExpr:Litn(4)] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(@"3333", result, nil);
}

- (void)testMulExpr3 { // invalid
    [[MulExpr exprWithLeftExpr:Litn(1) rightExpr:Lit([NSArray array])] evaluate:frame];
    STAssertEquals(kException, frame.resultType, nil);
}

- (void)testDivExpr1 { // numbers
    NSObject *result = [[DivExpr exprWithLeftExpr:Litn(9) rightExpr:Litn(2)] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(N(4), result, nil);
}

- (void)testDivExpr2 { // invalid
    [[DivExpr exprWithLeftExpr:Litn(9) rightExpr:Lit([NSArray array])] evaluate:frame];
    STAssertEquals(kException, frame.resultType, nil);
}

- (void)testModExpr1 { // numbers
    NSObject *result = [[ModExpr exprWithLeftExpr:Litn(9) rightExpr:Litn(2)] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(N(1), result, nil);
}

- (void)testModExpr2 { // string%tuple
    Expr *t = [TupleExpr exprWithExprs:[NSArray arrayWithObject:Litn(7)]];
    NSObject *result = [[ModExpr exprWithLeftExpr:Lit(@"<%s>") rightExpr:t] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects(@"<7>", result, nil);
}

- (void)testModExpr3 { // invalid
    [[ModExpr exprWithLeftExpr:Litn(9) rightExpr:Lit([NSArray array])] evaluate:frame];
    STAssertEquals(kException, frame.resultType, nil);
}


#pragma mark Testing "in"


- (void)testInExpr1 { // strings
    NSObject *result = [[InExpr exprWithLeftExpr:Lit(@"b") rightExpr:Lit(@"abc")] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects([Pyphon True], result, nil);
}

- (void)testInExpr2 { // strings
    NSObject *result = [[InExpr exprWithLeftExpr:Lit(@"d") rightExpr:Lit(@"abc")] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects([Pyphon False], result, nil);
}

- (void)testInExpr3 { // sequence
    NSArray *a = [NSArray arrayWithObjects:N(3), N(2), N(1), nil];
    NSObject *result = [[InExpr exprWithLeftExpr:Litn(1) rightExpr:Lit(a)] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects([Pyphon True], result, nil);
}

- (void)testInExpr4 { // sequence
    NSArray *a = [NSArray arrayWithObjects:N(3), N(2), N(1), nil];
    NSObject *result = [[InExpr exprWithLeftExpr:Litn(0) rightExpr:Lit(a)] evaluate:frame];
    STAssertFalse(frame.resultType, nil);
    STAssertEqualObjects([Pyphon False], result, nil);
}

- (void)testInExpr5 { // invalid
    [[InExpr exprWithLeftExpr:Litn(0) rightExpr:Litn(1)] evaluate:frame];
    STAssertEquals(kException, frame.resultType, nil);
}


#pragma mark Testing logical expressions


- (void)testNotExpr {
    STAssertEqualObjects([Pyphon True], [[NotExpr exprWithExpr:Litn(0)] evaluate:frame], nil);
    STAssertEqualObjects([Pyphon True], [[NotExpr exprWithExpr:Lit(@"")] evaluate:frame], nil);
    STAssertEqualObjects([Pyphon True], [[NotExpr exprWithExpr:Lit([Pyphon False])] evaluate:frame], nil);
    STAssertEqualObjects([Pyphon True], [[NotExpr exprWithExpr:[TupleExpr exprWithExprs:[NSArray array]]] evaluate:frame], nil);
    STAssertEqualObjects([Pyphon True], [[NotExpr exprWithExpr:[DictExpr exprWithExprs:[NSArray array]]] evaluate:frame], nil);
    STAssertEqualObjects([Pyphon False], [[NotExpr exprWithExpr:Litn(1)] evaluate:frame], nil);
    STAssertEqualObjects([Pyphon False], [[NotExpr exprWithExpr:Lit(@"a")] evaluate:frame], nil);
    STAssertEqualObjects([Pyphon False], [[NotExpr exprWithExpr:Lit([Pyphon True])] evaluate:frame], nil);
}

- (void)testOrExpr {
    NSObject *result;
    result = [[OrExpr exprWithLeftExpr:Litn(1) rightExpr:Litn(2)] evaluate:frame];
    STAssertEqualObjects(N(1), result, nil);
    result = [[OrExpr exprWithLeftExpr:Litn(0) rightExpr:Litn(2)] evaluate:frame];
    STAssertEqualObjects(N(2), result, nil);
}

- (void)testAndExpr {
    NSObject *result;
    result = [[AndExpr exprWithLeftExpr:Litn(1) rightExpr:Litn(2)] evaluate:frame];
    STAssertEqualObjects(N(2), result, nil);
    result = [[AndExpr exprWithLeftExpr:Litn(0) rightExpr:Litn(2)] evaluate:frame];
    STAssertEqualObjects(N(0), result, nil);
}

- (void)testIfExpr {
    NSObject *result;
    result = [[IfExpr exprWithTestExpr:Litn(1) thenExpr:Litn(2) elseExpr:Litn(3)] evaluate:frame];
    STAssertEqualObjects(N(2), result, nil);
    result = [[IfExpr exprWithTestExpr:Litn(0) thenExpr:Litn(2) elseExpr:Litn(3)] evaluate:frame];
    STAssertEqualObjects(N(3), result, nil);
}


#pragma mark -
#pragma mark Statements


- (void)_runString:(NSString *)string {
    Parser *parser = [[Parser alloc] initWithString:string];
    Suite *suite = [parser parse_file];
    [suite evaluate:frame];
    STAssertFalse(frame.resultType, @"exceptional result");
}

- (void)testPassStmt {
    [self _runString:@"pass"];
}

- (void)testIfStmt1 {
    [self _runString:@"if 1:a=1\nelse:b=2"];
    STAssertEqualObjects(N(1), [frame localValueForName:@"a"], nil);
}

- (void)testIfStmt2 {
    [self _runString:@"if 0:a=1\nelse:b=2"];
    STAssertEqualObjects(N(2), [frame localValueForName:@"b"], nil);
}

- (void)testIfStmt3 {
    [self _runString:@"a=1\nif 1:a=2"];
    STAssertEqualObjects(N(2), [frame localValueForName:@"a"], nil);
}

- (void)testIfStmt4 {
    [self _runString:@"a=1\nif 0:a=2"];
    STAssertEqualObjects(N(1), [frame localValueForName:@"a"], nil);
}

- (void)testIfStmt5 {
    [self _runString:@"if 0:a=1\nelif 0:a=2\nelse:a=3"];
    STAssertEqualObjects(N(3), [frame localValueForName:@"a"], nil);
}

- (void)testWhileStmt1 {
    [self _runString:@"while 0:pass\nelse:b=1"];
    STAssertEqualObjects(N(1), [frame localValueForName:@"b"], nil);
}

- (void)testWhileStmt2 {
    [self _runString:@"a=0\nwhile a<2:a=a+1\nelse:b=1"];
    STAssertEqualObjects(N(2), [frame localValueForName:@"a"], nil);
    STAssertEqualObjects(N(1), [frame localValueForName:@"b"], nil);
}

- (void)testWhileStmt3 {
    [self _runString:@"a=0\nwhile a<2:\n    a=a+1\n    if a==1:break\nelse:a=0"];
    STAssertEqualObjects(N(1), [frame localValueForName:@"a"], nil);
}

@end
