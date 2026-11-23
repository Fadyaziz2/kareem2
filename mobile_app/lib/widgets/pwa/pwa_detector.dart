import 'pwa_detector_stub.dart'
    if (dart.library.html) 'pwa_detector_web.dart';

bool isPwaBrowserModeOnly() => checkPwaBrowserModeOnly();

bool isSecureWebContext() => checkIsSecureWebContext();

void listenToAppInstalled(Function() onInstalled) => setupAppInstalledListener(onInstalled);

void initBeforeInstallPrompt([Function()? onPromptReady]) => setupBeforeInstallPromptListener(onPromptReady);

Future<bool> promptNativeInstall() => triggerNativeInstallPrompt();

bool hasNativePrompt() => canTriggerNativePrompt();

bool isPwaBannerDismissed() => checkPwaBannerDismissed();

void dismissPwaBanner() => setPwaBannerDismissed();
