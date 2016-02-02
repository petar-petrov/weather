//
//  MMWeatherCoreData.m
//  weather
//
//  Created by Petar Petrov on 28/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMWeatherCoreData.h"

#import "City.h"
#import "Weather.h"


@interface MMWeatherCoreData ()

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation MMWeatherCoreData

#pragma mark - Initilizer

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setupSaveNotification];
    }
    
    return self;
}

#pragma mark - Public

- (void)saveContext {
    __autoreleasing NSError *error = nil;
    
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)addCityWithInfo:(NSDictionary *)info {
    // check if city already in the data store
    if ([self isCityInDataStore:info[@"name"]]) {
        return;
    }
    
    City *city = (City *)[NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:self.managedObjectContext];
    
    city.name = info[@"name"];
    city.cityID = info[@"id"];
    city.latitude = info[@"coord"][@"lon"];
    city.longitude = info[@"coord"][@"lat"];
    
    city.currentWeather = [self weatherForCityWithInfo:info];
    
    [self saveContext];
}

- (void)cityWithName:(NSString *)name updateForecast:(NSDictionary *)forecastInfo {
    City *city = [self cityWithName:name];
    
    Weather *updatedWeather = [self weatherForCityWithInfo:forecastInfo];
    
    city.currentWeather = updatedWeather;
    
    [self saveContext];
}

- (void)cityWithName:(NSString *)name updateFiveDayForecast:(NSArray *)forecastInfo
{
    
}


- (NSArray *)allCities {
    
    return nil;
}

- (City *)cityWithName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    
    request.predicate = predicate;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:request error:nil]; // check for error
    
    City *city = [fetchedObjects lastObject];
    
    return city;
}

#pragma mark - Private

- (Weather *)weatherForCityWithInfo:(NSDictionary *)info
{
    Weather *currentWeather = (Weather *)[NSEntityDescription insertNewObjectForEntityForName:@"Weather" inManagedObjectContext:self.managedObjectContext];
    
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

- (void)setupSaveNotification {
    __weak MMWeatherCoreData *weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      MMWeatherCoreData *strongSelf = weakSelf;
                                                
                                                      if (note.object != strongSelf.managedObjectContext) {
                                                          [strongSelf.managedObjectContext performBlock:^{
                                                              [strongSelf.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
                                                          }];
                                                      };
                                                  }];
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    if (persistentStoreCoordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WeatherModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WeatherDB.sqlite"];
    
    __autoreleasing NSError *error = nil;
    
    NSDictionary *option = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                             NSInferMappingModelAutomaticallyOption : @YES};
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:option error:&error]) {
       NSLog(@"Unresolved error %@ : %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Document Directory

// Returns the URL to the applicaiton's Documents directory
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
