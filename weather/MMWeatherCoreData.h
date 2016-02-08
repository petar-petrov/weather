//
//  MMWeatherCoreData.h
//  weather
//
//  Created by Petar Petrov on 28/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@class City;

@interface MMWeatherCoreData : NSObject

+ (instancetype)defaultDataStore;

@property (strong, nonatomic, readonly) NSManagedObjectContext *mainContext;

/*!
 Save the current context
 */
- (void)saveContext;

- (NSManagedObjectContext *)privateContext;

@end
