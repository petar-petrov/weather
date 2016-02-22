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
#import "MMURLRequestHandler.h"

@interface MMOpenWeatherMapManager () <NSURLSessionDelegate>

@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic, readwrite) NSDate *allCitiesLastUpdatedDate;
@property (nonatomic, readonly) NSString *unit;

@end

@implementation MMOpenWeatherMapManager

@synthesize allCitiesLastUpdatedDate = _allCitiesLastUpdatedDate;

static NSString *const kAllCitiesLastUpdatedDateKey = @"kAllCitiesLastUpdatedDateKey";

#pragma mark - Custom Accessors

- (NSString *)unit {
    return [MMUnitsManager sharedManager].currentUnit;
}

- (NSDate *)allCitiesLastUpdatedDate {
    
    if (!_allCitiesLastUpdatedDate) {
        _allCitiesLastUpdatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kAllCitiesLastUpdatedDateKey];
    }
    
    return _allCitiesLastUpdatedDate;
}

- (void) setAllCitiesLastUpdatedDate:(NSDate *)allCitiesLastUpdatedDate {
    if (![_allCitiesLastUpdatedDate isEqualToDate:allCitiesLastUpdatedDate]) {
        _allCitiesLastUpdatedDate = allCitiesLastUpdatedDate;
        
        [[NSUserDefaults standardUserDefaults] setObject:_allCitiesLastUpdatedDate forKey:kAllCitiesLastUpdatedDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

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

static NSString *const kAppID = @"36eea9dcce34a3ec067b176eda6c1987";

- (void)updateAllCitiesWithCompletionHandler:(void (^)(void))block {
        
    NSArray *cities = [[MMCityManager defaultManager] allCities];
    
    __weak MMOpenWeatherMapManager *weakSelf = self;
    
    [self fetchWeatherForecaseForCities:cities completionHandler:^(NSArray *citiesData) {
        MMOpenWeatherMapManager *strongSelf = weakSelf;
        
        for (int index = 0; index < citiesData.count; index++) {
            NSDictionary *cityData = citiesData[index];
            
            BOOL saveFlag = (index == (citiesData.count - 1)) ? YES : NO;
            
            [[MMCityManager defaultManager] cityWithID:cityData[@"id"] updateForecast:cityData save:saveFlag];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.allCitiesLastUpdatedDate = [NSDate date];
            
            if (block != nil) {
                block();
            }
        });
    }];
}

- (void)updateForecastForCityWithID:(NSNumber *)cityID completionHandler:(void(^)(void))handler {
    City *city = [[MMCityManager defaultManager] cityWithID:cityID];
    
    [self fetchWeatherForecaseForCities:@[city] completionHandler:^(NSArray *list){
        [[MMCityManager defaultManager] cityWithID:cityID updateForecast:[list lastObject] save:YES];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (handler != nil) {
            handler();
        }
    });
}

- (void)fetchFiveDayForecastForCityWithID:(NSNumber *)cityID completionHandler:(void (^)(NSError *error))handler {
    
    NSString *idsString = cityID.stringValue;
    
    NSURL *url = [self constructURLWithPath:@"/data/2.5/forecast" queryDictionary:@{@"id" : idsString, @"appid" : kAppID, @"units" : self.unit}];
    
    [MMURLRequestHandler dataRequestWithURL:url
                               successBlock:^(id data) {
                                   NSArray *forecast = data[@"list"];
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [[MMCityManager defaultManager] cityWithID:cityID updateFiveDayForecast:forecast];

                                       if (handler != nil) {
                                           handler(nil);
                                       }
                                       
                                   });
                               }
                                  failBlock:^(NSError *error) {
                                      if (handler != nil) {
                                          handler(error);
                                      }
                                      
                                  }];
}

- (void)fetchWeatherForecaseForCities:(NSArray <City *> *)cities  completionHandler:(void (^) (NSArray *))handler {
 
    NSString *idsString = @"";
    
    for (int index = 0; index < cities.count; index++) {
        
        City *city = (City *)cities[index];
        
        idsString = [idsString stringByAppendingString:city.cityID.stringValue];
        
        if (index != (cities.count - 1)) {
            idsString = [idsString stringByAppendingString:@","];
        }
    }
    
    NSURL *url = [self constructURLWithPath:@"/data/2.5/group" queryDictionary:@{@"id" : idsString, @"appid" : kAppID, @"units" : self.unit}];
    
    [MMURLRequestHandler dataRequestWithURL:url
                               successBlock:^(id data){
                                   NSArray *cities = data[@"list"];

                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (handler != nil) {
                                           handler(cities);
                                       }
                                   });
                               }
                                  failBlock:nil];
}

- (void)searchForCityWithText:(NSString *)text completionHandler:(void(^)(NSArray *))handler {
    
    NSString *persentEncodedString = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL *url = [self constructURLWithPath:@"/data/2.5/find" queryDictionary:@{@"q" : persentEncodedString, @"appid" : kAppID, @"units" : self.unit, @"type" : @"like"}];
    
    if (self.dataTask) {
        [self.dataTask cancel];
        self.dataTask = nil;
    }
    
    self.dataTask = [MMURLRequestHandler dataRequestWithURL:url
                                               successBlock:^(id data){
                                                   NSMutableArray *cityFound = [NSMutableArray new];
           
                                                  for (NSDictionary *cityInfo in [data valueForKey:@"list"]) {
                                                      [cityFound addObject:@{@"name" : [cityInfo valueForKey:@"name" ], @"cityData" : cityInfo}];
                                                  }
           
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      if (handler != nil) {
                                                          handler(cityFound);
                                                      }
                                                  });
                                               }
                                                  failBlock:nil];
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
