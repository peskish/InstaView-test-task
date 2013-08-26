//
//  Item.h
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface Item : NSObject

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *itemId;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *place;
@property double latitude;
@property double longtitude;
@property BOOL liked;
@property long time;

@property (nonatomic, retain) NSURL *avatarURL;
@property (nonatomic, retain) NSURL *itemImageURL;
@property (nonatomic, retain) UIImage *userAvatar;
@property (nonatomic, retain) UIImage *itemImage;

@property (nonatomic, retain) NSURL *videoURL;

- (void) loadItemImage: (NSString *) imageURL;
- (void) loadUserAvatar: (NSString *) avatarUrlString;

@end
