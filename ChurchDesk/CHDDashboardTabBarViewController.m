//
//  CHDDashboardTabBarViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardTabBarViewController.h"
#import "CHDDashboardEventsViewController.h"
#import "CHDDashboardInvitationsViewController.h"
#import "CHDDashboardMessagesViewController.h"
#import "CHDTabItem.h"
#import "CHDDotView.h"

@interface CHDDashboardTabBarViewController ()
@property (nonatomic, strong) UIView* buttonContainer;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) NSArray* buttons;
@property (nonatomic, strong) NSArray *items;

@end

@implementation CHDDashboardTabBarViewController

+ (instancetype) dashboardTabBarViewController {
    CHDDashboardEventsViewController *dashboardEventsViewController = [CHDDashboardEventsViewController new];
    CHDDashboardInvitationsViewController *dashboardInvitationsViewController = [CHDDashboardInvitationsViewController new];
    CHDDashboardMessagesViewController *dashboardMessagesViewController = [[CHDDashboardMessagesViewController new] initWithStyle:CHDMessagesStyleUnreadMessages];

    CHDTabItem* eventsItem = [CHDTabItem new];
    eventsItem.viewController = dashboardEventsViewController;
    eventsItem.imageNormal = kImgTabCalendarPassive;
    eventsItem.imageSelected = kImgTabCalendarActive;
    eventsItem.title = NSLocalizedString(@"Today", @"");
    eventsItem.showNotification = NO;

    CHDTabItem* invitationsItem = [CHDTabItem new];
    invitationsItem.viewController = dashboardInvitationsViewController;
    invitationsItem.imageNormal = kImgTabInvitationPassive;
    invitationsItem.imageSelected = kImgTabInvitationActive;
    invitationsItem.title = NSLocalizedString(@"Invitations", @"");
    invitationsItem.showNotification = NO;

    CHDTabItem* messagesItem = [CHDTabItem new];
    messagesItem.viewController = dashboardMessagesViewController;
    messagesItem.imageNormal = kImgTabMailunread;
    messagesItem.imageSelected = kImgTabMailActive;
    messagesItem.title = NSLocalizedString(@"Unread", @"");
    messagesItem.showNotification = NO;

    NSArray *viewControllersArray = @[eventsItem, invitationsItem, messagesItem];

    return [[self alloc] initWithTabItems:viewControllersArray];
}

-(instancetype) initWithTabItems: (NSArray*) items {
    self.buttons = items;
    self = [super init];
    if(self){
        self.title = NSLocalizedString(@"Dashboard", @"");
        self.view.backgroundColor = [UIColor whiteColor];
        [self makeSubViews];
        [self setTabsWithItems:items];
    }
    return self;
}

-(void) makeSubViews {
    self.buttonContainer = [UIView new];
    [self.view addSubview:self.buttonContainer];
    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.equalTo(self.view);
        make.height.equalTo(@50);
    }];
}

-(void) setTabsWithItems: (NSArray *) items {
    __block UIButton* previousButton = nil;

    [items enumerateObjectsUsingBlock:^(CHDTabItem* item, NSUInteger idx, BOOL *stop) {

        if([item.viewController isKindOfClass:[CHDAbstractViewController class]]){
            CHDAbstractViewController *vc = (CHDAbstractViewController *)item.viewController;
            vc.chd_tabbarViewController = self;
            vc.chd_tabbarIdx = idx;
        }
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:item.imageNormal forState:UIControlStateNormal];
        [button setImage:item.imageSelected forState:UIControlStateSelected];
        [button setTitle:item.title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor chd_textDarkColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:12];

        CHDDotView* notification = [CHDDotView new];
        notification.dotColor = [UIColor chd_blueColor];

        //Get the title and image size to position them
        CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
        CGSize imageSize = button.imageView.image.size;

        // lower the text and push it left so it appears centered, use the title height to make the titles seem centered
        // to each other
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (titleSize.height * 2 + 2), 0.0);

        // raise the image and push it right so it appears centered
        //  above the text
        button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height - 2), 0.0, 0.0, - titleSize.width);

        RAC(button, backgroundColor) = [RACObserve(button, selected) map:^id(NSNumber *nSelected) {
            return nSelected.boolValue ? [UIColor chd_blueColor] : [UIColor chd_greyColor];
        }];

        [self rac_liftSelector:@selector(setSelectedIndex:) withSignals:[[button rac_signalForControlEvents:UIControlEventTouchUpInside] mapReplace:@(idx)], nil];

        RAC(button, selected) = [RACObserve(self, selectedIndex) map:^id(NSNumber *nSelectedIndex) {
            return @(nSelectedIndex.unsignedIntegerValue == idx);
        }];

        RAC(notification, hidden) = [RACObserve(item, showNotification) map:^id (NSNumber *nShow) {
            return @(!nShow.boolValue);
        }];

        [self.buttonContainer addSubview:button];
        [self.buttonContainer addSubview:notification];

        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(!previousButton ? self.buttonContainer : previousButton.mas_right );
            make.top.bottom.equalTo(self.buttonContainer);
            make.width.equalTo(self.buttonContainer).multipliedBy( 1.0 / (CGFloat)items.count );
        }];

        [notification mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(button).with.offset(5);
            make.centerX.equalTo(button).with.offset(18);
            make.width.height.equalTo(@8);
        }];

        previousButton = button;
    }];

    [self rac_liftSelector:@selector(setSelectedViewController:) withSignals:[RACObserve(self, selectedIndex) combinePreviousWithStart:@(NSNotFound) reduce:^id(NSNumber *nPrevious, NSNumber *nCurrent) {
        NSUInteger prevIdx = nPrevious.unsignedIntegerValue;
        NSUInteger currentIdx = nCurrent.unsignedIntegerValue;


        UIViewController *previousVC = prevIdx == NSNotFound ? nil : [(CHDTabItem*)items[prevIdx] viewController];
        UIViewController *currentVC = currentIdx == NSNotFound ? nil : [(CHDTabItem*)items[currentIdx] viewController];
        return RACTuplePack(previousVC, currentVC);
    }], nil];
    
    self.items = items;
}

- (void) setSelectedViewController: (RACTuple*) tuple {
    RACTupleUnpack(UIViewController *previousVC, UIViewController *selectedVC) = tuple;

    [previousVC willMoveToParentViewController:nil];
    [previousVC.view removeFromSuperview];
    [previousVC removeFromParentViewController];

    [self addChildViewController:selectedVC];
    [self.view addSubview:selectedVC.view];
    [selectedVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        switch (self.selectedIndex) {
            case 0:
                [Heap track:@"Dashboard today events tapped"];
                break;
            case 1:
                [Heap track:@"Dashboard invitations tapped"];
                break;
            case 2:
                [Heap track:@"Dashboard messages tapped"];
                break;
            default:
                break;
        }
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.buttonContainer.mas_top);
    }];

    [selectedVC didMoveToParentViewController:self];
}

- (void) notificationsForIndex: (NSUInteger) idx show: (BOOL) show {
    if(self.buttons.count > idx){
        CHDTabItem* item = self.buttons[idx];
        item.showNotification = show;
    }
}

- (BOOL) handleNotificationEventWithUserInfo: (NSDictionary*) userInfo {
    
    for (CHDTabItem *item in self.items) {
        UIViewController<CHDNotificationEventResponder> *viewController = (UIViewController<CHDNotificationEventResponder> *)item.viewController;
        if ([viewController respondsToSelector:@selector(canHandleEventWithUserInfo:)] && [viewController canHandleEventWithUserInfo:userInfo]) {
            NSUInteger index = [self.items indexOfObject:item];
            if (self.selectedIndex != index) {
                self.selectedIndex = index;
            }
            [viewController handleEventWithUserInfo:userInfo];
            return YES;
        }
    }
    return NO;
}

@end
