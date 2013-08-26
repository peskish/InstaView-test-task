//
//  ViewController.h
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Item.h"
#import "ItemDetail.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, retain) UITableView *mainTable;
@property (nonatomic, retain) NSMutableArray *items;


@end

