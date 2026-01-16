@wrapMethod(CR4Game) function PopulateMenuQueueMainAlways(out menus: array<name>) {
    wrappedMethod(menus);
    if (!theGame.GetInGameConfigWrapper().GetVarValue('PanelShortcuts', 'HoodsAddon'))
        theGame.GetInGameConfigWrapper().SetVarValue('PanelShortcuts', 'HoodsAddon', true);
}

@wrapMethod(CPanelShortcut) function PerformAction(targetName: name) {
    if (targetName == 'ToggleHood') {
            HOODS_swapEquipedHood();
            return;
    }

    wrappedMethod(targetName);
}