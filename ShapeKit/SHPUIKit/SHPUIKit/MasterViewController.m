//
//  MasterViewController.m
//  SHPUIKit
//
//  Created by Kasper Kronborg on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"



#define UI_ELEMENT_TITLE_KEY @"UI_ELEMENT_TITLE_KEY"
#define UI_ELEMENT_SEGUE_KEY @"UI_ELEMENT_SEGUE_KEY"



@interface MasterViewController ()
@end



@implementation MasterViewController
{
    NSArray *_objects;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDictionary *button = @{
    UI_ELEMENT_TITLE_KEY: @"SHPButton",
    UI_ELEMENT_SEGUE_KEY: @"SHPButtonSegue"
    };

    _objects = @[ button ];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *object = [_objects objectAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = [object objectForKey:UI_ELEMENT_TITLE_KEY];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [_objects objectAtIndex:(NSUInteger)indexPath.row];
    [self performSegueWithIdentifier:[object objectForKey:UI_ELEMENT_SEGUE_KEY] sender:self];
}

@end