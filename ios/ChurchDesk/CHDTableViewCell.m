//
//  CHDTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDTableViewCell.h"

@interface CHDTableViewCell()
@property (nonatomic, strong) CHDCellBackgroundView* cellBackgroundView;

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
    
    [self insertSubview:self.cellBackgroundView atIndex:0];

    self.cellBackgroundView.backgroundColor = [UIColor whiteColor];
}

-(void) makeConstraints{
    [self.cellBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

}

#pragma mark - Sub Views initialization

- (CHDCellBackgroundView *)cellBackgroundView {
    if (!_cellBackgroundView) {
        _cellBackgroundView = [CHDCellBackgroundView new];
    }
    return _cellBackgroundView;
}
@end
