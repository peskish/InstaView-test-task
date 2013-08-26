//
//  Auth.h
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Keys.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface Auth : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate>

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLConnection *tokenRequestConnection;

@end
