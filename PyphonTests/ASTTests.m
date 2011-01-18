//
//  ASTTests.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 18.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "ASTTests.h"


@implementation ASTTests

- (void)setUp {
	frame = [[Frame alloc] 
             initWithLocals:[NSMutableDictionary dictionary]
             globals:[NSMutableDictionary dictionary]];
    one = [NSNumber numberWithInt:1];
    two = [NSNumber numberWithInt:2];
}

- (void)tearDown {
    [frame release];
}

#pragma mark ==== expressions ====

- (void)testLiteralExpr {
	NSObject *result = [[LiteralExpr withValue:one] eval:frame];
	STAssertEqualObjects(one, result, nil);
}

- (void)testVariableExpr1 {
    [frame setLocalValue:one forName:@"a"];
    NSObject *result = [[VariableExpr withName:@"a"] eval:frame];
    STAssertEqualObjects(one, result, nil);
}

- (void)testVariableExpr2 {
    [frame setGlobalValue:two forName:@"b"];
    NSObject *result = [[VariableExpr withName:@"b"] eval:frame];
    STAssertEqualObjects(two, result, nil);
}

- (void)testVariableExpr3 {
    [frame setLocalValue:one forName:@"c"];
    [frame setGlobalValue:two forName:@"c"];
    NSObject *result = [[VariableExpr withName:@"c"] eval:frame];
    STAssertEqualObjects(one, result, nil);
}

- (void)testVariableExpr4 {
    NSObject *result = [[VariableExpr withName:@"d"] eval:frame];
    STAssertNil(result, nil);
}

#pragma mark ==== statements ====

- (Stmt *)_effectValue:(NSNumber *)value {
    return [AssignStmt 
            withLeftExpr:[VariableExpr withName:@"e"] 
            rightExpr:[LiteralExpr withValue:value]];
}

- (void)testIfStmt1 {
    Stmt *stmt = [IfStmt 
                  withTestExpr:[LiteralExpr withValue:one]
                  thenSuite:[Suite withStmt:[self _effectValue:one]] 
                  elseSuite:[Suite withStmt:[self _effectValue:two]]];
    [stmt execute:frame];
    STAssertEqualObjects(one, [frame localValueForName:@"e"], nil);
}

- (void)testIfStmt2 {
    Stmt *stmt = [IfStmt 
                  withTestExpr:[LiteralExpr withValue:nil]
                  thenSuite:[Suite withStmt:[self _effectValue:one]] 
                  elseSuite:[Suite withStmt:[self _effectValue:two]]];
    [stmt execute:frame];
    STAssertEqualObjects(two, [frame localValueForName:@"e"], nil);
}

@end
