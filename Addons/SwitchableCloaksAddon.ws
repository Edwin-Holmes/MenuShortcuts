@wrapMethod(CR4Game) function PopulateMenuQueueMainAlways(out menus: array<name>) {
    wrappedMethod(menus);
    if (!theGame.GetInGameConfigWrapper().GetVarValue('PanelShortcuts', 'ToggleCloaksAddon'))
        theGame.GetInGameConfigWrapper().SetVarValue('PanelShortcuts', 'ToggleCloaksAddon', true);
}

@wrapMethod(CPanelShortcut) function PerformAction(targetName: name) {
    var dummyAction: SInputAction;

    if (targetName == 'ToggleVanity') {
            dummyAction.aName = 'SwitchCloak';
            dummyAction.value = 1.0;
            dummyAction.lastFrameValue = 0.0;
            thePlayer.ArdCloakSwitch.OnToggleVanityItem(dummyAction);
            return;
    }

    wrappedMethod(targetName);
}