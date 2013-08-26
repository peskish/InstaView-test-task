//
//  ItemDetail.h
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ViewController.h"
#import "Item.h"
#import "Like.h"

@interface ItemDetail : UIViewController <MKMapViewDelegate>

@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) NSIndexPath *itemIndexPath;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) MKMapView *map;
@property (nonatomic, retain) MPMoviePlayerController *player;

@end
