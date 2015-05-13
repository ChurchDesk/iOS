//
// Created by Jakob Vinther-Larsen on 24/04/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDOverlayView.h"
@interface CHDOverlayView()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation CHDOverlayView

- (instancetype)init {
    if(self = [super init]){
        [self setup];
    }
    return self;
}

-(void)setup {
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:.90];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self);
        make.left.greaterThanOrEqualTo(self);
        make.right.lessThanOrEqualTo(self);
    }];
}

-(UILabel*)titleLabel{
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end