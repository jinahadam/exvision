//
//  DJIDispatch.h
//  DJI
//
//  Copyright (c) 2014年. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BEGIN_MAIN_DISPATCH_QUEUE dispatch_async(dispatch_get_main_queue(), ^{

#define BEGIN_DISPATCH_QUEUE_NAME(___NAME) dispatch_async([[DJIDispatch sharedInstance] getDispatchQueueWithName:___NAME], ^{

#define BEGIN_DISPATCH_QUEUE dispatch_async([[DJIDispatch sharedInstance] getDispatchQueueWithName:[NSString stringWithFormat:@"%@_dispatch_queue",NSStringFromClass([self class])]], ^{

#define END_DISPATCH_QUEUE });

/**
 *  单例，用于简化Dispatch的操作，同时统一调度dispatch。
 */
@interface DJIDispatch : NSObject

+ (id)sharedInstance;

/**
 *  按名称获取GCD队列。
 *
 *  @param name GCD队列的标识（唯一）
 *
 *  @return 返回GCD队列，当不存在该队列时，自动创建该队列，默认为同步队列。
 */
- (dispatch_queue_t)getDispatchQueueWithName:(NSString *)name;

/**
 *  按名称和类型创建GCD队列，（如无特殊需要直接调用获取方法自动创建即可）
 *
 *  @param name GCD队列的标识(唯一)
 *  @param type GCD队列的类型
 *
 *  @return 是否创建成功。（如已创建过该队列，则不再创建）
 */
- (BOOL)creatDispatchQueueWithName:(NSString *)name WithType:(dispatch_queue_attr_t)type;

@end
