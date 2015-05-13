//
//  Created by Ole Gammelgaard Poulsen on 29/04/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPAPIManager.h"

/*
Include the following in your Podfile to enable the Reactive Cocoa Extension

post_install do |installer_representation|
  installer_representation.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = '$(inherited) USE_REACTIVE_EXTENSION=1'
    end
  end
end
*/

@class SHPAPIResource;
@class RACSignal;

/* The key to use for retrieving the NSData object that we add to the userInfo dictionary of the NSError returned in the SHPAPIManagerResourceCompletionBlock
 */
extern NSString * const SHPAPIManagerReactiveExtensionErrorResponseKey;

@interface SHPAPIManager (ReactiveExtension)
- (RACSignal *)dispatchRequest:(SHPHTTPRequestBlock)requestBlock toResource:(SHPAPIResource *)resource;
- (RACSignal *)dispatchRequest:(SHPHTTPRequestBlock)requestBlock withBodyContent:(NSDictionary *)content toResource:(SHPAPIResource *)resource;
// Same as above, but by specifying NO in onlyResult the method will return the full SHPHTTPResponse object.
- (RACSignal *)dispatchRequest:(SHPHTTPRequestBlock)requestBlock withBodyContent:(NSDictionary *)content toResource:(SHPAPIResource *)resource onlyResult:(BOOL)onlyResult;

- (RACSignal *)dispatchRequest:(SHPHTTPRequestBlock)requestBlock withMultiparts:(NSArray *)parts toResource:(SHPAPIResource *)resource;
@end