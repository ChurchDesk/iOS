//
// Created by philip on 20/10/14.
//
// Copyright SHAPE A/S
//


#import "SHPFunctionalTests.h"
#import "NSArray+SHPArrayFunctional.h"
#import "NSSet+SHPSetFunctional.h"

@implementation SHPFunctionalTests

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

- (void)testArrayMap
{
    NSArray *numbersArray = @[ @1, @2, @3, @4 ];
    NSArray *mappedArray = [numbersArray shp_map:^id(NSNumber *number) { return [NSString stringWithFormat:@"Number: %@", number]; }];

    NSLog(@"mappedArray = %@", mappedArray);

    XCTAssertEqualObjects(mappedArray[2], @"Number: 3", @"Mapped object doesn't match");
}

- (void)testArrayMapWithIndex
{
    NSArray *numbersArray = @[ @5, @20, @87, @32 ];
    NSArray *mappedArrayWithIndex = [numbersArray shp_mapWithIndex:^id(NSNumber *number, NSUInteger index) { return [NSString stringWithFormat:@"Number: %@ at index: %i", number, index]; }];

    NSLog(@"mappedArrayWithIndex = %@", mappedArrayWithIndex);

    XCTAssertEqualObjects(mappedArrayWithIndex[2], @"Number: 87 at index: 2", @"Mapped object doesn't match");
}

- (void)testArrayFilter
{
    NSArray *numbersArray = @[ @1, @2, @3, @4 ];
    NSArray *onlyAboveTwo = [numbersArray shp_filter:^BOOL(NSNumber *number) { return [number integerValue] > 2; }];

    NSLog(@"onlyAboveTwo = %@", onlyAboveTwo);

    XCTAssertEqual([onlyAboveTwo count], 2);
    XCTAssertEqualObjects(onlyAboveTwo[0], @3);
    XCTAssertEqualObjects(onlyAboveTwo[1], @4);
}

- (void)testArrayFilterWithIndex
{
    NSArray *numbersArray = @[ @10, @3, @34, @11 ];
    NSArray *onlyAboveTwo = [numbersArray shp_filterWithIndex:^BOOL(NSNumber *number, NSUInteger index) { return index >= 2; }];

    NSLog(@"onlyAboveTwo = %@", onlyAboveTwo);

    XCTAssertEqual([onlyAboveTwo count], 2);
    XCTAssertEqualObjects(onlyAboveTwo[0], @34);
    XCTAssertEqualObjects(onlyAboveTwo[1], @11);
}

- (void)testArrayDetect {
    NSArray *numbersArray = @[ @1, @2, @3, @4 ];
    NSNumber *firstMatch = [numbersArray shp_detect:^BOOL(NSNumber *number) { return [number integerValue] == 2; }];
    XCTAssertEqual(firstMatch, @2);

    NSNumber *noMatch = [numbersArray shp_detect:^BOOL(NSNumber *number) { return [number integerValue] == 10; }];
    XCTAssertTrue(noMatch == nil, "Detect should return nil");
}

- (void)testArrayReduce
{
    NSArray *numbersArray = @[ @1, @2, @3, @4 ];
    NSNumber *sum = [numbersArray shp_reduce:@0 combine:^id(id currentReduction, id currentElement) { return @([currentReduction integerValue] + [currentElement integerValue]); }];

    NSLog(@"sum = %@", sum);

    XCTAssertEqualObjects(sum, @10);
}

- (void)testArrayAny
{

    NSArray *numberOfBladders = @[@2, @3, @2, @5, @18];
    BOOL doesCowWithCrazyNumberOfBladdersReallyExist = [numberOfBladders shp_any:^BOOL(NSNumber *number) { return [number integerValue] == 18; }];
    XCTAssertTrue(doesCowWithCrazyNumberOfBladdersReallyExist, "shp_any should return true");

    BOOL doesCowWithOutOfThisWorldNumberOfBladdersReallyExist = [numberOfBladders shp_any:^BOOL(NSNumber *number) { return [number integerValue] == 180000; }];
    XCTAssertFalse(doesCowWithOutOfThisWorldNumberOfBladdersReallyExist, "shp_any should return false");
}

- (void)testSetMap
{
    NSSet *numbersSet = [NSSet setWithArray:@[ @1, @2, @3, @4 ]];
    NSSet *mappedSet = [numbersSet shp_map:^id(NSNumber *number) {return [NSString stringWithFormat:@"Number: %@", number];}];

    NSLog(@"mappedSet = %@", mappedSet);

    XCTAssertEqual([numbersSet count], 4, "Mapped set should contain 4 elements");
}

- (void)testSetFilter
{
    NSSet *numbersSet = [NSSet setWithArray:@[ @1, @2, @3, @4 ]];
    NSSet *onlyAboveTwo = [numbersSet shp_filter:^BOOL(NSNumber *number) {return [number integerValue] > 2;}];

    NSLog(@"onlyAboveTwo = %@", onlyAboveTwo);

    XCTAssertEqual([onlyAboveTwo count], 2, "Filtered set should contain 2 elements");
}

- (void)testSetReduce
{
    NSSet *numbersSet = [NSSet setWithArray:@[ @1, @2, @3, @4 ]];
    NSNumber *sum = [numbersSet shp_reduce:@0 combine:^id(id currentReduction, id currentElement) {return @([currentReduction integerValue] + [currentElement integerValue]);}];

    NSLog(@"sum = %@", sum);

    XCTAssertEqualObjects(sum, @10);
}

@end
