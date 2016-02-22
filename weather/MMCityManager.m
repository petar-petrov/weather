//
//  MMCityManager.m
//  weather
//
//  Created by Petar Petrov on 05/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMCityManager.h"

@interface MMCityManager ()

@property (strong, nonatomic, readwrite) MMWeatherCoreData *dataStore;

@property (strong, nonatomic) NSManagedObjectContext *privateContext;

@end

@implementation MMCityManager

#pragma mark - Custom Accessor

- (NSManagedObjectContext *)privateContext {
    if (!_privateContext) {
        _privateContext = [self.dataStore privateContext];
    }
    
    return _privateContext;
}

#pragma mark - Class

+ (instancetype)defaultManager {
    static MMCityManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MMCityManager alloc] initWithDataStore:[MMWeatherCoreData new]];
    });
    
    return manager;
}

#pragma mark - Initilizers

- (instancetype)initWithDataStore:(MMWeatherCoreData *)dataStore {
    self = [super init];
    
    if (self) {
        _dataStore = dataStore;
    }
    
    return self;
}

#pragma mark - Add/Delete City

- (void)addCityWithInfo:(NSDictionary *)info {
    // check if city already in the data store
    if ([self isCityWithIDInDataStore:info[@"id"]]) {
        return;
    }
    
    City *city = (City *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([City class]) inManagedObjectContext:self.dataStore.mainContext];
    
    if (city) {
        city.name = info[@"name"];
        city.cityID = info[@"id"];
        city.latitude = info[@"coord"][@"lon"];
        city.longitude = info[@"coord"][@"lat"];
        
        city.currentWeather = [self weatherForCityWithInfo:info inManagedObjectContext:self.dataStore.mainContext];
        
        [self.dataStore saveContext];
    }
}

- (BOOL)deleteCity:(City *)city error:(NSError **)error {
    
    City *cityToDelete = [self.dataStore.mainContext existingObjectWithID:city.objectID error:error];
    
    if (error) {
        return NO;
    }
    
    [self.dataStore.mainContext deleteObject:cityToDelete];
    
    if ([self.dataStore.mainContext save:error]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)deleteCityWithID:(NSNumber *)cityID error:(NSError *__autoreleasing *)error {
    City *city = [self cityWithID:cityID];
    
    return [self deleteCity:city error:error];
}

#pragma mark - City's Weather Forecast

- (void)cityWithID:(NSNumber *)cityID updateForecast:(NSDictionary *)forecastInfo save:(BOOL)flag {
    __weak MMCityManager *weakSelf = self;
    
    [self.privateContext performBlockAndWait:^{
        __strong MMCityManager *strongSelf = weakSelf;
        
        City *city = [strongSelf cityWithID:cityID inContext:strongSelf.privateContext];
        
        Weather *updatedWeather = [strongSelf weatherForCityWithInfo:forecastInfo inManagedObjectContext:strongSelf.privateContext];
        
        city.currentWeather = updatedWeather;
        
        if (flag) {
            __autoreleasing NSError *error = nil;
            
            if(![strongSelf.privateContext save:&error] && error != nil) {
                NSLog(@"%@ : %@", error, [error userInfo]);
                abort();
            }
        }
    }];
}


- (void)cityWithID:(NSNumber *)cityID updateFiveDayForecast:(NSArray *)forecastInfo {
    __weak MMCityManager *weakSelf = self;
    
    [self.privateContext performBlockAndWait:^{
        __strong MMCityManager *strongSelf = weakSelf;
        
        City *city = [strongSelf cityWithID:cityID inContext:strongSelf.privateContext];
        
        [city removeFiveDayForecast:city.fiveDayForecast];
        
        @autoreleasepool {
            for (NSDictionary *forecast in forecastInfo) {
                Weather *weather = [strongSelf weatherForCityWithInfo:forecast inManagedObjectContext:strongSelf.privateContext];
                
                [city addFiveDayForecastObject:weather];
            }
        }
        
        __autoreleasing NSError *error = nil;
        
        if(![strongSelf.privateContext save:&error] && error != nil) {
            NSLog(@"%@", error);
            abort();
        }
    }];
}

- (NSArray <Weather *> *)fiveDayForecastForCity:(City *)city {
    __autoreleasing NSError *error = nil;
    
    City *mainContextCity = [self.dataStore.mainContext existingObjectWithID:city.objectID error:&error];
    
    if (error == nil) {
        NSArray *fiveDayForecast = [mainContextCity.fiveDayForecast allObjects];
        
        fiveDayForecast = [fiveDayForecast sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dataTime" ascending:YES]]];
        
        return fiveDayForecast;
    }
    
    return nil;
}

#pragma mark - Retrieve City/s

- (NSArray <City *> *)allCities {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([City class]) inManagedObjectContext:self.dataStore.mainContext];
    
    fetchRequest.entity = entity;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSArray *fetchedObjects = [self.dataStore.mainContext executeFetchRequest:fetchRequest error:nil];
    
    return fetchedObjects;
}

- (City *)cityWithID:(NSNumber *)cityID {
    City *city = [self cityWithID:cityID inContext:self.dataStore.mainContext];
    
    return city;
}

#pragma mark - Utility

static NSString *const iconURLStringBase = @"http://openweathermap.org/img/w/";

- (NSString *)iconURLStringForWeather:(Weather *)weather {
    __autoreleasing NSError *error = nil;
    
    Weather *mainContextWeather = [self.dataStore.mainContext existingObjectWithID:weather.objectID error:&error];
    
    if (mainContextWeather != nil && error == nil) {
       return [NSString stringWithFormat:@"%@%@.png", iconURLStringBase, weather.icon];
    }
    
    return nil;
}

- (void)setCityAsFavorite:(City *)city {
    
    __weak MMCityManager *weakSelf = self;

    [self.privateContext performBlock:^{
        MMCityManager *strongSelf = weakSelf;
        
        // check if city is current favorite and if YES return
        City *currentFavoriteCity = [strongSelf favoriteCityInContext:strongSelf.privateContext];
        
        if (currentFavoriteCity.objectID == city.objectID) {
            return;
        }
        
        // unfavorite current
        currentFavoriteCity.favorite = @(NO);
        
        // set the city as favorite
        City *fCity = [self.privateContext existingObjectWithID:city.objectID error:nil];
        
        fCity.favorite = @(YES);
        
        __autoreleasing NSError *error = nil;
        
        if (![strongSelf.privateContext save:nil] && error != nil) {
            NSLog(@"%@:%@", error, [error userInfo]);
            abort();
        }
    }];
}

- (City *)favoriteCity {
    __block City *favoriteCity = nil;
    
    [self.dataStore.mainContext performBlockAndWait:^{
        favoriteCity = [self favoriteCityInContext:self.dataStore.mainContext];
    }];
    
    return favoriteCity;
}

#pragma mark - Private

- (City *)favoriteCityInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:context];

    request.predicate = [NSPredicate predicateWithFormat:@"favorite = YES"];
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    
    return [fetchedObjects lastObject];
}

- (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    
    return [dateFormatter dateFromString:dateString];
}



- (City *)cityWithName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([City class]) inManagedObjectContext:context];
    request.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    
    request.predicate = predicate;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    request.sortDescriptors = @[sortDescriptor];
    
    __autoreleasing NSError *error = nil;
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    City *city = nil;
    
    if (fetchedObjects != nil && error == nil) {
        city = [fetchedObjects lastObject];
    }
    
    return city;
}

- (City *)cityWithID:(NSNumber *)cityID inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([City class]) inManagedObjectContext:context];
    request.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cityID == %@", cityID];
    
    request.predicate = predicate;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    request.sortDescriptors = @[sortDescriptor];
    
    __autoreleasing NSError *error = nil;
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    City *city = nil;
    
    if (fetchedObjects != nil && error == nil) {
        city = [fetchedObjects lastObject];
    }
    
    return city;
}

- (Weather *)weatherForCityWithInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context {
    Weather *currentWeather = (Weather *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Weather class]) inManagedObjectContext:context];
    
    currentWeather.clouds = info[@"clouds"][@"all"];
    currentWeather.windDegree = info[@"wind"][@"deg"];
    currentWeather.windSpeed = info[@"wind"][@"speed"];
    currentWeather.temp = info[@"main"][@"temp"];
    currentWeather.pressure = info[@"main"][@"pressure"];
    currentWeather.humidity = info[@"main"][@"humidity"];
    currentWeather.sunset = info[@"sys"][@"sunset"];
    currentWeather.sunrise = info[@"sys"][@"sunrise"];
    
    // fix this
    currentWeather.weatherDescription = info[@"weather"][0][@"description"];
    currentWeather.weatherMain = info[@"weather"][0][@"main"];
    currentWeather.icon = info[@"weather"][0][@"icon"];
    
    
    currentWeather.timeStamp = info[@"dt"];
    
    NSArray *allKeys = [info allKeys];
    
    for (NSString *key in allKeys) {
        if ([key isEqualToString:@"dt_txt"]) {
            currentWeather.isFiveDayForecast = @(YES);
            currentWeather.dataTime = [self dateFromString:info[@"dt_txt"]];
            
            return currentWeather;
        }
    }
    
    currentWeather.isFiveDayForecast = @(NO);
    
    return currentWeather;
}

// think of better name for this method
- (BOOL)isCityWithIDInDataStore:(NSNumber *)cityID {
    City *city = [self cityWithID:cityID];
    
    if (!city) {
        return NO;
    }
    
    return YES;
}

@end
