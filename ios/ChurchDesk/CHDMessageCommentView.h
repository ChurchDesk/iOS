//
//  CHDMessageCommentView.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CHDCommentViewState) {
    CHDCommentViewStateReply,
    CHDCommentViewStateUpdate,
};

@interface CHDMessageCommentView : UIView <UITextViewDelegate>
@property (nonatomic, readonly) UIButton* replyButton;
@property (nonatomic, readonly) UITextView *replyTextView;
@property (nonatomic, readonly) BOOL hasText;
@property (nonatomic) NSInteger textViewMaxHeight;
@property (nonatomic, assign) CHDCommentViewState state;
- (void) clearTextInput;
- (void) setTextInput: (NSString*) text;
@end
