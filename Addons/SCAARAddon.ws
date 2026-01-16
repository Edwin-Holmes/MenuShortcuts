@wrapMethod(CR4Game) function PopulateMenuQueueMainAlways(out menus: array<name>) {
    wrappedMethod(menus);
    if (!theGame.GetInGameConfigWrapper().GetVarValue('PanelShortcuts', 'SCAARAddon')) {
        theGame.GetInGameConfigWrapper().SetVarValue('PanelShortcuts', 'SCAARAddon', true);
    }
}

@wrapMethod(CPanelShortcut) function PerformAction(targetName: name) {
    if (targetName == 'Taunt') {
        SCAARCallTaunt();   
        return;
    }
    
    wrappedMethod(targetName);
}
