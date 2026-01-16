@addMethod(CR4HudModuleConsole) public function GetActionLog() : WmkActionLog {
    return actionLog;
}

@wrapMethod(CR4Game) function PopulateMenuQueueMainAlways(out menus: array<name>) {
    wrappedMethod(menus);
    if (!theGame.GetInGameConfigWrapper().GetVarValue('PanelShortcuts', 'ActionLogAddon'))
        theGame.GetInGameConfigWrapper().SetVarValue('PanelShortcuts', 'ActionLogAddon', true);
}

@wrapMethod(CPanelShortcut) function PerformAction(targetName: name) {
    var dummyAction: SInputAction;
    var hud : CR4ScriptedHud;
    var consoleModule : CR4HudModuleConsole;

    if (targetName == 'ToggleActionLog') {
        dummyAction.aName = 'ActionLog';
        dummyAction.value = 0.0;                                          // Simulate isReleased(action)
        dummyAction.lastFrameValue = 1.0;
        hud = (CR4ScriptedHud)theGame.GetHud();

        if (hud) {
            consoleModule = (CR4HudModuleConsole)hud.GetHudModule('ConsoleModule');
            if (consoleModule && consoleModule.GetActionLog()) {
                consoleModule.GetActionLog().OnActionLog(dummyAction);
                return;
            }
        }
    }

    wrappedMethod(targetName);
}
