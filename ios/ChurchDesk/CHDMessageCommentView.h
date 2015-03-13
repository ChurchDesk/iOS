//
//  CHDMessageCommentView.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHDMessageCommentView : UIView <UITextViewDelegate>
@property (nonatomic, readonly) UIButton* replyButton;
@property (nonatomic, readonly) UITextView *replyTextView;
-(void) clearTextInput;
@end
