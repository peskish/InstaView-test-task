//
//  Item.m
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//



#import "Item.h"

@implementation Item

@synthesize userName, userAvatar, time, itemImage, liked, place, avatarURL, itemImageURL, type, itemId, videoURL;

- (void) loadUserAvatar: (NSString *) avatarUrlString {
    
    self.avatarURL = [NSURL URLWithString:avatarUrlString];
    
    NSURLRequest *avatarRequest = [[NSURLRequest alloc] initWithURL:self.avatarURL];
    
    //self.userAvatar = [UIImage imageNamed:@"avatar_placeholder"];
    
    AFImageRequestOperation *avatarOperation = [AFImageRequestOperation imageRequestOperationWithRequest:avatarRequest imageProcessingBlock:nil
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *responceImage){
                                                                                                     
        self.userAvatar = responceImage;
                                                                                                     
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                                     
        NSLog(@"fail load user avatar");
                                                                                                     
    }];
    [avatarOperation start];
    
}

- (void) loadItemImage: (NSString *) imageURL {
    
    self.itemImageURL = [NSURL URLWithString:imageURL];
    
    NSURLRequest *imageRequest = [[NSURLRequest alloc] initWithURL:self.itemImageURL];
        
    AFImageRequestOperation *imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:imageRequest imageProcessingBlock:nil
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *responceImage){
        
        self.itemImage = responceImage;
                                                                                                    
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                                    
                                                                                                    
    }];
    [imageOperation start];
    
}

@end