//
//  ViewController.m
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    
    AppDelegate *delegate;
    NSManagedObjectContext *context;
    
   
    UIView *userInfoView;
    UIActivityIndicatorView *userAi;
    UIImageView *userImage;
    UILabel *nameLabel;
    UILabel *surnameLabel;
    
    BOOL isLoad;
    BOOL isLoadNew;
    UIActivityIndicatorView *tableBottomAi;
    
    UIView *refreshView;
    UIActivityIndicatorView *refreshAi;
    UILabel *refreshLabel;
    
}

@end

@implementation ViewController
@synthesize mainTable, items;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    
    [mainTable deselectRowAtIndexPath:[mainTable indexPathForSelectedRow] animated:NO];
    
    [self checkToken];
    
    [super viewDidAppear:YES];
}

- (void)viewDidLoad {
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    items = [[NSMutableArray alloc] init];
    
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = [delegate managedObjectContext];
    
    [self initControls];
    [self initUserInfoView];
    [self initTableView];
    
    [super viewDidLoad];
    
}

#pragma mark - Interface methods

- (void) initControls {
    
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setTitle:@"InstaView"];
    
    
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.frame = CGRectMake(0, 0, 60, 30);
    [logoutButton setTitle:@"Выход" forState:UIControlStateNormal];
    [logoutButton setShowsTouchWhenHighlighted:YES];
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *logoutBarButton = [[UIBarButtonItem alloc] initWithCustomView:logoutButton];
    [self.navigationItem setLeftBarButtonItem:logoutBarButton animated:YES];
    
}

- (void) initUserInfoView {
    
    userInfoView = [[UIView alloc]
                    initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, 100)];
    [userInfoView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:userInfoView];
    
    userAi = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 40, 10, 20, 20)];
    [userInfoView addSubview:userAi];
    
    userImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 70, 70)];
    [userImage setImage:[UIImage imageNamed:@"avatar_placeholder"]];
    [userInfoView addSubview:userImage];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 210, 30)];
    [nameLabel setTextColor:[UIColor blackColor]];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [userInfoView addSubview:nameLabel];
    
    [self performUserRequest:[[delegate api] getUserInfo]];
    
}

- (void) initTableView {
    
    mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 145, self.view.frame.size.width, self.view.frame.size.height - 145)];
    [mainTable setDelegate:self];
    [mainTable setDataSource:self];
    [self.view addSubview:mainTable];
    
    refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, -60, mainTable.frame.size.width, 60)];
    [refreshView setBackgroundColor:[UIColor lightGrayColor]];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, refreshView.frame.size.width, refreshView.frame.size.height)];
    [refreshLabel setTextAlignment:NSTextAlignmentCenter];
    [refreshLabel setTextColor:[UIColor whiteColor]];
    [refreshLabel setBackgroundColor:[UIColor clearColor]];
    [refreshLabel setText:@"Потяните вниз, чтобы обновить"];
    [refreshView addSubview:refreshLabel];
    
    refreshAi = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(30, 0, 20, refreshView.frame.size.height)];
    [refreshAi setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [refreshView addSubview:refreshAi];
    
    [mainTable addSubview:refreshView];
    
    tableBottomAi = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [tableBottomAi setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [mainTable setTableFooterView:tableBottomAi];
    
    [self refreshTable];
    
}


#pragma mark - Data methods

- (void) performUserRequest: (NSMutableURLRequest *) request {
    
    [userAi startAnimating];
    
    if ([delegate getInternetReachabilitiStatus]) {
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            [self updateUserInfo:JSON];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
        }];
        [operation start];
        
    } else {
        
        [self getUserInfoFromBase];
        [userAi stopAnimating];
        
    }
    
}

- (void) updateUserInfo: (id) userJSON {
    
    NSDictionary *userInfo = (NSDictionary *) [userJSON objectForKey:@"data"];
    
    if ([userInfo objectForKey:@"full_name"]) {
        
        [nameLabel setText:[userInfo objectForKey:@"full_name"]];
        
        if ([userInfo objectForKey:@"profile_picture"]) {
            
            //[userImage setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"profile_picture"]]];
            NSURL *imageURL = [NSURL URLWithString:[userInfo objectForKey:@"profile_picture"]];
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageURL];
            
            [userImage setImageWithURLRequest:imageRequest
                             placeholderImage:nil
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          
                                          userImage.image = image;
                                          [self deleteUserInfoFromBase];
                                          [self saveUserInfoToBase:[userInfo objectForKey:@"full_name"] :image];
                                          
                                          
                                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          NSLog(@"Fail to load user avatar");
                                          
                                      }];
            
        }
    }
    
    [userAi stopAnimating];
}

- (void) performFeedRequest: (NSMutableURLRequest *) request {
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        if (isLoadNew) {
            [items removeAllObjects];
        }
        [self loadFeedItems:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    [operation start];
    
}

- (void) loadFeedItems: (id) itemsJSON {
    
    for (NSDictionary *itemDict in [itemsJSON objectForKey:@"data"]) {
        
        [items addObject:[self setItem:itemDict]];
        
    }
    
    if ([items count] > 0) {
        [mainTable reloadData];
        isLoad = NO;
    }
    
    if ([refreshAi isAnimating]) {
        
        [refreshAi stopAnimating];
        [refreshLabel setText:@"Потяните вниз, чтобы обновить..."];
        isLoadNew = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [mainTable reloadRowsAtIndexPaths:[mainTable indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
        });
    }
    
    if ([tableBottomAi isAnimating]) {
        [tableBottomAi stopAnimating];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [mainTable reloadRowsAtIndexPaths:[mainTable indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

- (Item *) setItem: (NSDictionary *) itemDict {
    
    Item *item = [[Item alloc] init];
    
    [item setItemId:[itemDict objectForKey:@"id"]];
    
    NSDictionary *userTemp = [itemDict objectForKey:@"user"];
    if ([self isNotNullDict:userTemp]) {
        
        [item setUserName:[userTemp objectForKey:@"full_name"]];
        if ([userTemp objectForKey:@"profile_picture"])[item loadUserAvatar:[userTemp objectForKey:@"profile_picture"]];
        
    }
    
    NSDictionary *locationTemp = [itemDict objectForKey:@"location"];
    if ([self isNotNullDict:locationTemp]) {
        
        [item setPlace:[locationTemp objectForKey:@"name"]];
        [item setLatitude:[[locationTemp objectForKey:@"latitude"]doubleValue]];
        [item setLongtitude:[[locationTemp objectForKey:@"longitude"]doubleValue]];
        
    }
    
    NSDictionary *captionTemp = [itemDict objectForKey:@"caption"];
    if ([self isNotNullDict:captionTemp]) {
        
        NSNumber *time = [captionTemp objectForKey:@"created_time"];
        [item setTime:[time longLongValue]];
        
        [item setDescription:[captionTemp objectForKey:@"text"]];
        
    }
    
    if ([itemDict objectForKey:@"user_has_liked"])[item setLiked:[[itemDict objectForKey:@"user_has_liked"] boolValue]];
    
    if ([itemDict objectForKey:@"type"])[item setType:[itemDict objectForKey:@"type"]];
    
    if ([item.type isEqualToString:@"image"]) {
        
        NSDictionary *images = [itemDict objectForKey:@"images"];
        [item loadItemImage:[[images objectForKey:@"standard_resolution"] objectForKey:@"url"]];
        
    } else if ([item.type isEqualToString:@"video"]) {
        
        NSDictionary *videos = [itemDict objectForKey:@"videos"];
        [item setItemImage:[UIImage imageNamed:@"video_placeholder"]];
        [item setVideoURL:[NSURL URLWithString:[[videos objectForKey:@"standard_resolution"] objectForKey:@"url"]]];
        
    }
    
    return item;
    
}

- (BOOL) isNotNullDict: (id) object {
    
    if (![object isEqual:[NSNull null]] && [object isKindOfClass:[NSDictionary class]]) {
        
        return YES;
        
    } else {
        
        return NO;
        
    }
}

- (void) checkToken {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"i_token"];
    
    if ([token length] < 3) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
}

- (void) logout {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"i_token"];
    [defaults removeObjectForKey:@"user_id"];
    [defaults synchronize];
    
    [[delegate api] clearCookies];
    
    [self checkToken];
    
}

- (void) refreshTable {
    
    if ([delegate getInternetReachabilitiStatus]) {
        
        [refreshAi startAnimating];
        [refreshLabel setText:@"Загрузка данных..."];
        [self performFeedRequest:[[delegate api] getUsersFeed:15 maxID:@"" minID:@""]];
        
    } else {
        
        if ([refreshAi isAnimating]) [refreshAi stopAnimating];
        isLoad = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Невозможно обновить ленту. Отсутствует подключение к сети интернет." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
}

- (void) loadOlderItems {
    
    if ([delegate getInternetReachabilitiStatus]) {
        
        if ([items count] != 0) {
            
            [tableBottomAi startAnimating];
            [self performFeedRequest:[[delegate api] getUsersFeed:10 maxID:[[items objectAtIndex:[items count] - 1] itemId] minID:@""]];
        }
        
    } else {
        
        isLoad = NO;
        
    }
}


#pragma mark - UITableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Item *item = [items objectAtIndex:indexPath.row];
    
    UIImageView *backgroundItemImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [cell.contentView addSubview:backgroundItemImage];
    
    if (item.itemImage) {
      
        [backgroundItemImage setImage:[item itemImage]];
        
    } else {
        
        [backgroundItemImage setImage:[UIImage imageNamed:@"post_placeholder"]];
    }
    
    UIImageView *userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
    [cell.contentView addSubview:userAvatar];
    
    if (item.userAvatar) {
        
        [userAvatar setImage:[item userAvatar]];
        
    } else {
        
        [UIImage imageNamed:@"avatar_placeholder"];
    }
    
    UIColor *textColor = [UIColor whiteColor];
    UIColor *shadowColor = [UIColor blackColor];
    CGSize shadowSize = CGSizeMake(1.0f, -1.0f);
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 200, 20)];
    [userNameLabel setTextColor:textColor];
    [userNameLabel setBackgroundColor:[UIColor clearColor]];
    [userNameLabel setText:[item userName]];
    [userNameLabel setShadowColor:shadowColor];
    [userNameLabel setShadowOffset:shadowSize];
    [cell.contentView addSubview:userNameLabel];
    

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    dispatch_async(dispatch_get_current_queue(), ^{
        [mainTable reloadRowsAtIndexPaths:[mainTable indexPathsForVisibleRows] withRowAnimation: UITableViewRowAnimationNone];
    });
    
    ItemDetail *detailView = [[ItemDetail alloc] init];
    [detailView setItem:[items objectAtIndex:indexPath.row]];
    [detailView setItemIndexPath:indexPath];
    [self.navigationController pushViewController:detailView animated:YES];
    
}


#pragma mark - UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    

    
}

#pragma mark - CoreData methods

- (void) saveUserInfoToBase: (NSString *) userName :(UIImage *) userAvatarImage {

    
}

- (void) getUserInfoFromBase {
    

}

- (void) deleteUserInfoFromBase {
    

}

@end
