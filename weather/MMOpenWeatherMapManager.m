//
//  MMOpenWeatherMapManager.m
//  weather
//
//  Created by Petar Petrov on 28/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMOpenWeatherMapManager.h"

#import "MMCityManager.h"
#import "MMUnitsManager.h"

@import UIKit;

@interface MMOpenWeatherMapManager () <NSURLSessionDelegate>

@property (strong, nonatomic) NSURLSessionDataTask *dataTask;

@end

@implementation MMOpenWeatherMapManager

#pragma mark - Initilizers

+ (instancetype)sharedManager {
    static MMOpenWeatherMapManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MMOpenWeatherMapManager new];
    });
    
    return manager;
}

#pragma mark - Public

static NSString *const appid = @"36eea9dcce34a3ec067b176eda6c1987";

- (void)updateAllCitiesWithCompletionHandler:(void (^)(void))block {
        
    NSArray *cities = [[MMCityManager defaultManager] allCities];
    
    [self fetchWeatherForecaseForCities:cities completionHandler:^(NSArray *citiesData) {
        for (NSDictionary *cityData in citiesData) {
            [[MMCityManager defaultManager] cityWithID:cityData[@"id"] updateForecast:cityData];
        }
        
        [[MMCityManager defaultManager] saveChanges];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block != nil) {
                block();
            }
        });
    }];
}

- (void)fetchFiveDayForecastForCityWithID:(NSNumber *)cityID completionHandler:(void (^)(void))handler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPAdditionalHeaders:@{@"Accept": @"applcatoin/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:nil
                                                     delegateQueue:nil];
    
    NSString *unit = [MMUnitsManager sharedManager].currentUnit;
    
    NSString *idsString = cityID.stringValue;
    
    NSURL *url = [self constructURLWithPath:@"/data/2.5/forecast" queryDictionary:@{@"id" : idsString, @"appid" : appid, @"units" : unit}];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                if (error != nil) {
                                                    return;
                                                }
                                                
                                                id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                
                                                NSArray *forecast = result[@"list"];
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [[MMCityManager defaultManager] cityWithID:cityID updateFiveDayForecast:forecast];
                                                    
                                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                    
                                                    if (handler != nil) {
                                                        handler();
                                                    }
                                                    
                                                });
                                                
                                            }];
    [dataTask resume];
}

- (void)fetchWeatherForecaseForCities:(NSArray <City *> *)cities  completionHandler:(void (^) (NSArray *))handler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPAdditionalHeaders:@{@"Accept": @"applcatoin/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:nil
                                                     delegateQueue:nil];
    
    NSString *unit = [MMUnitsManager sharedManager].currentUnit;
    
    NSString *idsString = @"";
    
    for (int index = 0; index < cities.count; index++) {
        
        City *city = (City *)cities[index];
        
        idsString = [idsString stringByAppendingString:city.cityID.stringValue];
        
        if (index != cities.count) {
            idsString = [idsString stringByAppendingString:@","];
        }
    }
    
    NSURL *url = [self constructURLWithPath:@"/data/2.5/group" queryDictionary:@{@"id" : idsString, @"appid" : appid, @"units" : unit}];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                if (error != nil) {
                                                    return;
                                                }
                                                
                                                id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                
                                                NSArray *cities = result[@"list"];
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (handler != nil) {
                                                        handler(cities);
                                                        
                                                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    
    NSString *unit = [MMUnitsManager sharedManager].currentUnit;
    
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
