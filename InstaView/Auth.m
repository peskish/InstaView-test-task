//
//  Auth.m
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import "Auth.h"

@interface Auth () {
    
    AppDelegate *delegate;
    UIActivityIndicatorView *webViewAi;
    
}

@end

@implementation Auth
@synthesize webView;
@synthesize data;
@synthesize tokenRequestConnection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self checkToken];
    
    [super viewDidAppear:NO];
}

- (void)viewDidLoad {
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setHidesBackButton:YES];
    
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self createWebView];
    
    [super viewDidLoad];
    
}

- (void) checkToken {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"i_token"];
    
    if ([token length] > 3) {
        
        ViewController *mainView = [[ViewController alloc] init];
        [self.navigationController pushViewController:mainView animated:NO];
        
    } else {
        
        [self authorize];
        
    }
    
}

- (void) createWebView {
    
    webViewAi = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem *barAi = [[UIBarButtonItem alloc] initWithCustomView:webViewAi];
    self.navigationItem.leftBarButtonItem = barAi;
    
    UIBarButtonItem *barRefreshButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh"] style:UIBarButtonItemStyleBordered target:self action:@selector(authorize)];
    self.navigationItem.rightBarButtonItem = barRefreshButton;
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44)];
    [webView setScalesPageToFit:YES];
    [webView setDelegate:self];
    [self.view addSubview:webView];
    
}

- (void) authorize {
    
    if ([delegate getInternetReachabilitiStatus]) {
        
        tokenRequestConnection = nil;
        data = [NSMutableData data];
        
        NSString *scopeStr = @"scope=likes+comments";
        
        NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&display=touch&%@&redirect_uri=%@&response_type=code", CLIENT_ID, scopeStr, REDIRECT_URI];
        
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Авторизация невозможна. Отсутствует подключение к сети интернет. Подключитесь и нажмите обновить." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebView methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    [webViewAi startAnimating];
    
    NSString *responseString = [[request URL] absoluteString];
    
    NSString *urlCallbackPrefix = [NSString stringWithFormat:@"%@/?code=", REDIRECT_URI];
    
    if ([responseString hasPrefix:urlCallbackPrefix]) {
        
        NSString *authToken = [responseString substringFromIndex:[urlCallbackPrefix length]];
        
        NSURL *url = [NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        NSDictionary *authParamsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:authToken, @"code", REDIRECT_URI, @"redirect_uri", @"authorization_code", @"grant_type",  CLIENT_ID, @"client_id",  CLIENT_SECRET, @"client_secret", nil];
        
        NSString *authParamsString = [[delegate api] urlEncodedString:authParamsDictionary];
        
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        
        [request setHTTPMethod:@"POST"];
        [request addValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",charset] forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[authParamsString dataUsingEncoding:NSUTF8StringEncoding]];
        
        self.tokenRequestConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [self.tokenRequestConnection start];
        
        [webViewAi startAnimating];
        
        return NO;
        
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [webViewAi stopAnimating];
    
}

#pragma mark - NSURLConnection delegate methods

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data
{
    [self.data appendData:_data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.data setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *jsonError = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&jsonError];
    
    [webViewAi stopAnimating];
    
    if (jsonData && [NSJSONSerialization isValidJSONObject:jsonData]) {
        
        NSString *accesstoken = [jsonData objectForKey:@"access_token"];
        
        if (accesstoken) {
            
            [[delegate api] setToken:accesstoken];
            NSLog(@"access_token: %@", accesstoken);
            ViewController *mainView = [[ViewController alloc] init];
            [self.navigationController pushViewController:mainView animated:YES];
            
            return;
        }
    }
    
   
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}

@end
