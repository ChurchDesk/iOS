//
//  CHDTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDTableViewCell.h"

@interface CHDTableViewCell()
@property (nonatomic, strong) UIView* leftBorder;
@property (nonatomic, strong) UIView* separatorView;

@end

@implementation CHDTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeViews];
        [self makeConstraints];
    }

    return self;
}

-(void) makeViews {
    self.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.leftBorder];
    [self addSubview:self.separatorView];

    self.leftBorder.backgroundColor = [UIColor whiteColor];
}

-(void) makeConstraints{
    UIView*contentView = self.contentView;
    UIView* superview = self;

    [self.leftBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(contentView);
        make.width.equalTo(@3.5);
    }];

    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.equalTo(superview);
        make.height.equalTo(@1);
    }];
}

#pragma mark - Sub Views initialization

- (UIView *)leftBorder {
    if (!_leftBorder) {
        _leftBorder = [UIView new];
    }
    return _leftBorder;
}


-(UIView *) separatorView{
    if(!_separatorView){
        _separatorView = [UIView new];
        _separatorView.backgroundColor = [UIColor chd_categoryGreyColor];
    }

    return _separatorView;
}
@end
