//
// Created by philip on 23/10/14.
//
// Copyright SHAPE A/S
//

#import "SHPCryptoTests.h"
#import "SHPCrypto.h"

@implementation SHPCryptoTests

- (void)setUp
{
    [super setUp];

    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}

- (void)testSHA1Digest
{
    NSString *str = @"This is some great test data";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *digest = [SHPCrypto shp_SHA1HexDigestFromData:data];

    // Result digest computed independently in ruby using same input data
    XCTAssertEqualObjects(digest, @"9d389e532905cad41b496c27bbf19d850544a2b2");
}

- (void)testHMACSHA1Digest
{
    NSString *str = @"This is some great test data";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *secret = @"secret key";
    NSString *digest = [SHPCrypto shp_HMACSHA1HexSignatureFromData:data withSecret:secret];

    // Result digest computed independently in ruby using same input data
    XCTAssertEqualObjects(digest, @"7ee7f65717790af843c62c4b5fdb7e088525b7ab");
}

@end
