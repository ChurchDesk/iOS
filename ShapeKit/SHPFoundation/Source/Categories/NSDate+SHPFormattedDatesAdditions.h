//
//  Created by Ole Gammelgaard Poulsen on 02/04/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SHPFormattedDatesAdditions)

- (NSString *)shp_stringWithTimeStyle:(NSDateFormatterStyle)timeStyle dateStyle:(NSDateFormatterStyle)dateStyle;
- (NSString *)shp_stringWithTimeStyle:(NSDateFormatterStyle)timeStyle;
- (NSString *)shp_stringWithDateStyle:(NSDateFormatterStyle)dateStyle;
- (NSString *)shp_stringWithDateFormat:(NSString *)dateFormat;

@end
