@wrapMethod(CR4Game) function PopulateMenuQueueMainAlways(out menus: array<name>) {
    wrappedMethod(menus);
    if (!theGame.GetInGameConfigWrapper().GetVarValue('PanelShortcuts', 'IHCAddon'))
        theGame.GetInGameConfigWrapper().SetVarValue('PanelShortcuts', 'IHCAddon', true);
}

@wrapMethod(CPanelShortcut) function PerformAction(targetName: name) {
    var horseComp: W3HorseComponent;

    if (targetName == 'ToggleRoadFollow') {
            horseComp = thePlayer.GetUsedHorseComponent();
            horseComp.ToggleRoadFollow();
            return;
    }

    wrappedMethod(targetName);
}