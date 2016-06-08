//
//  CHDCreatePersonViewController.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 03/06/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import "CHDCreatePersonViewController.h"
#import "CHDStatusView.h"

@interface CHDCreatePersonViewController ()
@property (nonatomic, strong) CHDStatusView *statusView;
@end



@implementation CHDCreatePersonViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Create Contact", @"");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTouch)];
        UIBarButtonItem *sendButton = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Create", @"") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTouch)];
        [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
        self.navigationItem.rightBarButtonItem = sendButton;
        //self.messageViewModel = [CHDCreateMessageMailViewModel new];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeViews];
    [self makeConstraints];
    //[self makeBindings];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
}

-(void) leftBarButtonTouch{
    [self.view endEditing:YES];
    //Cancel the creation of new message
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)rightBarButtonTouch {
    
}

#pragma mark - Lazy initialization

-(void) makeViews {
    //[self.view addSubview:self.tableView];
    
    self.statusView = [[CHDStatusView alloc] init];
    self.statusView.successText = NSLocalizedString(@"Your message was sent", @"");
    self.statusView.processingText = NSLocalizedString(@"Sending message..", @"");
    self.statusView.autoHideOnSuccessAfterTime = 0;
    self.statusView.autoHideOnErrorAfterTime = 0;
}

-(void) makeConstraints {
    /*[self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];*/
}

//-(void) makeBindings {
//    [self rac_liftSelector:@selector(chd_willToggleKeyboard:) withSignals:[self shp_keyboardAwarenessSignal], nil];
//    
//    //put text if exists
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:kpeopleSubjectText]) {
//        self.messageViewModel.title = [defaults objectForKey:kpeopleSubjectText];
//    }
//    if ([defaults objectForKey:kPeopleMessageText]) {
//        self.messageViewModel.message = [defaults objectForKey:kPeopleMessageText];
//    }
//    
//    //Change the state of the send button
//    RAC(self.navigationItem.rightBarButtonItem, enabled) = RACObserve(self.messageViewModel, canSendMessage);
//}

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
