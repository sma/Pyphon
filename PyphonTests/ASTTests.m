//
//  ASTTests.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 18.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "ASTTests.h"
#import "Parser.h"

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
	NSObject *result = [[LiteralExpr withValue:one] evaluate:frame];
	STAssertEqualObjects(one, result, nil);
}

- (void)testVariableExpr1 {
    [frame setLocalValue:one forName:@"a"];
    NSObject *result = [[VariableExpr withName:@"a"] evaluate:frame];
    STAssertEqualObjects(one, result, nil);
}

- (void)testVariableExpr2 {
    [frame setGlobalValue:two forName:@"b"];
    NSObject *result = [[VariableExpr withName:@"b"] evaluate:frame];
    STAssertEqualObjects(two, result, nil);
}

- (void)testVariableExpr3 {
    [frame setLocalValue:one forName:@"c"];
    [frame setGlobalValue:two forName:@"c"];
    NSObject *result = [[VariableExpr withName:@"c"] evaluate:frame];
    STAssertEqualObjects(one, result, nil);
}

- (void)testVariableExpr4 {
    NSObject *result = [[VariableExpr withName:@"d"] evaluate:frame];
    STAssertNil(result, nil);
}

#pragma mark ==== statements ====

- (void)_runString:(NSString *)string {
    Parser *parser = [[Parser alloc] initWithString:string];
    Suite *suite = [parser parse_file];
    [parser release];
    [suite execute:frame];
}

- (void)testPassStmt {
    [self _runString:@"pass"];
}

- (void)testIfStmt1 {
    [self _runString:@"if 1:a=1\nelse:b=1"];
    STAssertEqualObjects(one, [frame localValueForName:@"a"], nil);
}

- (void)_testIfStmt2 {
    [self _runString:@"if 0:a=1\nelse:b=1"];
    STAssertEqualObjects(one, [frame localValueForName:@"b"], nil);
}

- (void)testWhileStmt1 {
    [self _runString:@"while 0:pass\nelse:b=1"];
    STAssertEqualObjects(one, [frame localValueForName:@"b"], nil);
}

- (void)testWhileStmt2 {
    [self _runString:@"a=0\nwhile a<2:a=a+1\nelse:b=1"];
    STAssertEqualObjects(two, [frame localValueForName:@"a"], nil);
    STAssertEqualObjects(one, [frame localValueForName:@"b"], nil);
}

@end
