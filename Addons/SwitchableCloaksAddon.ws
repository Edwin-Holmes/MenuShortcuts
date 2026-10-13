@wrapMethod(CR4Game) function PopulateMenuQueueMainAlways(out menus: array<name>) {
    wrappedMethod(menus);
    if (!theGame.GetInGameConfigWrapper().GetVarValue('PanelShortcuts', 'ToggleCloaksAddon'))
        theGame.GetInGameConfigWrapper().SetVarValue('PanelShortcuts', 'ToggleCloaksAddon', true);
}

@wrapMethod(CPanelShortcut) function PerformAction(targetName: name) {
    var dummyAction: SInputAction;
    thePlayer.DisplayHudMessage("Cloaks addon action called");

    if (targetName == 'ToggleVanity') {
            dummyAction.aName = 'SwitchCloak';
            dummyAction.value = 1.0;
            dummyAction.lastFrameValue = 0.0;
            if (!thePlayer.ArdCloakSwitch) {
                thePlayer.DisplayHudMessage("Class not found");
                return;
            }
            thePlayer.ArdCloakSwitch.OnToggleVanityItem(dummyAction);
            thePlayer.DisplayHudMessage("togglevanityitem called with switch cloak");
            return;
    }

    wrappedMethod(targetName);
}