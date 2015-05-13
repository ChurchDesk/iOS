//
// Created by Jakob Vinther-Larsen on 27/02/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDCommonTableViewCell.h"


@interface CHDNewMessageTextViewCell : CHDCommonTableViewCell <UITextViewDelegate>
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, readonly) UITextView* textView;
@end