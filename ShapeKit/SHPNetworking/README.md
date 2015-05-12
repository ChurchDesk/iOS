# SHPNetworking

## Working with SHPAPIManager
An API manager can be used out-of-the-box. All you really need, is to dispatch a request to a resource and boom you're off. 

	// Instantiate a manager with a base URL.
	SHPAPIManager *manager = [[SHPAPIManager alloc] init];
	[manager setBaseURL:[NSURL URLWithString:@"http://your.api.com"]];
	
	// Instantiate a resource with a path for the resource and a resulting class for the response.
	SHPAPIResource *resource = [[SHPAPIResource alloc] initWithPath:@"books"]; // With no "/" since that would be relative.
	[resource setResultClass:[NSArray class]];
	
	[resource addValidator:[SHPBlockValidator validatorWithBlock:(BOOL)^(id input, *error) {
		return [res isKindOfClas:[NSDictionary class]];
	}]];
	
	// Dispatch a request to the resource.
	[manager dispatchRequest:^(SHPHTTPRequest *request) {
		// Yield the request as a GET request - GET is default.
		[request setMethod:SHPHTTPRequestMethodGET];
		
	} toResource:resource withCompletion:^(NSArray *result, NSError *error) {
		// Our result is an array as defined on the resource earlier.

		if (!error) {
			NSLog(@"Books: %@", result);
		}
	}];

