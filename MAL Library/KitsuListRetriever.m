//
//  KitsuListRetriever.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/12/18.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "KitsuListRetriever.h"
#import <AFNetworking/AFNetworking.h>
#import "Utility.h"
#import "AtarashiiAPIListFormatKitsu.h"
#import "Kitsu.h"

@interface KitsuListRetriever ()

@end

@implementation KitsuListRetriever
- (void)retrieveKitsuLibrary:(int)userID type:(int)type atPage:(int)pagenum completionHandler:(void (^)(id responseObject)) completionHandler error:(void (^)(NSError * error)) errorHandler {
    if (pagenum == 0) {
        _tmplist = [NSMutableArray new];
        _metadata = [NSMutableArray new];
    }
    AFHTTPSessionManager *manager = [Utility jsonmanager];
    NSString *listtype;
    switch (type) {
        case 0:
            listtype = @"anime";
            break;
        case 1:
            listtype = @"manga";
            break;
        default:
            errorHandler(nil);
            return;
    }
    AFOAuthCredential *cred = [Kitsu getFirstAccount];
    if (cred && cred.expired) {
        [Kitsu refreshToken:^(bool success) {
            if (success) {
                [self retrieveKitsuLibrary:userID type:type atPage:pagenum completionHandler:completionHandler error:errorHandler];
            }
            else {
                errorHandler(nil);
            }
        }];
        return;
    }
    if (cred) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", cred.accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [manager GET:[NSString stringWithFormat:@"https://kitsu.io/api/edge/library-entries?filter[userId]=%i&filter[kind]=%@&include=%@&page[limit]=500&page[offset]=%i",userID, listtype, listtype, pagenum] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject[@"data"]){
            [_tmplist addObjectsFromArray:responseObject[@"data"]];
            if (responseObject[@"included"]){
                [_metadata addObjectsFromArray:responseObject[@"included"]];
            }
            if (responseObject[@"links"][@"next"]) {
                int nextPage = pagenum+1;
                [self retrieveKitsuLibrary:userID type:type atPage:nextPage completionHandler:completionHandler error:errorHandler];
            }
            else {
                switch (type) {
                    case 0:
                        completionHandler([AtarashiiAPIListFormatKitsu KitsutoAtarashiiAnimeList:self]);
                        break;
                    case 1:
                        completionHandler([AtarashiiAPIListFormatKitsu KitsutoAtarashiiMangaList:self]);
                        break;
                    default:
                        errorHandler(nil);
                        return;
                }
                
            }
        }
        else {
            completionHandler([AtarashiiAPIListFormatKitsu KitsutoAtarashiiAnimeList:self]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        errorHandler(error);
    }];
}
- (NSDictionary *)retrieveMetaDataWithID:(int)titleid {
    NSArray *filtered = [_metadata filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id==[cd] %i", titleid]];
    if (filtered.count > 0) {
        return filtered[0];
    }
    return nil;
}
@end