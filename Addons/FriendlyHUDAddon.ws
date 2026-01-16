@wrapMethod(CR4Game) function PopulateMenuQueueMainAlways(out menus: array<name>) {
    wrappedMethod(menus);
    if (!theGame.GetInGameConfigWrapper().GetVarValue('PanelShortcuts', 'FHUDAddon'))
        theGame.GetInGameConfigWrapper().SetVarValue('PanelShortcuts', 'FHUDAddon', true);
}

@wrapMethod(CPanelShortcut) function PerformAction(targetName: name) {
    if (targetName == 'ToggleEssentials'){
        ToggleEssentialModules(!IsHUDGroupEnabledForReason(GetFHUDConfig().essentialModules, "PinEssentialGroup"), "PinEssentialGroup");
        return;
    }
        
    if (targetName == 'Toggle3DMarkers'){
        thePlayer.fHUDConfig.Toggle3DMarkers();
        return;
    }

    wrappedMethod(targetName);
}