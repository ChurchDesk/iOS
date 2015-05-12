//
// Created by kronborg on 08/01/13.
//


#import "News.h"


@implementation News

- (NSDateFormatter *)dateFormatterForPropertyWithName:(NSString *)propName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];

    return dateFormatter;
}

@end