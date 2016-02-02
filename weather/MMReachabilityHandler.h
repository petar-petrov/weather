//
//  MMReachabilityHandler.h
//  weather
//
//  Created by Petar Petrov on 02/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Reachability/Reachability.h>

@interface MMReachabilityHandler : NSObject

- (void)performReachabilityCheckWithReachableBlock:(void (^)(void))reachableBlock unreachableBlock:(void (^)(void))unreachableBlock;

@end
