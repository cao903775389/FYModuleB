//
//  CTMediator+FYModuleB.m
//  FYModuleB
//
//  Created by casa on 2020/3/9.
//  Copyright © 2020 casa. All rights reserved.
//

#import "CTMediator+FYModuleB.h"

@implementation CTMediator (FYModuleB)

- (NSString *)FYModuleB_test
{
    NSString *result = (NSString *)[self performTarget:@"FYModuleB" action:@"test" params:nil shouldCacheTarget:NO];
    return result;
}

@end
