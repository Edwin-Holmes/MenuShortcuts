@wrapMethod(CR4Game) function PopulateMenuQueueMainAlways(out menus: array<name>) {
    wrappedMethod(menus);
    if (!theGame.GetInGameConfigWrapper().GetVarValue('PanelShortcuts', 'ImmersiveExplorationAddon'))
        theGame.GetInGameConfigWrapper().SetVarValue('PanelShortcuts', 'ImmersiveExplorationAddon', true);
}

@wrapMethod(CPanelShortcut) function PerformAction(targetName: name) {
    var ieWatcher : ImmersiveExplorationWatcher = GetImmExplSpawner();

    if (targetName == 'ToggleIEAutoWalk') { 
        if (ieWatcher) {
            ieWatcher.doubleTapPressed();
        }
        return;
    }
    
    if (targetName == 'ToggleIEFollowRoad') {
        if (ieWatcher) {
            if (!ieWatcher.canFollowRoad) {
                ieWatcher.canFollowRoad = true;
                FactsSet("imm_expl_follow_road", 2, -1);
                theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("imm_expl_road_follow_en"), 3000);
            } else {
                ieWatcher.canFollowRoad = false;
                FactsSet("imm_expl_follow_road", 1, -1);
                theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("imm_expl_road_follow_dis"), 3000);
            }
        }
        return;
    }
    
    wrappedMethod(targetName);
}