//
// Created by kronborg on 08/01/13.
//


#import "FitnessWorldAPI.h"
#import "News.h"


@implementation FitnessWorldAPI

- (void)getNewsWithCompletion:(SHPAPIManagerResourceCompletionBlock)completion
{
    SHPAPIResource *newsResource = [[SHPAPIResource alloc] initWithPath:@"news"];
    [newsResource setResultKeyPath:@"news_items"];
    [newsResource setResultObjectClass:[News class]];
    [newsResource addValidator:[SHPBlockValidator validatorWithValidationBlock:^BOOL(id input, __autoreleasing NSError **error) {
        if ([input isKindOfClass:[NSDictionary class]] && [input objectForKey:@"news_items"]) {
            return YES;
        }

        NSString *domain = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        *error = [NSError errorWithDomain:domain code:1000 userInfo:@{ NSLocalizedDescriptionKey : @"Not validated" }];

        return NO;
    }]];

    [self.manager dispatchRequest:^(SHPHTTPRequest *request) {
        [request setMethod:SHPHTTPRequestMethodGET];
    } toResource:newsResource withCompletion:completion];
}

@end
