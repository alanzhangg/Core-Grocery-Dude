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
    
    BOOL useMigrationManager = YES;
    if (useMigrationManager &&
                                        [self isMigrationNecessaryForStore:[self storeURL]]) {
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    } else {
        NSDictionary *options = @{
                                  NSMigratePersistentStoresAutomaticallyOption:@YES ,NSInferMappingModelAutomaticallyOption:@NO ,NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"} };
        NSError *error = nil;
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                            configuration:nil
                                                      URL:[self storeURL]
                                                  options:options error:&error];
        if (!_store) {
            NSLog(@"Failed to add store. Error: %@", error);abort();
        }
        else {NSLog(@"Successfully added store: %@", _store);}
    }
    
//    NSDictionary *options =
//    @{NSMigratePersistentStoresAutomaticallyOption: @YES , NSInferMappingModelAutomaticallyOption : @YES};
//    
//    NSError * error = nil;
//    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
//    
//    if (!_store) {NSLog(@"Failed to add store. Error: %@", error);abort();}
//    else {if (debug==1) {NSLog(@"Successfully added store: %@", _store);}}
    
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

#pragma mark - MIGRATION MANAGER

- (BOOL)isMigrationNecessaryForStore:(NSURL*)storeUrl{
    if (debug) {
        NSLog(@"%@    %@", self.class, NSStringFromSelector(_cmd));
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        if (debug==1) {NSLog(@"SKIPPED MIGRATION: Source database missing.");} return NO;
    }
    
    NSError * error = nil;
    NSDictionary * sourceMetaata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeUrl error:&error];
    NSManagedObjectModel * destinationMetadata = _coordinator.managedObjectModel;
    if ([destinationMetadata isConfiguration:nil compatibleWithStoreMetadata:sourceMetaata]) {
        if (debug==1) {
            NSLog(@"SKIPPED MIGRATION: Source is already compatible");}
        return NO;
    }
    return YES;
}

- (BOOL)migrationStore:(NSURL *)sourceStore{
    if (debug) {
        NSLog(@"%@    %@", self.class, NSStringFromSelector(_cmd));
    }
    
    BOOL success = NO;
    NSError * error = nil;
    
    //step 1:gather the source, destination and mapping model
    NSDictionary * sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sourceStore error:&error];
    
    NSManagedObjectModel * sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetaData];
    NSManagedObjectModel * destinationModel = _model;
    NSMappingModel * mapModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:destinationModel];
    
    //step 2 perform migration assuming the mappin model isn't null
    if (mapModel) {
        NSError * error = nil;
        NSMigrationManager * migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinationModel];
        
        [migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];
        NSURL * destinStore = [[self applicationStoreDirectory] URLByAppendingPathComponent:@"Temp.sqlite"];
        success = [migrationManager migrateStoreFromURL:sourceStore type:NSSQLiteStoreType options:nil withMappingModel:mapModel toDestinationURL:destinStore destinationType:NSSQLiteStoreType destinationOptions:nil error:&error];
        if (success) {
            //step 3 replace the old store with the new migration store
            if ([self replaceStore:sourceStore withStore:destinStore]) {
                if (debug) {
                    NSLog(@"SUCCESSFULLY MIGRATED %@ to the Current Model",
                          sourceStore.path);
                }
                [migrationManager removeObserver:self forKeyPath:@"migrationProcess"];
            }
            
        }else{
            if (debug) {
                NSLog(@"FAILED MIGRATION: %@",error);
            }
        }
        
    }else {
        if (debug==1) {NSLog(@"FAILED MIGRATION: Mapping Model is null");}
    }
    return YES;

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress =
            [[change objectForKey:NSKeyValueChangeNewKey] floatValue]; self.migrationVC.progressView.progress = progress;
            int percentage = progress * 100;
            NSString *string =
            [NSString stringWithFormat:@"Migration Progress: %i%%", percentage];
             NSLog(@"%@",string);
             self.migrationVC.label.text = string;
        });
    }
}

- (BOOL)replaceStore:(NSURL *)old withStore:(NSURL *)new{
    BOOL success = NO;
    NSError *Error = nil;
    if ([[NSFileManager defaultManager]
         removeItemAtURL:old error:&Error]) {
        Error = nil;
        if ([[NSFileManager defaultManager]
             moveItemAtURL:new toURL:old error:&Error]) { success = YES;
        }
        else {
            if (debug==1) {NSLog(@"FAILED to re-home new store %@", Error);} }
    }
    else {
        if (debug==1) {
            NSLog(@"FAILED to remove old store %@: Error:%@", old, Error);
        } }
    return success;
}

- (void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL {
    if (debug) {
        NSLog(@"%@  %@", self.class, NSStringFromSelector(_cmd));
    }
    
    // Show migration progress view preventing the user from using the app
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationVC = [sb instantiateViewControllerWithIdentifier:@"migration"];
    UIApplication * sa = [UIApplication sharedApplication];
    UINavigationController * na = (UINavigationController *)sa.keyWindow.rootViewController;
    [na presentViewController:self.migrationVC animated:YES completion:^{
        
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL done = [self migrationStore:storeURL];
        if (done) {
            // When migration finishes, add the newly migrated store
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                _store =
                [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                           configuration:nil
                                                     URL:[self storeURL]
                                                 options:nil error:&error];
                if (!_store) {
                    NSLog(@"Failed to add a migrated store. Error: %@", error);abort();}
                else {
                    NSLog(@"Successfully added a migrated store: %@", _store);}
                [self.migrationVC dismissViewControllerAnimated:NO completion:nil];
                self.migrationVC = nil;
            });
            
            
        }
        
    });
    
}

@end






