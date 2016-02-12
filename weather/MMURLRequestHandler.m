//
//  MMURLRequestHandler.m
//  weather
//
//  Created by Petar Petrov on 12/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMURLRequestHandler.h"

@implementation MMURLRequestHandler

+ (void)dataRequestWithURL:(NSURL *)url successBlock:(void(^)(id data))successBlock failBlock:(void(^)(NSError *error))failBlock {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Accept": @"applcatoin/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    [[session dataTaskWithURL:url
                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               if (httpResponse.statusCode != 200 && error != nil) {
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (failBlock != nil)
                                           failBlock(error);
                                   });
                                   
                                   return;
                               }
                               
                               NSError *jsonError = nil;
                               
                               id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                               
                               if (jsonError != nil) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (failBlock != nil)
                                           failBlock(jsonError);
                                   });
                                   
                                   return;
                               }
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (successBlock != nil) {
                                       successBlock(result);
                                   }
                               });
                               
                               
                           }] resume];
}

@end
