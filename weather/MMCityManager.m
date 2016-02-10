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

#pragma mark - Public

- (void)saveChanges {
    __autoreleasing NSError *error = nil;
    
    [self.privateContext save:&error];
}

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


- (void)cityWithName:(NSString *)name updateForecast:(NSDictionary *)forecastInfo {
    NSManagedObjectContext *privateContext = [self.dataStore privateContext];
    
    City *city = [self cityWithName:name inContext:privateContext];
    
    Weather *updatedWeather = [self weatherForCityWithInfo:forecastInfo inManagedObjectContext:privateContext];
    
    city.currentWeather = updatedWeather;
    
    __autoreleasing NSError *error = nil;
    
    [privateContext save:&error];
}

- (void)cityWithID:(NSNumber *)cityID updateForecast:(NSDictionary *)forecastInfo {
    City *city = [self cityWithID:cityID inContext:self.privateContext];
    
    Weather *updatedWeather = [self weatherForCityWithInfo:forecastInfo inManagedObjectContext:self.privateContext];
    
    city.currentWeather = updatedWeather;
}


- (void)cityWithID:(NSNumber *)cityID updateFiveDayForecast:(NSArray *)forecastInfo {
    City *city = [self cityWithID:cityID inContext:self.privateContext];
    
    [city removeFiveDayForcast:city.fiveDayForcast];
    
    @autoreleasepool {
        for (NSDictionary *forecast in forecastInfo) {
            Weather *weather = [self weatherForCityWithInfo:forecast inManagedObjectContext:self.privateContext];
            
            [city addFiveDayForcastObject:weather];
        }
    }
    
    [self saveChanges];
    
}

#warning - error not handled
- (NSArray <Weather *> *)fiveDayForecastForCity:(City *)city {
    City *mainContextCity = [self.dataStore.mainContext existingObjectWithID:city.objectID error:nil];
    
    NSArray *fiveDayForecast = [mainContextCity.fiveDayForcast allObjects];
    
    fiveDayForecast = [fiveDayForecast sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dataTimeText" ascending:YES]]];
    
    return fiveDayForecast;
}

- (NSArray <City *> *)allCities {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([City class]) inManagedObjectContext:self.dataStore.mainContext];
    
    fetchRequest.entity = entity;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSArray *fetchedObjects = [self.dataStore.mainContext executeFetchRequest:fetchRequest error:nil];
    
    return fetchedObjects;
}

- (City *)cityWithName:(NSString *)name {
    City *city = [self cityWithName:name inContext:self.dataStore.mainContext];
    
    return city;
}

- (City *)cityWithID:(NSNumber *)cityID {
    City *city = [self cityWithID:cityID inContext:self.dataStore.mainContext];
    
    return city;
}

- (BOOL)deleteCityWithName:(NSString *)name error:(NSError **)error {
    City *city = [self cityWithName:name];
    
    return [self deleteCity:city error:error];
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

static NSString *const iconURLStringBase = @"http://openweathermap.org/img/w/";

- (NSString *)iconURLStringForWeather:(Weather *)weather {
    __autoreleasing NSError *error = nil;
    
    Weather *mainContextWeather = [self.dataStore.mainContext existingObjectWithID:weather.objectID error:&error];
    
    if (mainContextWeather != nil && error == nil) {
       return [NSString stringWithFormat:@"%@%@.png", iconURLStringBase, weather.icon];
    }
    
    return nil;
}

#pragma mark - Private

- (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-DD HH:mm:ss";
    
    return [dateFormatter dateFromString:dateString];
}

- (instancetype)initWithDataStore:(MMWeatherCoreData *)dataStore {
    self = [super init];
    
    if (self) {
        _dataStore = dataStore;
    }
    
    return self;
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
    
    // fix this
    currentWeather.weatherDescription = info[@"weather"][0][@"description"];
    currentWeather.weatherMain = info[@"weather"][0][@"main"];
    currentWeather.icon = info[@"weather"][0][@"icon"];
    
    
    currentWeather.timeStamp = info[@"dt"];
    
    NSArray *allKeys = [info allKeys];
    
    for (NSString *key in allKeys) {
        if ([key isEqualToString:@"dt_txt"]) {
            currentWeather.isFiveDayForecast = @(YES);
            currentWeather.dataTimeText = [self dateFromString:info[@"dt_txt"]];
            
            return currentWeather;
            
            break;
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
