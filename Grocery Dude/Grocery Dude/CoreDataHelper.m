//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by zhang alan on 8/16/14.
//  Copyright (c) 2014 Tim Roadley. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

#define debug 1

#pragma mark - FILES

NSString * storeFileName = @"Grocery-Dude.sqlite";

- (NSString *)applicationDocumentDirection{
    if (debug) {
        NSLog(@"%@  %@", self.class, NSStringFromSelector(_cmd));
    }
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)applicationStoreDirectory{
    if (debug) {
        NSLog(@"%@ %@", self.class, NSStringFromSelector(_cmd));
        NSLog(@"%@", [NSURL fileURLWithPath:[self applicationDocumentDirection]]);
    }
//    NSString * urlString = [[self applicationDocumentDirection] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * storeDirectory = [[NSURL fileURLWithPath:[self applicationDocumentDirection]] URLByAppendingPathComponent:@"Stores"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[storeDirectory path]]) {
        NSError * error = nil;
        if ([fileManager createDirectoryAtURL:storeDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            if (debug==1) {
                NSLog(@"Successfully created Stores directory");}
        
            else {NSLog(@"FAILED to create Stores directory: %@", error);}
        }
        
    }
    return storeDirectory;
}

- (NSURL *)storeURL{
    if (debug) {
        NSLog(@"%@    %@", self.class, NSStringFromSelector(_cmd));
        NSLog(@"%@", [self applicationStoreDirectory]);
    }
    
    
    return [[self applicationStoreDirectory] URLByAppendingPathComponent:storeFileName];
}

#pragma mark - setup

- (id)init{
    if (debug) {
        NSLog(@"%@   %@", self.class, NSStringFromSelector(_cmd));
    }
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:_coordinator];
    return self;
}

- (void)loadStore{
    if (debug) {
        NSLog(@"%@    %@", self.class, NSStringFromSelector(_cmd));
        NSLog(@"%@", [self storeURL]);
    }
    
    if (_store) {
        return;
    }
    NSDictionary *options =
    @{NSMigratePersistentStoresAutomaticallyOption: @YES , NSInferMappingModelAutomaticallyOption : @YES ,NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}};
    
    NSError * error = nil;
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
    
    if (!_store) {NSLog(@"Failed to add store. Error: %@", error);abort();}
    else {if (debug==1) {NSLog(@"Successfully added store: %@", _store);}}
}

- (void)setupCoreData {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self loadStore];
}

#pragma mark - SAVING

- (void)saveContext{
    if (debug) {
        NSLog(@"%@     %@", self.class, NSStringFromSelector(_cmd));
    }
    
    if ([_context hasChanges]) {
        NSError * error = nil;
        if ([_context save:&error]) {
            NSLog(@"_context SAVED changes to persistent store");
        }else{
            NSLog(@"Failed to save _context: %@", error);
        }
    }else{
        NSLog(@"SKIPPED _context save, there are no changes!");
    }
    
}

@end






