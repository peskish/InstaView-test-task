//
//  ApiMethods.h
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Keys.h"
#import "AFNetworking.h"

@interface ApiMethods : UIViewController

@property (nonatomic, retain) NSDictionary *resultDict;

static NSString *toString(id object);
static NSString *urlEncode(id object);
- (void) setToken: (NSString *)token;
- (NSString*) urlEncodedString: (NSDictionary *) dictionary;
- (NSMutableURLRequest *) sendRequest: (NSString *)method apiPath:(NSString *)apiPath params:(NSString *) requestParams;
- (NSMutableURLRequest *) getUserInfo;
- (NSMutableURLRequest *) getUsersFeed: (int)count maxID:(NSString *)maxID minID:(NSString *)minID;
- (void) clearCookies;

@end