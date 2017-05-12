//
//  main.m
//  triggerDistributedNotification
//
//  Created by Joël Spaltenstein on 5/12/17.
//  Copyright © 2017 Spaltenstein Natural Image. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *hash = [NSString stringWithUTF8String:argv[2]];

        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"IPFSDicomTriggerNotification" object:nil userInfo:@{@"hash": hash} deliverImmediately:YES];
//        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"IPFSDicomTriggerNotification" object:nil];
//        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"IPFSDicomTriggerNotification" object:nil userInfo:@{@"hash": hash}];
    }
    return 0;
}
