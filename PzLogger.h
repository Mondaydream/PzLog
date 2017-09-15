//
//  PzLog.h
//
//
//  Created by 黄鹏志 on 15/09/2017.
//  Copyright © 2017 Pz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PzLoggerLevelNone = 0,
    PzLoggerLevelInfo = 1,
    PzLoggerLevelDebug = 1 << 1,
    PzLoggerLevelError = 1 << 2,
    PzLoggerLevelAll = PzLoggerLevelInfo | PzLoggerLevelDebug | PzLoggerLevelError,
} PzLoggerLevel;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PzLoggerDomainCURL;
extern NSString *const PzLoggerDomainNetwork;
extern NSString *const PzLoggerDomainIM;
extern NSString *const PzLoggerDomainStorage;
extern NSString *const PzLoggerDomainDefault;

@interface PzLogger : NSObject
+ (void)setAllLogsEnabled:(BOOL)enabled;
+ (void)setLoggerLevelMask:(NSUInteger)levelMask;
+ (void)addLoggerDomain:(NSString *)domain;
+ (void)removeLoggerDomain:(NSString *)domain;
+ (void)logFile:(const char *)file line:(const int)line domain:(nullable NSString *)domain level:(PzLoggerLevel)level message:(NSString *)fmt, ... NS_FORMAT_FUNCTION(5, 6);
+ (BOOL)levelEnabled:(PzLoggerLevel)level;
+ (BOOL)containDomain:(NSString *)domain;
@end

NS_ASSUME_NONNULL_END

#define _PzLoggerInfo(_domain, ...) [PzLogger logFile:__FILE__ line:__LINE__ domain:_domain level:PzLoggerLevelInfo message:__VA_ARGS__]
#define _PzLoggerDebug(_domain, ...) [PzLogger logFile:__FILE__ line:__LINE__ domain:_domain level:PzLoggerLevelDebug message:__VA_ARGS__]
#define _PzLoggerError(_domain, ...) [PzLogger logFile:__FILE__ line:__LINE__ domain:_domain level:PzLoggerLevelError message:__VA_ARGS__]

#define PzLoggerInfo(domain, ...) _PzLoggerInfo(domain, __VA_ARGS__)
#define PzLoggerDebug(domain, ...) _PzLoggerDebug(domain, __VA_ARGS__)
#define PzLoggerError(domain, ...) _PzLoggerError(domain, __VA_ARGS__)

#define PzLoggerI(...)  PzLoggerInfo(PzLoggerDomainDefault, __VA_ARGS__)
#define PzLoggerD(...) PzLoggerDebug(PzLoggerDomainDefault, __VA_ARGS__)
#define PzLoggerE(...) PzLoggerError(PzLoggerDomainDefault, __VA_ARGS__)
