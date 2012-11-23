 //
//  Stack.m
//  rainsync
//
//  Created by xorox64 on 12. 11. 1..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "Queue.h"

@implementation Queue

- (id)init{
    [super init];
    contents = [[NSMutableArray alloc]init];
    return self;

}

- (void)dealloc{
    [super dealloc];
    [contents release];

}

- (id)pop
{
    // nil if [self count] == 0
    id lastObject = [contents lastObject];
    if (lastObject)
        [contents removeLastObject];
    return lastObject;
}

- (NSUInteger)count{

    return [contents count];
    
}

- (void)push:(id)obj
{
    [contents addObject: obj];
}


@end
