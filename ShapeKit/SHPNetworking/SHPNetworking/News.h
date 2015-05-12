//
// Created by kronborg on 08/01/13.
//


#import <Foundation/Foundation.h>


@interface News : SHPManagedModel
@property (nonatomic, copy) NSString *headline;
@property (nonatomic, copy) NSString *bodyText;
@property (nonatomic, strong) NSDate *date;
@end