//
//  AppDelegate.m
//  Grocery Dude
//
//  Created by Tim Roadley on 18/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import "AppDelegate.h"
#import "Item.h"
#import "Measurement.h"
#import "Unit.h"

#define debug 1

@implementation AppDelegate

- (void)demo{
    if (debug) {
        NSLog(@"%@      %@", self.class, NSStringFromSelector(_cmd));
    }
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Amount"];
    [request setFetchLimit:50];
    NSError * error = nil;
    NSArray * fetchObjects = [_coreDataHelper.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@", error);
    }else{
        for (Unit *unit in fetchObjects) {
            NSLog(@"Fetched Object = %@", unit.name);
        }
    }
    
//    for (int i = 0; i < 50000; i++) {
//        Measurement * newMeasurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:_coreDataHelper.context];
//        newMeasurement.abc = [NSString stringWithFormat:@"-->> LOTS OF TEST DATA x%i",i];
//        NSLog(@"Inserted %@",newMeasurement.abc);
//    }
//    [_coreDataHelper saveContext];
    
//    NSArray *newItemNames = [NSArray arrayWithObjects:
//                             @"Apples", @"Milk", @"Bread", @"Cheese", @"Sausages", @"Butter", @"Orange Juice", @"Cereal", @"Coffee", @"Eggs", @"Tomatoes", @"Fish", nil];
//    
//    for (NSString * newItemName in newItemNames) {
//        Item * newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_coreDataHelper.context];
//        newItem.name = newItemName;
//        NSLog(@"Inserted New Managed Object for '%@'", newItem.name);
//    }
//    [_coreDataHelper saveContext];
//
//    NSFetchRequest * request = [[[_coreDataHelper model] fetchRequestTemplateForName:@"Test"] copy];
//    
//    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
//    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
//    
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"name != %@", @"Coffee"];
//    [request setPredicate:filter];
//    
//    NSArray * fetchedObjects = [_coreDataHelper.context executeFetchRequest:request error:nil];
//    
//    for (Item * item in fetchedObjects) {
//        NSLog(@"Fetched Object = %@", item.name);
//        [_coreDataHelper.context deleteObject:item];
//    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    NSLog(@"%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
    
    
    return YES;
}

- (CoreDataHelper *)cdh{
    if (debug) {
        NSLog(@"%@    %@", self.class, NSStringFromSelector(_cmd));
    }
    
    if (!_coreDataHelper) {
        _coreDataHelper = [CoreDataHelper new];
        [_coreDataHelper setupCoreData];
    }
    
    return _coreDataHelper;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self cdh];
    [self demo];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self cdh];
    [self demo];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
