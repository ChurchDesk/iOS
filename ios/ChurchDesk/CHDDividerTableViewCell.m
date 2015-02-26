//
//  CHDDividerTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDividerTableViewCell.h"

@implementation CHDDividerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor chd_lightGreyColor];
        
        [self setupSubviews];
    }
    return self;
}

- (void) setupSubviews {
    UIView *topLineView = [UIView new];
    topLineView.backgroundColor = [UIColor chd_cellDividerColor];
    
    UIView *bottomLineView = [UIView new];
    bottomLineView.backgroundColor = [UIColor chd_cellDividerColor];
    
    [self addSubview:topLineView];
    [self addSubview:bottomLineView];
    
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@36);
    }];
}

@end
