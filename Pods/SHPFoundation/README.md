# SHPFoundation

SHPFoundation contains fundamental Objective-C classes that should aid in all kinds of iOS development.

## Contents

Currently SHPFoundation includes the following:

### Collection categories

Inspired by Swift (but of course it all comes from Smalltalk). You can use these to quickly manipulate arrays or sets. You'll find methods named according to array methods from Swift:

* shp_map
* shp_filter
* shp_reduce

See the docs for more info


### SHPAdditions

Various categories for Foundation classes. All category methods are prefixed with 'shp'

### SHPUtilities

Contains some C functions to create UUID's, create GCD queues and more. Also has the SHPAssert macro to replace NSAssert.

### SHPTimer

Simple container for NSTimers. Makes it easier to keep references to timers without having to assign them to instance vars and reference them later.

### Tests

There are a limited number of unit tests available. Feel free to expand them :)
