//
//  ItemDetail.m
//  InstaView
//
//  Created by Artem Peskishev on 24.08.13.
//  Copyright (c) 2013 Artem Peskishev. All rights reserved.
//

#import "ItemDetail.h"

@interface ItemDetail () {
    
    LikeButton *like;
    ViewController *main;
    
}

@end

@implementation ItemDetail
@synthesize item, itemIndexPath, scrollView, map, player;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([player isPreparedToPlay]) {
        
        [player stop];
    }
    
    [item setLiked:[like liked]];
    [[main items] replaceObjectAtIndex:itemIndexPath.row withObject:item];
    
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad
{
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initItemDetailViews];
    
    main = [[ViewController alloc] init];
    
    [super viewDidLoad];
	
}

- (void) initItemDetailViews {
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height - 44)];
    [scrollView setBackgroundColor:[UIColor grayColor]];
    
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, 70)];
    [infoView setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:infoView];
    
    UIImageView *userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    [userAvatar setImage:[item userAvatar]];
    [infoView addSubview:userAvatar];
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 200, 20)];
    [userNameLabel setTextColor:[UIColor whiteColor]];
    [userNameLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [userNameLabel setBackgroundColor:[UIColor clearColor]];
    [userNameLabel setText:[item userName]];
    [infoView addSubview:userNameLabel];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[item time]];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 50, 250, 20)];
    [dateLabel setTextColor:[UIColor whiteColor]];
    [dateLabel setFont:[UIFont systemFontOfSize:11]];
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    [dateLabel setText:[NSString stringWithFormat:@"%@", [date descriptionWithLocale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]]];
    [infoView addSubview:dateLabel];
    
    like = [[LikeButton alloc] initWithFrame:CGRectMake(275, 5, 40, 40)];
    [like setItemId:[item itemId]];
    [like setLiked:[item liked]];
    [infoView addSubview:like];
    
    if ([item.type isEqualToString:@"video"]) {
        
        [self initVideoPlayer:[item videoURL]];
        
    } else {
        
        UIImageView *itemImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 70, 320, 320)];
        [itemImage setImage:[item itemImage]];
        [scrollView addSubview:itemImage];
    }
    

    
    UILabel *itemDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 400 + map.frame.size.height, scrollView.frame.size.width - 20, 50)];
    [itemDescriptionLabel setNumberOfLines:0];
    [itemDescriptionLabel setTextColor:[UIColor whiteColor]];
    [itemDescriptionLabel setBackgroundColor:[UIColor clearColor]];
    [itemDescriptionLabel setFont:[UIFont systemFontOfSize:14]];
    [itemDescriptionLabel setText:[item description]];
    [itemDescriptionLabel sizeToFit];
    [scrollView addSubview:itemDescriptionLabel];
    
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, [self calcScrollContentSize:scrollView].size.height + 20)];
    
    [self.view addSubview:scrollView];
    
}



- (void) initVideoPlayer: (NSURL *) videoURL {
    
    player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    player.view.frame = CGRectMake(0, 70, 320, 320);
    [player setMovieSourceType:MPMovieSourceTypeFile];
    player.shouldAutoplay = NO;
    [scrollView addSubview:player.view];
    
    [player prepareToPlay];
    
}

- (CGRect) calcScrollContentSize: (UIScrollView *) scroll {
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in scroll.subviews)
        contentRect = CGRectUnion(contentRect, view.frame);
    
    return contentRect;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
