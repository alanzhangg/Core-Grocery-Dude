//
//  CoreDataHelper.h
//  Grocery Dude
//
//  Created by zhang alan on 8/16/14.
//  Copyright (c) 2014 Tim Roadley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectModel * model;
@property (nonatomic, readonly) NSManagedObjectContext * context;
@property (nonatomic, readonly) NSPersistentStore * store;
@property (nonatomic, readonly) NSPersistentStoreCoordinator * coordinator;

- (void)setupCoreData;
- (void)saveContext;

@end
