//
//  Like.m
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import "Like.h"

@implementation LikeButton
@synthesize liked, itemId;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addTarget:self action:@selector(likeItem) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [self setLikeImage];
    
}

- (void) setLikeImage {
    
    if (liked) {
        
        [self setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        
    } else {
        
        [self setImage:[UIImage imageNamed:@"like_gray"] forState:UIControlStateNormal];
    }
    
}

- (void) likeItem {
    
    NSString *likes = [NSString stringWithFormat:@"media/%@/likes", itemId];
    NSString *fullRequestString = [NSString stringWithFormat:@"%@%@/?&access_token=%@",
                                   INSTAGRAM_API_BASE,
                                   likes,
                                   [[NSUserDefaults standardUserDefaults] objectForKey:@"i_token"]];
    
    NSLog(@"LIKE URL: %@",fullRequestString);
    
    NSMutableURLRequest *likeRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullRequestString]];
    
    if (liked) {
        
        liked = NO;
        [likeRequest setHTTPMethod:@"DELETE"];
    } else {
        
        liked = YES;
        [likeRequest setHTTPMethod:@"POST"];
    }
    
    [self setLikeImage];
    
    AFHTTPRequestOperation *likeOperation = [[AFHTTPRequestOperation alloc] initWithRequest:likeRequest];
    [likeOperation start];
    
}


@end

