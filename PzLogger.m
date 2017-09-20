//
//  PzLog.m
//  
//
//  Created by 黄鹏志 on 15/09/2017.
//  Copyright © 2017 Pz. All rights reserved.
//

#import "PzLogger.h"

NSString *const PzLoggerDomainCURL = @"LOG_CURL";
NSString *const PzLoggerDomainNetwork = @"LOG_NETWORK";
NSString *const PzLoggerDomainStorage = @"LOG_STORAGE";
NSString *const PzLoggerDomainIM = @"LOG_IM";
NSString *const PzLoggerDomainDefault = @"LOG_DEFAULT";

static NSMutableSet *loggerDomain = nil;
static NSUInteger loggerLevelMask = PzLoggerLevelNone;
static NSArray *loggerDomains = nil;
static dispatch_queue_t logQueue = NULL;

@implementation PzLogger

+ (void)load {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        loggerDomains = @[
                          PzLoggerDomainCURL,
                          PzLoggerDomainNetwork,
                          PzLoggerDomainIM,
                          PzLoggerDomainStorage,
                          PzLoggerDomainDefault
                          ];
        logQueue = dispatch_queue_create("Pz.log.queue", DISPATCH_QUEUE_SERIAL);
    });
#ifdef DEBUG
    [self setAllLogsEnabled:YES];
#else
    [self setAllLogsEnabled:NO];
#endif
}

+ (void)setAllLogsEnabled:(BOOL)enabled {
    if (enabled) {
        for (NSString *loggerDomain in loggerDomains) {
            [PzLogger addLoggerDomain:loggerDomain];
        }
        [PzLogger setLoggerLevelMask:PzLoggerLevelAll];
    } else {
        for (NSString *loggerDomain in loggerDomains) {
            [PzLogger removeLoggerDomain:loggerDomain];
        }
        [PzLogger setLoggerLevelMask:PzLoggerLevelNone];
    }
    
    [self setCertificateInspectionEnabled:enabled];
}

+ (void)setCertificateInspectionEnabled:(BOOL)enabled {
    if (enabled) {
        setenv("CURL_INSPECT_CERT", "YES", 1);
    } else {
        unsetenv("CURL_INSPECT_CERT");
    }
}

+ (void)setLoggerLevelMask:(NSUInteger)levelMask {
    loggerLevelMask = levelMask;
}

+ (void)addLoggerDomain:(NSString *)domain {
    if (!loggerDomain) {
        loggerDomain = [[NSMutableSet alloc] init];
    }
    [loggerDomain addObject:domain];
}

+ (void)removeLoggerDomain:(NSString *)domain {
    [loggerDomain removeObject:domain];
}

+ (BOOL)levelEnabled:(PzLoggerLevel)level {
    return loggerLevelMask & level;
}

+ (BOOL)containDomain:(NSString *)domain {
    return [loggerDomain containsObject:domain];
}

+ (void)logFile:(const char *)file line:(int)line domain:(NSString *)domain level:(PzLoggerLevel)level message:(NSString *)fmt, ... {
    if (!domain || [loggerDomain containsObject:domain]) {
        if (level & loggerLevelMask) {
            NSString *levelString = nil;
            switch (level) {
                case PzLoggerLevelInfo:
                    levelString = @"INFO";
                    break;
                case PzLoggerLevelDebug:
                    levelString = @"DEBUG";
                    break;
                case PzLoggerLevelError:
                    levelString = @"ERROR";
                    break;
                default:
                    levelString = @"UNKNOW";
                    break;
            }
            va_list args;
            va_start(args, fmt);
            NSString *message = [[NSString alloc] initWithFormat:fmt arguments:args];
            va_end(args);
            static dispatch_once_t onceToken;
            dispatch_async(logQueue, ^{
                 NSLog(@"| PzConnect | [%@] %@ [Line %d] %@", levelString, [[NSString stringWithUTF8String:file] lastPathComponent], line, message);
            });
            
        }
    }
}

@end
