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

+ (instancetype)defaultDataStore {
    static MMWeatherCoreData *dataStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataStore = [[MMWeatherCoreData alloc] init];
    });
    
    return dataStore;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setupSaveNotification];
    }
    
    return self;
}

#pragma mark - Custom Accessors

- (NSManagedObjectContext *)mainContext {
    
    return self.managedObjectContext;
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

- (NSManagedObjectContext *)privateContext {
    NSManagedObjectContext *privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateManagedObjectContext.undoManager = nil;
    privateManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    return privateManagedObjectContext;
}

#pragma mark - Private

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
