//
//  main.m
//  TimeMetricsTest
//
//  Created by Valentine Silvansky on 31.05.13.
//  Copyright (c) 2013 silvansky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSTimeMetrics.h"

#define NUM_THREADS   10
#define MAX_I         600

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		dispatch_queue_t queues[NUM_THREADS];
		dispatch_group_t group = dispatch_group_create();
		for (int i = 0; i < NUM_THREADS; i++)
		{
			queues[i] = dispatch_queue_create("async queue", DISPATCH_QUEUE_CONCURRENT);
		}
		NSLog(@"Starting with maximum i %d, number of threads %d", MAX_I, NUM_THREADS);
		[[VSTimeMetrics sharedInstance] startMeasuringForKey:@"total"];
		int currentQueue = 0;
		for (int i = 1; i < MAX_I; i++)
		{
			dispatch_block_t block = ^{
				@autoreleasepool
				{
					[[VSTimeMetrics sharedInstance] startMeasuringForKey:@"array"];
					NSMutableArray *a = [NSMutableArray arrayWithCapacity:i * i];
					for (int j = 0; j < i * i; j++)
					{
						[a addObject:@(j)];
					}
					[[VSTimeMetrics sharedInstance] finishMeasuringForKey:@"array"];
				}
			};
			dispatch_group_async(group, queues[currentQueue], block);
			currentQueue++;
			if (currentQueue == NUM_THREADS)
			{
				currentQueue = 0;
			}
		}
		dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
		[[VSTimeMetrics sharedInstance] finishMeasuringForKey:@"total"];
		NSLog(@"array:\n\tlast: %f,\n\tavg: %f,\n\ttotal: %f", [[VSTimeMetrics sharedInstance] lastMeasurementForKey:@"array"], [[VSTimeMetrics sharedInstance] averageMeasurementForKey:@"array"], [[VSTimeMetrics sharedInstance] totalMeasurementForKey:@"array"]);
		NSLog(@"total: %f", [[VSTimeMetrics sharedInstance] lastMeasurementForKey:@"array"]);
		NSLog(@"Report: %@", [[VSTimeMetrics sharedInstance] measurementReport]);
	}
	return 0;
}

