//
//  MigratonVC.h
//  Grocery Dude
//
//  Created by zhang alan on 8/23/14.
//  Copyright (c) 2014 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MigratonVC.h"

@interface MigratonVC : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) MigratonVC * migrationVC;

@end
