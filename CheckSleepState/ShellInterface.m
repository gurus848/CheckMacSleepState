//
//  ShellInterface.m
//  CheckSleepState
//
//  Created by Guru Senthil on 11/10/16.
//  Copyright © 2016 Guru Senthil. All rights reserved.
//

#import "ShellInterface.h"

@implementation ShellInterface

-(id)init {
    if ( self = [super init] ) {
        
    }
    return self;
}

- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

@end
