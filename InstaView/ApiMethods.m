//
//  ApiMethods.m
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import "ApiMethods.h"

@interface ApiMethods ()
@end

@implementation ApiMethods
@synthesize resultDict;

- (NSMutableURLRequest *) sendRequest: (NSString *)method apiPath:(NSString *)apiPath params:(NSString *) requestParams {
    
    NSString *fullRequestString = [NSString stringWithFormat:@"%@%@/?%@&access_token=%@",
                                   INSTAGRAM_API_BASE,
                                   apiPath,
                                   requestParams,
                                   [[NSUserDefaults standardUserDefaults] objectForKey:@"i_token"]];
    
    NSLog(@"REAL URL: %@",fullRequestString);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullRequestString]];
    [request setCachePolicy:NSURLCacheStorageAllowed];
    [request setHTTPMethod:method];
    
    return request;
}

- (NSMutableURLRequest *) getUserInfo {
    
    NSString *users = [NSString stringWithFormat:@"users/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]];
    
    return [self sendRequest:@"GET" apiPath:users params:@""];
    
}

- (NSMutableURLRequest *) getUsersFeed: (int)count maxID:(NSString *)maxID minID:(NSString *)minID {
    
    NSString *feed = @"users/self/feed";
    
    return [self sendRequest:@"GET" apiPath:feed params:[NSString stringWithFormat:@"&count=%i&max_id=%@&min_id=%@", count, maxID, minID]];
    
}

- (void) setToken: (NSString *)token {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"i_token"];
    [defaults synchronize];
    
    [self setUserID:token];
    
}

- (void) setUserID: (NSString *) token {
    
    NSArray *tokenParts = [token componentsSeparatedByString:@"."];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[tokenParts objectAtIndex:0] forKey:@"user_id"];
    [defaults synchronize];
    
}

- (void) clearCookies {
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


#pragma mark - Dictionaty and URL encoding

static NSString *toString(id object) {
    
    return [NSString stringWithFormat:@"%@", object];
    
}

static NSString *urlEncode(id object) {
    
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
}

- (NSString*) urlEncodedString: (NSDictionary *) dictionary {
    
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in dictionary)
    {
        id value = [dictionary objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    
    return [parts componentsJoinedByString: @"&"];
    
}

@end
