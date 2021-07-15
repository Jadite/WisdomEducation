/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.app.wisdom.edu.logic.cmd

import com.netease.yunxin.app.wisdom.edu.logic.model.NEEduMember
import com.netease.yunxin.app.wisdom.edu.logic.model.NEEduMemberProperties

class RoomMemberPropertiesRemoveAction(
    appKey: String,
    roomUuid: String,
    val key: String,
    val member: NEEduMember,
) : CMDAction(appKey, roomUuid)