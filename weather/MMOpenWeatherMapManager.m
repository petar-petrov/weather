//
//  MMOpenWeatherMapManager.m
//  weather
//
//  Created by Petar Petrov on 28/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMOpenWeatherMapManager.h"

#import "MMCityManager.h"

@import UIKit;

@interface MMOpenWeatherMapManager ()

@property (strong, nonatomic) NSURLSessionDataTask *dataTask;

@end

@implementation MMOpenWeatherMapManager

static NSString *const appid = @"36eea9dcce34a3ec067b176eda6c1987";

- (void)updateAllCitiesWithCompletionHandler:(void (^)(void))block {
        
    NSArray *cities = [[MMCityManager defaultManager] allCities];
    
    for (City *city in cities) {
        [self fetchWeatherForecaseForCity:city.name completionHandler:^(NSDictionary *weatherInfo){
            
            if (weatherInfo != nil) {
                
                [[MMCityManager defaultManager] cityWithName:city.name updateForecast:weatherInfo];
            }
            
        }];
    }
        
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ALL Cities updated");
        if (block != nil) {
            block();
        }
    });
    
}

- (void)fetchWeatherForecaseForCity:(NSString *)name  completionHandler:(void (^) (NSDictionary *))handler {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPAdditionalHeaders:@{@"Accept": @"applcatoin/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:nil
                                                     delegateQueue:nil];
    
    NSString *unit = [[NSUserDefaults standardUserDefaults] objectForKey:@"MMWeatherUnit"];
    
    NSURL *url = [self constructURLWithPath:@"/data/2.5/weather" queryDictionary:@{@"q" : name, @"appid" : appid, @"units" : unit}];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                if (error != nil) {
                                                    return;
                                                }
                                                
                                                id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (handler != nil) {
                                                        handler(result);
                                                        
                                                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                        
                                                        NSLog(@"City Updated");
                                                    }
                                                });
                                                
                                            }];
    [dataTask resume];
}

- (void)searchForCityWithText:(NSString *)text completionHandler:(void(^)(NSArray *))handler {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Accept": @"applcatoin/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    NSString *persentEncodedString = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSString *unit = [[NSUserDefaults standardUserDefaults] stringForKey:@"MMWeatherUnit"];
    
    NSURL *url = [self constructURLWithPath:@"/data/2.5/find" queryDictionary:@{@"q" : persentEncodedString, @"appid" : appid, @"units" : unit, @"type" : @"like"}];
    
    if (self.dataTask) {
        [self.dataTask cancel];
        self.dataTask = nil;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.dataTask = [session dataTaskWithURL:url
                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               
                               __autoreleasing NSError *jsonError = nil;
                               
                               if (httpResponse.statusCode == 200) {
                                   id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                                   
                                   if (!jsonError) {
                                       NSMutableArray *cityFound = [NSMutableArray new];
                                       
                                       for (NSDictionary *cityInfo in [result valueForKey:@"list"]) {
                                           [cityFound addObject:@{@"name" : [cityInfo valueForKey:@"name" ], @"cityData" : cityInfo}];
                                       }
                                    
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (handler != nil) {
                                               handler(cityFound);
                                           }
                                           
                                           [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                       });
                                   }
                               }
                           }];
    
    [self.dataTask resume];
}

#pragma mark - Private

- (NSURL *)constructURLWithPath:(NSString *)path queryDictionary:(NSDictionary *)items {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
    urlComponents.scheme = @"http";
    urlComponents.host = @"api.openweathermap.org";
    urlComponents.path = path;
    
    @autoreleasepool {
        if (items) {
            NSMutableArray *queryItems = [[NSMutableArray alloc] init];
            
            [items enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:obj];
                
                [queryItems addObject:item];
            }];
            
            urlComponents.queryItems = queryItems;
        }
    }
    
    return urlComponents.URL;
}

@end
