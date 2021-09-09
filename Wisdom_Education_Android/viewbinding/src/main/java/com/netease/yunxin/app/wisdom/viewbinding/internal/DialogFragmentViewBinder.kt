/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.app.wisdom.viewbinding.internal

import android.view.View
import androidx.annotation.IdRes
import androidx.annotation.RestrictTo
import androidx.fragment.app.DialogFragment
import androidx.viewbinding.ViewBinding

@RestrictTo(RestrictTo.Scope.LIBRARY)
@PublishedApi
internal class DialogFragmentViewBinder<T : ViewBinding>(
    private val viewBindingClass: Class<T>,
    @IdRes private val viewBindingRootId: Int = 0
) {

    /**
     * Cache static method `ViewBinding.bind(View)`
     */
    private val bindViewMethod by lazy(LazyThreadSafetyMode.NONE) {
        viewBindingClass.getMethod("bind", View::class.java)
    }

    /**
     * Create new [ViewBinding] instance
     */
    @Suppress("UNCHECKED_CAST")
    fun bind(fragment: DialogFragment): T {
        return bindViewMethod(null, getRootView(fragment)) as T
    }

    private fun getRootView(fragment: DialogFragment): View {
        val dialog = checkNotNull(fragment.dialog) { "Dialog hasn't been created yet" }
        val window = checkNotNull(dialog.window) { "Dialog has no window" }
        return if (viewBindingRootId != 0) {
            window.decorView.findViewById(viewBindingRootId)
        } else {
            window.decorView
        }
    }
}
