package com.ttechsoft.nemblockmonitorapp

import android.os.Bundle
import com.mikepenz.aboutlibraries.Libs
import com.mikepenz.aboutlibraries.LibsBuilder
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
                "toOssLicense" -> {
                    LibsBuilder()
                            .withActivityStyle(Libs.ActivityStyle.LIGHT_DARK_TOOLBAR)
                            .withActivityTitle("Licenses")
                            .withLicenseShown(true)
                            .withLibraries(
                                    "rational","built_value","web_socket_channel","meta","json_serializable","matcher","firebase_analytics","url_launcher","build_runner_core","boolean_selector","cupertino_icons","mime","code_builder","watcher","quiver","package_config","collection","firebase_messaging","bloc","html","kernel","pool","platform","glob","shared_preferences","pubspec_parse","pub_semver","source_gen","intl","path","build","http_parser","test_api","vector_math","http_multi_server","decimal","analyzer","dart_style","flutter_bloc","cloud_firestore","async","firebase_core","build_config","firebase_auth","charcode","http","json_annotation","io","shelf_web_socket","pedantic","built_collection","flutter_local_notifications","term_glyph","stream_channel","utf","source_span","shelf","string_scanner","js","front_end","args","typed_data","rxdart","crypto","build_resolvers","csslib","stack_trace","plugin","convert","build_runner","fixnum","stream_transform","timing","graphs","logging","yaml"
                            )
                    //start the activity
                    .start(this)
                }
                else -> {
                    result.notImplemented()
                }


            }
        }

    }
}
