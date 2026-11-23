// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

const String _dismissedKey = 'oqoody_pwa_dismissed';
dynamic _deferredPrompt;

bool checkPwaBrowserModeOnly() {
  try {
    final w = html.window;
    final isStandalone = w.matchMedia('(display-mode: standalone)').matches;
    final isFullscreen = w.matchMedia('(display-mode: fullscreen)').matches;
    final isMinimalUi = w.matchMedia('(display-mode: minimal-ui)').matches;

    // iOS Safari Home Screen standalone mode check
    bool isIosStandalone = false;
    try {
      // ignore: undefined_getter
      isIosStandalone = (w.navigator as dynamic).standalone == true;
    } catch (_) {}

    // Android Trusted Web Activity (TWA) or Android WebView referrer
    final isAndroidApp = html.document.referrer.startsWith('android-app://');

    if (isStandalone || isFullscreen || isMinimalUi || isIosStandalone || isAndroidApp) {
      return false; // Installed PWA or Native mode -> HIDE
    }

    return true; // Regular Web Browser -> SHOW
  } catch (_) {
    return false;
  }
}

bool checkIsSecureWebContext() {
  try {
    final isSecure = js_util.getProperty(html.window, 'isSecureContext');
    if (isSecure is bool) return isSecure;
    return html.window.location.protocol == 'https:' ||
        html.window.location.hostname == 'localhost' ||
        html.window.location.hostname == '127.0.0.1';
  } catch (_) {
    return true;
  }
}

void setupAppInstalledListener(Function() onInstalled) {
  try {
    html.window.addEventListener('appinstalled', (event) {
      setPwaBannerDismissed();
      onInstalled();
    });
  } catch (_) {}
}

void setupBeforeInstallPromptListener([Function()? onPromptReady]) {
  try {
    // If deferred prompt already captured in window.deferredPwaPrompt
    if (canTriggerNativePrompt() && onPromptReady != null) {
      onPromptReady();
    }

    html.window.addEventListener('beforeinstallprompt', (event) {
      event.preventDefault();
      _deferredPrompt = event;
      if (onPromptReady != null) {
        onPromptReady();
      }
    });

    // Also register into window.pwaPromptReadyListeners
    try {
      final listeners = js_util.getProperty(html.window, 'pwaPromptReadyListeners');
      if (listeners != null && onPromptReady != null) {
        js_util.callMethod(listeners, 'push', [() => onPromptReady()]);
      }
    } catch (_) {}
  } catch (_) {}
}

Future<bool> triggerNativeInstallPrompt() async {
  try {
    // 1. Try invoking window.triggerNativePwaInstall() defined in index.html
    if (js_util.hasProperty(html.window, 'triggerNativePwaInstall')) {
      final promise = js_util.callMethod(html.window, 'triggerNativePwaInstall', []);
      final res = await js_util.promiseToFuture(promise);
      final success = js_util.getProperty(res, 'success') == true;
      if (success) {
        setPwaBannerDismissed();
      }
      return success;
    }

    // 2. Direct prompt fallback
    dynamic promptEvent = _deferredPrompt;
    if (promptEvent == null) {
      try {
        promptEvent = js_util.getProperty(html.window, 'deferredPwaPrompt');
      } catch (_) {}
    }

    if (promptEvent != null) {
      js_util.callMethod(promptEvent, 'prompt', []);
      final choicePromise = js_util.getProperty(promptEvent, 'userChoice');
      final choice = await js_util.promiseToFuture(choicePromise);
      final outcome = js_util.getProperty(choice, 'outcome');
      if (outcome == 'accepted') {
        _deferredPrompt = null;
        try {
          js_util.setProperty(html.window, 'deferredPwaPrompt', null);
        } catch (_) {}
        setPwaBannerDismissed();
        return true;
      }
    }
  } catch (e) {
    // ignore
  }
  return false;
}

bool canTriggerNativePrompt() {
  try {
    if (js_util.getProperty(html.window, 'deferredPwaPrompt') != null) {
      return true;
    }
  } catch (_) {}
  return _deferredPrompt != null;
}

bool checkPwaBannerDismissed() {
  try {
    return html.window.sessionStorage[_dismissedKey] == 'true';
  } catch (_) {
    return false;
  }
}

void setPwaBannerDismissed() {
  try {
    html.window.sessionStorage[_dismissedKey] = 'true';
  } catch (_) {}
}
