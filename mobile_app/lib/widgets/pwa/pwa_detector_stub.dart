bool checkPwaBrowserModeOnly() => false;

bool checkIsSecureWebContext() => true;

void setupAppInstalledListener(Function() onInstalled) {}

void setupBeforeInstallPromptListener([Function()? onPromptReady]) {}

Future<bool> triggerNativeInstallPrompt() async => false;

bool canTriggerNativePrompt() => false;

bool checkPwaBannerDismissed() => false;

void setPwaBannerDismissed() {}
