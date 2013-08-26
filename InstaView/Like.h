//
//  Like.h
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiMethods.h"

@interface LikeButton : UIButton {
    
    BOOL liked;
    
}

@property (nonatomic, retain) NSString *itemId;
@property BOOL liked;

@end
