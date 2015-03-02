//
//  CHDMultiViewTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMultiViewTableViewCell.h"

@interface CHDMultiViewTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *multiViewContainer;
@property (nonatomic, strong) UIView *leftContainer;
@property (nonatomic, strong) UIView *rightContainer;

@end

@implementation CHDMultiViewTableViewCell

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
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10); 
        make.right.equalTo(self.contentView).offset(-30);
        make.bottom.equalTo(self.contentView).offset(-kSideMargin);
    }];
    
    [self.leftContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.multiViewContainer);
        make.width.equalTo(self.multiViewContainer).multipliedBy(0.5);
    }];
    
    [self.rightContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.multiViewContainer);
        make.left.equalTo(self.leftContainer.mas_right);
    }];
}

- (void) setViewsForMatrix: (NSArray*) views {
    [self.leftContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.rightContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    BOOL oddCount = (views.count % 2);
    UIView *container = self.leftContainer;
    for (UIView *view in views) {
        UIView *previousView = container.subviews.lastObject;
        BOOL lastView = view == views.lastObject ||
                        (container == self.rightContainer && oddCount && [views indexOfObject:view] == views.count-2);
        
        [container addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(container);
            make.top.equalTo(previousView ? previousView.mas_bottom : container).offset(previousView ? 10 : 0);
            if (lastView) {
                make.bottom.equalTo(container);
            }
        }];
        
        container = container == self.leftContainer ? self.rightContainer : self.leftContainer;
    }
}

#pragma mark - Lazy Initialization

- (UILabel *)titleLabel {
    if (!_titleLabel) {
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
