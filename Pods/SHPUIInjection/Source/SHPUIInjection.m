//
// Created by Peter Gammelgaard on 20/02/15.
// Copyright (c) 2015 Distinction. All rights reserved.
//

#if TARGET_IPHONE_SIMULATOR

#import <objc/runtime.h>
#import "SFDynamicCodeInjection.h"
#import <malloc/malloc.h>
#import <mach/mach.h>

static NSString *SHPUIInjectionWillPerformCodeInjectionNotification = @"SHPUIInjectionWillPerformCodeInjectionNotification";
static NSString *SHPUIInjectionDidPerformCodeInjectionNotification = @"SHPUIInjectionDidPerformCodeInjectionNotification";

static CFMutableSetRef registeredClasses;

typedef void (^shp_object_enumeration_block_t)(__unsafe_unretained id object, __unsafe_unretained Class actualClass);

// Mimics the objective-c object stucture for checking if a range of memory is an object.
typedef struct {
    Class isa;
} flex_maybe_object_t;

@implementation NSObject (Swizzling)
+ (void)shpuiinjection_swizzle:(SEL)originalSelector with:(SEL)newSelector
{
    Class aClass = [self class];
    Method origMethod = class_getInstanceMethod(aClass, originalSelector);
    Method newMethod = class_getInstanceMethod(aClass, newSelector);

    if(class_addMethod(aClass, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(aClass, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }

}
@end

@interface SFDynamicCodeInjection (Swizzled)

@end
@implementation SFDynamicCodeInjection (Swizzled)
#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"

- (void)shpuiinjection_performInjectionWithClass:(Class)injectedClass {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHPUIInjectionWillPerformCodeInjectionNotification object:injectedClass];
    [self shpuiinjection_performInjectionWithClass:injectedClass];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHPUIInjectionDidPerformCodeInjectionNotification object:injectedClass];
}
#pragma clang diagnostic pop

@end

@interface CALayer (Swizzled)

@end

@implementation CALayer (Swizzled)
#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"

- (void)shpuiinjection_layoutSublayers {
    @try {
        [self shpuiinjection_layoutSublayers];
    } @catch (NSException *exception) {
        NSArray* backtrace = [exception callStackSymbols];
        NSLog(@"%@: %@\n%@", exception.name,exception.reason, backtrace);
    }

}
#pragma clang diagnostic pop

@end

@implementation SHPUIInjection {

}

static NSMutableArray *oldClasses;
static NSMutableArray *data;

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnresolvedMessage"
+ (void)enable {
    data = [NSMutableArray new];
    oldClasses = [NSMutableArray new];

    SEL selectorToSwizzle = @selector(performInjectionWithClass:);
    SEL selectorToSwizzleTo = @selector(shpuiinjection_performInjectionWithClass:);
    [SFDynamicCodeInjection shpuiinjection_swizzle:selectorToSwizzle with:selectorToSwizzleTo];

    SEL layerSelectorToSwizzle = @selector(layoutSublayers);
    SEL layerSelectorToSwizzleTo = @selector(shpuiinjection_layoutSublayers);
    [CALayer shpuiinjection_swizzle:layerSelectorToSwizzle with:layerSelectorToSwizzleTo];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willPerformCodeInjection:) name:SHPUIInjectionWillPerformCodeInjectionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPerformCodeInjection:) name:SHPUIInjectionDidPerformCodeInjectionNotification object:nil];
}
#pragma clang diagnostic pop

+ (void)didPerformCodeInjection:(NSNotification *)notification {
    Class injectionClass = notification.object;
    NSMutableSet *viewControllers = [NSMutableSet new];
    NSString *classString = NSStringFromClass(injectionClass);
    __block BOOL isViewController = NO;

    [self enumerateLiveObjectsUsingBlock:^(__unsafe_unretained id object, Class actualClass) {
        if (![object isProxy]) {
            NSString *objectClassString = NSStringFromClass([object class]);
            if ([objectClassString isEqualToString:classString] && [object isKindOfClass:[UIViewController class]]) {
                UIViewController *viewController = object;
                [viewControllers addObject:viewController];
                isViewController = YES;
            } else if ([objectClassString isEqualToString:classString] && [object isKindOfClass:[UIView class]]) {
                UIView *view = object;

                UIResponder *responder = view;
                while ((responder = [responder nextResponder])) {
                    if ([responder isKindOfClass:UIViewController.class]) break;
                }
                UIViewController *viewController = (UIViewController *) responder;
                [self nilViewPropertiesForObject:object ignoreCachedClasses:NO];
                if (viewController) {
                    [viewControllers addObject:viewController];
                }
            }
        }
    }];

    for (UIViewController *viewController in viewControllers) {
        [self nilViewPropertiesForObject:viewController ignoreCachedClasses:!isViewController];
        [self reloadViewController:viewController];
    }
}

+ (void)willPerformCodeInjection:(NSNotification *)notification {
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "incompatible-function-pointer-arguments"
+ (void)nilViewPropertiesForObject:(NSObject *)object ignoreCachedClasses:(BOOL)ignoreCachedClasses {
    NSString *viewControllerClassString = NSStringFromClass([object class]);
	NSArray *allClasses = [self runtimeClasses];
	NSMutableArray *classes = [NSMutableArray new];
	for (Class cls in allClasses) {
        NSString *memory = [NSString stringWithFormat:@"%p", cls];
		if ([NSStringFromClass(cls) isEqualToString:viewControllerClassString] && (ignoreCachedClasses || ![oldClasses containsObject:memory])) {
			[classes addObject:cls];
		} 
	}

    for (Class cls in classes) {
        [oldClasses addObject:[NSString stringWithFormat:@"%p", cls]];
    }

    for (Class cls in classes) {
        NSArray *properties = [SHPUIInjection allPropertyNamesForClass:cls];

                for (NSString *propertyName in properties) {
                    Class klass = [SHPUIInjection classOfPropertyNamed:propertyName inClass:cls];
                    if ([klass isSubclassOfClass:[UIView class]] && !([object isKindOfClass:[UIViewController class]] && [propertyName isEqualToString:@"view"])) {
                        [object setValue:nil forKey:propertyName];
                        [object setValue:nil forKey:[@"_" stringByAppendingString:propertyName]];
                    }
                }
            }
}
#pragma clang diagnostic pop

+ (void)reloadViewController:(UIViewController *)viewController {
    UIView *superView = viewController.view.superview;
    [viewController.view removeFromSuperview];
    viewController.view = nil;
    @try {
        [viewController loadView];
        [superView addSubview:viewController.view];
        [viewController viewDidLoad];
        [viewController viewWillAppear:NO];
        [viewController viewDidAppear:NO];
    } @catch (NSException *exception) {
        NSArray* backtrace = [exception callStackSymbols];
        NSLog(@"%@: %@\n%@", exception.name,exception.reason, backtrace);
    }
}

+ (Class)classOfPropertyNamed:(NSString *)propertyName inClass:(Class)klass {
    Class propertyClass = nil;
    objc_property_t property = class_getProperty(klass, [propertyName UTF8String]);
    if (property) {
        NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
        if (splitPropertyAttributes.count > 0 && splitPropertyAttributes)
        {
            NSString *encodeType = splitPropertyAttributes[0];
            NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
            if (splitEncodeType.count>1) {
                NSString *className = splitEncodeType[1];
                propertyClass = NSClassFromString(className);
            }

        }
    }

    return propertyClass;
}

+ (NSArray *)allPropertyNamesForClass:(Class)klass
{
    unsigned count;
    Class newClass = klass;
    objc_property_t *properties = class_copyPropertyList(newClass, &count);

    NSMutableArray *rv = [NSMutableArray array];

    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];

        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }

    free(properties);

    return rv;
}

static kern_return_t memory_reader(task_t task, vm_address_t remote_address, vm_size_t size, void **local_memory)
{
    *local_memory = (void *)remote_address;
    return KERN_SUCCESS;
}

static void range_callback(task_t task, void *context, unsigned type, vm_range_t *ranges, unsigned rangeCount)
{
    shp_object_enumeration_block_t block = (__bridge shp_object_enumeration_block_t)context;
    if (!block) {
        return;
    }

    for (unsigned int i = 0; i < rangeCount; i++) {
        vm_range_t range = ranges[i];
        flex_maybe_object_t *tryObject = (flex_maybe_object_t *)range.address;
        Class tryClass = NULL;
#ifdef __arm64__
        // See http://www.sealiesoftware.com/blog/archive/2013/09/24/objc_explain_Non-pointer_isa.html
        extern uint64_t objc_debug_isa_class_mask WEAK_IMPORT_ATTRIBUTE;
        tryClass = (__bridge Class)((void *)((uint64_t)tryObject->isa & objc_debug_isa_class_mask));
#else
        tryClass = tryObject->isa;
#endif
        // If the class pointer matches one in our set of class pointers from the runtime, then we should have an object.
        if (CFSetContainsValue(registeredClasses, (__bridge const void *)(tryClass))) {
            block((__bridge id)tryObject, tryClass);
        }
    }
}

+ (void)enumerateLiveObjectsUsingBlock:(shp_object_enumeration_block_t)block
{
    if (!block) {
        return;
    }

    // Refresh the class list on every call in case classes are added to the runtime.
    [self updateRegisteredClasses];

    // For another exmple of enumerating through malloc ranges (which helped my understanding of the api) see:
    // http://llvm.org/svn/llvm-project/lldb/tags/RELEASE_34/final/examples/darwin/heap_find/heap/heap_find.cpp
    // Also https://gist.github.com/samdmarshall/17f4e66b5e2e579fd396
    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    kern_return_t result = malloc_get_all_zones(mach_task_self(), &memory_reader, &zones, &zoneCount);
    if (result == KERN_SUCCESS) {
        for (unsigned int i = 0; i < zoneCount; i++) {
            malloc_zone_t *zone = (malloc_zone_t *)zones[i];
            if (zone->introspect && zone->introspect->enumerator) {
                zone->introspect->enumerator(mach_task_self(), (__bridge void *)(block), MALLOC_PTR_IN_USE_RANGE_TYPE, zones[i], &memory_reader, &range_callback);
            }
        }
    }
}

+ (void)updateRegisteredClasses
{
    if (!registeredClasses) {
        registeredClasses = CFSetCreateMutable(NULL, 0, NULL);
    } else {
        CFSetRemoveAllValues(registeredClasses);
    }
    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    for (unsigned int i = 0; i < count; i++) {
        CFSetAddValue(registeredClasses, (__bridge const void *)(classes[i]));
    }
    free(classes);
}

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

@end

#endif
