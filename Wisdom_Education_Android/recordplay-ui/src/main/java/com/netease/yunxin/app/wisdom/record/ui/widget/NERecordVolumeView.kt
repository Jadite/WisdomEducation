/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.app.wisdom.record.ui.widget

import android.annotation.SuppressLint
import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.RelativeLayout
import android.widget.SeekBar
import com.netease.yunxin.app.wisdom.record.ui.databinding.LayoutVolumeViewBinding

class NERecordVolumeView(context: Context, attrs: AttributeSet?, defStyleAttr: Int = 0) :
    RelativeLayout(context, attrs, defStyleAttr) {

    private val binding = LayoutVolumeViewBinding.inflate(LayoutInflater.from(context), this, true)

    constructor(context: Context) : this(context, null, 0)

    constructor(context: Context, attrs: AttributeSet?) : this(context, attrs, 0)

    fun getControllerView(): SeekBar {
        return binding.seekbarVolume
    }

    @SuppressLint("ClickableViewAccessibility")
    fun show() {
        this.visibility = View.VISIBLE
        this.setOnClickListener {
            hide()
        }
    }

    fun hide() {
        this.visibility = View.GONE
        this.setOnTouchListener(null)
    }
}