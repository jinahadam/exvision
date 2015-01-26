//
//  DJIDispatch.m
//  DJI
//
//  Copyright (c) 2014年. All rights reserved.
//

#import "DJIDispatch.h"
#import "pthread.h"

@interface DJIDispatchObject : NSObject

@property (retain) dispatch_queue_t dispatchQueue;

@end

@implementation DJIDispatchObject

- (id)initWithDispatchName:(NSString *)name withType:(dispatch_queue_attr_t)type{
    self = [super init];
    if(self){
        _dispatchQueue = dispatch_queue_create([name cStringUsingEncoding:NSUTF8StringEncoding], type);
    }
    return self;
}

@end

@interface DJIDispatch()
{
    NSMutableDictionary *_dispatchDict;
    pthread_mutex_t _mutex;
}

@end

@implementation DJIDispatch

+ (id)sharedInstance{
    static DJIDispatch *instance = nil;
    if(instance == nil){
        instance = [[DJIDispatch alloc] init];
    }
    return instance;
}

- (id)init{
    self = [super init];
    if(self){
        _dispatchDict = [[NSMutableDictionary alloc] init];
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

- (dispatch_queue_t)getDispatchQueueWithName:(NSString *)name{
    pthread_mutex_lock(&_mutex);
    DJIDispatchObject *dispatchObject = (DJIDispatchObject *)_dispatchDict[name];
    if(dispatchObject == nil){
        dispatchObject = [[DJIDispatchObject alloc] initWithDispatchName:name withType:DISPATCH_QUEUE_SERIAL];
        [_dispatchDict setObject:dispatchObject forKey:name];
        pthread_mutex_unlock(&_mutex);
        return [dispatchObject dispatchQueue];
    }
    else{
        pthread_mutex_unlock(&_mutex);
        return [dispatchObject dispatchQueue];
    }
}

- (BOOL)creatDispatchQueueWithName:(NSString *)name WithType:(dispatch_queue_attr_t)type{
    pthread_mutex_lock(&_mutex);
    DJIDispatchObject *dispatchObject = (DJIDispatchObject *)_dispatchDict[name];
    if(dispatchObject == nil){
        dispatchObject = [[DJIDispatchObject alloc] initWithDispatchName:name withType:DISPATCH_QUEUE_SERIAL];
        [_dispatchDict setObject:dispatchObject forKey:name];
        pthread_mutex_unlock(&_mutex);
        return YES;
    }
    return NO;
}

@end
