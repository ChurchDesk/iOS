//
//  CHDPeopleTabBarController.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 15/03/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDPeopleTabBarController.h"
#import "CHDPeopleViewController.h"
#import "CHDSegmentsViewController.h"
#import "CHDTabItem.h"

@interface CHDPeopleTabBarController ()
@property (nonatomic, strong) UIView* buttonContainer;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) NSArray* buttons;
@property (nonatomic, strong) NSArray *items;
@end

@implementation CHDPeopleTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideTabButtons) name:khideTabButtons object:nil];
    // Do any additional setup after loading the view.
}

+ (instancetype) peopleTabBarViewController {
    CHDPeopleViewController *peopleViewController = [CHDPeopleViewController new];
    CHDSegmentsViewController *segmentsViewController = [CHDSegmentsViewController new];
    
    CHDTabItem* peopleItem = [CHDTabItem new];
    peopleItem.viewController = peopleViewController;
    peopleItem.imageNormal = kImgTabPeoplePassive;
    peopleItem.imageSelected = kImgTabPeopleActive;
    peopleItem.title = NSLocalizedString(@"People", @"");
    peopleItem.showNotification = NO;
    
    CHDTabItem* segmentsItem = [CHDTabItem new];
    segmentsItem.viewController = segmentsViewController;
    segmentsItem.imageNormal = kImgTabSegmentsPassive;
    segmentsItem.imageSelected = kImgTabSegmentsActive;
    segmentsItem.title = NSLocalizedString(@"Segments", @"");
    segmentsItem.showNotification = NO;
    
    NSArray *viewControllersArray = @[peopleItem, segmentsItem];
    return [[self alloc] initWithTabItems:viewControllersArray];
}

-(instancetype) initWithTabItems: (NSArray*) items {
    self.buttons = items;
    self = [super init];
    if(self){
        self.title = NSLocalizedString(@"People", @"");
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
            vc.chd_people_tabbarViewController = self;
            vc.chd_tabbarIdx = idx;
        }
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:item.imageNormal forState:UIControlStateNormal];
        [button setImage:item.imageSelected forState:UIControlStateSelected];
        [button setTitle:item.title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor chd_textDarkColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:12];
        
        //Get the title and image size to position them
        CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
        CGSize imageSize = button.imageView.image.size;
        
        // lower the text and push it left so it appe ,ars centered, use the title height to make the titles seem centered
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
        
        [self.buttonContainer addSubview:button];
        if ([button.titleLabel.text isEqualToString:NSLocalizedString(@"People", @"")]) {
            button.tag = 101;
        }
        else{
            button.tag = 102;
        }
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(!previousButton ? self.buttonContainer : previousButton.mas_right );
            make.top.bottom.equalTo(self.buttonContainer);
            make.width.equalTo(self.buttonContainer).multipliedBy( 1.0 / (CGFloat)items.count );
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
                self.title = NSLocalizedString(@"People", @"");
                [Heap track:@"People People tapped"];
                break;
            case 1:
                self.title = NSLocalizedString(@"Segments", @"");
                [Heap track:@"People Segments tapped"];
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

- (void)hideTabButtons{
    if (self.buttonContainer.hidden) {
        [self.buttonContainer setHidden:false];
    }
    else
    {
        [self.buttonContainer setHidden:true];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
