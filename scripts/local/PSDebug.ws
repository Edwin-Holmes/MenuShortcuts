@wrapMethod(CPanelShortcut)
function OnToggleHold(action: SInputAction) {
    thePlayer.DisplayHudMessage("ToggleHold event fired");
    return wrappedMethod(action);
}

@wrapMethod(CPanelShortcut)
function OnShortcutLeft(action: SInputAction) {
    thePlayer.DisplayHudMessage("ShortcutLeft event fired");
    return wrappedMethod(action);
}

@wrapMethod(CPanelShortcut)
function StartListening() {
    wrappedMethod();
    thePlayer.DisplayHudMessage("PanelShortcuts started listening");
}

@wrapMethod(CPlayerInput)
function OnCommSteelSword(action: SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();
    var retval: bool;
    retval = wrappedMethod(action);

    if (!ps) {
        thePlayer.DisplayHudMessage("CPanelShortcut not found");
        return retval;
    }

    if (ps && ps.ShortcutAllowed(ESB_Left)) {
        thePlayer.DisplayHudMessage("ESB_Left allowed");
    }
    else {
        thePlayer.DisplayHudMessage("ESB_Left blocked");
    }

    return retval;
}
