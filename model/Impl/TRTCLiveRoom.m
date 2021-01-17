//
//  TRTCLiveRoom.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/7.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCLiveRoom.h"
#import "TRTCLiveRoomMemberManager.h"
#import "TRTCLiveRoomModelDef.h"
#import "TXLiveRoomCommonDef.h"
#import "TRTCLiveRoomIMAction.h"
#import "TRTCCloudAnction.h"
#import <MJExtension.h>
#import <ImSDK/ImSDK.h>
#import "BIZPopupViewController.h"
#import "CountdownViewController.h"

static double trtcLiveSendMsgTimeOut = 15;
static double trtcLiveHandleMsgTimeOut = 10;
static double trtcLiveCheckStatusTimeOut = 3;

@interface NSNumber (String)

- (BOOL)isEqualToString:(NSString *)string;

@end

@implementation NSNumber (String)

- (BOOL)isEqualToString:(NSString *)string {
    return NO;
}

@end

@interface TRTCLiveRoom () <TRTCLiveRoomMembermanagerDelegate, V2TIMAdvancedMsgListener, V2TIMGroupListener>

@property (nonatomic, strong) TRTCCloudAnction *trtcAction;
@property (nonatomic, strong) TRTCLiveRoomMemberManager *memberManager;
@property (nonatomic, strong) TRTCLiveRoomConfig *config;
@property (nonatomic, strong) TRTCLiveUserInfo *me;
@property (nonatomic, assign) BOOL mixingPKStream; // PK是否混流
@property (nonatomic, assign) BOOL mixingLinkMicStream; // 连麦是否混流
@property (nonatomic, strong) TRTCLiveRoomInfo *curRoomInfo;

@property (nonatomic, strong, readonly) TXBeautyManager *beautyManager;
@property (nonatomic, assign) TRTCLiveRoomLiveStatus status;

@property (nonatomic, strong, readonly) NSString *roomID;
@property (nonatomic, strong, readonly) NSString *ownerId;

@property (nonatomic, copy) Callback enterRoomCallback;
@property (nonatomic, copy) ResponseCallback requestJoinAnchorCallback;
@property (nonatomic, copy) ResponseCallback requestRoomPKCallback;

@property (nonatomic, strong) TRTCPKAnchorInfo *pkAnchorInfo;
@property (nonatomic, strong) TRTCJoinAnchorInfo *joinAnchorInfo;
@property (nonatomic, assign, readonly) BOOL isOwner;
@property (nonatomic, assign, readonly) BOOL isAnchor;
@property (nonatomic, assign, readonly) BOOL configCdn;
@property (nonatomic, assign, readonly) BOOL shouldPlayCdn;
@property (nonatomic, assign, readonly) BOOL shouldMixStream;
@property (nonatomic, strong) CountdownViewController *smallViewController;

@end

@implementation TRTCLiveRoom

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.memberManager.delegate = self;
    }
    return self;
}

- (void)dealloc {
    TRTCLog(@"dealloc TRTCLiveRoom");
}

#pragma mark - 懒加载&&只读属性
- (TRTCCloudAnction *)trtcAction {
    if (!_trtcAction) {
        _trtcAction = [[TRTCCloudAnction alloc] init];
    }
    return _trtcAction;
}

- (TRTCLiveRoomMemberManager *)memberManager {
    if (!_memberManager) {
        _memberManager = [[TRTCLiveRoomMemberManager alloc] init];
    }
    return _memberManager;
}

- (TRTCPKAnchorInfo *)pkAnchorInfo {
    if (!_pkAnchorInfo) {
        _pkAnchorInfo = [[TRTCPKAnchorInfo alloc] init];
    }
    return _pkAnchorInfo;
}

-(TRTCJoinAnchorInfo *)joinAnchorInfo {
    if (!_joinAnchorInfo) {
        _joinAnchorInfo = [[TRTCJoinAnchorInfo alloc] init];
    }
    return _joinAnchorInfo;
}

- (NSString *)roomID {
    return self.trtcAction.roomId;
}

- (NSString *)ownerId {
    return self.memberManager.ownerId;
}

- (TXBeautyManager *)beautyManager {
    return self.trtcAction.beautyManager;
}

- (void)setStatus:(TRTCLiveRoomLiveStatus)status {
    if (_status != status) {
        if (self.curRoomInfo) {
            self.curRoomInfo.roomStatus = status;
            if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRoomInfoChange:)]) {
                [self.delegate trtcLiveRoom:self onRoomInfoChange:self.curRoomInfo];
            }
        } else {
            NSString *streameUrl = [NSString stringWithFormat:@"%@_stream", self.me.userId];
            TRTCLiveRoomInfo* roomInfo = [[TRTCLiveRoomInfo alloc] initWithRoomId:self.roomID
                                                                         roomName:@""
                                                                         coverUrl:@""
                                                                          ownerId:self.me.userId ?: @""
                                                                        ownerName:self.me.userName ?: @""
                                                                        streamUrl:streameUrl
                                                                      memberCount:self.memberManager.audience.count
                                                                       roomStatus:status];
            if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRoomInfoChange:)]) {
                [self.delegate trtcLiveRoom:self onRoomInfoChange:roomInfo];
            }
        }
    }
    _status = status;
}


#pragma mark - public method

#pragma mark - 用户
- (void)loginWithSdkAppID:(int)sdkAppID userID:(NSString *)userID userSig:(NSString *)userSig config:(TRTCLiveRoomConfig *)config callback:(Callback)callback {
    BOOL result = [TRTCLiveRoomIMAction setupSDKWithSDKAppID:sdkAppID userSig:userSig messageLister:self];
    if (!result) {
        if (callback) {
            callback(-1, @"初始化失败");
        }
        return;
    }
    @weakify(self)
    [TRTCLiveRoomIMAction loginWithUserID:userID userSig:userSig callback:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (code == 0) {
            TRTCLiveUserInfo *user = [[TRTCLiveUserInfo alloc] init];
            user.userId = userID;
            self.me = user;
            self.config = config;
            [self.trtcAction setupWithUserId:userID urlDomain:config.cdnPlayDomain sdkAppId:sdkAppID userSig:userSig];
            
        }
        if (callback) {
            callback(0, @"login success.");
        }
    }];
}

- (void)logout:(Callback)callback {
    @weakify(self)
    [TRTCLiveRoomIMAction logout:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        self.me = nil;
        self.config = nil;
        [self.trtcAction reset];
        if (callback) {
            callback(code, message);
        }
        [TRTCLiveRoomIMAction releaseSdk];
    }];
}

- (void)setSelfProfileWithName:(NSString *)name avatarURL:(NSString *)avatarURL callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    me.avatarURL = avatarURL;
    me.userName = name;
    @weakify(self)
    [TRTCLiveRoomIMAction setProfileWithName:name avatar:avatarURL callback:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (code == 0) {
            [self.memberManager updateProfile:me.userId name:name avatar:avatarURL];
        }
        if (callback) {
            callback(code, message);
        }
    }];
}

- (void)createRoomWithRoomID:(UInt32)roomID roomParam:(TRTCCreateRoomParam *)roomParam callback:(Callback)callback {
    [TRTCCloud sharedInstance].delegate = self;
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    BOOL result = [self checkRoomUnjoined:callback];
    if (!result) {
        return;
    }
    NSString *roomIDStr = [NSString stringWithFormat:@"%d", roomID];
    self.curRoomInfo = [[TRTCLiveRoomInfo alloc] initWithRoomId:roomIDStr
                                                       roomName:roomParam.roomName
                                                       coverUrl:roomParam.coverUrl
                                                        ownerId:me.userId
                                                      ownerName:me.userName
                                                      streamUrl:[NSString stringWithFormat:@"%@_stream", me.userId]
                                                    memberCount:0
                                                     roomStatus:TRTCLiveRoomLiveStatusSingle];
    @weakify(self)
    [TRTCLiveRoomIMAction createRoomWithRoomID:roomIDStr
                                     roomParam:roomParam success:^(NSArray<TRTCLiveUserInfo *> * _Nonnull members, NSDictionary<NSString *,id> * _Nonnull customInfo, TRTCLiveRoomInfo * _Nullable roomInfo) {
        @strongify(self)
        if (!self) {
            return;
        }
        self.status = TRTCLiveRoomLiveStatusSingle;
        self.trtcAction.roomId = roomIDStr;
        [self.memberManager setmembers:members groupInfo:customInfo];
        [self.memberManager setOwner:me];
        if (callback) {
            callback(0, @"");
        }
    } error:callback];
}

- (void)destroyRoom:(Callback)callback {
    TRTCLiveUserInfo *user = [self checkUserLogIned:callback];
    if (!user) {
        return;
    }
    NSString *roomId = [self checkRoomJoined:callback];
    if (!roomId) {
        return;
    }
    if (![self checkIsOwner:callback]) {
        return;
    }
    [self reset];
    [TRTCLiveRoomIMAction destroyRoomWithRoomID:roomId callback:callback];
}

- (void)enterRoomWithRoomID:(UInt32)roomID callback:(Callback)callback {
    [TRTCCloud sharedInstance].delegate = self;
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    if (![self checkRoomUnjoined:callback]) {
        return;
    }
    NSString *roomIDStr = [NSString stringWithFormat:@"%d", roomID];
    if (self.shouldPlayCdn) {
        self.trtcAction.roomId = roomIDStr;
        [self imEnter:roomIDStr callback:callback];
    } else {
        [self trtcEnter:roomIDStr userId:me.userId callback:callback];
        @weakify(self)
        [self imEnter:roomIDStr callback:^(int code, NSString * _Nullable message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (code != 0 && [self canDelegateResponseMethod:@selector(trtcLiveRoom:onError:message:)]) {
                [self.delegate trtcLiveRoom:self onError:code message:message];
            }
        }];
    }
    
}

- (void)imEnter:(NSString *)roomID callback:(Callback)callback {
    @weakify(self)
    [TRTCLiveRoomIMAction enterRoomWithRoomID:roomID success:^(NSArray<TRTCLiveUserInfo *> * _Nonnull members, NSDictionary<NSString *,id> * _Nonnull customInfo, TRTCLiveRoomInfo * _Nullable roomInfo) {
        @strongify(self)
        if (!self) {
            return;
        }
        [self.memberManager setmembers:members groupInfo:customInfo];
        self.curRoomInfo = roomInfo;
        self.status = roomInfo != nil ? roomInfo.roomStatus : TRTCLiveRoomLiveStatusSingle;
        if (callback) {
            callback(0, @"");
        }
        if (self.shouldPlayCdn) {
            [self notifyAvailableStreams];
        }
    } error:callback];
}

- (void)trtcEnter:(NSString *)roomID userId:(NSString *)userId callback:(Callback)callback {
    self.trtcAction.roomId = roomID;
    self.enterRoomCallback = callback;
    [self.trtcAction enterRoomWithRoomID:roomID userId:userId role:TRTCRoleAudience];
    NSString *uuid = [self.trtcAction.curroomUUID mutableCopy];
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([uuid isEqualToString:self.trtcAction.curroomUUID] && self.enterRoomCallback) {
            self.enterRoomCallback(-1, @"enterRoom 请求超时");
            self.enterRoomCallback = nil;
        }
    });
}

- (void)exitRoom:(Callback)callback {
    if (![self checkUserLogIned:callback]) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    if (self.isOwner) {
        if (callback) {
            callback(-1, @"只有普通成员才能退房");
        }
        return;
    }
    [self reset];
    [TRTCLiveRoomIMAction exitRoomWithRoomID:roomID callback:callback];
}

- (void)getRoomInfosWithRoomIDs:(NSArray<NSNumber *> *)roomIDs callback:(RoomInfoCallback)callback {
    NSMutableArray *strRoomIds = [[NSMutableArray alloc] initWithCapacity:2];
    [roomIDs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* str = [obj stringValue];
        [strRoomIds addObject:str];
    }];
    [TRTCLiveRoomIMAction getRoomInfoWithRoomIds:strRoomIds success:^(NSArray<TRTCLiveRoomInfo *> * _Nonnull roomInfos) {
        NSMutableArray *sortInfo = [[NSMutableArray alloc] initWithCapacity:2];
        NSMutableDictionary *resultMap = [[NSMutableDictionary alloc] initWithCapacity:2];
        for (TRTCLiveRoomInfo *room in roomInfos) {
            resultMap[room.roomId] = room;
        }
        for (NSString *roomId in strRoomIds) {
            if ([resultMap.allKeys containsObject:roomId]) {
                TRTCLiveRoomInfo *roomInfo = resultMap[roomId];
                if (roomInfo) {
                    [sortInfo addObject:roomInfo];
                }
            }
        }
        if (callback) {
            callback(0, @"success", sortInfo);
        }
    } error:^(int code, NSString * _Nonnull message) {
        if (callback) {
            callback(code, message, @[]);
        }
    }];
}

- (void)getAnchorList:(UserListCallback)callback {
    if (callback) {
        callback(0, @"", self.memberManager.anchors.allValues);
    }
}

- (void)getAudienceList:(UserListCallback)callback {
    NSString *roomId = [self checkRoomJoined:nil];
    if (!roomId) {
        if (callback) {
            callback(-1, @"没有进入房间", self.memberManager.audience);
        }
        return;
    }
    @weakify(self)
    [TRTCLiveRoomIMAction getAllMembersWithRoomID:roomId success:^(NSArray<TRTCLiveUserInfo *> * _Nonnull members) {
        @strongify(self)
        if (!self) {
            return;
        }
        for (TRTCLiveUserInfo *user in members) {
            if (!self.memberManager.anchors[user.userId]) {
                [self.memberManager addAudience:user];
            }
        }
        if (callback) {
            callback(0, @"", self.memberManager.audience);
        }
    } error:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (callback) {
            callback(0, @"", self.memberManager.audience);
        }
    }];
}

- (void)startCameraPreviewWithFrontCamera:(BOOL)frontCamera view:(UIView *)view callback:(Callback)callback {
    if (![self checkUserLogIned:callback]) {
        return;
    }
    [self.trtcAction startLocalPreview:frontCamera view:view];
    callback(0, @"success");
}

- (void)stopCameraPreview {
    [self.trtcAction stopLocalPreview];
}

- (void)startPublishWithStreamID:(NSString *)streamID callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    [self.trtcAction setupVideoParam:NO];
    [self.trtcAction startPublish:streamID];
    NSString *streamIDNonnull = ([streamID isEqualToString:@""] || !streamID) ? [self.trtcAction cdnUrlForUser:me.userId roomId:roomID] : streamID;
//    if (self.isOwner) {
//        [self.memberManager updateStream:me.userId streamId:streamIDNonnull];
//        if (callback) {
//            callback(0, @"");
//        }
//    } else if (self.ownerId) {
        [self.trtcAction switchRole:TRTCRoleAnchor];
        [TRTCLiveRoomIMAction notifyStreamToAnchorWithUserId:self.ownerId streamID:streamIDNonnull callback:callback];
//    } else {
//        NSAssert(NO, @"");
//    }
}

- (void)stopPublish:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    [self.trtcAction stopPublish];
    [self.memberManager updateStream:me.userId streamId:nil];
    if (self.isOwner) {
        [self.trtcAction exitRoom];
    } else {
        // 观众结束连麦
        [self stopCameraPreview];
        [self switchRoleOnLinkMic:NO];
    }
}

- (void)startPlayWithUserID:(NSString *)userID view:(UIView *)view callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    TRTCLiveUserInfo *user = self.memberManager.pkAnchor;
    NSString *pkAnchorRoomId = self.pkAnchorInfo.roomId;
    if (user && pkAnchorRoomId) {
        [self.trtcAction startPlay:user.userId streamID:user.streamId view:view usesCDN:self.shouldPlayCdn roomId:pkAnchorRoomId callback:callback];
    } else if (self.memberManager.anchors[userID]) {
        TRTCLiveUserInfo *anchor = self.memberManager.anchors[userID];
        [self.trtcAction startPlay:anchor.userId streamID:anchor.streamId view:view usesCDN:self.shouldPlayCdn roomId:nil callback:callback];
    } else {
        if (callback) {
            callback(-1, @"未找到该主播");
        }
    }
}

- (void)stopPlayWithUserID:(NSString *)userID callback:(Callback)callback {
    if (!userID) {
        callback(-1, @"user id is nil");
        return;
    }
    [self.trtcAction stopPlay:userID usesCDN:self.shouldPlayCdn];
    if (callback) {
        callback(0, @"");
    }
}

- (void)requestJoinAnchor:(NSString *)reason responseCallback:(ResponseCallback)responseCallback {
    if (!responseCallback) {
        responseCallback = ^(BOOL reslut, NSString *msg) {};
    }
    TRTCLiveUserInfo *me = [self checkUserLogIned:nil];
    if (!me) {
        responseCallback(NO, @"还未登录");
        return;
    }
    NSString *roomID = [self checkRoomJoined:nil];
    if (!roomID) {
        responseCallback(NO, @"没有进入房间");
        return;
    }
    if (self.isAnchor) {
        responseCallback(NO, @"当前已经是连麦状态");
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusRoomPK || self.pkAnchorInfo.userId) {
        responseCallback(NO, @"当前主播正在PK");
        return;
    }
    if (self.joinAnchorInfo.userId) {
        responseCallback(NO, @"当前用户正在等待连麦回复");
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusNone) {
        responseCallback(NO, @"出错请稍后尝试");
        return;
    }
    
    if (!self.ownerId) {
        return;
    }
    self.requestJoinAnchorCallback = responseCallback;
    self.joinAnchorInfo.userId = me.userId ?: @"";
    self.joinAnchorInfo.uuid = [[NSUUID UUID] UUIDString];
    NSString *uuid = self.joinAnchorInfo.uuid;
    [TRTCLiveRoomIMAction requestJoinAnchorWithUserID:self.ownerId reason:reason callback:^(int code, NSString * _Nonnull message) {
        if (code != 0) {
            if (responseCallback) {
                responseCallback(NO, message);
            }
        }
    }];
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveSendMsgTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (self.requestJoinAnchorCallback && [uuid isEqualToString:self.joinAnchorInfo.uuid]) {
            self.requestJoinAnchorCallback(NO, @"主播未回应连麦请求");
            self.requestJoinAnchorCallback = nil;
            [self clearJoinState];
        }
    });
}

- (void)responseJoinAnchor:(NSString *)userID agree:(BOOL)agree reason:(NSString *)reason {
    TRTCLiveUserInfo *me = [self checkUserLogIned:nil];
    if (!me && !self.isOwner) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:nil];
    if (!roomID) {
        return;
    }
    if ([self.joinAnchorInfo.userId isEqualToString:userID]) {
        self.joinAnchorInfo.isResponsed = YES;
        NSString *uuid = self.joinAnchorInfo.uuid;
        if (agree) {
            @weakify(self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveCheckStatusTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self)
                if (!self) {
                    return;
                }
                if (self.memberManager.anchors[userID] == nil && [uuid isEqualToString:self.joinAnchorInfo.uuid]) {
                    // 连麦未进房
                    [self kickoutJoinAnchor:userID callback:nil];
                    [self clearJoinState];
                } else {
                    [self clearJoinState:NO];
                }
            });
        } else {
            [self clearJoinState:NO];
        }
    }
    [TRTCLiveRoomIMAction respondJoinAnchorWithUserID:userID agreed:agree reason:reason callback:nil];
}

- (void)kickoutJoinAnchor:(NSString *)userID callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me && !self.isOwner) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    if (!self.memberManager.anchors[userID]) {
        if (callback) {
            callback(-1, @"该用户尚未连麦");
        }
        return;
    }
    [TRTCLiveRoomIMAction kickoutJoinAnchorWithUserID:userID callback:callback];
    [self stopLinkMic:userID];
}

- (void)requestRoomPKWithRoomID:(UInt32)roomID userID:(NSString *)userID responseCallback:(ResponseCallback)responseCallback {
    if (!responseCallback) {
        responseCallback = ^(BOOL reslut, NSString *msg) {};
    }
    TRTCLiveUserInfo *me = [self checkUserLogIned:nil];
    if (!me) {
        responseCallback(NO, @"还未登录");
        return;
    }
    NSString *myRoomId = [self checkRoomJoined:nil];
    if (!myRoomId) {
        responseCallback(NO, @"没有进入房间");
        return;
    }
    NSString* streamId = [self checkIsPublishing:nil];
    if (!streamId) {
        responseCallback(NO, @"只有推流后才能操作");
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusLinkMic || self.joinAnchorInfo.userId) {
        responseCallback(NO, @"当前主播正在连麦, 无法开启PK");
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusRoomPK) {
        responseCallback(NO, @"当前主播正在PK");
        return;
    }
    if (self.pkAnchorInfo.userId) {
        responseCallback(NO, @"当前用户正在等待PK回复");
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusNone) {
        responseCallback(NO, @"出错请稍后尝试");
        return;
    }
    NSString *roomIDStr = [NSString stringWithFormat:@"%d", roomID];
    self.requestRoomPKCallback = responseCallback;
    self.pkAnchorInfo.userId = userID;
    self.pkAnchorInfo.roomId = roomIDStr;
    self.pkAnchorInfo.uuid = [[NSUUID UUID] UUIDString];
    NSString *uuid = self.pkAnchorInfo.uuid;
    [TRTCLiveRoomIMAction requestRoomPKWithUserID:userID fromRoomID:myRoomId fromStreamID:streamId callback:^(int code, NSString * _Nonnull message) {
        if (code != 0) {
            responseCallback(NO, message);
        }
    }];
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveSendMsgTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (self.requestRoomPKCallback && [uuid isEqualToString:self.pkAnchorInfo.uuid]) {
            self.requestRoomPKCallback(NO, @"主播未回应跨房PK请求");
            self.requestRoomPKCallback = nil;
            [self clearPKState];
        }
    });
}

- (void)responseRoomPKWithUserID:(NSString *)userID agree:(BOOL)agree reason:(NSString *)reason {
    TRTCLiveUserInfo *me = [self checkUserLogIned:nil];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:nil];
    if (!roomID) {
        return;
    }
    if (![self checkIsOwner:nil]) {
        return;
    }
    NSString *streamId = [self checkIsPublishing:nil];
    if (!streamId) {
        return;
    }
    if ([self.pkAnchorInfo.userId isEqualToString:userID]) {
        self.pkAnchorInfo.isResponsed = YES;
        if (agree) {
            NSString *uuid = self.pkAnchorInfo.uuid;
            @weakify(self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveCheckStatusTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self)
                if (!self) {
                    return;
                }
                if (self.status != TRTCLiveRoomLiveStatusRoomPK && [uuid isEqualToString:self.pkAnchorInfo.uuid]) {
                    [self quitRoomPK:nil];
                    [self clearPKState];
                }
            });
        } else {
            [self clearPKState];
        }
    }
    [TRTCLiveRoomIMAction responseRoomPKWithUserID:userID agreed:agree reason:reason streamID:streamId callback:nil];
}

- (void)quitRoomPK:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    if (self.status == TRTCLiveRoomLiveStatusRoomPK && self.memberManager.pkAnchor) {
        [self.pkAnchorInfo reset];
        self.status = TRTCLiveRoomLiveStatusSingle;
        [[TRTCCloud sharedInstance] disconnectOtherRoom];
        [self.memberManager removeAnchor:self.memberManager.pkAnchor.userId];
        [TRTCLiveRoomIMAction quitRoomPKWithUserID:self.memberManager.pkAnchor.userId callback:callback];
    } else {
        if (callback) {
            callback(-1, @"当前不是PK状态");
        }
    }
}

#pragma mark - 音频设置
- (void)switchCamera {
    [[TRTCCloud sharedInstance] switchCamera];
}

- (void)setMirror:(BOOL)isMirror {
    [[TRTCCloud sharedInstance] setVideoEncoderMirror:isMirror];
}

- (void)muteLocalAudio:(BOOL)isMuted {
    [[TRTCCloud sharedInstance] muteLocalAudio:isMuted];
}

- (void)muteRemoteAudioWithUserID:(NSString *)userID isMuted:(BOOL)isMuted {
    [[TRTCCloud sharedInstance] muteRemoteAudio:userID mute:isMuted];
}

- (void)muteAllRemoteAudio:(BOOL)isMuted {
    [[TRTCCloud sharedInstance] muteAllRemoteAudio:isMuted];
}

- (void)setAudioQuality:(NSInteger)quality {
    if (quality == 3) {
        [[TRTCCloud sharedInstance] setAudioQuality:TRTCAudioQualityMusic];
    } else if (quality == 2) {
        [[TRTCCloud sharedInstance] setAudioQuality:TRTCAudioQualityDefault];
    } else {
        [[TRTCCloud sharedInstance] setAudioQuality:TRTCAudioQualitySpeech];
    }
}

- (void)showVideoDebugLog:(BOOL)isShow {
    [[TRTCCloud sharedInstance] showDebugView:isShow ? 2 : 0];
}

#pragma mark - 发送消息
- (void)sendRoomTextMsg:(NSString *)message callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    [TRTCLiveRoomIMAction sendRoomTextMsgWithRoomID:roomID message:message callback:callback];
}

- (void)sendRoomCustomMsgWithCommand:(NSString *)cmd message:(NSString *)message callback:(Callback)callback {
    TRTCLiveUserInfo *me = [self checkUserLogIned:callback];
    if (!me) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:callback];
    if (!roomID) {
        return;
    }
    [TRTCLiveRoomIMAction sendRoomCustomMsgWithRoomID:roomID command:cmd message:message callback:callback];
}

- (TXBeautyManager *)getBeautyManager {
    return self.beautyManager;
}

- (TXAudioEffectManager *)getAudioEffectManager {
    return [[TRTCCloud sharedInstance] getAudioEffectManager];
}

#pragma mark - private method
- (BOOL)canDelegateResponseMethod:(SEL)method {
    return self.delegate && [self.delegate respondsToSelector:method];
}

#pragma mark - TRTCCloudDelegate
- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo {
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onError:message:)]) {
        [self.delegate trtcLiveRoom:self onError:errCode message:errMsg];
    }
}

- (void)onWarning:(TXLiteAVWarning)warningCode warningMsg:(NSString *)warningMsg extInfo:(NSDictionary *)extInfo {
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onWarning:message:)]) {
        [self.delegate trtcLiveRoom:self onWarning:warningCode message:warningMsg];
    }
}
- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available{
    ///TODO
    
        NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    NSString *tempStr = @"";
    if (available) {
        tempStr = @"star";
    }else{
        tempStr = @"stop";
    }
        NSDictionary *tempDic = @{@"userId":userId,
                                  @"available":tempStr
        };
        [center postNotificationName:@"屏幕共享" object:self userInfo:tempDic];
}


- (void)onEnterRoom:(NSInteger)result {
    [self logApi:@"onEnterRoom", nil];
    if (self.enterRoomCallback) {
        self.enterRoomCallback(0, @"success");
        self.enterRoomCallback = nil;
    }
}

- (void)onRemoteUserEnterRoom:(NSString *)userId {
    if (self.shouldPlayCdn) {
        return;
    }
    if ([self.joinAnchorInfo.userId isEqualToString:userId]) {
        [self clearJoinState:NO];
    }
    if ([self.trtcAction isUserPlaying:userId]) {
        [self.trtcAction startTRTCPlay:userId];
        return;
    }
    if (self.isOwner) {
        if ([self.memberManager.pkAnchor.userId isEqualToString:userId]) {
            self.status = TRTCLiveRoomLiveStatusRoomPK;
            [self.memberManager confirmPKAnchor:userId];
        } else if (!self.memberManager.anchors[userId]) {
            self.status = TRTCLiveRoomLiveStatusLinkMic;
            [self addTempAnchor:userId];
        }
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
            [self.delegate trtcLiveRoom:self onAnchorEnter:userId];
        }
        [self.trtcAction updateMixingParams:self.shouldMixStream];
    } else {
        if (!self.memberManager.anchors[userId]) {
            [self addTempAnchor:userId];
        }
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
            [self.delegate trtcLiveRoom:self onAnchorEnter:userId];
        }
    }
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    [self logApi:@"onremoteUserLeaveRoom", userId, nil];
    if (self.shouldPlayCdn) {
        return;
    }
    if (self.isOwner) {
        if (self.memberManager.anchors[userId] && self.memberManager.anchors.count <= 2) {
            if (self.pkAnchorInfo.userId && self.pkAnchorInfo.roomId) {
                if ([self canDelegateResponseMethod:@selector(trtcLiveRoomOnQuitRoomPK:)]) {
                    [self.delegate trtcLiveRoomOnQuitRoomPK:self];
                }
            }
            [self clearPKState];
            [self clearJoinState];
            self.status = TRTCLiveRoomLiveStatusSingle;
        }
        [self.memberManager removeAnchor:userId];
    }
    
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorExit:)]) {
        [self.delegate trtcLiveRoom:self onAnchorExit:userId];
    }
    if (self.isOwner) {
        [self.trtcAction updateMixingParams:self.shouldMixStream];
    }
}

- (void)onFirstVideoFrame:(NSString *)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height {
    [self.trtcAction onFirstVideoFrame:userId];
}

#pragma mark - TRTCLiveRoomMembermanagerDelegate
- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onUserEnter:(TRTCLiveUserInfo *)user isAnchor:(BOOL)isAnchor {
    if (isAnchor) {
        if (self.configCdn && [self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
            [self.delegate trtcLiveRoom:self onAnchorEnter:user.userId];
        }
    } else {
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAudienceEnter:)]) {
            [self.delegate trtcLiveRoom:self onAudienceEnter:user];
            NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"peopleCount++" object:self userInfo:nil];
            //[]//进入
        }
    }
}

- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onUserLeave:(TRTCLiveUserInfo *)user isAnchor:(BOOL)isAnchor {
    if (isAnchor) {
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorExit:)]) {
            [self.delegate trtcLiveRoom:self onAnchorExit:user.userId];
        }
    } else {
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAudienceExit:)]) {
            [self.delegate trtcLiveRoom:self onAudienceExit:user];
        }
    }
}

- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onChangeStreamId:(NSString *)streamID userId:(NSString *)userId {
    if (self.shouldPlayCdn) {
        return;
    }
    if (self.shouldMixStream && ![self.ownerId isEqualToString:userId]) {
        return;
    }
    if (streamID && ![streamID isEqualToString:@""]) {
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
            [self.delegate trtcLiveRoom:self onAnchorEnter:userId];
        }
    } else {
        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorExit:)]) {
            [self.delegate trtcLiveRoom:self onAnchorExit:userId];
        }
    }
}

- (void)memberManager:(TRTCLiveRoomMemberManager *)manager onChangeAnchorList:(NSArray<NSDictionary<NSString *,id> *> *)anchorList {
    if (!self.isOwner) {
        return;
    }
    NSString *roomID = [self checkRoomJoined:nil];
    if (!roomID) {
        return;
    }
    NSDictionary *data = @{
        @"type": @(self.status),
        @"list": anchorList,
    };
    [TRTCLiveRoomIMAction updateGroupInfoWithRoomID:roomID groupInfo:data callback:nil];
}

- (UIViewController *)currentActiveController {
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//    MADLog(@"windowLevel: %.0f", window.windowLevel);
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *rootVC = window.rootViewController;
    UIViewController *activeVC = nil;
        
    while (true) {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            activeVC = [(UINavigationController *)rootVC visibleViewController];
        } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
            activeVC = [(UITabBarController *)rootVC selectedViewController];
        } else if (rootVC.presentedViewController) {
            activeVC = rootVC.presentedViewController;
        } else if (rootVC.childViewControllers.count > 0) {
            activeVC = [rootVC.childViewControllers lastObject];
        } else {
            break;
        }
        rootVC = activeVC;
    }
    return activeVC;
}

///TODO
#pragma mark - V2TIMAdvancedMsgListener
- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    //接收消息
    if (msg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        V2TIMCustomElem *elem = msg.customElem;
        NSData *data = elem.data;
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            return;
        }
        
        NSNumber* cmd = json[@"cmd"] ?: @(0);
        if (cmd.intValue != 0){
            //连麦开启
            NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"连麦" object:self userInfo:json];
        }
         NSNumber* pushType = json[@"pushType"] ?: @(0);
        
        
        NSNumber* code = json[@"pushType"] ?: @(0);
        if (code.intValue == 10) {
            ///TODO
            NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"通知" object:self userInfo:json];
            
        }
        if (code.intValue == 2) {
            
            
            msg = [[V2TIMManager sharedInstance] createTextMessage:[NSString stringWithFormat:@"↗↖%@",json[@"content"]]] ;
            
            [self handleActionMessage:TRTCLiveRoomIMActionTypeRoomTextMsg elem:msg.textElem message:msg json:@{}];
        }
        
        if (code.intValue == 10012) {
            //禁言
        }
        
        
//        json
//        {
//            code = 200;
//            data =     {
//                content = "\U5f00\U59cb\U7b7e\U5230";
//                countTime = 34;
//            };
//            message = "\U6210\U529f";
//            pushType = 5;
//        }
        NSNumber* action = json[@"action"] ?: @(0);
        id version = json[@"version"] ?: @"";
        BOOL isString = [version isKindOfClass:[NSString class]];
        if (isString && ![version isEqualToString:trtcLiveRoomProtocolVersion]) {
            // 处理兼容性问题
        }
        [self handleActionMessage:[action intValue] elem:elem message:msg json:json];
        
        if (pushType.intValue == 5) {
            //签到
            if ([[self currentActiveController] isKindOfClass:[CountdownViewController class]]) {
                return;
            }
            pushType = @(0);
            _smallViewController = [[CountdownViewController alloc] init];
            _smallViewController.timeCount = [(NSString *)json[@"data"][@"countTime"] intValue];
            BIZPopupViewController *popupViewController = [[BIZPopupViewController alloc] initWithContentViewController:_smallViewController contentSize:CGSizeMake(300, 270)];
            popupViewController.showDismissButton = false;
            _smallViewController.popView = popupViewController;
            
            [[self currentActiveController] presentViewController:popupViewController animated:NO completion:nil];
        }
    } else if (msg.elemType == V2TIM_ELEM_TYPE_TEXT) {
        if (msg.textElem) {
            [self handleActionMessage:TRTCLiveRoomIMActionTypeRoomTextMsg elem:msg.textElem message:msg json:@{}];
        }
    }else if (msg.elemType == V2TIM_ELEM_TYPE_IMAGE){
        // 图片消息
        ///TODOV2TIMImageElem
        [self handleActionMessage:TRTCLiveRoomIMActionTypeRoomImage elem:msg.imageElem message:msg json:@{}];
    }
}

- (void)handleActionMessage:(TRTCLiveRoomIMActionType)action elem:(V2TIMElem *)elem message:(V2TIMMessage *)message json:(NSDictionary<NSString *, id> *)json {
    NSDate* sendTime = message.timestamp;
    // 超过10秒默认超时
    if (sendTime && sendTime.timeIntervalSinceNow < -50) {
        return;
    }
    NSString *userID = message.sender;
    if (!userID) {
        return;
    }
    TRTCLiveUserInfo *liveUser = [[TRTCLiveUserInfo alloc] init];
    liveUser.userId = userID;
    liveUser.userName = message.nickName ?: @"";
    liveUser.avatarURL = message.faceURL ?: @"";
    if (!self.memberManager.anchors[liveUser.userId]) {
        // 非主播，更新观众列表
        if (action != TRTCLiveRoomIMActionTypeRespondRoomPK &&
            action != TRTCLiveRoomIMActionTypeRequestRoomPK &&
            action != TRTCLiveRoomIMActionTypeQuitRoomPK) {
             [self.memberManager addAudience:liveUser];
        }
    }
    
    switch (action) {
        case TRTCLiveRoomIMActionTypeRequestJoinAnchor:
            [self handleJoinAnchorRequestFromUser:liveUser reason:json[@"reason"] ?: @""];
            break;
        case TRTCLiveRoomIMActionTypeRespondJoinAnchor:
        {
            NSNumber *agreedNum = json[@"accept"];
            BOOL agreed = [agreedNum boolValue];
            if (agreed) {
                [self switchRoleOnLinkMic:YES];
                NSString *uuid = self.joinAnchorInfo.uuid;
                @weakify(self)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveCheckStatusTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    @strongify(self)
                    if (!self) {
                        return;
                    }
                    if (self.memberManager.anchors[userID] == nil && [uuid isEqualToString:self.joinAnchorInfo.uuid]) {
                        [self kickoutJoinAnchor:userID callback:nil];
                        [self clearJoinState];
                    } else {
                        [self clearJoinState:NO];
                    }
                });
            } else {
                [self clearJoinState];
            }
            NSString *reason = json[@"reason"] ?: @"";
            if (self.requestJoinAnchorCallback) {
                self.requestJoinAnchorCallback(agreed, reason);
                self.requestJoinAnchorCallback = nil;
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeKickoutJoinAnchor:
        {
            if ([self canDelegateResponseMethod:@selector(trtcLiveRoomOnKickoutJoinAnchor:)]) {
                [self.delegate trtcLiveRoomOnKickoutJoinAnchor:self];
            }
            [self switchRoleOnLinkMic:NO];
        }
            break;
        case TRTCLiveRoomIMActionTypeNotifyJoinAnchorStream:
        {
            NSString *streamId = json[@"stream_id"];
            if (streamId) {
                [self startLinkMic:userID streamId:streamId];
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeRequestRoomPK:
        {
            NSString *roomId = json[@"from_room_id"];
            NSString *streamId = json[@"from_stream_id"];
            if (roomId && streamId) {
                [self handleRoomPKRequestFromUser:liveUser roomId:roomId streamId:streamId];
            }
        }
            break;
        case  TRTCLiveRoomIMActionTypeRespondRoomPK:
        {
            NSNumber *agreedNum = json[@"accept"];
            BOOL agreed = [agreedNum boolValue];
            NSString *streamId = json[@"stream_id"];
            if (streamId && self.requestRoomPKCallback) {
                if (agreed) {
                    [self startRoomPKWithUser:liveUser streamId:streamId];
                    NSString *uuid = self.pkAnchorInfo.uuid;
                    @weakify(self)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveCheckStatusTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        @strongify(self)
                        if (!self) {
                            return;
                        }
                        if (self.status != TRTCLiveRoomLiveStatusRoomPK && [uuid isEqualToString:self.pkAnchorInfo.uuid]) {
                            [self quitRoomPK:nil];
                            [self clearPKState];
                        }
                    });
                } else {
                    [self clearPKState];
                }
                NSString *reason = json[@"reason"] ?: @"";
                if (self.requestRoomPKCallback) {
                    self.requestRoomPKCallback(agreed, reason);
                    self.requestRoomPKCallback = nil;
                }
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeQuitRoomPK:
        {
            self.status = TRTCLiveRoomLiveStatusSingle;
            TRTCLiveUserInfo *pkAnchor = self.memberManager.pkAnchor;
            if (pkAnchor) {
                [self.memberManager removeAnchor:pkAnchor.userId];
            }
            if (self.pkAnchorInfo.userId && self.pkAnchorInfo.roomId) {
                if ([self canDelegateResponseMethod:@selector(trtcLiveRoomOnQuitRoomPK:)]) {
                    [self.delegate trtcLiveRoomOnQuitRoomPK:self];
                }
            }
            [self clearPKState];
        }
            break;
        case TRTCLiveRoomIMActionTypeRoomTextMsg:
        {
            V2TIMTextElem *textElem = (V2TIMTextElem *)elem;
            NSString *text = textElem.text;
            if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRecvRoomTextMsg:fromUser:)]) {
                [self.delegate trtcLiveRoom:self onRecvRoomTextMsg:text fromUser:liveUser];
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeRoomImage:
            {
                TIMImageElem * textElem = (TIMImageElem * )elem;
                NSString * pic_path = @"/xxx/imgPath.jpg";
                //遍历所有图片规格(缩略图、大图、原图)
                NSArray * imgList = [textElem imageList];
                ///TODO
                for (TIMImage * image in imgList) {

                        if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRecvRoomTextMsg:fromUser:)]) {
                            [self.delegate trtcLiveRoom:self onRecvRoomTextMsg:[NSString stringWithFormat:@"↖↗%@",image.url] fromUser:liveUser];
                            break;
                          }
                }
//                TCMsgModel *msgModel = [[TCMsgModel alloc] init];
//                msgModel.userName = @"我";
//                msgModel.msgType = TCMsgModelType_Image;
//                msgModel.userId = [[[ProfileManager shared] loginUserModel] userId];
//                msgModel.userHeadImageUrl = [[ProfileManager shared] curUserModel].avatar;
//                msgModel.tempImage = image;
//                msgModel.msgHeight = 200;
//                [self bulletMsg:msgModel];

        }
        
            case TRTCLiveRoomIMActionTypeRoomCustomMsg:
            {
                NSString *command = json[@"command"];
                NSString *message = json[@"message"];
                if (command && message) {
                    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRecvRoomCustomMsgWithCommand:message:fromUser:)]) {
                        [self.delegate trtcLiveRoom:self onRecvRoomCustomMsgWithCommand:command message:message fromUser:liveUser];
                    }
                }
            }
            break;
        case TRTCLiveRoomIMActionTypeUpdateGroupInfo:
        {
            [self.memberManager updateAnchorsWithGroupinfo:json];
            NSNumber *roomStatus = json[@"type"];
            if (roomStatus) {
                self.status = [roomStatus intValue];
            }
        }
            break;
        case TRTCLiveRoomIMActionTypeUnknown:
//            NSAssert(NO, @"未知命令");
            break;
        default:
            TRTCLog(@"!!!!!!!! 未知消息type");
            break;
    }
}

#pragma mark - V2TIMGroupListener
- (void)onMemberInvited:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList {
    for (V2TIMGroupMemberInfo *member in memberList) {
        TRTCLiveUserInfo *user = [[TRTCLiveUserInfo alloc] init];
        user.userId = member.userID;
        user.userName = member.nickName ?: @"";
        user.avatarURL = member.faceURL ?: @"";
        [self.memberManager addAudience:user];
    }
}

- (void)onMemberLeave:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member {
    [self.memberManager removeMember:member.userID];
}

- (void)onMemberEnter:(NSString *)groupID memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList {
    for (V2TIMGroupMemberInfo *member in memberList) {
        TRTCLiveUserInfo *user = [[TRTCLiveUserInfo alloc] init];
        user.userId = member.userID;
        user.userName = member.nickName ?: @"";
        user.avatarURL = member.faceURL ?: @"";
        [self.memberManager addAudience:user];
    }
}

- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray<V2TIMGroupChangeInfo *> *)changeInfoList {
    V2TIMGroupChangeInfo *info = [changeInfoList firstObject];
    if (info) {
        NSDictionary *customInfo = [info.value mj_JSONObject];
        NSNumber *roomStatus = customInfo[@"type"];
        self.status = [roomStatus intValue];
    }
}

- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    [self handleRoomDismissed:YES];
}

- (void)onRevokeAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList {
    [self handleRoomDismissed:YES];
}


#pragma mark - Actions
- (void)notifyAvailableStreams {
    if (self.shouldMixStream) {
        if (self.ownerId && [self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
            [self.delegate trtcLiveRoom:self onAnchorEnter:self.ownerId];
        }
    } else {
        [self.memberManager.anchors.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorEnter:)]) {
                [self.delegate trtcLiveRoom:self onAnchorEnter:obj];
            }
        }];
    }
}

- (void)handleRoomDismissed:(BOOL)isOwnerDeleted {
    NSString *roomID = [self checkRoomJoined:nil];
    if (!roomID) {
        return;
    }
    if (self.isOwner && !isOwnerDeleted) {
        [self destroyRoom:nil];
    } else {
        [self exitRoom:nil];
    }
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRoomDestroy:)]) {
        [self.delegate trtcLiveRoom:self onRoomDestroy:roomID];
    }
}

- (void)handleJoinAnchorRequestFromUser:(TRTCLiveUserInfo *)user reason:(NSString *)reason {
    if (self.status == TRTCLiveRoomLiveStatusRoomPK || self.pkAnchorInfo.userId != nil) {
        [self responseJoinAnchor:user.userId agree:NO reason:@"主播正在跨房PK中"];
        return;
    }
    if (self.joinAnchorInfo.userId != nil) {
        if (![self.joinAnchorInfo.userId isEqualToString:user.userId]) {
            [self responseJoinAnchor:user.userId agree:NO reason:@"主播正在处理他人连麦中"];
        }
        return;
    }
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRequestJoinAnchor:reason:timeout:)]) {
        [self.delegate trtcLiveRoom:self onRequestJoinAnchor:user reason:reason timeout:trtcLiveHandleMsgTimeOut];
    }
    self.joinAnchorInfo.userId = user.userId;
    self.joinAnchorInfo.uuid = [[NSUUID UUID] UUIDString];
    NSString *uuid = [self.joinAnchorInfo.uuid mutableCopy];
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveHandleMsgTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (!self.joinAnchorInfo.isResponsed && [uuid isEqualToString:self.joinAnchorInfo.uuid]) {
            [self responseJoinAnchor:user.userId agree:NO reason:@"超时未回应"];
            [self clearJoinState];
        }
    });
}

- (void)startLinkMic:(NSString *)userId streamId:(NSString *)streamId {
    self.status = TRTCLiveRoomLiveStatusLinkMic;
    [self.memberManager switchMember:userId toAnchor:YES streamId:streamId];
}

- (void)stopLinkMic:(NSString *)userId {
    self.status = self.memberManager.anchors.count <= 2 ? TRTCLiveRoomLiveStatusSingle : TRTCLiveRoomLiveStatusLinkMic;
    [self.memberManager switchMember:userId toAnchor:NO streamId:nil];
}

- (void)switchRoleOnLinkMic:(BOOL)isLinkMic {
    TRTCLiveUserInfo *me = [self checkUserLogIned:nil];
    if (!me) {
        return;
    }
    [self.memberManager switchMember:me.userId toAnchor:isLinkMic streamId:nil];
    if (self.configCdn && self.shouldMixStream && !isLinkMic) {
        [self.memberManager.anchors enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TRTCLiveUserInfo * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isEqualToString:self.ownerId] && [self.trtcAction isUserPlaying:key]) {
                if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onAnchorExit:)]) {
                    [self.delegate trtcLiveRoom:self onAnchorExit:key];
                }
            }
        }];
    }
    // 将播放流进行切换
    BOOL usesCDN = self.configCdn && !isLinkMic;
    [self.trtcAction togglePlay:usesCDN];
}

- (void)handleRoomPKRequestFromUser:(TRTCLiveUserInfo *)user roomId:(NSString *)roomId streamId:(NSString *)streamId {
    if (self.status == TRTCLiveRoomLiveStatusLinkMic || self.joinAnchorInfo.userId != nil) {
        [self responseRoomPKWithUserID:user.userId agree:NO reason:@"主播正在连麦中"];
        return;
    }
    if ((self.pkAnchorInfo.userId != nil && ![self.pkAnchorInfo.roomId isEqualToString:roomId]) || self.status == TRTCLiveRoomLiveStatusRoomPK) {
        [self responseRoomPKWithUserID:user.userId agree:NO reason:@"主播正在PK中"];
        return;
    }
    if ([self.pkAnchorInfo.userId isEqualToString:user.userId]) {
        return;
    }
    self.pkAnchorInfo.userId = user.userId;
    self.pkAnchorInfo.roomId = roomId;
    self.pkAnchorInfo.uuid = [[NSUUID UUID] UUIDString];
    NSString *uuid = self.pkAnchorInfo.uuid;
    [self prepareRoomPKWithUser:user streamId:streamId];
    if ([self canDelegateResponseMethod:@selector(trtcLiveRoom:onRequestRoomPK:timeout:)]) {
        [self.delegate trtcLiveRoom:self onRequestRoomPK:user timeout:trtcLiveHandleMsgTimeOut];
    }
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLiveHandleMsgTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (!self.pkAnchorInfo.isResponsed && [uuid isEqualToString:self.pkAnchorInfo.uuid]) {
            [self responseRoomPKWithUserID:user.userId agree:NO reason:@"超时未响应"];
            [self clearPKState];
        }
    });
}

- (void)clearPKState {
    [self.pkAnchorInfo reset];
    [self.memberManager removePKAnchor];
}

- (void)clearJoinState {
    [self clearJoinState:YES];
}

- (void)clearJoinState:(BOOL)shouldRemove {
    if (shouldRemove && self.joinAnchorInfo.userId) {
        [self.memberManager removeAnchor:self.joinAnchorInfo.userId];
    }
    [self.joinAnchorInfo reset];
}


/// 观众连麦后，添加的临时主播
/// @param userId 主播ID
- (void)addTempAnchor:(NSString *)userId {
    TRTCLiveUserInfo *user = [[TRTCLiveUserInfo alloc] init];
    user.userId = userId;
    [self.memberManager addAnchor:user];
}

/// 预先保存待PK的主播，等收到视频流后，再确认PK状态
/// @param user 主播
/// @param streamId 流id
- (void)prepareRoomPKWithUser:(TRTCLiveUserInfo *)user streamId:(NSString *)streamId {
    user.streamId = streamId;
    [self.memberManager prepaerPKAnchor:user];
}

// 发起PK的主播，收到确认回复后，调到该函数开启跨房PK
- (void)startRoomPKWithUser:(TRTCLiveUserInfo *)user streamId:(NSString *)streamId {
    NSString *roomId = self.pkAnchorInfo.roomId;
    if (!roomId) {
        return;
    }
    [self prepareRoomPKWithUser:user streamId:streamId];
    [self.trtcAction startRoomPK:roomId userId:user.userId];
}

#pragma mark - Beauty
- (void)setFilter:(UIImage *)image {
    [self.trtcAction setFilter:image];
}

- (void)setFilterConcentration:(float)concentration {
    [self.trtcAction setFilterConcentration:concentration];
}

- (void)setGreenScreenFile:(NSURL *)fileUrl {
    [self.trtcAction setGreenScreenFile:fileUrl];
}

#pragma mark - Utils
- (void)logApi:(NSString *)api, ... NS_REQUIRES_NIL_TERMINATION {
    
}

- (TRTCLiveUserInfo *)checkUserLogIned:(Callback)callback {
    if (!self.me) {
        if (callback) {
            callback(-1, @"还未登录");
        }
        return nil;
    }
    return self.me;
}

- (NSString *)checkRoomJoined:(Callback)callback {
    if (!self.roomID) {
        if (callback) {
            callback(-1, @"还未进入房间");
        }
        return nil;
    }
    return self.roomID;
}

- (BOOL)checkRoomUnjoined:(Callback)callback {
    if (self.roomID) {
        if (callback) {
            callback(-1, @"当前在房间中");
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkIsOwner:(Callback)callback {
    if (!self.isOwner) {
        if (callback) {
            callback(-1, @"只有主播才能操作");
        }
        return NO;
    }
    return YES;
}

- (NSString *)checkIsPublishing:(Callback)callback {
    if (!self.me.streamId) {
        if (callback) {
             callback(-1, @"只有推流后才能操作");
        }
        return nil;
    }
    return self.me.streamId;
}

- (void)reset {
    self.enterRoomCallback = nil;
    [self.trtcAction exitRoom];
    [self.trtcAction stopAllPlay:self.shouldPlayCdn];
    self.trtcAction.roomId = nil;
    self.status = TRTCLiveRoomLiveStatusNone;
    [self clearPKState];
    [self clearJoinState];
    [self.memberManager clearMembers];
    self.curRoomInfo = nil;
}

#pragma mark - private readOnly property
- (BOOL)isOwner {
    if (self.me.userId) {
        return [self.me.userId isEqualToString:self.memberManager.ownerId];
    }
    return NO;
}

- (BOOL)isAnchor {
    if (self.me.userId) {
        return self.memberManager.anchors[self.me.userId] != nil;
    }
    return false;
}

- (BOOL)configCdn {
    return self.config.useCDNFirst;
}

- (BOOL)shouldPlayCdn {
    return self.configCdn && !self.isAnchor;
}

- (BOOL)shouldMixStream {
    switch (self.status) {
        case TRTCLiveRoomLiveStatusNone:
            return NO;
        case TRTCLiveRoomLiveStatusSingle:
            return NO;
        case TRTCLiveRoomLiveStatusLinkMic:
            return self.mixingLinkMicStream;
        case TRTCLiveRoomLiveStatusRoomPK:
            return self.mixingPKStream;
        default:
            break;
    }
    return NO;
}

@end
