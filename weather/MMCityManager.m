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

@end

@implementation MMCityManager

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

- (void)addCityWithInfo:(NSDictionary *)info {
    // check if city already in the data store
    if ([self isCityInDataStore:info[@"name"]]) {
        return;
    }
    
    City *city = (City *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([City class]) inManagedObjectContext:self.dataStore.managedObjectContext];
    
    city.name = info[@"name"];
    city.cityID = info[@"id"];
    city.latitude = info[@"coord"][@"lon"];
    city.longitude = info[@"coord"][@"lat"];
    
    city.currentWeather = [self weatherForCityWithInfo:info inManagedObjectContext:self.dataStore.managedObjectContext];
    
    [self.dataStore saveContext];
}


- (void)cityWithName:(NSString *)name updateForecast:(NSDictionary *)forecastInfo {
    NSManagedObjectContext *privateContext = [self.dataStore privateContext];
    
    City *city = [self cityWithName:name inContext:privateContext];
    
    Weather *updatedWeather = [self weatherForCityWithInfo:forecastInfo inManagedObjectContext:privateContext];
    
    city.currentWeather = updatedWeather;
    
    __autoreleasing NSError *error = nil;
    
    [privateContext save:&error];
}


- (void)cityWithName:(NSString *)name updateFiveDayForecast:(NSArray *)forecastInfo {
    
}

- (NSArray <City *> *)allCities {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([City class]) inManagedObjectContext:self.dataStore.managedObjectContext];
    
    fetchRequest.entity = entity;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSArray *fetchedObjects = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return fetchedObjects;
}

- (City *)cityWithName:(NSString *)name {
    City *city = [self cityWithName:name inContext:self.dataStore.managedObjectContext];
    
    return city;
}

- (BOOL)deleteCityWithName:(NSString *)name error:(NSError **)error {
    City *city = [self cityWithName:name];
    
    return [self deleteCity:city error:error];
}

- (BOOL)deleteCity:(City *)city error:(NSError **)error {
    
    City *cityToDelete = [self.dataStore.managedObjectContext existingObjectWithID:city.objectID error:error];
    
    if (error) {
        return NO;
    }
    
    [self.dataStore.managedObjectContext deleteObject:cityToDelete];
    
    if ([self.dataStore.managedObjectContext save:error]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Private

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
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil]; // check for error
    
    City *city = [fetchedObjects lastObject];
    
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
            currentWeather.dataTimeText = info[@"dt_txt"];
            
            break;
        } else {
            currentWeather.isFiveDayForecast = @(NO);
            break;
        }
    }
    
    return currentWeather;
}

// think of better name for this method
- (BOOL)isCityInDataStore:(NSString *)name {
    City *city = [self cityWithName:name];
    
    if (!city) {
        return NO;
    }
    
    return YES;
}

@end
