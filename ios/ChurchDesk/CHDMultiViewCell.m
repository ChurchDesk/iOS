//
//  CHDMultiViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMultiViewCell.h"

@interface CHDMultiViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *multiViewContainer;
@property (nonatomic, strong) UIView *leftContainer;
@property (nonatomic, strong) UIView *rightContainer;

@end

@implementation CHDMultiViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self addSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) addSubviews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.multiViewContainer];
    [self.multiViewContainer addSubview:self.leftContainer];
    [self.multiViewContainer addSubview:self.rightContainer];
}

- (void) makeConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).offset(kSideMargin);
        make.top.equalTo(self.contentView).offset(kSideMargin);
    }];
    
    [self.multiViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(14);
        make.right.equalTo(self.contentView).offset(-30);
        make.bottom.equalTo(self.contentView).offset(-kSideMargin);
    }];
    
    [self.leftContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.multiViewContainer);
        make.width.equalTo(self.multiViewContainer).multipliedBy(0.5);
    }];
    
    [self.rightContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.multiViewContainer);
        make.left.equalTo(self.leftContainer);
    }];
}

- (void) setViewsForMatrix: (NSArray*) views {
    [self.multiViewContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *previousView = nil;
    BOOL leftView = YES;
    for (UIView *view in views) {
        [self.multiViewContainer addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftView ? self.multiViewContainer : previousView.mas_right);
        }];
        
        previousView = view;
        leftView = !leftView;
    }
}

#pragma mark - Lazy Initialization

- (UILabel *)titleLabel {
    if (_titleLabel) {
        _titleLabel = [UILabel chd_regularLabelWithSize:17];
    }
    return _titleLabel;
}

- (UIView *)multiViewContainer {
    if (!_multiViewContainer) {
        _multiViewContainer = [UIView new];
    }
    return _multiViewContainer;
}

- (UIView *)leftContainer {
    if (!_leftContainer) {
        _leftContainer = [UIView new];
    }
    return _leftContainer;
}

- (UIView *)rightContainer {
    if (!_rightContainer) {
        _rightContainer = [UIView new];
    }
    return _rightContainer;
}

@end
