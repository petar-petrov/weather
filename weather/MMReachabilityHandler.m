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
    
//    reach.reachableBlock = ^(Reachability *reach) {
//        if (reach.currentReachabilityStatus != NotReachable)
//            if (reachableBlock != nil) {
//                reachableBlock();
//            }
//        
//    };
//    
//    reach.unreachableBlock = ^(Reachability *reach) {        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (unreachableBlock != nil) {
//                unreachableBlock();
//            }
//        });
//    };
//    
//    [reach startNotifier];
}



@end
