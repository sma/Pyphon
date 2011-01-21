//
//  Tester.m
//  Pyphon
//
//  Created by Stefan Matthias Aust on 19.01.11.
//  Copyright 2011 I.C.N.H. All rights reserved.
//

#import "Tester.h"
#import "Parser.h"


@implementation Tester

- (NSString *)runContentsOfFile:(NSString *)path {
    NSMutableString *report = [NSMutableString string];
    
    NSArray *lines = [[NSString stringWithContentsOfFile:path
                                                encoding:NSUTF8StringEncoding 
                                                   error:nil]
                      componentsSeparatedByString:@"\n"];

    NSMutableString *buffer = [NSMutableString string];
    
    for (NSString *line in lines) {
        if ([line length] == 0 || [line characterAtIndex:0] == '#') {
            continue;
        }
        if ([line hasPrefix:@">>> "] || [line hasPrefix:@"... "]) {
            [buffer appendString:[line substringFromIndex:4]];
            [buffer appendString:@"\n"];
        } else {
            NSString *source = buffer;
            NSString *expected = line;

            [report appendString:@"----------\n"];
            [report appendString:source];
            
            Parser *p = [[Parser alloc] initWithString:source];
            Suite *s = [p parse_file];
            [p release];
            NSMutableDictionary *d = [[NSMutableDictionary alloc] init]; 
            Frame *f = [[Frame alloc] initWithLocals:d globals:d];
            [d release];
            
            @try {
                NSString *actual = [[s evaluate:f] __repr__];

                if ([actual isEqualToString:expected]) {
                    [report appendString:@"\nOK\n"];
                } else {
                    [report appendString:@"\nActual  : "];
                    [report appendString:actual];
                    [report appendString:@"\nExpected: "];
                    [report appendString:expected];
                    [report appendString:@"\n"];
                }
            }
            @catch (NSException *exception) {
                [report appendFormat:@"\n%@: %@\n", exception.name, exception.reason];
            }
            
            [f release];
            
            [buffer setString:@""];
        }
    }
    if ([buffer length]) {
        @throw NSInvalidArgumentException;
    }
    
    return report;
}

+ (NSString *)run {
    Tester *tester = [[Tester alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"parsertests" ofType:@"py"];
    NSString *report = [tester runContentsOfFile:path];
    [tester release];
    NSLog(@"%@", report);
    return report;
}

@end
