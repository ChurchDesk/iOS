//
// Created by philip on 23/12/14.
//
// Copyright SHAPE A/S
//

#import <objc/runtime.h>
#import "SHPRuntime.h"

@implementation SHPRuntime

+ (NSArray *)runtimeClasses {
    // ----------------
    // Get class name of each class
    // ----------------
    int numClasses;
    Class *classes = NULL;

    // Get all classes registered in runtime
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);

    NSMutableArray *classRefs = [[NSMutableArray alloc] initWithCapacity:numClasses];
    if (numClasses > 0 ) {
        classes = (__unsafe_unretained Class *) malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);

        for (int i = 0; i < numClasses; i++) {
            Class superClass = classes[i];
            do {
                superClass = class_getSuperclass(superClass);
            } while (superClass && superClass != [NSObject class]);

            if (superClass == nil) {
                continue;
            }
            [classRefs addObject:classes[i]];
        }
        free(classes);
    }

    return classRefs;
}

+ (NSArray *)runtimeClassesConformingToProtocol:(Protocol *)aProtocol {
    NSArray *classes = [self runtimeClasses];

    // ----------------
    // Find classes conforming to TableKitCellProtocol
    // ----------------
    NSMutableArray *classesConformingToProtocol = [NSMutableArray array];
    for (Class klass in classes) {
        if ([klass respondsToSelector:@selector(conformsToProtocol:)]) {
            if ([klass conformsToProtocol:aProtocol]) {
                [classesConformingToProtocol addObject:klass];
            }
        }
    }

    return classesConformingToProtocol;
}

@end
