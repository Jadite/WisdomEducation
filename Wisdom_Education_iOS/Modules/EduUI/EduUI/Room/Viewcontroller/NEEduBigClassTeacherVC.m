//
//  NEEduBigClassTeacherVC.m
//  EduUI
//
//  Created by Groot on 2021/6/3.
//  Copyright © 2021 NetEase. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file
//

#import "NEEduBigClassTeacherVC.h"
#import "NEEduHandsupStudentList.h"
#import "UIView+Toast.h"

@interface NEEduBigClassTeacherVC ()<NEEduHandsupStudentListDelegate>
@property (nonatomic, strong) NEEduMenuItem *handsupItem;
@property (nonatomic, strong) NSMutableArray<NEEduHttpUser *> *applyMembers;
@property (nonatomic, assign) NEEduHandsupState handsupState;
@property (nonatomic, strong) NEEduHandsupStudentList *applyVC;

@end

@implementation NEEduBigClassTeacherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateHandsupStateWithProfile:[EduManager shared].profile];
}

- (void)initMenuItems {
    NEEduMenuItem *audoItem = [[NEEduMenuItem alloc] initWithTitle:@"静音" image:[UIImage ne_imageNamed:@"menu_audio"]];
    audoItem.selectTitle = @"取消静音";
    audoItem.type = NEEduMenuItemTypeAudio;
    [audoItem setSelctedImage:[UIImage ne_imageNamed:@"menu_audio_off"]];
    
    NEEduMenuItem *videoItem = [[NEEduMenuItem alloc] initWithTitle:@"关闭摄像头" image:[UIImage ne_imageNamed:@"menu_video"]];
    videoItem.selectTitle = @"打开摄像头";
    videoItem.type = NEEduMenuItemTypeVideo;
    [videoItem setSelctedImage:[UIImage ne_imageNamed:@"menu_video_off"]];

    NEEduMenuItem *shareItem = [[NEEduMenuItem alloc] initWithTitle:@"共享屏幕" image:[UIImage ne_imageNamed:@"menu_share_screen"]];
    shareItem.type = NEEduMenuItemTypeShareScreen;
    [shareItem setSelctedImage:[UIImage ne_imageNamed:@"menu_share_screen_stop"]];
    
    NEEduMenuItem *membersItem = [[NEEduMenuItem alloc] initWithTitle:@"课堂成员" image:[UIImage ne_imageNamed:@"menu_members"]];
    membersItem.type = NEEduMenuItemTypeMembers;
    
    NEEduMenuItem *handsupItem = [[NEEduMenuItem alloc] initWithTitle:@"举手" image:[UIImage ne_imageNamed:@"menu_handsup"]];
    handsupItem.type = NEEduMenuItemTypeHandsup;
    [handsupItem setSelctedImage:[UIImage ne_imageNamed:@"menu_handsup_select"]];
    self.handsupItem = handsupItem;
    
    NEEduMenuItem *chatItem = [[NEEduMenuItem alloc] initWithTitle:@"聊天室" image:[UIImage ne_imageNamed:@"menu_chat"]];
    chatItem.type = NEEduMenuItemTypeChat;
    self.menuItems = @[audoItem,videoItem,shareItem,membersItem,handsupItem,chatItem];
}
- (NSArray <NEEduHttpUser *>*)membersWithProfile:(NEEduRoomProfile *)profile {
    NEEduHttpUser *teacher = [[NEEduHttpUser alloc] init];
    teacher.role = NEEduRoleHost;
    NSMutableArray *totalArray = [NSMutableArray arrayWithObject:teacher];
    NSMutableArray *onlineArray = [NSMutableArray arrayWithObject:teacher];
    for (NEEduHttpUser *user in profile.snapshot.members) {
        if ([user.role isEqualToString:NEEduRoleHost]) {
            [totalArray replaceObjectAtIndex:0 withObject:user];
            [onlineArray replaceObjectAtIndex:0 withObject:user];
        }else {
            if ([user.userUuid isEqualToString:[EduManager shared].localUser.userUuid]) {
                //自己
                [totalArray insertObject:user atIndex:1];
                if (user.properties.avHandsUp.value == NEEduHandsupStateTeaAccept) {
                    [onlineArray insertObject:user atIndex:1];
                }
            }else  {
                [totalArray addObject:user];
                if (user.properties.avHandsUp.value == NEEduHandsupStateTeaAccept) {
                    [onlineArray addObject:user];
                }
            }
        }
    }
    self.totalMembers = totalArray;
    self.members = onlineArray;
    self.room = profile.snapshot.room;
    return onlineArray;
}
- (void)updateHandsupStateWithProfile:(NEEduRoomProfile *)profile {
    //统计举手申请人数
    NSMutableArray *array = [NSMutableArray array];
    for (NEEduHttpUser *user in profile.snapshot.members) {
        if (user.properties.avHandsUp.value == NEEduHandsupStateApply) {
            [array addObject:user];
        }
    }
    self.applyMembers = array;
    self.handsupItem.badgeNumber = self.applyMembers.count;
    if (self.applyVC.presentingViewController) {
        [self.applyVC.tableView reloadData];
    }
}

- (void)onHandsupStateChange:(NEEduHandsupState)state user:(NEEduHttpUser *)user {
    self.handsupState = state;
    switch (state) {
        case NEEduHandsupStateIdle:
            //学生关闭
            [self handleHandsupClose:user];
            break;
        case NEEduHandsupStateApply:
            //学生申请
            [self handleHandsupAppy:user];
            break;
        case NEEduHandsupStateTeaAccept:
            [self handleHandsupAccept:user];
            break;
        case NEEduHandsupStateStuCancel:
            //学生取消
            [self handleHandsupCancel:user];
            break;
        case NEEduHandsupStateTeaOffStage:
            [self handleHandsupTeacherOffStage:user];
            break;
        default:
            break;
    }
}
- (void)handleHandsupAppy:(NEEduHttpUser *)user {
    //1.红点人数更新
    [self.applyMembers addObject:user];
    self.handsupItem.badgeNumber = self.applyMembers.count;
    //2.toast
    if (self.applyVC.presentingViewController) {
        [self.applyVC.tableView reloadData];
    }else {
        [self.view makeToast:@"有新的举手申请"];
    }
}
- (void)handleHandsupCancel:(NEEduHttpUser *)user {
    [self.applyMembers removeObject:user];
    self.handsupItem.badgeNumber = self.applyMembers.count;
    if (self.applyVC.presentingViewController) {
        [self.applyVC.tableView reloadData];
    }
}
- (void)handleHandsupAccept:(NEEduHttpUser *)user {
    [self.members addObject:user];
    if (self.membersVC) {
        [self.membersVC user:user.userUuid online:YES];
    }
    [[EduManager shared].videoService subscribeAudio:YES forUserID:user.rtcUid];
    [[EduManager shared].videoService subscribeVideo:YES forUserID:user.rtcUid];
}
- (void)handleHandsupClose:(NEEduHttpUser *)user {
    //学生关闭
    NEEduHttpUser *removeUser;
    for (NEEduHttpUser *userTmp in self.members) {
        if ([userTmp.userUuid isEqualToString:user.userUuid]) {
            removeUser = userTmp;
        }
    }
    if (removeUser) {
        [self.members removeObject:removeUser];
    }
    
    [self.collectionView reloadData];
    [[EduManager shared].videoService subscribeAudio:NO forUserID:user.rtcUid];
    [[EduManager shared].videoService subscribeVideo:NO forUserID:user.rtcUid];
    if (self.membersVC) {
        [self.membersVC user:user.userUuid online:NO];
    }
    
}
- (void)handleHandsupTeacherOffStage:(NEEduHttpUser *)user {
    NEEduHttpUser *removeUser;
    for (NEEduHttpUser *userTmp in self.members) {
        if ([userTmp.userUuid isEqualToString:user.userUuid]) {
            removeUser = userTmp;
        }
    }
    if (removeUser) {
        [self.members removeObject:removeUser];
    }
    
    [self.collectionView reloadData];
    [[EduManager shared].videoService subscribeAudio:NO forUserID:user.rtcUid];
    [[EduManager shared].videoService subscribeVideo:NO forUserID:user.rtcUid];
    if (self.membersVC) {
        [self.membersVC user:user.userUuid online:NO];
    }
}

#pragma mark -老师点击举手申请列表
- (void)handsupItem:(NEEduMenuItem *)item {
    if ([EduManager shared].profile.snapshot.room.states.step.value == NEEduLessonStateNone) {
        [self.view makeToast:@"还未开始上课"];
        return;
    }
    NEEduHandsupStudentList *applyVC = [[NEEduHandsupStudentList alloc] init];
    applyVC.applyStudents = self.applyMembers;
    applyVC.delegate = self;
    self.applyVC = applyVC;
    applyVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:applyVC animated:YES completion:nil];
}
#pragma mark - NEEduMessageServiceDelegate
- (void)onUserInWithUser:(NEEduHttpUser *)user members:(NSArray *)members {
    if ([user.role isEqualToString:NEEduRoleHost]) {
        [self.members replaceObjectAtIndex:0 withObject:user];
        [self.totalMembers replaceObjectAtIndex:0 withObject:user];
    }else {
        if ([user.userUuid isEqualToString:[EduManager shared].localUser.userUuid]) {
            //自己
            [self.totalMembers insertObject:user atIndex:1];
            if (user.properties.avHandsUp.value == NEEduHandsupStateTeaAccept) {
                [self.members insertObject:user atIndex:1];
            }
        }else {
            [self.totalMembers addObject:user];
            if (user.properties.avHandsUp.value == NEEduHandsupStateTeaAccept) {
                [self.members addObject:user];
            }
        }
    }
    [self.collectionView reloadData];
    //更新课堂成员页面
    if (self.membersVC) {
        if ([user.role isEqualToString:NEEduRoleHost]) {
            return;
        }
        [self.membersVC memberIn:[self memberFromHttpUser:user]];
    }
}

- (void)onUserOutWithUser:(NEEduHttpUser *)user members:(nonnull NSArray *)members {
    NEEduHttpUser *placeholdUser = [[NEEduHttpUser alloc] init];
    if ([user.role isEqualToString:NEEduRoleHost]) {
        placeholdUser.role = NEEduRoleHost;
        [self.totalMembers replaceObjectAtIndex:0 withObject:placeholdUser];
        [self.members replaceObjectAtIndex:0 withObject:placeholdUser];
    }else {
        NEEduHttpUser *removeUser;
        for (NEEduHttpUser *tempUser in self.members) {
            if ([tempUser.userUuid isEqualToString:user.userUuid]) {
                removeUser = tempUser;
                break;
            }
        }
        if (removeUser) {
            [self.members removeObject:removeUser];
        }
        NEEduHttpUser *remove;
        for (NEEduHttpUser *tempUser in self.totalMembers) {
            if ([tempUser.userUuid isEqualToString:user.userUuid]) {
                remove = tempUser;
            }
        }
        if (remove) {
            [self.totalMembers removeObject:remove];
        }
    }
    [self.collectionView reloadData];
    //更新课堂成员页面
    if (self.membersVC) {
        if ([user.role isEqualToString:NEEduRoleHost]) {
            return;
        }
        [self.membersVC memberOut:user.userUuid];
    }
    
    //更新举手申请
    NEEduHttpUser *removeUser;
    for (NEEduHttpUser *applyUser in self.applyMembers) {
        if ([applyUser.userUuid isEqualToString:user.userUuid]) {
            removeUser = applyUser;
            break;
        }
    }
    if (removeUser) {
        [self.applyMembers removeObject:removeUser];
        self.handsupItem.badgeNumber = self.applyMembers.count;
        if (self.applyVC.presentingViewController) {
            [self.applyVC.tableView reloadData];
        }
    }
}
#pragma mark - NEEduHandsupStudentListDelegate
- (void)didAgreeWithMember:(NEEduHttpUser *)member {
    self.handsupItem.badgeNumber = self.applyMembers.count;
}
- (void)didDisAgreeWithMember:(NEEduHttpUser *)member {
    self.handsupItem.badgeNumber = self.applyMembers.count;
}
@end
