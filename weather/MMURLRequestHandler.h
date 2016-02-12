//
//  MMURLRequestHandler.h
//  weather
//
//  Created by Petar Petrov on 12/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMURLRequestHandler : NSObject

+ (void)dataRequestWithURL:(NSURL *)url successBlock:(void(^)(id data))successBlock failBlock:(void(^)(NSError *error))failBlock;

@end
