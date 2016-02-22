//
//  MMReachabilityHandler.m
//  weather
//
//  Created by Petar Petrov on 02/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMReachabilityHandler.h"

@import UIKit;

@implementation MMReachabilityHandler

+ (void)performReachabilityCheckWithReachableBlock:(void (^)(void))reachableBlock unreachableBlock:(void (^)(void))unreachableBlock {
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    if (reach.isReachable ) {
        if (reachableBlock != nil) {
            reachableBlock();
        }
    } else {
        if (unreachableBlock != nil) {
            unreachableBlock();
        }
    }
}



@end
