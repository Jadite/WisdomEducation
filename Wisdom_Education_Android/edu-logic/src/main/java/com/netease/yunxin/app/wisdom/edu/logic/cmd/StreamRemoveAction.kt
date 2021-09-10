/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.app.wisdom.edu.logic.cmd

import com.netease.yunxin.app.wisdom.edu.logic.model.NEEduMember

/**
 * Created by hzsunyj on 2021/5/27.
 */
class StreamRemoveAction(
    appKey: String,
    roomUuid: String,
    val streamType: String,
    val member: NEEduMember,
) : CMDAction(appKey, roomUuid)