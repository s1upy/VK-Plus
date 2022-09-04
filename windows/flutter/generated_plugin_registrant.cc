//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <dart_vlc/dart_vlc_plugin.h>
#include <desktop_webview_window/desktop_webview_window_plugin.h>
#include <flutter_native_view/flutter_native_view_plugin.h>
#include <screen_retriever/screen_retriever_plugin.h>
#include <sidebar_bigeagle/sidebar_bigeagle_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DartVlcPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DartVlcPlugin"));
  DesktopWebviewWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopWebviewWindowPlugin"));
  FlutterNativeViewPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterNativeViewPlugin"));
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
  SidebarBigeaglePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SidebarBigeaglePlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}
