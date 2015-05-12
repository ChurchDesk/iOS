//
//  Created by Peter Gammelgaard on 02/05/14.
//  Copyright (c) 2013 SHAPE A/S. All rights reserved.
//

#import "MySecondViewController.h"


@implementation MySecondViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor grayColor]];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 50, 100, 40)];
    [button setTitle:@"Dismiss" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}


//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

@end