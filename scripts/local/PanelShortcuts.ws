enum EShortcutButton {
    ESB_Up,
    ESB_Down,
    ESB_Left,
    ESB_Right,
    ESB_LeftThumb,
    ESB_RightThumb,
    ESB_LeftShoulder,
    ESB_RightShoulder
}

struct SLookupDetails {
    var target: name;
    var isMenu: bool;
}

function GetPanelShortcut(): CPanelShortcut {
    var wp: W3PlayerWitcher = GetWitcherPlayer();
    if (wp) {
        return wp.panelShortcut;
    }
    return(CPanelShortcut)NULL;
}

class CPanelShortcut extends CObject {
    public  var killStatsPopup: bool;
    private var panelShortcutHeld: bool;
    private var shortcutLookup: array<SLookupDetails>;
    private var modMenu: CInGameConfigWrapper;
    private var openedMenu: name; default openedMenu = '';
    private var openedWithBackground: bool;
    private var upEnabled, downEnabled, leftEnabled, rightEnabled, 
                leftThumbEnabled, rightThumbEnabled, leftShoulderEnabled, rightShoulderEnabled: bool;
    private var upCombatDisabled, downCombatDisabled, leftCombatDisabled, rightCombatDisabled, 
                leftThumbCombatDisabled, rightThumbCombatDisabled, leftShoulderCombatDisabled, rightShoulderCombatDisabled: bool;
    private var upTarget, downTarget, leftTarget, rightTarget, 
                leftThumbTarget, rightThumbTarget, leftShoulderTarget, rightShoulderTarget: SLookupDetails; 

    private function Init() {                             // Populate action name array
        AddShortcut('InventoryMenu', true);               // 0
        AddShortcut('MapMenu', true);                     // 1
        AddShortcut('JournalQuestMenu', true);            // 2
        AddShortcut('CharacterMenu', true);               // 3
        AddShortcut('DeckBuilder', true);                 // 4
        AddShortcut('GlossaryBestiaryMenu', true);        // 5
        AddShortcut('GlossaryEncyclopediaMenu', true);    // 6
        AddShortcut('AlchemyMenu', true);                 // 7
        AddShortcut('CraftingMenu', true);                // 8
        AddShortcut('MeditationClockMenu', true);         // 9
        AddShortcut('GlossaryBooksMenu', true);           // 10
        AddShortcut('InventoryMenuFriendly', true);       // 11
        AddShortcut('HorseStashMenu', true);              // 12
        AddShortcut('ToggleHood', false);                 // 13
        AddShortcut('ToggleVanity', false);               // 14
        AddShortcut('ToggleEssentials', false);           // 15
        AddShortcut('Toggle3DMarkers', false);            // 16
        AddShortcut('ToggleRoadFollow', false);           // 17
        AddShortcut('Taunt', false);                      // 18
        AddShortcut('ToggleIEAutoWalk', false);           // 19
        AddShortcut('ToggleActionLog', false);            // 20

        modMenu = theGame.GetInGameConfigWrapper();       // Menu shorthand

        RefreshShortcutSettings();
    }

    public function RefreshShortcutSettings() {
        upEnabled               = modMenu.GetVarValue('PanelShortcuts', 'EnableUp');
        downEnabled             = modMenu.GetVarValue('PanelShortcuts', 'EnableDown');
        leftEnabled             = modMenu.GetVarValue('PanelShortcuts', 'EnableLeft');
        rightEnabled            = modMenu.GetVarValue('PanelShortcuts', 'EnableRight');
        leftThumbEnabled        = modMenu.GetVarValue('PanelShortcuts', 'EnableLeftThumb');
        rightThumbEnabled       = modMenu.GetVarValue('PanelShortcuts', 'EnableRightThumb');
        leftShoulderEnabled     = modMenu.GetVarValue('PanelShortcuts', 'EnableLeftShoulder');
        rightShoulderEnabled    = modMenu.GetVarValue('PanelShortcuts', 'EnableRightShoulder');

        upCombatDisabled            = modMenu.GetVarValue('PanelShortcuts', 'CombatDisableUp');
        downCombatDisabled          = modMenu.GetVarValue('PanelShortcuts', 'CombatDisableDown');
        leftCombatDisabled          = modMenu.GetVarValue('PanelShortcuts', 'CombatDisableLeft');
        rightCombatDisabled         = modMenu.GetVarValue('PanelShortcuts', 'CombatDisableRight');
        leftThumbCombatDisabled     = modMenu.GetVarValue('PanelShortcuts', 'CombatDisableLeftThumb');
        rightThumbCombatDisabled    = modMenu.GetVarValue('PanelShortcuts', 'CombatDisableRightThumb');
        leftShoulderCombatDisabled  = modMenu.GetVarValue('PanelShortcuts', 'CombatDisableLeftShoulder');
        rightShoulderCombatDisabled = modMenu.GetVarValue('PanelShortcuts', 'CombatDisableRightShoulder');

        upTarget            = shortcutLookup[StringToInt(modMenu.GetVarValue('PanelShortcuts', 'ShortcutUp'))];
        downTarget          = shortcutLookup[StringToInt(modMenu.GetVarValue('PanelShortcuts', 'ShortcutDown'))];
        leftTarget          = shortcutLookup[StringToInt(modMenu.GetVarValue('PanelShortcuts', 'ShortcutLeft'))];
        rightTarget         = shortcutLookup[StringToInt(modMenu.GetVarValue('PanelShortcuts', 'ShortcutRight'))];
        leftThumbTarget     = shortcutLookup[StringToInt(modMenu.GetVarValue('PanelShortcuts', 'ShortcutLeftThumb'))];
        rightThumbTarget    = shortcutLookup[StringToInt(modMenu.GetVarValue('PanelShortcuts', 'ShortcutRightThumb'))];
        leftShoulderTarget  = shortcutLookup[StringToInt(modMenu.GetVarValue('PanelShortcuts', 'ShortcutLeftShoulder'))];
        rightShoulderTarget = shortcutLookup[StringToInt(modMenu.GetVarValue('PanelShortcuts', 'ShortcutRightShoulder'))];

        DisableInvalidShortcuts();                                  
    }

    private function AddShortcut(targetName: name, menuFlag: bool) {  // Push struct into shortcutLookup
        var shortcut: SLookupDetails;
        shortcut.target = targetName;
        shortcut.isMenu = menuFlag;
        shortcutLookup.PushBack(shortcut);
    }

    private function DisableInvalidShortcuts() {
        ValidateShortcuts('ToggleHood', 'HoodsAddon', "Shortcut disabled: Hoods addon not installed.");
        ValidateShortcuts('ToggleVanity', 'ToggleCloaksAddon', "Shortcut disabled: Switchable Cloaks addon not installed.");
        ValidateShortcuts('ToggleEssentials', 'FHUDAddon', "Shortcut disabled: Friendly HUD addon not installed.");
        ValidateShortcuts('Toggle3DMarkers', 'FHUDAddon', "Shortcut disabled: Friendly HUD addon not installed.");
        ValidateShortcuts('ToggleRoadFollow', 'IHCAddon', "Shortcut disabled: IHC addon not installed.");
        ValidateShortcuts('Taunt', 'SCAARAddon', "Shortcut disabled: SCAAR addon not installed");
        ValidateShortcuts('ToggleIEAutoWalk', 'ImmersiveExplorationAddon', "Shortcut disabled: IE addon not installed");
        ValidateShortcuts('ToggleActionLog', 'ActionLogAddon', "Shortcut disabled: Action Log addon not installed");
    }

    public function IsPanelShortcutHeld(): bool {                   // No longer used but you never know
        return panelShortcutHeld;
    }

    public function StartListening() {                              // Register listeners
        Init();
        theInput.RegisterListener(this, 'OnToggleHold',             'Panel_Shortcut_Hold');
        theInput.RegisterListener(this, 'OnShortcutUp',             'Panel_Shortcut_Up');
        theInput.RegisterListener(this, 'OnShortcutRight',          'Panel_Shortcut_Right');
        theInput.RegisterListener(this, 'OnShortcutDown',           'Panel_Shortcut_Down');
        theInput.RegisterListener(this, 'OnShortcutLeft',           'Panel_Shortcut_Left');
        theInput.RegisterListener(this, 'OnShortcutLeftThumb',      'Panel_Shortcut_LeftThumb');
        theInput.RegisterListener(this, 'OnShortcutRightThumb',     'Panel_Shortcut_RightThumb');
        theInput.RegisterListener(this, 'OnShortcutLeftShoulder',   'Panel_Shortcut_LeftShoulder');
        theInput.RegisterListener(this, 'OnShortcutRightShoulder',  'Panel_Shortcut_RightShoulder');
    }

    event OnToggleHold(action: SInputAction) {
        if (IsPressed(action))
            panelShortcutHeld = true;
        else if (IsReleased(action))
            panelShortcutHeld = false;
    }

    event OnShortcutUp(action: SInputAction) {
        ProcessShortcut(action, ESB_Up, upTarget, 'Panel_Shortcut_Up');
    }
    event OnShortcutDown(action: SInputAction) {
        ProcessShortcut(action, ESB_Down, downTarget, 'Panel_Shortcut_Down');
    }
    event OnShortcutLeft(action: SInputAction) {
        ProcessShortcut(action, ESB_Left, leftTarget, 'Panel_Shortcut_Left');
    }
    event OnShortcutRight(action: SInputAction) {
        ProcessShortcut(action, ESB_Right, rightTarget, 'Panel_Shortcut_Right');
    }
    event OnShortcutLeftThumb(action: SInputAction) {
        ProcessShortcut(action, ESB_LeftThumb, leftThumbTarget, 'Panel_Shortcut_LeftThumb');
    }
    event OnShortcutRightThumb(action: SInputAction) {
        ProcessShortcut(action, ESB_RightThumb, rightThumbTarget, 'Panel_Shortcut_RightThumb');
    }
    event OnShortcutLeftShoulder(action: SInputAction) {
        ProcessShortcut(action, ESB_LeftShoulder, leftShoulderTarget, 'Panel_Shortcut_LeftShoulder');
    }
    event OnShortcutRightShoulder(action: SInputAction) {
        ProcessShortcut(action, ESB_RightShoulder, rightShoulderTarget, 'Panel_Shortcut_RightShoulder');
    }

    private function ProcessShortcut(action: SInputAction, button: EShortcutButton, shortcut: SLookupDetails, psAction: name) {
    if (ShortcutAllowed(button) && IsPressed(action)) {
        if (shortcut.isMenu) {
            MenuToggle(shortcut.target);
        } else {
            PerformAction(shortcut.target);
        }
        theInput.SuppressPropagatingEventAfterAction(psAction);
        }
    }

    private function MenuToggle(menuId: name) {
        if (openedMenu == menuId) {
            theGame.CloseMenu(menuId);
            if(openedWithBackground) {
                theGame.CloseMenu('CommonMenu');
                }
            openedMenu = '';
            openedWithBackground = false;
        }

        else if (OpenMenu(menuId)) {
            openedMenu = menuId;
        }
    }

    private function OpenMenu(menuId: name): bool {
        var allowed: bool = false;
        var block: EInputActionBlock;
        var initDataObject : W3InventoryInitData;
        
        switch(menuId) {                                            // Check if action is allowed
            case 'InventoryMenu':
            case 'InventoryMenuFriendly':
                allowed = thePlayer.IsActionAllowed(EIAB_OpenInventory);
                block   = EIAB_OpenInventory;
                killStatsPopup = true;
                break;

            case 'HorseStashMenu':
                allowed = thePlayer.IsActionAllowed(EIAB_OpenInventory);
                block   = EIAB_OpenInventory;
                break;

            case 'CharacterMenu':
                allowed = thePlayer.IsActionAllowed(EIAB_OpenCharacterPanel);
                block   = EIAB_OpenCharacterPanel;
                break;

            case 'JournalQuestMenu':
                allowed = thePlayer.IsActionAllowed(EIAB_OpenJournal);
                block   = EIAB_OpenJournal;
                break;

            case 'MapMenu':
                allowed = thePlayer.IsActionAllowed(EIAB_OpenMap);
                block   = EIAB_OpenMap;
                break;

            case 'AlchemyMenu':
                allowed = thePlayer.IsActionAllowed(EIAB_OpenAlchemy);
                block   = EIAB_OpenAlchemy;
                break;

            case 'GlossaryBestiaryMenu':
            case 'GlossaryEncyclopediaMenu':
            case 'GlossaryBooksMenu':
                allowed = thePlayer.IsActionAllowed(EIAB_OpenGlossary);
                block   = EIAB_OpenGlossary;
                break;

            case 'DeckBuilder':
                allowed = thePlayer.IsActionAllowed(EIAB_OpenGwint);
                block   = EIAB_OpenGwint;
                break;

            case 'MeditationClockMenu':
                allowed = thePlayer.IsActionAllowed(EIAB_OpenMeditation);
                block   = EIAB_OpenMeditation;
                break;

            case 'CraftingMenu':
                allowed = true;                                     // Vanilla doesn’t block crafting
                block   = EIAB_Undefined;                           // Fallback; always allowed
                break;

            default:
                allowed = false;
                block   = EIAB_Undefined;

                GetWitcherPlayer().DisplayHudMessage("Menu not found:" + menuId);
                break; 
        }

        if(!allowed) {
            thePlayer.DisplayActionDisallowedHudMessage(block);
            return false;
        }

        if(menuId == 'DeckBuilder') {
            openedWithBackground = false;
            theGame.RequestMenu(menuId);

        } 
        else if(menuId == 'HorseStashMenu') {
            openedWithBackground = true;
            initDataObject = new W3InventoryInitData in theGame.GetGuiManager();
            initDataObject.setDefaultState('StashInventory');
            theGame.RequestMenuWithBackground('InventoryMenu', 'CommonMenu', initDataObject);

        } 
        else if(menuId == 'InventoryMenuFriendly') {
            openedWithBackground = true;
            initDataObject = new W3InventoryInitData in theGame.GetGuiManager();
            initDataObject.setDefaultState('CharacterInventory');
            theGame.RequestMenuWithBackground('InventoryMenu', 'CommonMenu', initDataObject);

        } 
        else {
            openedWithBackground = true;
            theGame.RequestMenuWithBackground(menuId, 'CommonMenu');
        }

        return true;
    }

    private function PerformAction(targetName: name) {              // Mod addons wrap this function.
        GetWitcherPlayer().DisplayHudMessage("Action not found:" + targetName);
    }

    public function ShortcutAllowed(button : EShortcutButton) : bool {
        var enabled : bool;
        var combatDisabled : bool;

        if (!panelShortcutHeld)                                     // Exit early if not holding trigger
            return false;

        switch (button) {                                           // Shortcut enabled / enabled during combat?
            case ESB_Up:
                enabled = upEnabled;
                combatDisabled = upCombatDisabled;
                break;

            case ESB_Down:
                enabled = downEnabled;
                combatDisabled = downCombatDisabled;
                break;

            case ESB_Left:
                enabled = leftEnabled;
                combatDisabled = leftCombatDisabled;
                break;

            case ESB_Right:
                enabled = rightEnabled;
                combatDisabled = rightCombatDisabled;
                break;

            case ESB_LeftThumb:
                enabled = leftThumbEnabled;
                combatDisabled = leftThumbCombatDisabled;
                break;

            case ESB_RightThumb:
                enabled = rightThumbEnabled;
                combatDisabled = rightThumbCombatDisabled;
                break;

            case ESB_LeftShoulder:
                enabled = leftShoulderEnabled;
                combatDisabled = leftShoulderCombatDisabled;
                break;

            case ESB_RightShoulder:
                enabled = rightShoulderEnabled;
                combatDisabled = rightShoulderCombatDisabled;
                break;
            
            default:
                GetWitcherPlayer().DisplayHudMessage("Button not found:" + button);
                return false;
        }

        if (!enabled)                                               // Shortcut disabled in menu  
            return false;

        if (combatDisabled && GetWitcherPlayer().IsInCombat())      // Shortcut disabled during combat
            return false;

        return true;                                                // Shortcut allowed
    }

    private function ValidateShortcuts(target: name, addon: name, msg: string) {
        var wp: W3PlayerWitcher = GetWitcherPlayer();

        if (!modMenu.GetVarValue('PanelShortcuts', addon)) {        // Check shortcut targets against menu's addon flags
            if (upTarget.target == target) {
                upEnabled = false;
                wp.DisplayHudMessage(msg); 
            }
            if (downTarget.target == target) { 
                downEnabled = false;
                wp.DisplayHudMessage(msg); 
            }
            if (leftTarget.target == target) {
                leftEnabled = false;
                wp.DisplayHudMessage(msg); 
            }
            if (rightTarget.target == target) { 
                rightEnabled = false;
                wp.DisplayHudMessage(msg); 
            }
            if (leftThumbTarget.target == target) { 
                leftThumbEnabled = false;     
                wp.DisplayHudMessage(msg); 
            }
            if (rightThumbTarget.target == target) { 
                rightThumbEnabled = false;    
                wp.DisplayHudMessage(msg); 
            }
            if (leftShoulderTarget.target == target) { 
                leftShoulderEnabled = false;  
                wp.DisplayHudMessage(msg); 
            }
            if (rightShoulderTarget.target == target) { 
                rightShoulderEnabled = false; 
                wp.DisplayHudMessage(msg); 
            }
        }
    }

    public function StopListening() {                               // Unregister listeners     
        theInput.UnregisterListener(this, 'Panel_Shortcut_Hold');
        theInput.UnregisterListener(this, 'Panel_Shortcut_Up');
        theInput.UnregisterListener(this, 'Panel_Shortcut_Right');
        theInput.UnregisterListener(this, 'Panel_Shortcut_Down');
        theInput.UnregisterListener(this, 'Panel_Shortcut_Left');
        theInput.UnregisterListener(this, 'Panel_Shortcut_LeftThumb');
        theInput.UnregisterListener(this, 'Panel_Shortcut_RightThumb');
        theInput.UnregisterListener(this, 'Panel_Shortcut_LeftShoulder');
        theInput.UnregisterListener(this, 'Panel_Shortcut_RightShoulder');
        theInput.UnregisterListener(this, 'Panel_Shortcut_Start');
        theInput.UnregisterListener(this, 'Panel_Shortcut_Select');
    }
}


@addField(W3PlayerWitcher) 
public var panelShortcut : CPanelShortcut;                                          // Store instance here

@wrapMethod(W3PlayerWitcher) function OnSpawned(spawnData : SEntitySpawnData) {     // Create instance and initialise 
    panelShortcut = new CPanelShortcut in this;
    panelShortcut.StartListening();

    return wrappedMethod(spawnData);
}

@wrapMethod(W3PlayerWitcher) function OnDeath(damageAction : W3DamageAction) {      // Clean up instance
    if(panelShortcut) {
        panelShortcut.StopListening();
        delete panelShortcut;
        panelShortcut = NULL;
    }
    return wrappedMethod(damageAction);
}

// Block character stats popup when inventory opened via shortcut (still not blocking R2 release)
@wrapMethod(CR4InventoryMenu) function OnShowFullStats() {
    var ps: CPanelShortcut = GetPanelShortcut();
    
    if (ps.killStatsPopup) {
        return false;
    }
    return wrappedMethod();
}

@wrapMethod(CR4InventoryMenu) function OnCloseMenu() {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps) {
        ps.killStatsPopup = false;
    }
    return wrappedMethod();
}

// Block shortcut inputs when toggle held and enabled in menu
@wrapMethod(CPlayerInput) function OnApplyOil(action : SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && (ps.ShortcutAllowed(ESB_Left) || ps.ShortcutAllowed(ESB_Right))) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCommDrinkPotion1(action : SInputAction) {
   var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_Up)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCommDrinkPotion2(action : SInputAction) {
   var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_Down)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCommDrinkPotion3(action : SInputAction) {
   var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_Up)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCommDrinkPotion4(action : SInputAction) {
   var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_Down)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCommDrinkpotionUpperHeld(action : SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_Up)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCommDrinkpotionLowerHeld(action : SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_Down)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCommSteelSword(action : SInputAction) {
   var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_Left)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCommSilverSword(action : SInputAction) {
   var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_Right)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCommSheatheAny(action : SInputAction) {
   var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && (ps.ShortcutAllowed(ESB_Left) || ps.ShortcutAllowed(ESB_Right))) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCbtComboDigitLeft(action : SInputAction) {
   var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_Left)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCbtComboDigitRight(action : SInputAction) {
   var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_Right)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCbtCameraLock(action: SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_RightThumb)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCommSpawnHorse(action: SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_LeftThumb)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CR4HudModuleQuests) function OnHighlightNextObjective(action: SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_RightThumb)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(PhotomodeManager) function OnPhotomodeEnableStep(action: SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && (ps.ShortcutAllowed(ESB_LeftThumb) || ps.ShortcutAllowed(ESB_RightThumb))) {
        return false;
    }

    return wrappedMethod(action);
}

@wrapMethod(CR4HudModuleRadialMenu) function OnRadialMenu(action: SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_LeftShoulder)) {
        return false;
    }
    return wrappedMethod(action);
}

/*
@wrapMethod(W3VehicleCombatManager) function OnItemAction (action: SinputAction) {  // Can't wrap state Null; doesn't seem likely during horse combat anyway
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_RightShoulder)) {
        return false;
    }
    return wrappedMethod(action);
}
*/

@wrapMethod(CPlayerInput) function OnCbtThrowItem(action : SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_RightShoulder)) {
        return false;
    }
    return wrappedMethod(action);
}

@wrapMethod(CPlayerInput) function OnCbtThrowItemHold(action : SInputAction) {
    var ps: CPanelShortcut = GetPanelShortcut();

    if (ps && ps.ShortcutAllowed(ESB_RightShoulder)) {
        return false;
    }
    return wrappedMethod(action);
}

// Set defaults if not user set
@wrapMethod(CR4Game) function PopulateMenuQueueMainAlways( out menus : array< name > ) {
    wrappedMethod(menus);
    MPS_SetDefaults();
}

function MPS_SetDefaults() 
{
    var modMenu: CInGameConfigWrapper = theGame.GetInGameConfigWrapper();
    var currentVersion: float = 1.8;
    var userVersion: float = StringToFloat(modMenu.GetVarValue('PanelShortcuts', 'PanelShortcutsVersion'), 0.0);

    if (userVersion == currentVersion) {                                            // Up to date = early exit
        return;
    }

    if (userVersion < 1.3) {                                                        // added in 1.3
        modMenu.SetVarValue('PanelShortcuts', 'EnableUp', true);
        modMenu.SetVarValue('PanelShortcuts', 'EnableDown', true);
        modMenu.SetVarValue('PanelShortcuts', 'EnableLeft', true);
        modMenu.SetVarValue('PanelShortcuts', 'EnableRight', true);
        modMenu.SetVarValue('PanelShortcuts', 'CombatDisableUp', false);
        modMenu.SetVarValue('PanelShortcuts', 'CombatDisableDown', false);
        modMenu.SetVarValue('PanelShortcuts', 'CombatDisableLeft', false);
        modMenu.SetVarValue('PanelShortcuts', 'CombatDisableRight', false);
    }
    if (userVersion < 1.6) {                                                        // added in 1.6
        modMenu.SetVarValue('PanelShortcuts', 'EnableLeftThumb', true);
        modMenu.SetVarValue('PanelShortcuts', 'EnableRightThumb', true);
        modMenu.SetVarValue('PanelShortcuts', 'EnableLeftShoulder', true);
        modMenu.SetVarValue('PanelShortcuts', 'EnableRightShoulder', true);
        modMenu.SetVarValue('PanelShortcuts', 'CombatDisableLeftThumb', false);
        modMenu.SetVarValue('PanelShortcuts', 'CombatDisableRightThumb', false);
        modMenu.SetVarValue('PanelShortcuts', 'CombatDisableLeftShoulder', false);
        modMenu.SetVarValue('PanelShortcuts', 'CombatDisableRightShoulder', false);
        modMenu.SetVarValue('PanelShortcuts', 'ShortcutLeftThumb', '2');
        modMenu.SetVarValue('PanelShortcuts', 'ShortcutRightThumb', '2');
        modMenu.SetVarValue('PanelShortcuts', 'ShortcutLeftShoulder', '2');
        modMenu.SetVarValue('PanelShortcuts', 'ShortcutRightShoulder', '2');
    }
    if (userVersion < currentVersion) {
        modMenu.SetVarValue('PanelShortcuts', 'PanelShortcutsVersion', currentVersion);
    }    
}

@wrapMethod(CR4IngameMenu) function OnClosingMenu() {                           // Update menu settings on menu close
    var ps: CPanelShortcut = GetPanelShortcut();
    var retVal: bool;
    retVal = wrappedMethod();

    if (ps) {ps.RefreshShortcutSettings();}

    return retVal;
}