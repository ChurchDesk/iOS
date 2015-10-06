//
//  CHDMessage.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 24/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessage.h"
#import "CHDComment.h"

@implementation CHDMessage
- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"messageId"]) {
        return @"id";
    }
    if ([propName isEqualToString:@"messageLine"]) {
        return @"lastMessageLine";
    }
    if ([propName isEqualToString:@"changeDate"]) {
        return @"updatedAt";
    }
    if ([propName isEqualToString:@"lastActivityDate"]) {
        return @"lastActivity";
    }
    if([propName isEqualToString:@"siteId"]) {
        return @"organizationId";
    }
    if([propName isEqualToString:@"lastCommentDate"]) {
        return @"lastReplyTime";
    }
    if([propName isEqualToString:@"lastActivityDate"]) {
        return @"lastReplyTime";
    }
    if([propName isEqualToString:@"read"]) {
        return @"hasRead";
    }
    if([propName isEqualToString:@"comments"]) {
        return @"replies";
    }
    return [super mapPropertyForPropertyWithName:propName];
}
- (Class)nestedClassForArrayPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"comments"]) {
        return [CHDComment class];
    }
    return [super nestedClassForArrayPropertyWithName:propName];
}

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    if([propName isEqualToString:@"comments"] && [value isKindOfClass:[NSArray class]]){
        NSArray *rawComments = value;
        NSMutableArray *comments = [[NSMutableArray alloc] init];

        [rawComments enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
            CHDComment *comment = [[CHDComment alloc] initWithDictionary:obj];
            [comments addObject:comment];
        }];

        if(comments.count == 1){
            return @[comments.firstObject];
        }

        NSArray *newComments = [comments sortedArrayUsingComparator:^NSComparisonResult(CHDComment *comment1, CHDComment *comment2) {
            return [comment1.createdDate compare:comment2.createdDate];
        }];

        return newComments;
    }

    return [super transformedValueForPropertyWithName:propName value:value];
}

@end
