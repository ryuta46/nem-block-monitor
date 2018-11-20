package com.ttechsoft.nemblockmonitorapp

import android.os.Bundle
import com.ryuta46.nemkotlin.account.AccountGenerator
import com.ryuta46.nemkotlin.enums.Version
import com.ryuta46.nemkotlin.util.ConvertUtils

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    companion object {
        private const val channel = "nemblockmonitorapp.ttechsoft.com/nem"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        GeneratedPluginRegistrant.registerWith(this)

        val methodChannel = MethodChannel(flutterView, channel).setMethodCallHandler { methodCall, result ->
            when(methodCall.method) {
                "calculateAddress" -> {
                    val publicKey = methodCall.argument<String>("publicKey")
                    val networkType = when (methodCall.argument<Int>("networkType")) {
                        0x68 -> Version.Main
                        else -> Version.Test
                    }

                    val address = AccountGenerator.calculateAddress(ConvertUtils.toByteArray(publicKey!!), networkType)
                    result.success(address)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

    }
}
