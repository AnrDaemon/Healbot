--[[ HealBot Continued ]]

local HealBot_UnitIcons={};
local HealBot_Watch_HoT={};
local HealBot_SmartCast_Spells={};
local HealBot_DebugMsg={};
local HealBot_SpamCut={}
local HealBot_Vers={}
local strfind=strfind
local strsub=strsub
local gsub=gsub
local HealBot_UpUnitInCombat={}
local HealBot_VehicleCheck={};   
local HealBot_ReCheckBuffsTime=nil
local HealBot_ReCheckBuffsTimed={}
local HealBot_cleanGUIDs={}
local HealBot_Ignore_Debuffs = {["Class"]={},["Movement"]={},["NonHarmful"]={},};
local HealBot_Timers={["HB1Inc"]=0,["HB1Th"]=0.04,["HB2Inc"]=0,["HB2Th"]=0.2,["HBaInc"]=0,["HBaTh"]=0.02,["CheckTimeMod"]=0.08}
local arrg = {}
local PlayerBuffs = {}
local PlayerBuffTypes = {}
local LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
for i = 1, #HealBot_Default_Textures do
    LSM:Register("statusbar", HealBot_Default_Textures[i].name, HealBot_Default_Textures[i].file)
end
for i = 1, #HealBot_Default_Sounds do
    LSM:Register("sound", HealBot_Default_Sounds[i].name, HealBot_Default_Sounds[i].file)
end
for i = 1, #HealBot_Default_Fonts do
    LSM:Register("font", HealBot_Default_Fonts[i].name, HealBot_Default_Fonts[i].file)
end
local LDB11 = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)
local HealBot_PlayerBuff={}
local HealBot_CheckBuffs = {}
local HealBot_ShortBuffs = {}
local HealBot_BuffWatch={}
local CooldownBuffs={}
local debuffCodes={ [HEALBOT_DISEASE_en]=5, [HEALBOT_MAGIC_en]=6, [HEALBOT_POISON_en]=7, [HEALBOT_CURSE_en]=8, [HEALBOT_CUSTOM_en]=9}
local HealBot_VehicleUnit={}
local HealBot_UnitInVehicle={}
local HealBot_TargetIcons={}
local HealBot_notVisible={}
local HealBot_CustomDebuff_RevDurLast={}
local hbManaPlayers={}
local hbShareSkins={}
local HealBot_trackHiddenFrames={}
local _
local HealBot_Buff_ItemID={};
local HealBot_Buff_Aura2Item={};
local HealBot_NameTextUpdate={}

local HealBot_luVars={}
HealBot_luVars["shareSkinsSent"]=0
HealBot_luVars["hbInsName"]=HEALBOT_WORD_OUTSIDE
HealBot_luVars["TargetUnitID"]="player"
HealBot_luVars["qaFR"]=40
HealBot_luVars["qaFR1"]=30
HealBot_luVars["qaFR2"]=30
HealBot_luVars["qaFR3"]=30
HealBot_luVars["qaFR4"]=30
HealBot_luVars["maxFR"]=30
HealBot_luVars["IsSolo"]=true
HealBot_luVars["FocusHealsOn"]=true
HealBot_luVars["PetHealsOn"]=true
HealBot_luVars["TargetHealsOn"]=true
HealBot_luVars["EnemyBarsOn"]=true
HealBot_luVars["EnemyBarsCastOn"]=0
HealBot_luVars["UseCrashProtection"]=false
HealBot_luVars["MaskAuraDCheck"]=GetTime()
HealBot_luVars["ReloadUI"]=0
HealBot_luVars["MessageReloadUI"]=0
HealBot_luVars["slowSwitch"]=0
HealBot_luVars["fastSwitch"]=0
HealBot_luVars["HealthCheckTime"]=GetTime()+5
HealBot_luVars["RangeCheckTime"]=GetTime()+1
HealBot_luVars["hbLoaded"]=false
HealBot_luVars["VersionRequest"]=false
HealBot_luVars["ResetFlag"]=false
HealBot_luVars["dSpell"]=false
HealBot_luVars["dSpell"]=false
HealBot_luVars["CheckPlayerBuffsGUID"]=false
HealBot_luVars["CheckPlayerBuffsTime"]=false
HealBot_luVars["AddonMsgType"]=3
HealBot_luVars["InCombatUpdate"]=false
HealBot_luVars["InCombatUpdTime"]=GetTime()+2
HealBot_luVars["CheckTalents"]=true
HealBot_luVars["CastingTarget"]="player"
HealBot_luVars["27YardsOnly"]=false
HealBot_luVars["nextRecalcParty"]=GetTime()+10
HealBot_luVars["DoUpdates"]=false
HealBot_luVars["ResetAllUnitStatus"]=false

function HealBot_nextRecalcParty(addTime)
    if GetTime()+addTime<HealBot_luVars["nextRecalcParty"] then
        HealBot_luVars["nextRecalcParty"]=GetTime()+addTime
    end
end

local function HealBot_InitVars()
    CooldownBuffs={[HEALBOT_FEAR_WARD]=true, 
                   [HEALBOT_PAIN_SUPPRESSION]=true, 
                   [HEALBOT_POWER_INFUSION]=true,}
    HealBot_luVars["dSpell"]=HEALBOT_HEAVY_RUNECLOTH_BANDAGE;
    HealBot_Ignore_Debuffs["NonHarmful"] = {[HEALBOT_DEBUFF_MAJOR_DREAMLESS] = true,
                                            [HEALBOT_DEBUFF_GREATER_DREAMLESS] = true,
                                            [HEALBOT_DEBUFF_DREAMLESS_SLEEP] = true,
                                            [HEALBOT_DEBUFF_SHATTERED_DEFENSES] = true,
                                            [HEALBOT_DEBUFF_OVERWHELMING_POWER] = true,};
    HealBot_Ignore_Debuffs["Movement"] = {[HEALBOT_DEBUFF_FROSTBOLT] = true,
                                          [HEALBOT_DEBUFF_MAGMA_SHACKLES] = true,
                                          [HEALBOT_DEBUFF_SLOW] = true,
                                          [HEALBOT_DEBUFF_CHILLED] = true,
                                          [HEALBOT_DEBUFF_CONEOFCOLD] = true,
                                          [HEALBOT_DEBUFF_FROST_SHOCK] = true,
                                          [HEALBOT_DEBUFF_EARTHBIND] = true,
                                          [HEALBOT_DEBUFF_SEAL_OF_JUSTICE] = true,};
    HealBot_Ignore_Debuffs["Class"] = {
        ["WARR"] = { [HEALBOT_DEBUFF_IGNITE_MANA] = true, 
                     [HEALBOT_DEBUFF_TAINTED_MIND] = true, 
                     [HEALBOT_DEBUFF_VIPER_STING] = true,
                     [HEALBOT_DEBUFF_CURSE_OF_IMPOTENCE] = true,
                     [HEALBOT_DEBUFF_DECAYED_INTELLECT] = true,
                     [HEALBOT_DEBUFF_TRAMPLE] = true,
                     [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},
        ["ROGU"] = { [HEALBOT_DEBUFF_SILENCE] = true,    
                     [HEALBOT_DEBUFF_IGNITE_MANA] = true, 
                     [HEALBOT_DEBUFF_TAINTED_MIND] = true, 
                     [HEALBOT_DEBUFF_VIPER_STING] = true,
                     [HEALBOT_DEBUFF_CURSE_OF_IMPOTENCE] = true,
                     [HEALBOT_DEBUFF_DECAYED_INTELLECT] = true,
                     [HEALBOT_DEBUFF_TRAMPLE] = true,
                     [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},
        ["HUNT"] = { [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},	
        ["MAGE"] = { [HEALBOT_DEBUFF_DECAYED_STRENGHT] = true,
                     [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},
        ["DRUI"] = { [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},
        ["PALA"] = { [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},
        ["PRIE"] = { [HEALBOT_DEBUFF_DECAYED_STRENGHT] = true,
                     [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},
        ["SHAM"] = { [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},
        ["WARL"] = { [HEALBOT_DEBUFF_DECAYED_STRENGHT] = true,
                     [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},
        ["DEAT"] = { [HEALBOT_DEBUFF_DECAYED_INTELLECT] = true,
                     [HEALBOT_DEBUFF_TRAMPLE] = true,
                     [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},
        ["MONK"] = { [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},	
        ["DEMO"] = { [HEALBOT_DEBUFF_UNSTABLE_AFFLICTION] = true,
					 [HEALBOT_DEBUFF_VAMPIRIC_TOUCH] = true,},
    };
    HealBot_Buff_ItemID = {
        [HEALBOT_ORALIUS_WHISPERING_CRYSTAL] = 118922,
        [HEALBOT_EVER_BLOOMING_FROND] = 118935,
        [HEALBOT_REPURPOSED_FEL_FOCUSER] = 147707,
    };
    HealBot_Buff_Aura2Item = {
        [HEALBOT_WHISPERS_OF_INSANITY] = HEALBOT_ORALIUS_WHISPERING_CRYSTAL,
        [HEALBOT_BLOOM] = HEALBOT_EVER_BLOOMING_FROND,
        [HEALBOT_FEL_FOCUS] = HEALBOT_REPURPOSED_FEL_FOCUSER,
    };
end

function HealBot_retLSM()
    return LSM
end

function HealBot_MessageReloadUI(limit)
    if not HealBot_Data["UILOCK"] then
        HealBot_luVars["MessageReloadUI"]=0
        HealBot_luVars["ReloadUI"]=GetTime()+limit
    else
        HealBot_luVars["MessageReloadUI"]=limit
    end
end

function HealBot_setLuVars(vName, vValue)
    HealBot_luVars[vName]=vValue
end

function HealBot_retLuVars(vName)
    return HealBot_luVars[vName]
end

function HealBot_setNotVisible(hbGUID,unit)
    HealBot_notVisible[hbGUID]=unit
end

function HealBot_Clear_BuffWatch()
    for x,_ in pairs(HealBot_BuffWatch) do
        HealBot_BuffWatch[x]=nil;
    end
end

function HealBot_Set_BuffWatch(buffName)
    table.insert(HealBot_BuffWatch,buffName);
end

function HealBot_Clear_CheckBuffs()
    for x,_ in pairs(HealBot_CheckBuffs) do
        HealBot_CheckBuffs[x]=nil;
    end
end

function HealBot_Set_CheckBuffs(buffName)
    if not CooldownBuffs[buffName] and not HealBot_CheckBuffs[buffName] then
        HealBot_CheckBuffs[buffName]=true;
    end
end

function HealBot_RetMyBuffTime(hbGUID,buffName)
    if not HealBot_PlayerBuff[hbGUID] or not HealBot_PlayerBuff[hbGUID][buffName] then return end
    if HealBot_ShortBuffs[buffName] then
        return HealBot_PlayerBuff[hbGUID][buffName]+HealBot_Config_Buffs.ShortBuffTimer
    else
        return HealBot_PlayerBuff[hbGUID][buffName]+HealBot_Config_Buffs.LongBuffTimer
    end
end

function HealBot_cpQueue(id, mName, mBody)
    HealBot_luVars["cpMacro"]=GetTime()+8
    if id==0 then
        HealBot_luVars["cpSave0"]=true
        HealBot_luVars["cpName0"]=mName
        HealBot_luVars["cpBody0"]=mBody
    elseif id==1 then
        HealBot_luVars["cpSave1"]=true
        HealBot_luVars["cpName1"]=mName
        HealBot_luVars["cpBody1"]=mBody
    elseif id==2 then
        HealBot_luVars["cpSave2"]=true
        HealBot_luVars["cpName2"]=mName
        HealBot_luVars["cpBody2"]=mBody
    elseif id==3 then
        HealBot_luVars["cpSave3"]=true
        HealBot_luVars["cpName3"]=mName
        HealBot_luVars["cpBody3"]=mBody
    elseif id==4 then
        HealBot_luVars["cpSave4"]=true
        HealBot_luVars["cpName4"]=mName
        HealBot_luVars["cpBody4"]=mBody
    else
        HealBot_luVars["cpSave5"]=true
        HealBot_luVars["cpName5"]=mName
        HealBot_luVars["cpBody5"]=mBody
    end
end

local function HealBot_cpSave(mName, mBody)
    local perCharacter = 1
    if Healbot_Config_Skins.Protection[Healbot_Config_Skins.Current_Skin]["GENERALMACRO"] then
        perCharacter = nil
    end
    local z=GetMacroIndexByName(mName)
    if (z or 0) == 0 then
        z = CreateMacro(mName, "Spell_Holy_SealOfSacrifice", mBody, perCharacter)
    else
        z = EditMacro(z, mName, "Spell_Holy_SealOfSacrifice", mBody)
    end
end

local function HealBot_cpSaveAll()
    if HealBot_luVars["cpSave0"] then
        HealBot_luVars["cpSave0"]=nil
        HealBot_cpSave(HealBot_luVars["cpName0"], HealBot_luVars["cpBody0"])
    end
    if HealBot_luVars["cpSave1"] then
        HealBot_luVars["cpSave1"]=nil
        HealBot_cpSave(HealBot_luVars["cpName1"], HealBot_luVars["cpBody1"])
    end
    if HealBot_luVars["cpSave2"] then
        HealBot_luVars["cpSave2"]=nil
        HealBot_cpSave(HealBot_luVars["cpName2"], HealBot_luVars["cpBody2"])
    end
    if HealBot_luVars["cpSave3"] then
        HealBot_luVars["cpSave3"]=nil
        HealBot_cpSave(HealBot_luVars["cpName3"], HealBot_luVars["cpBody3"])
    end
    if HealBot_luVars["cpSave4"] then
        HealBot_luVars["cpSave4"]=nil
        HealBot_cpSave(HealBot_luVars["cpName4"], HealBot_luVars["cpBody4"])
    end
    HealBot_luVars["cpMacro"]=nil
    HBmsg=HEALBOT_CP_MACRO_SAVE.."   "..date("%H:%M:%S", time())
    HealBot_Options_cpMacroSave:SetText(HBmsg)
    HealBot_Options_SetcpMacroSave(HBmsg)
end

function HealBot_SetResetFlag(mode)
    if mode=="HARD" then
        ReloadUI()
    else
        HealBot_luVars["ResetFlag"]=1
    end
end

function HealBot_TooltipInit()
    if ( HealBot_ScanTooltip:IsOwned(HealBot) ) then return; end;
    HealBot_ScanTooltip:SetOwner(HealBot, 'ANCHOR_NONE' );
    HealBot_ScanTooltip:ClearLines();
end

function HealBot_AddChat(HBmsg)
    DEFAULT_CHAT_FRAME:AddMessage(HBmsg, 0.7, 0.7, 1.0);
end

function HealBot_AddDebug(HBmsg)
    
    if HBmsg and (HealBot_SpamCut[HBmsg] or 0)<GetTime() then
        HealBot_SpamCut[HBmsg]=GetTime()+1        
        HBmsg="["..date("%H:%M", time()).."] DEBUG: "..HBmsg;
        table.insert(HealBot_DebugMsg,HBmsg)
    end
end

function HealBot_TogglePanel(HBpanel)
    if not HBpanel then return end
    if ( HBpanel:IsVisible() ) then
        HideUIPanel(HBpanel);
    else
        ShowUIPanel(HBpanel);
    end
end

function HealBot_StartMoving(HBframe)
    if ( not HBframe.isMoving ) and ( HBframe.isLocked ~= 1 ) then
        HBframe:StartMoving();
        HBframe.isMoving = true;
    end
end

function HealBot_StopMoving(HBframe,hbCurFrame)
    if ( HBframe.isMoving ) then
        HBframe:StopMovingOrSizing();
        HBframe.isMoving = false;
    end
    if hbCurFrame then
        HealBot_CheckActionFrame(HBframe,hbCurFrame)
    end
end

function HealBot_CheckActionFrame(HBframe,hbCurFrame)
    if HealBot_Config.DisabledNow==1 then return end
    if HBframe:IsVisible() and HBframe:GetTop() then
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==1 then
            local fTop=HealBot_Comm_round(((HBframe:GetTop()/GetScreenHeight())*100),2)
            local fLeft=HealBot_Comm_round(((HBframe:GetLeft()/GetScreenWidth())*100),2)
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"] = fTop
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"] = fLeft
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==2 then
            local fBottom=HealBot_Comm_round(((HBframe:GetBottom()/GetScreenHeight())*100),2)
            local fLeft=HealBot_Comm_round(((HBframe:GetLeft()/GetScreenWidth())*100),2)
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"] = fBottom
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"] = fLeft
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==3 then
            local fTop=HealBot_Comm_round(((HBframe:GetTop()/GetScreenHeight())*100),2)
            local fRight=HealBot_Comm_round(((HBframe:GetRight()/GetScreenWidth())*100),2)
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"] = fTop
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"] = fRight
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==4 then
            local fBottom=HealBot_Comm_round(((HBframe:GetBottom()/GetScreenHeight())*100),2)
            local fRight=HealBot_Comm_round(((HBframe:GetRight()/GetScreenWidth())*100),2)
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"] = fBottom
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"] = fRight
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==5 then
            local fTop=HealBot_Comm_round(((HBframe:GetTop()/GetScreenHeight())*100),2)
            local fHcenter=HealBot_Comm_round(((HBframe:GetCenter()/GetScreenWidth())*100),2)
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"] = fTop
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"] = fHcenter
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==6 then
            local fVcenter=HealBot_Comm_round(((((HBframe:GetTop()+HBframe:GetBottom())/2)/GetScreenHeight())*100),2)
            local fLeft=HealBot_Comm_round(((HBframe:GetLeft()/GetScreenWidth())*100),2)
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"] = fVcenter
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"] = fLeft
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==7 then
            local fVcenter=HealBot_Comm_round(((((HBframe:GetTop()+HBframe:GetBottom())/2)/GetScreenHeight())*100),2)
            local fRight=HealBot_Comm_round(((HBframe:GetRight()/GetScreenWidth())*100),2)
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"] = fVcenter
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"] = fRight
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==8 then
            local fBottom=HealBot_Comm_round(((HBframe:GetBottom()/GetScreenHeight())*100),2)
            local fHcenter=HealBot_Comm_round(((HBframe:GetCenter()/GetScreenWidth())*100),2)
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"] = fBottom
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"] = fHcenter
        end
        HealBot_CheckFrame(hbCurFrame, HBframe) 
        HealBot_Action_setPoint(hbCurFrame)
    end
end

function HealBot_CheckFrame(hbCurFrame, HBframe)
    if HealBot_Config.DisabledNow==1 then return end
    local wPct=HealBot_Comm_round(((Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Current_Skin][hbCurFrame]["WIDTH"]/GetScreenWidth())*100),2)
    local hPct=HealBot_Comm_round(((Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Current_Skin][hbCurFrame]["HEIGHT"]/GetScreenHeight())*100),2)
    if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==1 then
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]<0.01 then 
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=0.01
        elseif (Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]+wPct)>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=100-wPct
        end
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]<hPct then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=hPct
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=100
        end
    elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==2 then
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]<0.01 then 
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=0.01
        elseif (Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]+wPct)>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=100-wPct
        end
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]<0.01 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=0.01
        elseif (Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]+hPct)>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=100-hPct
        end
    elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==3 then
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]<wPct then 
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=wPct
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=100
        end
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]<hPct then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=hPct
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=100
        end
    elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==4 then
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]<wPct then 
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=wPct
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=100
        end
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]<0.01 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=0.01
        elseif (Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]+hPct)>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=100-hPct
        end
    elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==5 then
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]<0.01 then 
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=0.01
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=100
        end
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]<hPct then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=hPct
        elseif (Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"])>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=100
        end
    elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==6 then
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]<0.01 then 
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=0.01
        elseif (Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]+wPct)>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=100-wPct
        end
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]<0.01 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=0.01 
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=100
        end
    elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==7 then
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]<wPct then 
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=wPct
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=100
        end
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]<0.01 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=0.01 
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=100
        end
    elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["FRAME"]==8 then
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]<0.01 then 
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=0.01
        elseif Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["X"]=100
        end
        if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]<0.01 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=0.01
        elseif (Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]+hPct)>100 then
            Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Current_Skin][hbCurFrame]["Y"]=100-hPct
        end
    end
end

function HealBot_TalentQuery(unit)
    if unit and UnitIsVisible(unit) and UnitIsConnected(unit) and CanInspect(unit) then 
        NotifyInspect(unit); 
    end
end

local function HealBot_SlashCmd(cmd)
    if not cmd then cmd="" end
    local HBcmd, x, y, z = string.split(" ", cmd)
    HBcmd=string.lower(HBcmd) 
    if (HBcmd=="" or HBcmd=="o" or HBcmd=="options" or HBcmd=="opt" or HBcmd=="config" or HBcmd=="cfg") then
        HealBot_TogglePanel(HealBot_Options);
    elseif (HBcmd=="d" or HBcmd=="defaults") then
        HealBot_Options_Defaults_OnClick(HealBot_Options_Defaults);
    elseif (HBcmd=="ui") then
        HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_HARDRELOAD)
        HealBot_SetResetFlag("HARD")
    elseif (HBcmd=="ri" or (HBcmd=="reset" and x and string.lower(x)=="healbot")) then
        HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_SOFTRELOAD)
        HealBot_SetResetFlag("SOFT")
    elseif (HBcmd=="rc" or (HBcmd=="reset" and x and string.lower(x)=="customdebuffs")) then
        HealBot_luVars["ResetFlag"]=2
    elseif (HBcmd=="rs" or (HBcmd=="reset" and x and string.lower(x)=="skin")) then
        HealBot_luVars["ResetFlag"]=3
    elseif (HBcmd=="show") then
        HealBot_Action_Reset()
    elseif (HBcmd=="cb") then
        HealBot_Panel_ClearBlackList()
    elseif (HBcmd=="cspells") then
        HealBot_Copy_SpellCombos()
    elseif (HBcmd=="rspells") then
        HealBot_Reset_Spells()
    elseif (HBcmd=="rcures") then
        HealBot_Reset_Cures()
    elseif (HBcmd=="rbuffs") then
        HealBot_Reset_Buffs()
    elseif (HBcmd=="disable") then
        HealBot_Options_DisableHealBotOpt:SetChecked(1)
        HealBot_Options_DisableHealBot(1)
    elseif (HBcmd=="enable") then
        HealBot_Options_DisableHealBotOpt:SetChecked(0)
        HealBot_Options_DisableHealBot(0)
    elseif (HBcmd=="t") then
        if HealBot_Config.DisabledNow==0 then
            HealBot_Options_DisableHealBotOpt:SetChecked(1)
            HealBot_Options_DisableHealBot(1)
        else
            HealBot_Options_DisableHealBotOpt:SetChecked(0)
            HealBot_Options_DisableHealBot(0)
        end
    elseif (HBcmd=="comms") then
        HealBot_Comms_Zone()
    elseif (HBcmd=="help" or HBcmd=="h") then
        HealBot_luVars["HelpCnt1"]=0
    elseif (HBcmd=="hs") then
        HealBot_luVars["HelpCnt2"]=0
    elseif (HBcmd=="skin" and x) then
        if y then x=x.." "..y end
        if z then x=x.." "..z end
        HealBot_Options_Set_Current_Skin(x)
    elseif (HBcmd=="as") then
        HealBot_ToggleAcceptSkins()
    elseif (HBcmd=="use10") then
        if HealBot_Config.MacroUse10==1 then
            HealBot_Config.MacroUse10=0
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_USE10OFF)
        else
            HealBot_Config.MacroUse10=1
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_USE10ON)
        end
    elseif (HBcmd=="suppress" and x) then
        x=string.lower(x)
        HealBot_ToggleSuppressSetting(x)
    elseif (HBcmd=="test") then
        HealBot_TestBars(x)
    elseif (HBcmd=="tr" and x) then
        HealBot_Panel_SethbTopRole(x)
    elseif (HBcmd=="ssp") then
        HealBot_Panel_SetSubSortPlayer()
    elseif (HBcmd=="spt") then
        if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["SELFPET"]==1 then
            Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["SELFPET"]=0
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_SELFPETSOFF)
        else
            Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["SELFPET"]=1
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_SELFPETSON)
        end
        HealBot_Data["REFRESH"]=true;
    elseif (HBcmd=="manabloom" and x) then
        if tonumber(x) and tonumber(x)>0 and tonumber(x)<=100 then
            HealBot_Globals.minManaBloom=ceil(x)
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_EVER_BLOOMING_FROND.." highlighted when mana below "..ceil(x).."%")
        else
            HealBot_AddChat(HEALBOT_CHAT_ADDONID.."Invalid Number")
        end
    elseif (HBcmd=="healthbloom" and x) then
        if tonumber(x) and tonumber(x)>0 and tonumber(x)<=100 then
            HealBot_Globals.minHealthBloom=ceil(x)
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_EVER_BLOOMING_FROND.." highlighted when health below "..ceil(x).."%")
        else
            HealBot_AddChat(HEALBOT_CHAT_ADDONID.."Invalid Number")
        end
    elseif (HBcmd=="cp") then
        if Healbot_Config_Skins.Protection[Healbot_Config_Skins.Current_Skin]["CRASH"] then
            Healbot_Config_Skins.Protection[Healbot_Config_Skins.Current_Skin]["CRASH"]=false
        else
            Healbot_Config_Skins.Protection[Healbot_Config_Skins.Current_Skin]["CRASH"]=true
        end
    elseif (HBcmd=="bt") then
        if HealBot_Config_Buffs.BuffWatch then
            HealBot_Config_Buffs.BuffWatch=false
        else
            HealBot_Config_Buffs.BuffWatch=true
        end
        HealBot_Options_MonitorBuffs:SetChecked(HealBot_Config_Buffs.BuffWatch)
        HealBot_Options_MonitorBuffs_Toggle()
    elseif (HBcmd=="dt") then
        if HealBot_Config_Cures.DebuffWatch then
            HealBot_Config_Cures.DebuffWatch=false
        else
            HealBot_Config_Cures.DebuffWatch=true
        end
        HealBot_Options_MonitorDebuffs:SetChecked(HealBot_Config_Cures.DebuffWatch)
        HealBot_Options_MonitorDebuffs_Toggle()
    elseif (HBcmd=="pcs" and x) then
        local minBH=50
        for j=1,10 do
            if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Current_Skin][j]["HEIGHT"]<minBH then
                minBH=Healbot_Config_Skins.BarText[Healbot_Config_Skins.Current_Skin][j]["HEIGHT"]
            end
        end
		if (tonumber(x)<25) and ((minBH-tonumber(x))>0) then
			HealBot_Globals.PowerChargeTxtSizeMod=tonumber(x)
			HealBot_SetResetFlag("SOFT")
		end
    elseif (HBcmd=="hrfm") then
        HealBot_trackHiddenFrames["RAID"]=true
        if HealBot_Globals.RaidHideMethod==0 then
            HealBot_Globals.RaidHideMethod=1
            HealBot_setOptions_Timer(188)
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_OPTIONS_HIDERAIDFRAMES.." "..HEALBOT_WORD_DISABLE.." "..HEALBOT_WORD_ALWAYS)
        else
            local hbHideRaidFrameSetting=0
            if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDERAIDF"] then hbHideRaidFrameSetting=1 end
            HealBot_Globals.RaidHideMethod=3+hbHideRaidFrameSetting
            Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDERAIDF"]=false
            HealBot_setOptions_Timer(188)
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_OPTIONS_HIDERAIDFRAMES.." "..HEALBOT_WORD_DISABLE.." "..HEALBOT_WORD_NEVER)
        end
    elseif (HBcmd=="hrfms") then
        if HealBot_Globals.RaidHideMethod==0 then
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_OPTIONS_HIDERAIDFRAMES.." "..HEALBOT_WORD_DISABLE.." "..HEALBOT_WORD_NEVER)
        else
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_OPTIONS_HIDERAIDFRAMES.." "..HEALBOT_WORD_DISABLE.." "..HEALBOT_WORD_ALWAYS)
        end
	elseif (HBcmd=="debug") then
		if CanInspect("target") then HealBot_TalentQuery("target") end
    elseif (HBcmd=="rld" and x) then
        if tonumber(x) and tonumber(x)>0 and tonumber(x)<=30 then
            HealBot_Globals.ResLagDuration=ceil(x)
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_RESLAG_INDICATOR.." "..ceil(x).." "..HEALBOT_WORDS_SEC)
        else
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_RESLAG_INDICATOR_ERROR)
        end
    elseif (HBcmd=="flb") then
        if HealBot_Globals.ByPassLock==1 then
            HealBot_Globals.ByPassLock=0
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_FRAMELOCK_BYPASS_OFF)
        else
            HealBot_Globals.ByPassLock=1
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_FRAMELOCK_BYPASS_ON)
        end
    elseif (HBcmd=="rtb") then
        if HealBot_Globals.TargetBarRestricted==1 then
            HealBot_Globals.TargetBarRestricted=0
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_RESTRICTTARGETBAR_OFF)
        else
            HealBot_Globals.TargetBarRestricted=1
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_RESTRICTTARGETBAR_ON)
        end
    elseif (HBcmd=="tsa" and x) then
        if tonumber(x) and tonumber(x)>0 and tonumber(x)<101 then
            HealBot_Globals.tsadjmod=tonumber(x)
            HealBot_AddChat(HEALBOT_CHAT_ADDONID.."Text size adjust = "..x)
        end
    elseif (HBcmd=="dm") then
        HealBot_MountsPets_DislikeMount("Dislike")
    elseif (HBcmd=="em") then
        HealBot_MountsPets_DislikeMount("Exclude")
    elseif (HBcmd=="afr") then
        HealBot_AddChat("qaFR="..HealBot_luVars["qaFR"])
    elseif (HBcmd=="aggro" and x and y) then
        if tonumber(x) and tonumber(x)==2 then
            if tonumber(y) and tonumber(y)>24 and tonumber(x)<96 then
                HealBot_Globals.aggro2pct=tonumber(y)
                HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_AGGRO2_SET_MSG..y)
            else
                HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_AGGRO2_ERROR_MSG)
            end
        elseif tonumber(x) and tonumber(x)==3 then
            if tonumber(y) and tonumber(y)>74 and tonumber(y)<101 then
                HealBot_Globals.aggro3pct=tonumber(y)
                HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_AGGRO3_SET_MSG..y)
            else
                HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_AGGRO3_ERROR_MSG)
            end
        else
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_AGGRO_ERROR_MSG)
        end
    elseif (HBcmd=="lang" and x) then
        HealBot_Options_Lang(x)
    elseif (HBcmd=="cw") then  -- Clear Warnings
        HealBot_Globals.OneTimeMsg={}
    elseif (HBcmd=="zzz") then
        HealBot_AddDebug("HealBot_Timers[CheckTimeMod]="..HealBot_Timers["CheckTimeMod"])
    else
        if x then HBcmd=HBcmd.." "..x end
        if y then HBcmd=HBcmd.." "..y end
        if z then HBcmd=HBcmd.." "..z end
        HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_UNKNOWNCMD..HBcmd)
        HealBot_luVars["HelpCnt1"]=0
    end
end

function HealBot_setResetFlagCode(resetCode)
    HealBot_luVars["ResetFlag"]=resetCode
end

function HealBot_ToggleAcceptSkins()
    if HealBot_Globals.AcceptSkins==1 then
        HealBot_Globals.AcceptSkins=0
        HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_ACCEPTSKINOFF)
    else
        HealBot_Globals.AcceptSkins=1
        HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_ACCEPTSKINON)
    end
    HealBot_Comms_AcceptSkins()
end

function HealBot_ToggleSuppressSetting(settingType)
    if settingType=="sound" then
        if HealBot_Globals.MacroSuppressSound==1 then
            HealBot_Globals.MacroSuppressSound=0
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_MACROSOUNDON)
        else
            HealBot_Globals.MacroSuppressSound=1
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_MACROSOUNDOFF)
        end
        HealBot_Action_SetAllAttribs()
        HealBot_Comms_MacroSuppressSound()
    elseif settingType=="error" then
        if HealBot_Globals.MacroSuppressError==1 then
            HealBot_Globals.MacroSuppressError=0
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_MACROERRORON)
        else
            HealBot_Globals.MacroSuppressError=1
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_MACROERROROFF)
        end
        HealBot_Action_SetAllAttribs()
        HealBot_Comms_MacroSuppressError()
    end
end

function HealBot_TestBars(noBars)
    local numBars=noBars or HealBot_Globals.TestBars["BARS"]
    if numBars and tonumber(numBars) and tonumber(numBars)>4 and tonumber(numBars)<51 then
        numBars=tonumber(numBars)
        HealBot_Panel_SetNumBars(numBars)
        HealBot_Panel_ToggleTestBars()
     elseif HealBot_Panel_retTestBars() then
         HealBot_Panel_ToggleTestBars()
    end
    HealBot_nextRecalcParty(0); HealBot_Data["REFRESH"]=true;  
end

local function HealBot_configClassHoT()
    local hbClassHoTwatch=HealBot_Globals.WatchHoT
    for sName,_ in pairs(HealBot_Watch_HoT) do
        HealBot_Watch_HoT[sName]=nil
    end
    for xClass,_  in pairs(hbClassHoTwatch) do
        local HealBot_configClassHoTClass=HealBot_Globals.WatchHoT[xClass]
        for sName,x  in pairs(HealBot_configClassHoTClass) do
            if xClass=="ALL" and x==3 then
                HealBot_Watch_HoT[sName]="C"
                if sName==HEALBOT_GIFT_OF_THE_NAARU and HealBot_Data["PRACE_EN"]=="Draenei" then HealBot_Watch_HoT[sName]="C" end
            elseif (x==4) or (x==3 and xClass==HealBot_Data["PCLASSTRIM"]) then
                HealBot_Watch_HoT[sName]="A"
                if sName==HEALBOT_GIFT_OF_THE_NAARU and HealBot_Data["PRACE_EN"]=="Draenei" then HealBot_Watch_HoT[sName]="A" end
            elseif x==2 then 
                HealBot_Watch_HoT[sName]="S"
                if sName==HEALBOT_GIFT_OF_THE_NAARU and HealBot_Data["PRACE_EN"]=="Draenei" then HealBot_Watch_HoT[sName]="S" end
            else
                HealBot_Watch_HoT[sName]=nil
            end
        end
    end
end

local function HealBot_CheckTime_Modifier()
    if IsInRaid() then
        if GetNumGroupMembers() < 15 then
            HealBot_Timers["CheckTimeMod"]=HealBot_Comm_round(HealBot_Globals.RangeCheckFreq/(HealBot_luVars["qaFR"]/8), 4) -- At 50FPS with default settings = 0.032
        else
            HealBot_Timers["CheckTimeMod"]=HealBot_Comm_round(HealBot_Globals.RangeCheckFreq/(HealBot_luVars["qaFR"]/4), 4) -- At 50FPS with default settings = 0.016
        end
    elseif IsInGroup() then
        HealBot_Timers["CheckTimeMod"]=HealBot_Comm_round(HealBot_Globals.RangeCheckFreq/(HealBot_luVars["qaFR"]/16), 4) -- At 50FPS with default settings = 0.064
    else
        HealBot_Timers["CheckTimeMod"]=HealBot_Comm_round(HealBot_Globals.RangeCheckFreq/(HealBot_luVars["qaFR"]/80), 4) -- At 50FPS with default settings = 0.32
    end
end

local HealBot_UnknownUnitUpdated={}
local function HealBot_RecalcParty()
    if HealBot_luVars["DoUpdates"] then
        HealBot_Data["REFRESH"]=false
        HealBot_Action_PartyChanged();
        for xUnit,_ in pairs(HealBot_UnknownUnitUpdated) do
            HealBot_UnknownUnitUpdated[xUnit]=nil
        end
        HealBot_CheckTime_Modifier()
    end
end

local function HealBot_ClearAllBuffs()
    for _,xButton in pairs(HealBot_Unit_Button) do
        if xButton.aura.buff.name then
            HealBot_ClearBuff(xButton,true)
        end
    end
end

function HealBot_ClearAllDebuffs()
    for xUnit,xButton in pairs(HealBot_Unit_Button) do
        HealBot_ClearDebuff(xButton)
    end
end

function HealBot_SetAuraChecks()
    if not HealBot_Data["UILOCK"] and HealBot_Config_Buffs.NoAuraWhenRested and IsResting() then
        if HealBot_luVars["BuffCheck"] then 
            HealBot_luVars["BuffCheck"]=false
            HealBot_ClearAllBuffs() 
        end
        if HealBot_luVars["DebuffCheck"] then 
            HealBot_luVars["DebuffCheck"]=false
            HealBot_ClearAllDebuffs() 
        end
    else
        if HealBot_Config_Buffs.BuffWatchWhenGrouped and GetNumGroupMembers()==0 then
            if HealBot_luVars["BuffCheck"] then 
                HealBot_luVars["BuffCheck"]=false
                HealBot_ClearAllBuffs() 
            end
        elseif HealBot_Config_Buffs.BuffWatch then
            if not HealBot_luVars["BuffCheck"] then 
                HealBot_luVars["BuffCheck"]=true
                HealBot_CheckAllBuffs() 
            end
        else
            if HealBot_luVars["BuffCheck"] then 
                HealBot_luVars["BuffCheck"]=false
                HealBot_ClearAllBuffs() 
            end
        end
        if HealBot_Config_Cures.DebuffWatchWhenGrouped and GetNumGroupMembers()==0 then
            if HealBot_luVars["DebuffCheck"] then 
                HealBot_luVars["DebuffCheck"]=false
                HealBot_ClearAllDebuffs() 
            end
        elseif HealBot_Config_Cures.DebuffWatch then
            if not HealBot_luVars["DebuffCheck"] then 
                HealBot_luVars["DebuffCheck"]=true
                HealBot_CheckAllDebuffs() 
            end
        else
            if HealBot_luVars["DebuffCheck"] then 
                HealBot_luVars["DebuffCheck"]=false
                HealBot_ClearAllDebuffs() 
            end
        end
    end
end

local function HealBot_CheckZone()
    HealBot_Set_Timers()
    HealBot_setOptions_Timer(405)
    HealBot_setOptions_Timer(10)
    HealBot_luVars["hbInsNameCheck"]=GetTime()+1
    HealBot_setOptions_Timer(7950)
    HealBot_SetAuraChecks()
end

local hbStanceBuffs = {}
local function HealBot_setHbStanceBuffs()
    if HealBot_Data["PCLASSTRIM"]=="PALA" then
        hbStanceBuffs = {}
        local i = GetSpecialization()
        local specID = 0
        if i then specID = GetSpecializationInfo(i,false,false) end
        if specID==65 then
            hbStanceBuffs[HEALBOT_SEAL_OF_COMMAND]=1
            hbStanceBuffs[HEALBOT_SEAL_OF_INSIGHT]=2
        elseif specID==66 then
            hbStanceBuffs[HEALBOT_SEAL_OF_RIGHTEOUSNESS]=1
            hbStanceBuffs[HEALBOT_SEAL_OF_INSIGHT]=2
        else
            hbStanceBuffs[HEALBOT_SEAL_OF_TRUTH]=1
            hbStanceBuffs[HEALBOT_SEAL_OF_RIGHTEOUSNESS]=2
            hbStanceBuffs[HEALBOT_SEAL_OF_JUSTICE]=3
            hbStanceBuffs[HEALBOT_SEAL_OF_INSIGHT]=4
        end
    elseif HealBot_Data["PCLASSTRIM"]=="MONK" then
        hbStanceBuffs = {
            [HEALBOT_STANCE_MONK_SERPENT]=1,
            [HEALBOT_STANCE_MONK_TIGER]=2,
            }
    end
end

local function HealBot_Update_BuffsForSpecDD(ddId,bType)
    if bType=="Debuff" then
        for z=1,4 do
            if HealBot_Config_Cures.HealBotDebuffDropDown[ddId] and not HealBot_Config_Cures.HealBotDebuffDropDown[z..ddId] then 
                HealBot_Config_Cures.HealBotDebuffDropDown[z..ddId]=HealBot_Config_Cures.HealBotDebuffDropDown[ddId] 
            elseif not HealBot_Config_Cures.HealBotDebuffDropDown[z..ddId] then 
                HealBot_Config_Cures.HealBotDebuffDropDown[z..ddId]=4
            end
            if HealBot_Config_Cures.HealBotDebuffText[ddId] and not HealBot_Config_Cures.HealBotDebuffText[z..ddId] then 
				local sName = HealBot_Config_Cures.HealBotDebuffText[ddId] 
				if sName == HEALBOT_NATURES_CURE and z ~= 4 then 
					sName = HEALBOT_REMOVE_CORRUPTION
				elseif sName == HEALBOT_REMOVE_CORRUPTION and z == 4 then 
					sName = HEALBOT_NATURES_CURE
				elseif sName == HEALBOT_PURIFY_SPIRIT and z ~= 3 then 
					sName = HEALBOT_CLEANSE_SPIRIT
				elseif sName == HEALBOT_CLEANSE_SPIRIT and z == 3 then 
					sName = HEALBOT_PURIFY_SPIRIT
				end
				HealBot_Config_Cures.HealBotDebuffText[z..ddId]=sName
            elseif not not HealBot_Config_Cures.HealBotDebuffText[z..ddId] then 
                HealBot_Config_Cures.HealBotDebuffText[z..ddId]=HEALBOT_WORDS_NONE
            end
        end
    else
        for z=1,4 do
            if HealBot_Config_Buffs.HealBotBuffDropDown[ddId] and not HealBot_Config_Buffs.HealBotBuffDropDown[z..ddId] then 
                HealBot_Config_Buffs.HealBotBuffDropDown[z..ddId]=HealBot_Config_Buffs.HealBotBuffDropDown[ddId]
            elseif not HealBot_Config_Buffs.HealBotBuffDropDown[z..ddId] then 
                HealBot_Config_Buffs.HealBotBuffDropDown[z..ddId]=4
            end
            if HealBot_Config_Buffs.HealBotBuffText[ddId] and not HealBot_Config_Buffs.HealBotBuffText[z..ddId] then 
                HealBot_Config_Buffs.HealBotBuffText[z..ddId]=HealBot_Config_Buffs.HealBotBuffText[ddId]
            elseif not HealBot_Config_Buffs.HealBotBuffText[z..ddId] then 
                HealBot_Config_Buffs.HealBotBuffText[z..ddId]=HEALBOT_WORDS_NONE
            end
        end
    end
end

local function HealBot_Update_BuffsForSpec(buffType)
    if buffType then
        if buffType=="Debuff" then
            for x=1,3 do
                HealBot_Update_BuffsForSpecDD(x,"Debuff")
            end
        else
            for x=1,8 do
                HealBot_Update_BuffsForSpecDD(x,"Buff")
            end
        end
    else
        for x=1,3 do
            HealBot_Update_BuffsForSpecDD(x,"Debuff")
        end
        for x=1,8 do
            HealBot_Update_BuffsForSpecDD(x,"Buff")
        end
    end
end

local function HealBot_Update_SpellCombos()
    local combo,button=nil,nil
    for x=1,3 do
        if x==1 then
            combo = HealBot_Config_Spells.EnabledKeyCombo;
        elseif x==2 then
            combo = HealBot_Config_Spells.DisabledKeyCombo;
        else
            combo = HealBot_Config_Spells.EnemyKeyCombo;
        end
        for y=1,15 do
            button = HealBot_Options_ComboClass_Button(y)
            for z=1,4 do
                if combo then
                    combo[button..z] = combo[button]
                    combo["Shift"..button..z] = combo["Shift"..button]
                    combo["Ctrl"..button..z] = combo["Ctrl"..button]
                    combo["Alt"..button..z] = combo["Alt"..button]
                    combo["Ctrl-Shift"..button..z] = combo["Ctrl-Shift"..button]
                    combo["Alt-Shift"..button..z] = combo["Alt-Shift"..button]
                end
            end
        end
    end
end

local function HealBot_DoReset_Spells(pClassTrim)
    HealBot_Config_Spells.EnabledKeyCombo = {}
    HealBot_Config_Spells.DisabledKeyCombo = {}
    HealBot_Config_Spells.EnemyKeyCombo = {}
    local bandage=HealBot_GetBandageType()
    local x=""
    if pClassTrim=="DRUI" then
        HealBot_Config_Spells.EnabledKeyCombo = {
          ["Left"] = HEALBOT_REGROWTH,
          ["CtrlLeft"] =  HEALBOT_REMOVE_CORRUPTION,
          ["Right"] = HEALBOT_HEALING_TOUCH,
          ["CtrlRight"] =  HEALBOT_NATURES_CURE,
          ["Middle"] = HEALBOT_REJUVENATION,
          ["ShiftMiddle"] = bandage,
          ["Alt-ShiftLeft"] = HEALBOT_DISABLED_TARGET,
          ["Alt-ShiftRight"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
        HealBot_Config_Spells.DisabledKeyCombo = {
          ["Left"] = HEALBOT_DISABLED_TARGET,
          ["ShiftLeft"] = HEALBOT_MARK_OF_THE_WILD,
          ["Right"] = HEALBOT_ASSIST,
          ["Middle"] = HEALBOT_REJUVENATION,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
    elseif pClassTrim=="MONK" then
        HealBot_Config_Spells.EnabledKeyCombo = {
          ["Left"] = HEALBOT_SOOTHING_MIST,
          ["ShiftLeft"] = HEALBOT_SURGING_MIST,
          ["ShiftRight"] = HEALBOT_REVIVAL,
          ["CtrlLeft"] =  HEALBOT_DETOX,
          ["Right"] = HEALBOT_ENVELOPING_MIST,
          ["Middle"] =  HEALBOT_RENEWING_MIST,
          ["ShiftMiddle"] = HEALBOT_UPLIFT,
          ["CtrlMiddle"] = HEALBOT_LIFE_COCOON,
          ["AltMiddle"] = HEALBOT_ZEN_MEDITATION,
          ["Alt-ShiftLeft"] = HEALBOT_DISABLED_TARGET,
          ["Alt-ShiftRight"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
        HealBot_Config_Spells.DisabledKeyCombo = {
          ["Left"] = HEALBOT_DISABLED_TARGET,
          ["Middle"] =  HEALBOT_RENEWING_MIST,
          ["Right"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
    elseif pClassTrim=="PALA" then
        HealBot_Config_Spells.EnabledKeyCombo = {
          ["Left"] = HEALBOT_FLASH_OF_LIGHT,
          ["ShiftLeft"] = x,
          ["ShiftRight"] = HEALBOT_LIGHT_OF_DAWN,
          ["CtrlLeft"] =  HEALBOT_CLEANSE,
          ["Right"] = HEALBOT_HOLY_LIGHT,
          ["Middle"] =  HEALBOT_WORD_OF_GLORY,
          ["ShiftMiddle"] = HEALBOT_HOLY_RADIANCE,
          ["Alt-ShiftLeft"] = HEALBOT_DISABLED_TARGET,
          ["Alt-ShiftRight"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
        HealBot_Config_Spells.DisabledKeyCombo = {
          ["Left"] = HEALBOT_DISABLED_TARGET,
          ["Middle"] =  HEALBOT_HAND_OF_SALVATION,
          ["Right"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
    elseif pClassTrim=="PRIE" then
        HealBot_Config_Spells.EnabledKeyCombo = {
          ["Left"] = HEALBOT_FLASH_HEAL,
          ["ShiftLeft"] = HEALBOT_BINDING_HEAL,
          ["CtrlLeft"] = HEALBOT_PURIFY,
          ["Right"] = HEALBOT_HEAL,
          ["ShiftRight"] = HEALBOT_HOLY_WORD_SERENITY,
          ["CtrlRight"] = HEALBOT_MASS_DISPEL,
          ["Middle"] = HEALBOT_RENEW,
          ["ShiftMiddle"] = HEALBOT_PRAYER_OF_MENDING,
          ["AltMiddle"] = HEALBOT_PRAYER_OF_HEALING,
          ["CtrlMiddle"] = HEALBOT_DIVINE_HYMN,
          ["Alt-ShiftLeft"] = HEALBOT_DISABLED_TARGET,
          ["Alt-ShiftRight"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
        HealBot_Config_Spells.DisabledKeyCombo = {
          ["Left"] = HEALBOT_DISABLED_TARGET,
          ["Right"] = HEALBOT_ASSIST,
          ["AltLeft"] = HEALBOT_RESURRECTION,
          ["ShiftRight"] = HEALBOT_HOLY_WORD_SERENITY,
          ["Middle"] = HEALBOT_RENEW,
          ["Ctrl-ShiftLeft"] = HEALBOT_FLASH_HEAL,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
    elseif pClassTrim=="SHAM" then
        if HealBot_Config.CurrentSpec==3 then
            x=HEALBOT_PURIFY_SPIRIT;
        else
            x=HEALBOT_CLEANSE_SPIRIT;
        end
        HealBot_Config_Spells.EnabledKeyCombo = {
          ["Left"] = HEALBOT_HEALING_WAVE,
          ["CtrlLeft"] = x,
          ["Right"] = x,
          ["CtrlRight"] = x,
          ["ShiftLeft"] = HEALBOT_CHAIN_HEAL,
		  ["Middle"] = HEALBOT_HEALING_RAIN,
          ["ShiftMiddle"] = HEALBOT_HEALING_SURGE,
          ["AltLeft"] = HEALBOT_HEALING_STREAM_TOTEM,
          ["AltRight"] = x,
          ["Alt-ShiftLeft"] = HEALBOT_DISABLED_TARGET,
          ["Alt-ShiftRight"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
        HealBot_Config_Spells.DisabledKeyCombo = {
          ["Left"] = HEALBOT_DISABLED_TARGET,
          ["Right"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
    elseif pClassTrim=="MAGE" then
        HealBot_Config_Spells.EnabledKeyCombo = {
          ["Left"] = HEALBOT_REMOVE_CURSE,
          ["ShiftLeft"] = bandage,
          ["Alt-ShiftLeft"] = HEALBOT_DISABLED_TARGET,
          ["Alt-ShiftRight"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
        HealBot_Config_Spells.DisabledKeyCombo = {
          ["Left"] = HEALBOT_DISABLED_TARGET,
          ["ShiftLeft"] = bandage,
          ["Right"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
    else
        HealBot_Config_Spells.EnabledKeyCombo = {
          ["Left"] = bandage,
          ["Alt-ShiftLeft"] = HEALBOT_DISABLED_TARGET,
          ["Alt-ShiftRight"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
        HealBot_Config_Spells.DisabledKeyCombo = {
          ["Left"] = HEALBOT_DISABLED_TARGET,
          ["ShiftLeft"] = bandage,
          ["Right"] = HEALBOT_ASSIST,
          ["Ctrl-ShiftLeft"] = HEALBOT_MENU,
          ["Ctrl-ShiftRight"] = HEALBOT_HBMENU,
                                         }
    end
end

local function HealBot_DoReset_Cures(pClassTrim)
    HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_WORDS_NONE,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
    HealBot_Config_Cures.HealBotDebuffDropDown = {[1]=4,[2]=4,[3]=4}
    if pClassTrim=="DRUI" then
        if HealBot_GetSpellId(HEALBOT_NATURES_CURE) then
            if HealBot_GetSpellId(HEALBOT_REMOVE_CORRUPTION) then
                HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_REMOVE_CORRUPTION,[2]=HEALBOT_NATURES_CURE,[3]=HEALBOT_WORDS_NONE}
            else
                HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_NATURES_CURE,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
            end
        elseif HealBot_GetSpellId(HEALBOT_REMOVE_CORRUPTION) then
            HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_REMOVE_CORRUPTION,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
        end
    elseif pClassTrim=="MONK" then
        if HealBot_GetSpellId(HEALBOT_DETOX) then
            HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_DETOX,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
        end
    elseif pClassTrim=="PALA" then
        if HealBot_GetSpellId(HEALBOT_CLEANSE) then
            HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_CLEANSE,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
        elseif HealBot_GetSpellId(HEALBOT_CLEANSE_TOXIN) then
            HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_CLEANSE_TOXIN,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
        end
    elseif pClassTrim=="PRIE" then
        if HealBot_GetSpellId(HEALBOT_PURIFY) then
            if HealBot_GetSpellId(HEALBOT_MASS_DISPEL) then
                if HealBot_GetSpellId(HEALBOT_PURIFY_DISEASE) then
                    HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_PURIFY,[2]=HEALBOT_MASS_DISPEL,[3]=HEALBOT_PURIFY_DISEASE}
                else
                    HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_PURIFY,[2]=HEALBOT_MASS_DISPEL,[3]=HEALBOT_WORDS_NONE}
                end
            elseif HealBot_GetSpellId(HEALBOT_PURIFY_DISEASE) then
                HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_PURIFY,[2]=HEALBOT_PURIFY_DISEASE,[3]=HEALBOT_WORDS_NONE}
            else
                HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_PURIFY,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
            end
        elseif HealBot_GetSpellId(HEALBOT_MASS_DISPEL) then
            if HealBot_GetSpellId(HEALBOT_PURIFY_DISEASE) then
                HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_MASS_DISPEL,[2]=HEALBOT_PURIFY_DISEASE,[3]=HEALBOT_WORDS_NONE}
            else
                HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_MASS_DISPEL,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
            end
        elseif HealBot_GetSpellId(HEALBOT_PURIFY_DISEASE) then
            HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_PURIFY_DISEASE,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
        end
    elseif pClassTrim=="SHAM" then
        if HealBot_GetSpellId(HEALBOT_PURIFY_SPIRIT) then
            HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_PURIFY_SPIRIT,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
        elseif HealBot_GetSpellId(HEALBOT_CLEANSE_SPIRIT) then
            HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_CLEANSE_SPIRIT,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
        end
    elseif pClassTrim=="MAGE" then
        if HealBot_GetSpellId(HEALBOT_REMOVE_CURSE) then
            HealBot_Config_Cures.HealBotDebuffText = {[1]=HEALBOT_REMOVE_CURSE,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE}
        end
    end
end

local function HealBot_DoReset_Buffs(pClassTrim)
    HealBot_Config_Buffs.HealBotBuffText = {[1]=HEALBOT_WORDS_NONE,[2]=HEALBOT_WORDS_NONE,[3]=HEALBOT_WORDS_NONE,[4]=HEALBOT_WORDS_NONE,[5]=HEALBOT_WORDS_NONE,
                                      [6]=HEALBOT_WORDS_NONE,[7]=HEALBOT_WORDS_NONE,[8]=HEALBOT_WORDS_NONE,[9]=HEALBOT_WORDS_NONE}
    HealBot_Config_Buffs.HealBotBuffDropDown = {[1]=4,[2]=4,[3]=4,[4]=4,[5]=4,[6]=4,[7]=2,[8]=2,[9]=2}
    if pClassTrim=="DRUI" then
        if HealBot_GetSpellId(HEALBOT_MARK_OF_THE_WILD) then
            HealBot_Config_Buffs.HealBotBuffText[1]=HEALBOT_MARK_OF_THE_WILD
        end
    elseif pClassTrim=="MONK" then
        if HealBot_GetSpellId(HEALBOT_LEGACY_WHITETIGER) and HealBot_Config.CurrentSpec==3 then
            HealBot_Config_Buffs.HealBotBuffText[1]=HEALBOT_LEGACY_EMPEROR
            HealBot_Config_Buffs.HealBotBuffText[2]=HEALBOT_LEGACY_WHITETIGER
        elseif HealBot_GetSpellId(HEALBOT_LEGACY_EMPEROR) then
            HealBot_Config_Buffs.HealBotBuffText[1]=HEALBOT_LEGACY_EMPEROR
        end
    elseif pClassTrim=="PALA" then
        local i=1
        if HealBot_GetSpellId(HEALBOT_BLESSING_OF_KINGS) then
            HealBot_Config_Buffs.HealBotBuffText[i]=HEALBOT_BLESSING_OF_KINGS
            i=i+1
        end
        if HealBot_GetSpellId(HEALBOT_BLESSING_OF_MIGHT) then
            HealBot_Config_Buffs.HealBotBuffText[i]=HEALBOT_BLESSING_OF_MIGHT
            i=i+1
        end
        if HealBot_GetSpellId(HEALBOT_BLESSING_OF_WISDOM) then
            HealBot_Config_Buffs.HealBotBuffText[i]=HEALBOT_BLESSING_OF_WISDOM
        end
    elseif pClassTrim=="PRIE" then
        if HealBot_GetSpellId(HEALBOT_POWER_WORD_FORTITUDE) then
            HealBot_Config_Buffs.HealBotBuffText[1]=HEALBOT_POWER_WORD_FORTITUDE
        end
        if HealBot_GetSpellId(HEALBOT_FEAR_WARD) then
            HealBot_Config_Buffs.HealBotBuffText[2]=HEALBOT_FEAR_WARD
            HealBot_Config_Buffs.HealBotBuffDropDown[2]=24
        end
    elseif pClassTrim=="SHAM" then
        if HealBot_GetSpellId(HEALBOT_WATER_SHIELD) then
            HealBot_Config_Buffs.HealBotBuffText[1]=HEALBOT_WATER_SHIELD
        end
        if HealBot_GetSpellId(HEALBOT_EARTH_SHIELD) then
            HealBot_Config_Buffs.HealBotBuffText[2]=HEALBOT_EARTH_SHIELD
            HealBot_Config_Buffs.HealBotBuffDropDown[2]=24
        end
    elseif pClassTrim=="MAGE" then
        if HealBot_GetSpellId(HEALBOT_ARCANE_BRILLIANCE) then
            HealBot_Config_Buffs.HealBotBuffText[1]=HEALBOT_ARCANE_BRILLIANCE
        end
    elseif pClassTrim=="WARR" then
        if HealBot_GetSpellId(HEALBOT_COMMANDING_SHOUT) then
            HealBot_Config_Buffs.HealBotBuffText[1]=HEALBOT_COMMANDING_SHOUT
        end
        if HealBot_GetSpellId(HEALBOT_VIGILANCE) then
            HealBot_Config_Buffs.HealBotBuffText[2]=HEALBOT_VIGILANCE
            HealBot_Config_Buffs.HealBotBuffDropDown[2]=24
        end
    elseif pClassTrim=="WARL" then
        if HealBot_GetSpellId(HEALBOT_DARK_INTENT) then
            HealBot_Config_Buffs.HealBotBuffText[1]=HEALBOT_DARK_INTENT
        end
    end
    if IsUsableItem(HEALBOT_EVER_BLOOMING_FROND) or HealBot_IsItemInBag(HEALBOT_EVER_BLOOMING_FROND) then
        HealBot_Config_Buffs.HealBotBuffText[7]=HEALBOT_EVER_BLOOMING_FROND
    end
    if IsUsableItem(HEALBOT_ORALIUS_WHISPERING_CRYSTAL) or HealBot_IsItemInBag(HEALBOT_ORALIUS_WHISPERING_CRYSTAL) then
        HealBot_Config_Buffs.HealBotBuffText[8]=HEALBOT_ORALIUS_WHISPERING_CRYSTAL
    end
    if IsUsableItem(HEALBOT_REPURPOSED_FEL_FOCUSER) or HealBot_IsItemInBag(HEALBOT_REPURPOSED_FEL_FOCUSER) then
        HealBot_Config_Buffs.HealBotBuffText[9]=HEALBOT_REPURPOSED_FEL_FOCUSER
    end
end

local function HealBot_InitNewChar()
    if HealBot_Config_Spells.EnabledKeyCombo then
        if not HealBot_Config_Spells.DisabledKeyCombo then 
            HealBot_Config_Spells.DisabledKeyCombo=HealBot_Config_Spells.EnabledKeyCombo
        end
        if not HealBot_Config_Spells.EnemyKeyCombo then
            HealBot_Config_Spells.EnemyKeyCombo={}
        end
    else
        HealBot_DoReset_Spells(HealBot_Data["PCLASSTRIM"])
        HealBot_DoReset_Cures(HealBot_Data["PCLASSTRIM"])
        HealBot_DoReset_Buffs(HealBot_Data["PCLASSTRIM"])
        HealBot_Config_Buffs.HealBotBuffColR = {[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1}
        HealBot_Config_Buffs.HealBotBuffColG = {[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1}
        HealBot_Config_Buffs.HealBotBuffColB = {[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1}
        HealBot_Update_SpellCombos()
        HealBot_Update_BuffsForSpec()
        for i=1, 10 do
            HealBot_Action_setPoint(i)
            HealBot_Action_unlockFrame(i)
        end
    end
end

local function HealBot_Load(hbCaller)
    HealBot_SetAuraChecks()
    HealBot_setOptions_Timer(60)
    HealBot_setOptions_Timer(50)
    HealBot_setOptions_Timer(40)
    HealBot_setOptions_Timer(25)
	HealBot_Action_setpcClass()
    HealBot_Tooltip:SetBackdropColor(0,0,0,HealBot_Globals.ttalpha)
    HealBot_Action_SetDebuffAggroCols()
    HealBot_Action_SetHightlightAggroCols()
    HealBot_Action_SetHightlightTargetAggroCols()
    HealBot_Action_SetAggroCols()
    HealBot_Panel_SetNumBars(HealBot_Globals.TestBars["BARS"])
    HealBot_Panel_SethbTopRole(HealBot_Globals.TopRole)
    local x=HealBot_Globals.ttalpha+0.12
    if x>1 then x=1 end
    HealBot_Tooltip:SetBackdropBorderColor(0.32,0.32,0.4, x)
    HealBot_setOptions_Timer(200)
    HealBot_luVars["UseCrashProtection"]=GetTime()+HealBot_Config.CrashProtStartTime
    HealBot_Action_setLowManaTrig()
    HealBot_Options_MonitorBuffs_Toggle()
    HealBot_Options_MonitorDebuffs_Toggle()
    --
    HealBot_setOptions_Timer(8000)
    HealBot_Data["PGUID"]=UnitGUID("player")
    HealBot_PlayerBuff[HealBot_Data["PGUID"]]={}
    HealBot_setHbStanceBuffs()
    HealBot_InitSpells()
    HealBot_useCrashProtection()
    HealBot_Options_Set_Current_Skin()
    HealBot_Action_ResetSkin("init")
    HealBot_InitNewChar()
    HealBot_Options_SetSkins();
    HealBot_Data["REFRESH"]=true;
    HealBot_configClassHoT()
    if HealBot_luVars["AddonMsgType"]==2 then HealBot_Comms_SendAddonMsg("CTRA", "SR", HealBot_luVars["AddonMsgType"], HealBot_Data["PNAME"]) end
    if not HealBot_luVars["HelpNotice"] then
        HealBot_setOptions_Timer(990)
        HealBot_luVars["HelpNotice"]=true
    end
    HealBot_Panel_SetmaxHealDiv(UnitLevel("player"))
    HealBot_Options_RaidTargetUpdate()
    if hbCaller~="playerEW" then
        HealBot_OnEvent_PlayerEnteringWorld()
    end
    HealBot_setOptions_Timer(140)
    if HealBot_Globals.ShowTooltip then
        HealBot_Options_LoadTips()
    end
    HealBot_setFocusHeals()
    HealBot_setPetHeals()
    HealBot_setTargetHeals()
    HealBot_setEnemyBars()
    HealBot_MMButton_Init();
end

local function HealBot_Register_Events()
    if HealBot_Config.DisabledNow==0 then
        HealBot:RegisterEvent("PLAYER_REGEN_DISABLED");
        HealBot:RegisterEvent("PLAYER_REGEN_ENABLED");
        HealBot:RegisterEvent("PLAYER_TARGET_CHANGED");
        HealBot:RegisterEvent("PLAYER_FOCUS_CHANGED");
        HealBot:RegisterEvent("UNIT_ENTERED_VEHICLE");
        HealBot:RegisterEvent("UNIT_EXITED_VEHICLE");
        HealBot:RegisterEvent("UNIT_EXITING_VEHICLE");
        HealBot:RegisterEvent("UNIT_HEALTH");
        HealBot:RegisterEvent("UNIT_MAXHEALTH");
        HealBot:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED");
        local regPower=false
        for j=1,10 do
            if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Current_Skin][j]["POWERSIZE"]>0 then 
                regPower=true
            elseif Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Current_Skin][j]["POWERCNT"] and  
               (HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_PALADIN] or HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_MONK]) then
                regPower=true
            end
        end
        if regPower or Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["LOWMANA"]>1 then
            HealBot_Register_Mana() 
		end
        HealBot:RegisterEvent("LEARNED_SPELL_IN_TAB");
        HealBot:RegisterEvent("PLAYER_TALENT_UPDATE");
        HealBot:RegisterEvent("UNIT_AURA");
        HealBot:RegisterEvent("CHARACTER_POINTS_CHANGED");
		HealBot:RegisterEvent("INSPECT_READY");
        HealBot:RegisterEvent("CHAT_MSG_SYSTEM");
        HealBot:RegisterEvent("MODIFIER_STATE_CHANGED");
        HealBot:RegisterEvent("UNIT_PET");
        HealBot:RegisterEvent("UNIT_NAME_UPDATE");
        if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Current_Skin]["SHOW"] then HealBot_Register_Aggro() end

		HealBot:RegisterEvent("ROLE_CHANGED_INFORM");
        local regThis={}
        for j=1,10 do
            if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][j]["SHOW"] then regThis["RAIDTARGET"]=true end
            if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Current_Skin][j]["SHOWRC"] then regThis["READYCHECK"]=true end
            if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Current_Skin][j]["IC"]>1 or Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Current_Skin][j]["AC"]>1 then regThis["INCHEAL"]=true end
        end
        if regThis["RAIDTARGET"] then HealBot:RegisterEvent("RAID_TARGET_UPDATE") end
        if regThis["READYCHECK"] then HealBot_Register_ReadyCheck() end
        if regThis["INCHEAL"] then HealBot_Register_IncHeals() end
        HealBot:RegisterEvent("UNIT_SPELLCAST_SENT");
        HealBot:RegisterEvent("UNIT_SPELLCAST_START");
        HealBot:RegisterEvent("UNIT_SPELLCAST_STOP");
        HealBot:RegisterEvent("UNIT_SPELLCAST_FAILED");
        HealBot:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
        HealBot:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
        HealBot:RegisterEvent("UPDATE_MACROS");
        HealBot:RegisterEvent("UNIT_CONNECTION");
        HealBot:RegisterEvent("COMPANION_LEARNED");
        HealBot:RegisterEvent("PLAYER_CONTROL_GAINED");
        HealBot:RegisterEvent("PET_BATTLE_OPENING_START");
        HealBot:RegisterEvent("PET_BATTLE_OVER");
        if HealBot_Globals.EnLibQuickHealth then HealBot:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") end
    end
    HealBot:RegisterEvent("GROUP_ROSTER_UPDATE");
    HealBot:RegisterEvent("CHAT_MSG_ADDON");
    HealBot:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    HealBot:RegisterEvent("ZONE_CHANGED");
    HealBot:RegisterEvent("ZONE_CHANGED_INDOORS");
    HealBot_setOptions_Timer(125)
    HealBot_Set_Timers()
end

local function HealBot_UnRegister_Events()
    HealBot_Timers["HB1Th"]=0.5
    HealBot_Timers["HB2Th"]=1
    if HealBot_Config.DisabledNow==1 then
        HealBot:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
        HealBot:UnregisterEvent("ZONE_CHANGED");
        HealBot:UnregisterEvent("ZONE_CHANGED_INDOORS");
        HealBot:UnregisterEvent("PLAYER_REGEN_DISABLED");
        HealBot:UnregisterEvent("PLAYER_REGEN_ENABLED");
        HealBot:UnregisterEvent("UNIT_ENTERED_VEHICLE");
        HealBot:UnregisterEvent("UNIT_EXITED_VEHICLE");
        HealBot:UnregisterEvent("UNIT_EXITING_VEHICLE");
        HealBot:UnregisterEvent("PLAYER_TARGET_CHANGED");
        HealBot:UnregisterEvent("PLAYER_FOCUS_CHANGED");
        HealBot:UnregisterEvent("GROUP_ROSTER_UPDATE");
        HealBot:UnregisterEvent("UNIT_HEALTH");
        HealBot_UnRegister_Mana()
        HealBot_UnRegister_ReadyCheck()
        HealBot_UnRegister_IncHeals()
        HealBot:UnregisterEvent("UNIT_AURA");
        HealBot:UnregisterEvent("CHAT_MSG_SYSTEM");
        HealBot_UnRegister_Aggro()
        HealBot:UnregisterEvent("UNIT_PET");
        HealBot:UnregisterEvent("UNIT_NAME_UPDATE");
		HealBot:UnregisterEvent("ROLE_CHANGED_INFORM");
        HealBot:UnregisterEvent("PLAYER_TALENT_UPDATE");
        HealBot:UnregisterEvent("COMPANION_LEARNED");
        HealBot:UnregisterEvent("MODIFIER_STATE_CHANGED");
        HealBot:UnregisterEvent("PLAYER_CONTROL_GAINED");
        HealBot:UnregisterEvent("UNIT_TARGET")
    end

    HealBot:UnregisterEvent("RAID_TARGET_UPDATE")
    HealBot:UnregisterEvent("LEARNED_SPELL_IN_TAB");
    HealBot:UnregisterEvent("UNIT_SPELLCAST_SENT");
    HealBot:UnregisterEvent("UNIT_SPELLCAST_START");
    HealBot:UnregisterEvent("UNIT_SPELLCAST_STOP");
    HealBot:UnregisterEvent("UNIT_SPELLCAST_FAILED");
    HealBot:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    HealBot:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	HealBot:UnregisterEvent("INSPECT_READY");
    HealBot:UnregisterEvent("CHARACTER_POINTS_CHANGED");
    HealBot:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    HealBot:UnregisterEvent("PET_BATTLE_OPENING_START");
    HealBot:UnregisterEvent("PET_BATTLE_OVER");
end

local function HealBot_ClearUnitAggro(button)
    local doClear=true
    if UnitExists(button.unit) and (button.aggro.status<0 or button.aggro.status>4) then 
        doClear=false
    end
    button.aggro.threatpct = -5
    HealBot_Action_aggroIndicatorUpd(button)
    if doClear then
        HealBot_Action_UpdateAggro(button.unit,false,nil,0)
    end
end

local function HealBot_EndAggro()
    for _,xButton in pairs(HealBot_Unit_Button) do
        HealBot_ClearUnitAggro(xButton)
    end
end

local function HealBot_Reset()
    HealBot_UnRegister_Events()
    HealBot_Timers["HB1Th"]=0.04
    HealBot_Timers["HB2Th"]=0.1
    HealBot_Panel_ClearBlackList()
    HealBot_Panel_ClearHealTargets()
    HealBot_Action_ResethbInitButtons()
    HealBot_EndAggro() 
    HealBot_Panel_ClearBarArrays()
    HealBot_setOptions_Timer(150)
    HealBot_Data["PGUID"]=false
    HealBot_Load("hbReset") 
    HealBot_setOptions_Timer(420)
    HealBot_setOptions_Timer(7950)
    HealBot_Register_Events()
end

local function HealBot_UnitID(unit)   
    local idGUID=HealBot_UnitGUID(unit)
    local xButton=HealBot_Unit_Button[unit]    
    if xButton and idGUID then
        if xButton.guid~=idGUID and xButton.status.enemy < 0 then
            HealBot_PrepUnitNameUpdate(unit, idGUID, xButton.guid)
        end
        return unit, idGUID, xButton
    elseif idGUID and HealBot_UnitData[idGUID] and UnitIsUnit(unit,HealBot_UnitData[idGUID]["UNIT"]) and HealBot_Unit_Button[HealBot_UnitData[idGUID]["UNIT"]] then
        return HealBot_UnitData[idGUID]["UNIT"], idGUID, HealBot_Unit_Button[HealBot_UnitData[idGUID]["UNIT"]]
    end
    return nil,nil
end

local function HealBot_HealsInUpdate(button)
    if UnitExists(button.unit) then
        if button.health.incoming~=(UnitGetIncomingHeals(button.unit) or 0) then
            button.health.incoming=(UnitGetIncomingHeals(button.unit) or 0)
            HealBot_Action_setHealthText(button)
            HealBot_Action_UpdateHealsInButton(button)
        end
    elseif button.health.incoming>0 then
        button.health.incoming=0
        HealBot_Action_setHealthText(button)
        HealBot_Action_UpdateHealsInButton(button)
    end
end

local function HealBot_AbsorbsUpdate(button)
    if UnitExists(button.unit) then
        if button.health.absorbs~=UnitGetTotalAbsorbs(button.unit) then
            button.health.absorbs=UnitGetTotalAbsorbs(button.unit)
            HealBot_Action_setHealthText(button)
            HealBot_Action_UpdateAbsorbsButton(button)
        end
    elseif button.health.absorbs>0 then
        button.health.absorbs=0
        HealBot_Action_setHealthText(button)
        HealBot_Action_UpdateAbsorbsButton(button)
    end
end

local function HealBot_Health_CheckTime(button)
    HealBot_luVars["HealthCheckTime"]=HealBot_luVars["HealthCheckTime"]+(HealBot_Timers["CheckTimeMod"]*4)
    if HealBot_luVars["HealthCheckTime"]<GetTime() then
        HealBot_luVars["HealthCheckTime"]=GetTime()+0.04
    end
    button.checks.health=HealBot_luVars["HealthCheckTime"]
end

function HealBot_Range_CheckTime(button)
    HealBot_luVars["RangeCheckTime"]=HealBot_luVars["RangeCheckTime"]+(HealBot_Timers["CheckTimeMod"])
    if HealBot_luVars["RangeCheckTime"]<GetTime() then
        HealBot_luVars["RangeCheckTime"]=GetTime()+0.01
    end
    button.checks.range=HealBot_luVars["RangeCheckTime"]
end

local function HealBot_DoUnitNameUpdate(unUnit,unGUID)
    if unGUID then
        if unGUID==HealBot_Data["PGUID"] then 
            unUnit="player" 
        elseif unUnit=="target" then
            unUnit=HealBot_Panel_RaidUnit(unGUID) or "target"
        end
    end
    if HealBot_Unit_Button[unUnit] then
        local unb=HealBot_Unit_Button[unUnit]
        if unGUID then
            if HealBot_notVisible[unGUID] then 
                HealBot_notVisible[unGUID]=unUnit 
            end
            if HealBot_UnitData[unGUID] then
                HealBot_UnitData[unGUID]["NAME"]=HealBot_GetUnitName(unUnit)
                HealBot_UnitData[unGUID]["UNIT"]=unUnit
            else
                HealBot_Data["REFRESH"]=true;
            end
        else
            HealBot_Data["REFRESH"]=true;
            HealBot_UnknownUnitUpdated[unUnit]=true
        end
        unb.guid=unGUID or HealBot_UnitGUID(unUnit) or "nk"
        HealBot_HealsInUpdate(unb)
        HealBot_AbsorbsUpdate(unb)
        HealBot_CheckAllUnitVehicle(unUnit)
        if UnitExists(unUnit) then
            HealBot_CheckAllDebuffs(unUnit)
            unb.checks.health=GetTime()+1
        else
            HealBot_ClearBuff(unb)
            HealBot_ClearDebuff(unb)
        end
        HealBot_Action_setNameText(unb) 
        HealBot_Action_Refresh(unb) 
    end
end

function HealBot_UnitNameUpdate(unUnit,unGUID)
    HealBot_DoUnitNameUpdate(unUnit,unGUID)
end

function HealBot_PrepUnitNameUpdate(unit, curGUID, oldGUID)
    if oldGUID then
        local xUnit=HealBot_Panel_RaidUnit(oldGUID) or "none"
        HealBot_UnitNameUpdate(xUnit,oldGUID)
    end
    HealBot_UnitNameUpdate(unit,curGUID)
end

local function HealBot_ResetCustomDebuffs()
    HealBot_Globals.HealBot_Custom_Debuffs=HealBot_Options_copyTable(HealBot_GlobalsDefaults.HealBot_Custom_Debuffs)
    HealBot_Globals.Custom_Debuff_Categories=HealBot_Options_copyTable(HealBot_GlobalsDefaults.Custom_Debuff_Categories)
    HealBot_Globals.FilterCustomDebuff=HealBot_Options_copyTable(HealBot_GlobalsDefaults.FilterCustomDebuff)
    HealBot_Globals.CDCBarColour=HealBot_Options_copyTable(HealBot_GlobalsDefaults.CDCBarColour)
    HealBot_Options_NewCDebuff:SetText("")
    HealBot_Options_InitSub(407)
    HealBot_Options_InitSub(408)
    HealBot_Options_InitSub(419)
    HealBot_SetCDCBarColours();
    HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_CONFIRMCUSTOMDEFAULTS)
end

local function HealBot_ResetSkins()
    Healbot_Config_Skins = HealBot_Config_SkinsDefaults
    HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_CONFIRMSKINDEFAULTS)
    HealBot_Config.LastVersionSkinUpdate=HealBot_lastVerSkinUpdate
    HealBot_Options_ReloadUI(HEALBOT_CMD_RESETSKINS)
end

local function HealBot_UnitMaxHealth(unit)
	local healthFactor = 1
    if (HealBot_Config.AdjustMaxHealth == true) then
        local maxHealthPercent = select(15, UnitAura("boss1", HEALBOT_DEBUFF_AURA_OF_CONTEMPT_ID))
        if maxHealthPercent then
            healthFactor = maxHealthPercent / 100
        end
    end
    return UnitHealthMax(unit) * healthFactor
end

local temp_caster={}
local temp_HoT={}
local temp_sID={}
local function HealBot_HoT_AlphaValue(secLeft, curFrame)
    if not UnitIsDeadOrGhost("player") then
        if secLeft>=0 and secLeft<7 and Healbot_Config_Skins.Icons[Healbot_Config_Skins.Current_Skin][curFrame]["FADE"] then
            return (secLeft/9)+.3
        elseif secLeft>=0 then
            return 1
        end
    end
    return 0
end

local function HealBot_HoT_UpdateIcon(button, index, secLeft, huIcons, hotID)
    if not button then return; end;
    local bar = _G["HealBot_Action_HealUnit"..button.id.."Bar"]
    local iconName = _G[bar:GetName().."Icon"..index];
    local hbiconcount = _G[bar:GetName().."Count"..index];
    local hbiconcount2 = _G[bar:GetName().."Count"..index.."a"];
    local iconTxt=nil
    local x=HealBot_HoT_AlphaValue(secLeft, button.frame)
    if button.aura.debuff.iconId and button.aura.debuff.iconId==hotID and x>0 then 
        x=1
    end
    iconName:SetAlpha(x)
    if x==0 then 
        hbiconcount:SetTextColor(1,1,1,0);
        hbiconcount2:SetTextColor(1,1,1,0)
        hbiconcount:SetText(" ");
        hbiconcount2:SetText(" ");
    elseif huIcons then
        local xGUID, sName, sID=string.split("!", hotID or "H!B!C")
        if (Healbot_Config_Skins.IconText[Healbot_Config_Skins.Current_Skin][button.frame]["SSCNT"] and xGUID~=HealBot_Data["PGUID"]) or 
            Healbot_Config_Skins.IconText[Healbot_Config_Skins.Current_Skin][button.frame]["SCNT"]==false then
            iconTxt=nil
        else
            if huIcons[hotID]["COUNT"] and huIcons[hotID]["COUNT"]>1 then
                iconTxt=huIcons[hotID]["COUNT"]
            else
                iconTxt=huIcons[hotID]["TEXT2"]
            end
        end
        if huIcons[hotID]["TEXTURE"] then iconName:SetTexture(huIcons[hotID]["TEXTURE"]); end
        if iconTxt then
            hbiconcount2:SetText(iconTxt);
            hbiconcount2:SetTextColor(1,1,1,1);
        else
            hbiconcount2:SetText(" ");
            hbiconcount2:SetTextColor(1,1,1,0);
        end
        if (Healbot_Config_Skins.IconText[Healbot_Config_Skins.Current_Skin][button.frame]["SSDUR"] and xGUID~=HealBot_Data["PGUID"]) or 
            Healbot_Config_Skins.IconText[Healbot_Config_Skins.Current_Skin][button.frame]["SDUR"]==false then
            iconTxt=nil
        else
            iconTxt=secLeft
        end
        hbiconcount:SetText(iconTxt or " ");
        if not iconTxt or (iconTxt<0) or (iconTxt>Healbot_Config_Skins.IconText[Healbot_Config_Skins.Current_Skin][button.frame]["DURTHRH"]) then
            hbiconcount:SetTextColor(1,1,1,0);
        elseif iconTxt<=Healbot_Config_Skins.IconText[Healbot_Config_Skins.Current_Skin][button.frame]["DURWARN"] and index<15 then
            if (sName==HEALBOT_REJUVENATION or sName==HEALBOT_REGROWTH) then
                y, x, _ = GetSpellCooldown(HEALBOT_SWIFTMEND);
                if x and y and (x+y)==0 then
                    hbiconcount:SetTextColor(0,1,0,1);
                else
                    hbiconcount:SetTextColor(1,0,0,1);        
                end
            else
                hbiconcount:SetTextColor(1,0,0,1);           
            end
        else
            hbiconcount:SetTextColor(1,1,1,1);
        end   
    end    
end 

local HealBot_TargetIconsTextures = {[1]=[[Interface\Addons\HealBot\Images\Star.tga]],
                                     [2]=[[Interface\Addons\HealBot\Images\Circle.tga]],
                                     [3]=[[Interface\Addons\HealBot\Images\Diamond.tga]],
                                     [4]=[[Interface\Addons\HealBot\Images\Triangle.tga]],
                                     [5]=[[Interface\Addons\HealBot\Images\Moon.tga]],
                                     [6]=[[Interface\Addons\HealBot\Images\Square.tga]],
                                     [7]=[[Interface\Addons\HealBot\Images\Cross.tga]],
                                     [8]=[[Interface\Addons\HealBot\Images\Skull.tga]],}
                                     
local function HealBot_RaidTargetUpdate(button, iconID)
    local bar = _G["HealBot_Action_HealUnit"..button.id.."Bar"]
    if not bar then return end
    local iconName=nil
    if (Healbot_Config_Skins.BarText[Healbot_Config_Skins.Current_Skin][button.frame]["CLASSONBAR"] and 
        Healbot_Config_Skins.BarText[Healbot_Config_Skins.Current_Skin][button.frame]["CLASSTYPE"]==1) or 
        button.aura.debuff.iconId then
        iconName = _G[bar:GetName().."Icon16"];
    else
        iconName = _G[bar:GetName().."Icon16"];
        iconName:SetAlpha(0);
        iconName = _G[bar:GetName().."Icon15"];
    end
    if iconID then
        iconName:SetTexture(HealBot_TargetIconsTextures[iconID])
        iconName:SetAlpha(1);
    else
        iconName:SetAlpha(0);
    end
end

local function HealBot_HoT_UpdateNoIcon(button, huIcons, hotID, sID, secLeft)
    local i=0
    if huIcons[hotID]["DEBUFF"] then
        i=15
        if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][button.frame]["SHOW"] and HealBot_TargetIcons[button.unit] then
            HealBot_RaidTargetUpdate(button, HealBot_TargetIcons[button.unit])
        end
    else
        i=1
        for buffID,_ in pairs(huIcons) do 
            if huIcons[buffID]["ICON"]>0 and not huIcons[buffID]["DEBUFF"] then 
                i=i+1
            end 
        end  
    end
    if huIcons[hotID]["DEBUFF"] or i<15 then 
        huIcons[hotID]["ICON"]=i
        HealBot_HoT_UpdateIcon(button, i, secLeft, huIcons, hotID)
    end
end

local temp_icons={}
local tmpIcons={}
local tmpIndex={}
local delIndex={}
local function HealBot_HoT_RefreshIcons(button)
    local huIcons=HealBot_UnitIcons[button.unit]
    local hotCount=0
    local maxIcon=0
    if huIcons then
        for i=1,14 do
            tmpIndex[i]=nil
            tmpIcons[i]=nil
            delIndex[i]=nil
        end
        for hotID,_ in pairs(huIcons) do
            if huIcons[hotID]["ICON"]>0 and huIcons[hotID]["ICON"]<15 then 
                tmpIndex[huIcons[hotID]["ICON"]]=hotID
                hotCount=hotCount+1
                if huIcons[hotID]["ICON"]>maxIcon then maxIcon=huIcons[hotID]["ICON"] end
            end
        end
        for i=1,maxIcon do
            if tmpIndex[i] then
                table.insert(tmpIcons,huIcons[tmpIndex[i]]);
                if i>hotCount then
                    delIndex[i]=true
                end
            end
        end
        for i=1,#tmpIcons do
            local o=tmpIcons[i]["ICON"]
            if o~=i then
                local secLeft=10
                if HealBot_Globals.HealBot_Custom_Debuffs_RevDur[hotName] then
                    secLeft=ceil(GetTime()-huIcons[tmpIndex[o]]["EXPIRE"])
                else
                    secLeft=floor(huIcons[tmpIndex[o]]["EXPIRE"]-GetTime())
                end
                huIcons[tmpIndex[o]]["ICON"]=i
                HealBot_HoT_UpdateIcon(button, i, secLeft, huIcons, tmpIndex[o])
            end
        end
        for i=hotCount+1,maxIcon do
            if delIndex[i] then
                HealBot_HoT_UpdateIcon(button, i, -1)
            end
        end
    end
end

local function HealBot_HoT_RemoveIcon(button, huIcons, hotID)
    if huIcons[hotID] and huIcons[hotID]["ICON"]>0 then
        HealBot_HoT_UpdateIcon(button, huIcons[hotID]["ICON"], -1, huIcons, hotID)
        huIcons[hotID]=nil
        if button.aura.debuff.iconId and button.aura.debuff.iconId==hotID then
            if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Current_Skin][button.frame]["CLASSONBAR"] and Healbot_Config_Skins.BarText[Healbot_Config_Skins.Current_Skin][button.frame]["CLASSTYPE"]==1 then
                HealBot_Action_SetClassIconTexture(button)
            elseif Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][button.frame]["SHOW"] and HealBot_TargetIcons[button.unit] then 
                HealBot_RaidTargetUpdate(button, nil)
                HealBot_RaidTargetUpdate(button, HealBot_TargetIcons[button.unit])
            end
        else
            HealBot_HoT_RefreshIcons(button) 
        end
    end
end

local function HealBot_HoT_Update(button, hotID)
    local huIcons=HealBot_UnitIcons[button.unit]
    if huIcons[hotID] then
        local _, hotName, sID=string.split("!", hotID)
        local secLeft=-1
        if huIcons[hotID]["EXPIRE"]>10 then
            if HealBot_Globals.HealBot_Custom_Debuffs_RevDur[hotName] then
                secLeft=ceil(GetTime()-huIcons[hotID]["EXPIRE"])
            else
                secLeft=floor(huIcons[hotID]["EXPIRE"]-GetTime())
            end
        end
        if secLeft<0 then
            HealBot_HoT_RemoveIcon(button, huIcons, hotID)
        elseif huIcons[hotID]["ICON"]>0 then
            HealBot_HoT_UpdateIcon(button, huIcons[hotID]["ICON"], secLeft, huIcons, hotID)
        else
            HealBot_HoT_UpdateNoIcon(button, huIcons, hotID, sID, secLeft)
        end
    end
end

function HealBot_setUnitIcons(unit)
    if not HealBot_UnitIcons[unit] then HealBot_UnitIcons[unit]={} end
end

local hbExcludeSpells = { [67358]="Rejuvenating",
                          [58597]="Sacred Shield",
                          --[65148]="Sacred Shield",
                        }
                        
local hbExcludeBuffSpells = { [65148]="Sacred Shield",
                        }
                        
local hbHoTcaster="!";
local hbFoundHoT={}
local hbNoEndTime=GetTime()+604800
local function HealBot_HasMyBuffs(button)
    local xUnit=button.unit
    if UnitExists(xUnit) then
        for x,_ in pairs(hbFoundHoT) do
            hbFoundHoT[x]=nil;
        end
        local k = 1
        local auraData={}
        if not UnitIsFriend("player",xUnit) then
            while true do
                local bName,iTexture,bCount,_,_,expirationTime, caster,_,_,spellID = UnitAura(xUnit, k, "HARMFUL"); 
                if bName and caster and caster=="player" and expirationTime then
                    if not hbExcludeSpells[spellID] then 
                        if (expirationTime or 0)==0 then expirationTime=hbNoEndTime end
                        auraData[spellID]={["NAME"]=bName,["TEXTURE"]=iTexture,["COUNT"]=bCount,["TIME"]=expirationTime,["CASTER"]=caster}
                    end
                    k=k+1
                else
                    break
                end
            end
        else
            while true do
                local bName,iTexture,bCount,_,_,expirationTime, caster,_,_,spellID = UnitAura(xUnit, k, "HELPFUL");
                local uClassTrim = strsub(uClassEN or "XXXX",1,4)
                if not caster then caster=HEALBOT_WORDS_UNKNOWN end
                if bName and caster and expirationTime then
                    if not hbExcludeSpells[spellID] then 
                        local y=HealBot_Watch_HoT[bName] or "nil"
                        if (y=="A" or (y=="S" and caster=="player") or (y=="C" and HealBot_Data["PCLASSTRIM"]==uClassTrim)) then
                            if (expirationTime or 0)==0 then expirationTime=hbNoEndTime end
                            auraData[spellID]={["NAME"]=bName,["TEXTURE"]=iTexture,["COUNT"]=bCount,["TIME"]=expirationTime,["CASTER"]=caster}
                        end
                    end
                    k=k+1
                else
                    break
                end
            end
        end
        for spellID, _ in pairs(auraData) do
            local xGUID=HealBot_UnitGUID(auraData[spellID]["CASTER"]) or "0"
            local hbHoTID=xGUID.."!" ..auraData[spellID]["NAME"].."!"..spellID
            hbFoundHoT[hbHoTID]=true
            if not HealBot_UnitIcons[xUnit][hbHoTID] then HealBot_UnitIcons[xUnit][hbHoTID]={} end
            if not HealBot_UnitIcons[xUnit][hbHoTID]["ICON"] then HealBot_UnitIcons[xUnit][hbHoTID]["ICON"]=0 end
            if not HealBot_UnitIcons[xUnit][hbHoTID]["EXPIRE"] then HealBot_UnitIcons[xUnit][hbHoTID]["EXPIRE"]=auraData[spellID]["TIME"]+1 end
            if auraData[spellID]["COUNT"] and auraData[spellID]["COUNT"]~=(HealBot_UnitIcons[xUnit][hbHoTID]["COUNT"] or -1) then
                HealBot_UnitIcons[xUnit][hbHoTID]["COUNT"]=auraData[spellID]["COUNT"]
                HealBot_UnitIcons[xUnit][hbHoTID]["EXPIRE"]=auraData[spellID]["TIME"]+1
            end    
            if HealBot_UnitIcons[xUnit][hbHoTID]["EXPIRE"]~=auraData[spellID]["TIME"] then
                HealBot_UnitIcons[xUnit][hbHoTID]["EXPIRE"]=auraData[spellID]["TIME"]
                HealBot_UnitIcons[xUnit][hbHoTID]["TEXTURE"]=auraData[spellID]["TEXTURE"]
                HealBot_HoT_Update(button, hbHoTID)
            end
        end
        local huIcons=HealBot_UnitIcons[xUnit]
        if huIcons then
            for buffID, _ in pairs(huIcons) do
                if not hbFoundHoT[buffID] and not huIcons[buffID]["DEBUFF"] then
                    huIcons[buffID]["EXPIRE"]=1
                    if huIcons[buffID]["ICON"]>0 then
                        HealBot_HoT_Update(button, buffID)
                    else
                        huIcons[buffID]=nil
                    end
                end
            end
        end
    end
end

function HealBot_RecalcHeals(button)
    if HealBot_luVars["DoUpdates"] then
        HealBot_Action_Refresh(button);
    else
        HealBot_Action_ResetUnitStatus(button)
    end
end

local function HealBot_Reset_UnitHealth(button)
    if UnitExists(button.unit) then
        local x=UnitHealth(button.unit)
        local y=HealBot_UnitMaxHealth(button.unit)
        if (x~=button.health.current) or (y~=button.health.max) then
            button.health.current=x
            button.health.max=y
            HealBot_Action_setHealthText(button)
            HealBot_Action_UpdateHealthButton(button)
        else
            local ebubar = _G["HealBot_Action_HealUnit"..button.id.."Bar"]
            local bptc=floor((button.health.current/button.health.max)*100)
            if (Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Current_Skin][button.frame]["IC"] == 3) then
                bptc=floor(((button.health.current+button.health.incoming)/button.health.max)*100)
                if bptc>100 then bptc=100 end
            end
            if ebubar:GetValue()~=bptc then 
                HealBot_Action_setHealthText(button)
                HealBot_Action_UpdateHealthButton(button)
            end
        end
    end
end

function HealBot_Reset_Unit(button)
    HealBot_ClearBuff(button)
    HealBot_ClearDebuff(button)
    HealBot_Reset_UnitHealth(button)
    HealBot_ClearUnitAggro(button)
    HealBot_Action_ResetUnitStatus(button)
    if HealBot_Action_RetMyTarget(button.guid) then HealBot_Action_Toggle_Enabled(button); end
end

function HealBot_GetSpellId(spellName)
    if (not spellName) then return nil end
    if HealBot_Spells[spellName] and HealBot_Spells[spellName].known then   
        return HealBot_Spells[spellName].id; 
    end
    return nil;
end

local _

function HealBot_IncHeals_retHealsIn(unit, button)
    if UnitIsEnemy(unit,"player") then
        button.health.incoming=0
        button.health.absorbs=0
    end
    local x=button.health.incoming
    local y=button.health.absorbs
    if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Current_Skin][button.frame]["AC"]<2 then y=0 end
    if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Current_Skin][button.frame]["IC"]<2 then x=0 end
    return x, y
end

local function HealBot_IncHeals_ClearAll()
    for xUnit,xButton in pairs(HealBot_Unit_Button) do
        xButton.health.incoming=0
        xButton.health.absorbs=0
    end
end

local function HealBot_OnEvent_Combat_Log(self, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    if HealBot_UnitData[destGUID] and UnitExists(HealBot_UnitData[destGUID]["UNIT"]) and HealBot_Unit_Button[HealBot_UnitData[destGUID]["UNIT"]] then
        local xButton=HealBot_Unit_Button[HealBot_UnitData[destGUID]["UNIT"]]
        if xButton.status.enemy < 0 then
            if (event == "SWING_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" or event == "SPELL_DAMAGE" or event == "DAMAGE_SPLIT" or
                event == "DAMAGE_SHIELD" or event == "SPELL_HEAL" or event == "SPELL_PERIODIC_HEAL" or event == "ENVIRONMENTAL_DAMAGE" or
                event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then
                if xButton.health.incoming>0 then HealBot_HealsInUpdate(xButton) end
                if xButton.health.absorbs>0 then HealBot_AbsorbsUpdate(xButton) end
                HealBot_Reset_UnitHealth(xButton)
            end
        end
    end
end

function HealBot_OnLoad(self)
    HealBot:RegisterEvent("VARIABLES_LOADED");
    HealBot:RegisterEvent("PLAYER_REGEN_DISABLED");
    HealBot:RegisterEvent("PLAYER_REGEN_ENABLED");
    HealBot:RegisterEvent("GET_ITEM_INFO_RECEIVED");
    SLASH_HEALBOT1 = "/healbot";
    SLASH_HEALBOT2 = "/hb";
    SlashCmdList["HEALBOT"] = function(msg)
        HealBot_SlashCmd(msg);
    end
end

function HealBot_Set_Timers()
    if HealBot_Config.DisabledNow==0 then
        HealBot_Timers["HB1Th"]=HealBot_Comm_round((1+(HealBot_Globals.RangeCheckFreq*4))/(HealBot_luVars["qaFR"]/5), 4) -- At 50FPS with default settings = 0.18
        HealBot_Timers["HB2Th"]=HealBot_Comm_round(HealBot_Globals.RangeCheckFreq/(HealBot_luVars["qaFR"]/4), 4) -- At 50FPS with default settings = 0.016
        HealBot_Timers["HBaTh"]=0.02
    else
        HealBot_Timers["HB1Th"]=1
        HealBot_Timers["HB2Th"]=(HealBot_Globals.RangeCheckFreq*10)
    end
end

local HealBot_Options_Timer={}
function HealBot_setOptions_Timer(value)
    HealBot_luVars["HealBot_Options_Timer"]=value
    HealBot_Options_Timer[value]=true
    if value==500 then HealBot_Timers["HB1Th"]=0.01 end
end

local HealBot_ErrorNum=0
local hbRequestTime=0

local function HealBot_setqaFR()
    HealBot_luVars["tmpFR"]=GetFramerate()
    if HealBot_luVars["tmpFR"]>100 then 
        HealBot_luVars["tmpFR"]=100 
    end
    if (HealBot_luVars["tmpFR"])>HealBot_luVars["maxFR"] then
        HealBot_luVars["qaFR"]=HealBot_Comm_round((HealBot_luVars["tmpFR"]+HealBot_luVars["qaFR1"]+HealBot_luVars["qaFR2"]+HealBot_luVars["qaFR3"]+HealBot_luVars["qaFR4"])/5, 2)
        HealBot_luVars["qaFR1"]=HealBot_luVars["qaFR"]
        HealBot_luVars["qaFR2"]=HealBot_luVars["qaFR1"]
        HealBot_luVars["qaFR3"]=HealBot_luVars["qaFR2"]
        HealBot_luVars["qaFR4"]=HealBot_luVars["qaFR3"]
    end
    HealBot_CheckTime_Modifier()
end

local function HealBot_Update_DefaultSkins()
    local cacheSkinDefaults=HealBot_Options_copyTable(HealBot_Config.SkinDefault)
    HealBot_Config.SkinDefault={}
    for x in pairs (Healbot_Config_Skins.Skins) do
        HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]] = {[HEALBOT_WORD_SOLO]=false, 
                                                                     [HEALBOT_WORD_PARTY]=false, 
                                                                     [HEALBOT_OPTIONS_RAID10]=false, 
                                                                     [HEALBOT_OPTIONS_RAID25]=false, 
                                                                     [HEALBOT_OPTIONS_RAID40]=false,
                                                                     [HEALBOT_WORD_ARENA]=false, 
                                                                     [HEALBOT_WORD_BG10]=false, 
                                                                     [HEALBOT_WORD_BG15]=false, 
                                                                     [HEALBOT_WORD_BG40]=false, 
                                                                     [HEALBOT_WORD_PETBATTLE]=false}
        if cacheSkinDefaults[Healbot_Config_Skins.Skins[x]]==2 then
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_SOLO]=true;
        elseif cacheSkinDefaults[Healbot_Config_Skins.Skins[x]]==3 then
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_PARTY]=true;
        elseif cacheSkinDefaults[Healbot_Config_Skins.Skins[x]]==4 then
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_OPTIONS_RAID10]=true;
        elseif cacheSkinDefaults[Healbot_Config_Skins.Skins[x]]==5 then
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_OPTIONS_RAID25]=true;
        elseif cacheSkinDefaults[Healbot_Config_Skins.Skins[x]]==6 then
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_OPTIONS_RAID40]=true;
        elseif cacheSkinDefaults[Healbot_Config_Skins.Skins[x]]==7 then
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_ARENA]=true;
        elseif cacheSkinDefaults[Healbot_Config_Skins.Skins[x]]==8 then
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_BG10]=true;
        elseif cacheSkinDefaults[Healbot_Config_Skins.Skins[x]]==9 then
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_BG15]=true;
        elseif cacheSkinDefaults[Healbot_Config_Skins.Skins[x]]==10 then
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_BG40]=true;
        elseif cacheSkinDefaults[Healbot_Config_Skins.Skins[x]]==11 then
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_PETBATTLE]=true;
        end
    end
end

local function HealBot_Update_Skins()
    if HealBot_Globals.LastVersionSkinUpdate then
        HealBot_Globals.LastVersionSkinUpdate=nil
    end
    if HealBot_Config.ActionVisible==0 or HealBot_Config.ActionVisible==1 then
        HealBot_Config.ActionVisible={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0,[9]=0,[10]=0}
    end
    local foundSkin=false
    for x in pairs (Healbot_Config_Skins.Skins) do
        if not HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]] then 
            HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]] = {[HEALBOT_WORD_SOLO]=false, 
                                                                         [HEALBOT_WORD_PARTY]=false, 
                                                                         [HEALBOT_OPTIONS_RAID10]=false, 
                                                                         [HEALBOT_OPTIONS_RAID25]=false, 
                                                                         [HEALBOT_OPTIONS_RAID40]=false,
                                                                         [HEALBOT_WORD_ARENA]=false, 
                                                                         [HEALBOT_WORD_BG10]=false, 
                                                                         [HEALBOT_WORD_BG15]=false, 
                                                                         [HEALBOT_WORD_BG40]=false, 
                                                                         [HEALBOT_WORD_PETBATTLE]=false}
        end
        if Healbot_Config_Skins.Skins[x]==Healbot_Config_Skins.Current_Skin then foundSkin=true end
    end
    if not foundSkin then 
        Healbot_Config_Skins.Current_Skin=HEALBOT_SKINS_STD 
        Healbot_Config_Skins.Skin_ID = 1;
    end

    local tMajor, tMinor, tPatch, tHealbot = string.split(".", HealBot_Config.LastVersionSkinUpdate)
    if tonumber(tMajor)<7 then
        HealBot_Options_SetDefaults();
        HealBot_ReloadUI()
    elseif tonumber(tMajor)<8 then

        if not HealBot_Globals.TestBars["PROFILE"] then HealBot_Globals.TestBars["PROFILE"]=3 end
        if not HealBot_Globals.TestBars["ENEMY"] then HealBot_Globals.TestBars["ENEMY"]=2 end
        if not HealBot_Globals.CDCBarColour[HEALBOT_CUSTOM_en.."9"] then HealBot_Globals.CDCBarColour[HEALBOT_CUSTOM_en.."9"]={ R = 0.25, G = 0.10, B = 0.45, } end
		if not HealBot_Globals.CDCBarColour[HEALBOT_CUSTOM_en.."10"] then HealBot_Globals.CDCBarColour[HEALBOT_CUSTOM_en.."10"]={ R = 0.45, G = 0, B = 0.28, } end
        if not HealBot_Globals.CDCBarColour[HEALBOT_CUSTOM_en.."11"] then HealBot_Globals.CDCBarColour[HEALBOT_CUSTOM_en.."11"]={ R = 0.45, G = 0.17, B = 0.14, } end
        if not HealBot_Globals.CDCBarColour[HEALBOT_CUSTOM_en.."12"] then HealBot_Globals.CDCBarColour[HEALBOT_CUSTOM_en.."12"]={ R = 0.45, G = 0.34, B = 0.0, } end
        if not HealBot_Globals.HealBot_Custom_Debuffs[HEALBOT_CUSTOM_CAT_CUSTOM_IMPORTANT] then HealBot_Globals.HealBot_Custom_Debuffs[HEALBOT_CUSTOM_CAT_CUSTOM_IMPORTANT]=9 end
		if not HealBot_Globals.HealBot_Custom_Debuffs[HEALBOT_CUSTOM_CAT_CUSTOM_DAMAGE] then HealBot_Globals.HealBot_Custom_Debuffs[HEALBOT_CUSTOM_CAT_CUSTOM_DAMAGE]=10 end
        if not HealBot_Globals.HealBot_Custom_Debuffs[HEALBOT_CUSTOM_CAT_CUSTOM_EFFECT] then HealBot_Globals.HealBot_Custom_Debuffs[HEALBOT_CUSTOM_CAT_CUSTOM_EFFECT]=11 end
        if not HealBot_Globals.HealBot_Custom_Debuffs[HEALBOT_CUSTOM_CAT_CUSTOM_MISC] then HealBot_Globals.HealBot_Custom_Debuffs[HEALBOT_CUSTOM_CAT_CUSTOM_MISC]=12 end
        if HealBot_Globals.scaleCaliStats then HealBot_Globals.scaleCaliStats=nil end
        if HealBot_Globals.rangeCalibrationWeight then HealBot_Globals.rangeCalibrationWeight=nil end
    
        local hbClassHoTwatchDef=HealBot_GlobalsDefaults.WatchHoT
        for class,x  in pairs(hbClassHoTwatchDef) do
            if not HealBot_Globals.WatchHoT[class] then
                HealBot_Globals.WatchHoT[class]={} 
            end
            local hbClassHoTwatchDefClass=HealBot_Globals.WatchHoT[class]
            for sName,x in pairs(hbClassHoTwatchDefClass) do
                if HealBot_Globals.WatchHoT[class][sName] and HealBot_Globals.WatchHoT[class][sName]==1 then
                    HealBot_Globals.WatchHoT[class][sName]=nil
                end
            end
        end
		HealBot_Globals.OneTimeMsg={}
        
        for x in pairs (Healbot_Config_Skins.Skins) do
            if not Healbot_Config_Skins.EmergIncMonitor[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.EmergIncMonitor[Healbot_Config_Skins.Skins[x]]=1 end
            if not Healbot_Config_Skins.ExtraIncGroup[Healbot_Config_Skins.Skins[x]] then 
                Healbot_Config_Skins.ExtraIncGroup[Healbot_Config_Skins.Skins[x]]={[1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true}
            end           
            if not Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]]={
                [1] = {["NAME"]=HEALBOT_OPTIONS_SELFHEALS_en,["STATE"]=false,["FRAME"]=1}, 
                [2] = {["NAME"]=HEALBOT_OPTIONS_TANKHEALS_en,["STATE"]=true,["FRAME"]=1},
                [3] = {["NAME"]=HEALBOT_CLASSES_HEALERS_en,["STATE"]=false,["FRAME"]=1}, 
                [4] = {["NAME"]=HEALBOT_OPTIONS_GROUPHEALS_en,["STATE"]=true,["FRAME"]=1}, 
                [5] = {["NAME"]=HEALBOT_OPTIONS_MYTARGET_en,["STATE"]=true,["FRAME"]=1}, 
                [6] = {["NAME"]=HEALBOT_FOCUS_en,["STATE"]=false,["FRAME"]=1}, 
                [7] = {["NAME"]=HEALBOT_OPTIONS_EMERGENCYHEALS_en,["STATE"]=true,["FRAME"]=1}, 
                [8] = {["NAME"]=HEALBOT_OPTIONS_PETHEALS_en,["STATE"]=false,["FRAME"]=1},
                [9] = {["NAME"]=HEALBOT_VEHICLE_en,["STATE"]=false,["FRAME"]=1},
               [10] = {["NAME"]=HEALBOT_OPTIONS_TARGETHEALS_en,["STATE"]=false,["FRAME"]=1},
               [11] = {["NAME"]=HEALBOT_CUSTOM_CASTBY_ENEMY_en,["STATE"]=false,["FRAME"]=5},}
            else
                local freeHealGroups={}
                table.insert(freeHealGroups,HEALBOT_OPTIONS_SELFHEALS_en)
                table.insert(freeHealGroups,HEALBOT_OPTIONS_TANKHEALS_en)
                table.insert(freeHealGroups,HEALBOT_CLASSES_HEALERS_en)
                table.insert(freeHealGroups,HEALBOT_OPTIONS_GROUPHEALS_en)
                table.insert(freeHealGroups,HEALBOT_OPTIONS_MYTARGET_en)
                table.insert(freeHealGroups,HEALBOT_FOCUS_en)
                table.insert(freeHealGroups,HEALBOT_OPTIONS_EMERGENCYHEALS_en)
                table.insert(freeHealGroups,HEALBOT_OPTIONS_PETHEALS_en)
                table.insert(freeHealGroups,HEALBOT_VEHICLE_en)
                table.insert(freeHealGroups,HEALBOT_OPTIONS_TARGETHEALS_en)
                table.insert(freeHealGroups,HEALBOT_CUSTOM_CASTBY_ENEMY_en)
                
                for gl=1,11 do
                    if not Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]={} end
                    if Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]["NAME"] then
                        local mti=0
                        for z=1, #freeHealGroups do
                            if Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]["NAME"]==freeHealGroups[z] then
                                mti=z
                            end
                        end
                        if mti>0 then
                            table.remove(freeHealGroups,mti)
                        end
                    end
                end
                for gl=1,11 do
                    if not Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]["NAME"] then
                        Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]["NAME"]=freeHealGroups[1]
                        table.remove(freeHealGroups,1)
                    end
                    if not Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]["STATE"] then Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]["STATE"]=false end
                    if not Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]["FRAME"] then 
                        if Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]["NAME"]==HEALBOT_CUSTOM_CASTBY_ENEMY_en then
                            Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]["FRAME"]=5
                        else
                            Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Skins[x]][gl]["FRAME"]=1 
                        end
                    end
                end
            end
            if not Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.Chat[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.Chat[Healbot_Config_Skins.Skins[x]]={} end
            if not Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]] then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]={} end
            for gl=1,10 do
                if not Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]={} end
                if not Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl] then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]={} end
            end

            for gl=1,10 do
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["TIPLOC"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["TIPLOC"]=5 end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["AUTOCLOSE"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["AUTOCLOSE"]=false end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["OPENSOUND"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["OPENSOUND"]=false end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["LOCKED"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["LOCKED"]=false end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["SCALE"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["SCALE"]=1 end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BACKR"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BACKR"]=0.2 end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BACKG"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BACKG"]=0.2 end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BACKB"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BACKB"]=0.7 end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BACKA"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BACKA"]=0.1 end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BORDERR"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BORDERR"]=0.2 end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BORDERG"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BORDERG"]=0.2 end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BORDERB"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BORDERB"]=0.2 end
                if Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BORDERA"]==nil then Healbot_Config_Skins.Frame[Healbot_Config_Skins.Skins[x]][gl]["BORDERA"]=0.4 end
                if Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["SCALE"]==nil then Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["SCALE"]=0.7 end
                if Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["DURTHRH"]==nil then Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["DURTHRH"]=9 end
                if Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["DURWARN"]==nil then Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["DURWARN"]=3 end
                if Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["SCNT"]==nil then Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["SCNT"]=true end
                if Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["SSCNT"]==nil then Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["SSCNT"]=false end
                if Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["SDUR"]==nil then Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["SDUR"]=true end
                if Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["SSDUR"]==nil then Healbot_Config_Skins.IconText[Healbot_Config_Skins.Skins[x]][gl]["SSDUR"]=true end
                if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["SHOW"]==nil then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["SHOW"]=true end
                if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["STAR"]==nil then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["STAR"]=true end
                if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["CIRCLE"]==nil then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["CIRCLE"]=true end
                if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["DIAMOND"]==nil then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["DIAMOND"]=true end
                if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["TRIANGLE"]==nil then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["TRIANGLE"]=true end
                if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["MOON"]==nil then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["MOON"]=true end
                if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["SQUARE"]==nil then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["SQUARE"]=true end
                if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["CROSS"]==nil then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["CROSS"]=true end
                if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["SKULL"]==nil then Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Skins[x]][gl]["SKULL"]=true end
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["ONBAR"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["ONBAR"]=1 end
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["DOUBLE"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["DOUBLE"]=false end
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SHOWDEBUFF"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SHOWDEBUFF"]=true end
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SHOWRC"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SHOWRC"]=true end
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SHOWDIR"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SHOWDIR"]=true end
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SHOWDIRMOUSE"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SHOWDIRMOUSE"]=false end
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SCALE"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SCALE"]=0.7 end
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["I15EN"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["I15EN"]=true end
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SHOWBUFF"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["SHOWBUFF"]=true end
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["POSITION"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["POSITION"]=2 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["ER"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["ER"]=1 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["EG"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["EG"]=1 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["EB"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["EB"]=0 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["EA"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["EA"]=1 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["DR"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["DR"]=0.5 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["DG"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["DG"]=0.5 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["DB"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["DB"]=0.5 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["DA"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["DA"]=0.4 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["CR"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["CR"]=1 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["CG"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["CG"]=1 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["CB"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["CB"]=1 end
                if Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["CA"]==nil then Healbot_Config_Skins.BarTextCol[Healbot_Config_Skins.Skins[x]][gl]["CA"]=1 end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["FONT"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["FONT"]=HealBot_Default_Font end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["HEIGHT"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["HEIGHT"]=10 end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["CLASSTYPE"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["CLASSTYPE"]=1 end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["SHOWROLE"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["SHOWROLE"]=true end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["CLASSONBAR"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["CLASSONBAR"]=false end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["NAMEONBAR"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["NAMEONBAR"]=true end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["HLTHONBAR"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["HLTHONBAR"]=true end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["CLASSCOL"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["CLASSCOL"]=false end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["ALIGN"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["ALIGN"]=2 end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["DOUBLE"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["DOUBLE"]=true end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["INCHEALS"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["INCHEALS"]=2 end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["NUMFORMAT1"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["NUMFORMAT1"]=1 end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["NUMFORMAT2"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["NUMFORMAT2"]=1 end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["OUTLINE"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["OUTLINE"]=1 end
                if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["HLTHTYPE"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["HLTHTYPE"]=1 end
                if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["IC"]==nil then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["IC"]=4 end
                if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["IR"]==nil then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["IR"]=0.2 end
                if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["IG"]==nil then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["IG"]=1 end
                if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["IB"]==nil then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["IB"]=0.2 end
                if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["IA"]==nil then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["IA"]=0.82 end
                if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["AC"]==nil then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["AC"]=3 end
                if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["AR"]==nil then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["AR"]=1 end
                if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["AG"]==nil then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["AG"]=1 end
                if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["AB"]==nil then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["AB"]=1 end
                if Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["AA"]==nil then Healbot_Config_Skins.BarIACol[Healbot_Config_Skins.Skins[x]][gl]["AA"]=0.78 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["HLTH"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["HLTH"]=1 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BACK"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BACK"]=1 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["HR"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["HR"]=0.4 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["HG"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["HG"]=0.7 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["HB"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["HB"]=0.7 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["HA"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["HA"]=1 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["ORA"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["ORA"]=0.4 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["DISA"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["DISA"]=0.1 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BR"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BR"]=0.4 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BG"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BG"]=0.7 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BB"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BB"]=0.7 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BA"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BA"]=0 end
                if Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BOUT"]==nil then Healbot_Config_Skins.BarCol[Healbot_Config_Skins.Skins[x]][gl]["BOUT"]=1 end
                if Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["OUTLINE"]==nil then Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["OUTLINE"]=1 end
                if Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["FONT"]==nil then Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["FONT"]=HealBot_Default_Font end
                if Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["HEIGHT"]==nil then Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["HEIGHT"]=9 end
                if Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["R"]==nil then Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["R"]=1 end
                if Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["G"]==nil then Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["G"]=1 end
                if Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["B"]==nil then Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["B"]=0.1 end
                if Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["A"]==nil then Healbot_Config_Skins.HeadText[Healbot_Config_Skins.Skins[x]][gl]["A"]=0.7 end
                if Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["SHOW"]==nil then Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["SHOW"]=false end
                if Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["TEXTURE"]==nil then Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["TEXTURE"]=HealBot_Default_Textures[10].name end
                if Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["WIDTH"]==nil then Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["WIDTH"]=0.7 end
                if Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["HEIGHT"]==nil then Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["HEIGHT"]=0.5 end
                if Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["R"]==nil then Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["R"]=0.1 end
                if Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["G"]==nil then Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["G"]=0.7 end
                if Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["B"]==nil then Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["B"]=0.1 end
                if Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["A"]==nil then Healbot_Config_Skins.HeadBar[Healbot_Config_Skins.Skins[x]][gl]["A"]=0.4 end
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["CMARGIN"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["CMARGIN"]=2 end 
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["POWERSIZE"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["POWERSIZE"]=0 end 
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["AGGROSIZE"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["AGGROSIZE"]=2 end
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["GRPCOLS"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["GRPCOLS"]=false end
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["POWERCNT"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["POWERCNT"]=true end
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["TEXTURE"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["TEXTURE"]=HealBot_Default_Textures[8].name end
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["TEXTURE"]=="Empty" then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["TEXTURE"]="Smooth" end
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["HEIGHT"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["HEIGHT"]=25 end
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["WIDTH"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["WIDTH"]=144 end
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["NUMCOLS"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["NUMCOLS"]=2 end
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["RMARGIN"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["RMARGIN"]=1 end
                if Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["OFIX"]==nil then Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Skins[x]][gl]["OFIX"]=1 end
                if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["FRAME"]==nil then Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["FRAME"]=1 end
                if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["BARS"]==nil then Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["BARS"]=1 end
                if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["GROW"]==nil then Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["GROW"]=2 end
                if Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["NAME"]==nil then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["NAME"]="" end
                if Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["SHOW"]==nil then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["SHOW"]=false end
                if Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["FONT"]==nil then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["FONT"]=HealBot_Default_Font end
                if Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["SIZE"]==nil then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["SIZE"]=12 end
                if Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["OUTLINE"]==nil then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["OUTLINE"]=1 end
                if Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["OFFSET"]==nil then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["OFFSET"]=10 end
                if Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["R"]==nil then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["R"]=1 end
                if Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["G"]==nil then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["G"]=1 end
                if Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["B"]==nil then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["B"]=1 end
                if Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["A"]==nil then Healbot_Config_Skins.FrameAlias[Healbot_Config_Skins.Skins[x]][gl]["A"]=1 end
                if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["Y"]==nil then Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["Y"]=(49+gl) end
                if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["X"]==nil then Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["X"]=(49+gl) end
                if Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["Y"]>100 or Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["X"]>100 then
                    local Y=HealBot_Comm_round(((Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["Y"]/GetScreenHeight())*100),2)
                    local X=HealBot_Comm_round(((Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["X"]/GetScreenWidth())*100),2)
                    Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["Y"]=Y
                    Healbot_Config_Skins.Anchors[Healbot_Config_Skins.Skins[x]][gl]["X"]=X
                end
            end

            if Healbot_Config_Skins.Author[Healbot_Config_Skins.Skins[x]]==nil then Healbot_Config_Skins.Author[Healbot_Config_Skins.Skins[x]] = HEALBOT_WORDS_UNKNOWN end
            if Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]["STATE"]==nil then Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]["STATE"]=false end
            if Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]["INCTANK"]==nil then Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]["INCTANK"]=false end
            if Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]["INCGROUP"]==nil then Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]["INCGROUP"]=false end
            if Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]["INCFOCUS"]==nil then Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]["INCFOCUS"]=false end
            if Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]["INCMYTARGETS"]==nil then Healbot_Config_Skins.BarsHide[Healbot_Config_Skins.Skins[x]]["INCMYTARGETS"]=false end
            if Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]["CRASH"]==nil then Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]["CRASH"]=false end
            if Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]["GENERALMACRO"]==nil then Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]["GENERALMACRO"]=false end
            if Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]["COMBAT"]==nil then Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]["COMBAT"]=false end
            if Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]["COMBATPARTY"]==nil then Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]["COMBATPARTY"]=1 end
            if Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]["COMBATRAID"]==nil then Healbot_Config_Skins.Protection[Healbot_Config_Skins.Skins[x]]["COMBATRAID"]=2 end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["ALERT"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["ALERT"]=3 end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["ALERTIND"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["ALERTIND"]=2 end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["R"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["R"]=1 end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["G"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["G"]=0 end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["B"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["B"]=0 end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["MAXA"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["MAXA"]=1 end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["MINA"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["MINA"]=0.2 end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["FREQ"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["FREQ"]=0.03 end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOWIND"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOWIND"]=true end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOW"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOW"]=true end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOWBARS"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOWBARS"]=true end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOWTEXT"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOWTEXT"]=false end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOWBARSPCT"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOWBARSPCT"]=false end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOWTEXTPCT"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["SHOWTEXTPCT"]=true end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["TEXTFORMAT"]==nil then Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Skins[x]]["TEXTFORMAT"]=3 end
            if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["CBAR"]==nil then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["CBAR"]=true end
            if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["CBARCOMBAT"]==nil then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["CBARCOMBAT"]=false end
            if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["TBAR"]==nil then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["TBAR"]=false end
            if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["TBARCOMBAT"]==nil then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["TBARCOMBAT"]=false end
            if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["CR"]==nil then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["CR"]=1 end
            if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["CG"]==nil then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["CG"]=1 end
            if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["CB"]==nil then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["CB"]=0.7 end
            if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["TR"]==nil then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["TR"]=0.8 end
            if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["TG"]==nil then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["TG"]=0.8 end
            if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["TB"]==nil then Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Skins[x]]["TB"]=0.7 end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["ALERTIC"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["ALERTIC"]=1 end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["ALERTOC"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["ALERTOC"]=0.95 end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["GROUPPETS"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["GROUPPETS"]=true end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["SELFPET"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["SELFPET"]=0 end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TINCSELF"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TINCSELF"]=false end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TINCGROUP"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TINCGROUP"]=true end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TINCRAID"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TINCRAID"]=true end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TINCPET"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TINCPET"]=false end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TALWAYSSHOW"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TALWAYSSHOW"]=false end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["FALWAYSSHOW"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["FALWAYSSHOW"]=false end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TONLYFRIEND"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["TONLYFRIEND"]=false end
            if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["FONLYFRIEND"]==nil then Healbot_Config_Skins.Healing[Healbot_Config_Skins.Skins[x]]["FONLYFRIEND"]=false end
            if Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["HIDEPARTYF"]==nil then Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["HIDEPARTYF"]=false end
            if Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["HIDEPTF"]==nil then Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["HIDEPTF"]=false end
            if Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["HIDEBOSSF"]==nil then Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["HIDEBOSSF"]=false end
            if Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["HIDERAIDF"]==nil then Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["HIDERAIDF"]=true end
            if Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["FLUIDBARS"]==nil then Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["FLUIDBARS"]=false end
            if Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["FLUIDFREQ"]==nil then Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["FLUIDFREQ"]=3 end
            if Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["LOWMANA"]==nil then Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["LOWMANA"]=2 end
            if Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["LOWMANACOMBAT"]==nil then Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["LOWMANACOMBAT"]=true end
            if Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["RAIDORDER"]==nil then Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["RAIDORDER"]=3 end
            if Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBORDER"]==nil then Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBORDER"]=5 end
            if Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBIG"]==nil then Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBIG"]=true end
            if Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBIP"]==nil then Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBIP"]=true end
            if Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBIV"]==nil then Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBIV"]=true end
            if Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBIT"]==nil then Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBIT"]=true end
            if Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBIMT"]==nil then Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBIMT"]=false end
            if Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBPF"]==nil then Healbot_Config_Skins.Sort[Healbot_Config_Skins.Skins[x]]["SUBPF"]=true end
            if Healbot_Config_Skins.Chat[Healbot_Config_Skins.Skins[x]]["NOTIFY"]==nil then Healbot_Config_Skins.Chat[Healbot_Config_Skins.Skins[x]]["NOTIFY"]=1 end
            if Healbot_Config_Skins.Chat[Healbot_Config_Skins.Skins[x]]["CHAN"]==nil then Healbot_Config_Skins.Chat[Healbot_Config_Skins.Skins[x]]["CHAN"]="" end
            if Healbot_Config_Skins.Chat[Healbot_Config_Skins.Skins[x]]["MSG"]==nil then Healbot_Config_Skins.Chat[Healbot_Config_Skins.Skins[x]]["MSG"]=HEALBOT_NOTIFYOTHERMSG end
            if Healbot_Config_Skins.Chat[Healbot_Config_Skins.Skins[x]]["RESONLY"]==nil then Healbot_Config_Skins.Chat[Healbot_Config_Skins.Skins[x]]["RESONLY"]=true end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCSELF"]==nil then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCSELF"]=false end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCTANKS"]==nil then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCTANKS"]=true end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCMYTAR"]==nil then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCMYTAR"]=false end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCARENA"]==nil then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCARENA"]=true end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCARENAPETS"]==nil then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCARENAPETS"]=false end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["NUMBOSS"]==nil then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["NUMBOSS"]=2 end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["HIDE"]==nil then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["HIDE"]=true end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["EXISTSHOWPTAR"]==nil then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["EXISTSHOWPTAR"]=false end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["EXISTSHOWBOSS"]==nil then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["EXISTSHOWBOSS"]=true end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["EXISTSHOWARENA"]==nil then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["EXISTSHOWARENA"]=true end
			if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCDPS"] then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["INCDPS"]=nil end
            if Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["FRAME"] then Healbot_Config_Skins.Enemy[Healbot_Config_Skins.Skins[x]]["FRAME"]=nil end
        end

        if HealBot_Globals.mapScale then HealBot_Globals.mapScale=nil end
        HealBot_Update_DefaultSkins()
    elseif HealBot_Config.LastVersionSkinUpdate~=HEALBOT_VERSION then   
        if tonumber(tMajor)<9 and tonumber(tMinor)<1 and tonumber(tPatch)<2 and tonumber(tHealbot)<5 then
            HealBot_Update_DefaultSkins()
        end
        if tonumber(tMajor)<9 and tonumber(tMinor)<1 and tonumber(tPatch)<2 and tonumber(tHealbot)<7 then
            for x in pairs (Healbot_Config_Skins.Skins) do
                for gl=1,10 do
                    if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["FADE"]==nil then Healbot_Config_Skins.Icons[Healbot_Config_Skins.Skins[x]][gl]["FADE"]=true end
                end
            end
        end
        if tonumber(tMajor)<9 and tonumber(tMinor)<1 and tonumber(tPatch)<2 and tonumber(tHealbot)<9 then
            for x in pairs (Healbot_Config_Skins.Skins) do
                local y=floor(Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["FLUIDFREQ"])
                Healbot_Config_Skins.General[Healbot_Config_Skins.Skins[x]]["FLUIDFREQ"]=y
            end
        end
        if tonumber(tMajor)<9 and tonumber(tMinor)<1 and tonumber(tPatch)<2 and tonumber(tHealbot)<10 then
            for x in pairs (Healbot_Config_Skins.Skins) do
                for gl=1,10 do
                    if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["MAXCHARS"]==nil then Healbot_Config_Skins.BarText[Healbot_Config_Skins.Skins[x]][gl]["MAXCHARS"]=0 end
                end
            end
        end
        --if tonumber(tMajor)<9 and tonumber(tMinor)<1 and tonumber(tPatch)<2 and tonumber(tHealbot)<next-version-allow-for-beta then
        --    HealBot_Options_ResetSetting("CUSTOM")
        --end
        if HealBot_Globals.mapScale then HealBot_Globals.mapScale=nil end
    end
    
    if HealBot_Config.CurrentSpec==9 then
        HealBot_Config.CurrentSpec=1
        HealBot_Update_SpellCombos()
        HealBot_Update_BuffsForSpec()
    end
    
    HealBot_Config.LastVersionSkinUpdate=HEALBOT_VERSION
    HealBot_Config.Version=HEALBOT_VERSION
end

local function HealBot_OnEvent_VariablesLoaded(self)
    HealBot_globalVars()
    HealBot_Lang_InitVars()
    HealBot_Data_InitVars()
    HealBot_InitVars()
    HealBot_Options_InitVars()
    HealBot_Options_setLists()
    table.foreach(HealBot_ConfigDefaults, function (key,val)
        if HealBot_Config[key]==nil then
            HealBot_Config[key] = val;
        end
    end);
    table.foreach(HealBot_GlobalsDefaults, function (key,val)
        if HealBot_Globals[key]==nil then
            HealBot_Globals[key] = val;
        end
    end);
    table.foreach(HealBot_Config_SkinsDefaults, function (key,val)
        if Healbot_Config_Skins[key]==nil then
            Healbot_Config_Skins[key] = val;
        end
    end);
    table.foreach(HealBot_Config_SpellsDefaults, function (key,val)
        if HealBot_Config_Spells[key]==nil then
            HealBot_Config_Spells[key] = val;
        end
    end);
    table.foreach(HealBot_Config_BuffsDefaults, function (key,val)
        if HealBot_Config_Buffs[key]==nil then
            HealBot_Config_Buffs[key] = val;
        end
    end);
    table.foreach(HealBot_Config_CuresDefaults, function (key,val)
        if HealBot_Config_Cures[key]==nil then
            HealBot_Config_Cures[key] = val;
        end
    end);
    
    local pClass, pClassEN=UnitClass("player")
    HealBot_Data["PCLASSTRIM"]=strsub(pClassEN,1,4)
    
    HealBot_customTempUserName=HealBot_Options_copyTable(HealBot_Globals.HealBot_customPermUserName)
    HealBot_Update_Skins()  

    if HealBot_Globals.localLang then
        HealBot_Options_Lang(HealBot_Globals.localLang)
    elseif strsub(GetLocale(),1,2)~="en" then
        HealBot_Options_Lang(GetLocale())
    end
    HealBot_Options_setClassEn()
    
    if HealBot_Config.Profile==2 then
        HealBot_Options_hbProfile_setClass()
    end
    HealBot_Init_Spells_Defaults();
    local pRace, pRaceEN=UnitRace("player")
    HealBot_Data["PRACE_EN"]=pRaceEN
    HealBot_Data["PNAME"]=UnitName("player")
    HealBot_Data["PLEVEL"]=UnitLevel("player")
    C_ChatInfo.RegisterAddonMessagePrefix("HealBot")
    HealBot_Options_InitBuffClassList()
    HealBot_setOptions_Timer(5)
    HealBot_Vers[HealBot_Data["PNAME"]]=HEALBOT_VERSION

    local HEALBOT_STATS_ID = 1 --RAID_BUFF_1 --Stats
    local HEALBOT_STAMINA_ID = 2 --RAID_BUFF_2 --Stamina
    local HEALBOT_ATTACK_POWER_ID = 3 --RAID_BUFF_3 --Attack Power
    local HEALBOT_HASTE_ID = 4 --RAID_BUFF_4 --Haste
    local HEALBOT_SPELL_POWER_ID = 5 --RAID_BUFF_5 --Spell Power
    local HEALBOT_CRITICAL_STRIKE_ID = 6 --RAID_BUFF_6 --Critical Strike
    local HEALBOT_MASTERY_ID = 7 --RAID_BUFF_7 --Mastery
    local HEALBOT_MULTISTRIKE_ID = 8 --RAID_BUFF_8 --Multistrike
    local HEALBOT_VERSATILITY_ID = 9 --RAID_BUFF_9 --Versatility
    
    HealBot_BuffNameTypes = {
        -- Death Knight
        [HEALBOT_HORN_OF_WINTER] = {HEALBOT_ATTACK_POWER_ID},
        [HEALBOT_POWER_OF_THE_GRAVE] = {HEALBOT_MASTERY_ID},
        [HEALBOT_UNHOLY_AURA] = {HEALBOT_HASTE_ID, HEALBOT_VERSATILITY_ID},
        -- Druid
        [HEALBOT_MARK_OF_THE_WILD] = {HEALBOT_STATS_ID, HEALBOT_VERSATILITY_ID},
        [HEALBOT_MOONKIN_AURA] = {HEALBOT_MASTERY_ID},
        [HEALBOT_LEADER_OF_THE_PACK] = {HEALBOT_CRITICAL_STRIKE_ID},
        -- Hunter
        [HEALBOT_TRUESHOT_AURA] = {HEALBOT_ATTACK_POWER_ID},
        [HEALBOT_LW_FORTITUDE_OF_THE_BEAR] = {HEALBOT_STAMINA_ID},
        [HEALBOT_LW_POWER_OF_THE_PRIMATES] = {HEALBOT_STATS_ID},
        [HEALBOT_LW_WISDOM_OF_THE_SERPENT] = {HEALBOT_SPELL_POWER_ID},
        [HEALBOT_LW_GRACE_OF_THE_CAT] = {HEALBOT_MASTERY_ID},
        [HEALBOT_LW_HASTE_OF_THE_HYENA] = {HEALBOT_HASTE_ID},
        [HEALBOT_LW_FEROCITY_OF_THE_RAPTOR] = {HEALBOT_CRITICAL_STRIKE_ID},
        [HEALBOT_LW_QUICKNESS_OF_THE_DRAGONHAWK] = {HEALBOT_MULTISTRIKE_ID},
        [HEALBOT_LW_VERSATILITY_OF_THE_RAVAGER] = {HEALBOT_VERSATILITY_ID},
        -- Hunter Pets
        [HEALBOT_BARK_OF_THE_WILD] = {HEALBOT_STATS_ID},
        [HEALBOT_BLESSING_OF_KONGS] = {HEALBOT_STATS_ID},
        [HEALBOT_EMBRACE_OF_THE_SHALE_SPIDER] = {HEALBOT_STATS_ID, HEALBOT_CRITICAL_STRIKE_ID},
        [HEALBOT_STRENGTH_OF_THE_EARTH] = {HEALBOT_STATS_ID, HEALBOT_VERSATILITY_ID},
        [HEALBOT_INVIGORATING_ROAR] = {HEALBOT_STAMINA_ID},
        [HEALBOT_STURDINESS] = {HEALBOT_STAMINA_ID},
        [HEALBOT_SAVAGE_VIGOR] = {HEALBOT_STAMINA_ID, HEALBOT_HASTE_ID},
        [HEALBOT_QIRAJI_FORTITUDE] = {HEALBOT_STAMINA_ID, HEALBOT_SPELL_POWER_ID},
        [HEALBOT_SERPENTS_CUNNING] = {HEALBOT_SPELL_POWER_ID},
        [HEALBOT_STILL_WATER] = {HEALBOT_SPELL_POWER_ID, HEALBOT_CRITICAL_STRIKE_ID},
        [HEALBOT_ROAR_OF_COURAGE] = {HEALBOT_MASTERY_ID},
        [HEALBOT_KEEN_SENSES] = {HEALBOT_MASTERY_ID},
        [HEALBOT_SPIRIT_BEAST_BLESSING] = {HEALBOT_MASTERY_ID},
        [HEALBOT_PLAINSWALKING] = {HEALBOT_MASTERY_ID},
        [HEALBOT_CACKLING_HOWL] = {HEALBOT_HASTE_ID},
        [HEALBOT_ENERGIZING_SPORES] = {HEALBOT_HASTE_ID},
        [HEALBOT_SPEED_OF_THE_SWARM] = {HEALBOT_HASTE_ID},
        [HEALBOT_TERRIFYING_ROAR] = {HEALBOT_CRITICAL_STRIKE_ID},
        [HEALBOT_FEARLESS_ROAR] = {HEALBOT_CRITICAL_STRIKE_ID},
        [HEALBOT_STRENGTH_OF_THE_PACK] = {HEALBOT_CRITICAL_STRIKE_ID},
        [HEALBOT_FURIOUS_HOWL] = {HEALBOT_CRITICAL_STRIKE_ID},
        [HEALBOT_SONIC_FOCUS] = {HEALBOT_MULTISTRIKE_ID},
        [HEALBOT_WILD_STRENGTH] = {HEALBOT_MULTISTRIKE_ID, HEALBOT_VERSATILITY_ID},
        [HEALBOT_DOUBLE_BITE] = {HEALBOT_MULTISTRIKE_ID},
        [HEALBOT_SPRY_ATTACKS] = {HEALBOT_MULTISTRIKE_ID},
        [HEALBOT_BREATH_OF_THE_WINDS] = {HEALBOT_MULTISTRIKE_ID},
        [HEALBOT_TENACITY] = {HEALBOT_VERSATILITY_ID},
        [HEALBOT_INDOMITABLE] = {HEALBOT_VERSATILITY_ID},
        [HEALBOT_DEFENSIVE_QUILLS] = {HEALBOT_VERSATILITY_ID},
        [HEALBOT_CHITINOUS_ARMOR] = {HEALBOT_VERSATILITY_ID},
        [HEALBOT_GRACE] = {HEALBOT_VERSATILITY_ID},
        -- Mage
        [HEALBOT_ARCANE_BRILLIANCE] = {HEALBOT_SPELL_POWER_ID, HEALBOT_CRITICAL_STRIKE_ID},
        [HEALBOT_DALARAN_BRILLIANCE] = {HEALBOT_SPELL_POWER_ID, HEALBOT_CRITICAL_STRIKE_ID},
        -- Monk
        [HEALBOT_LEGACY_EMPEROR] = {HEALBOT_STATS_ID},
        [HEALBOT_LEGACY_WHITETIGER] = {HEALBOT_STATS_ID, HEALBOT_CRITICAL_STRIKE_ID},
        [HEALBOT_WINDFLURRY] = {HEALBOT_MULTISTRIKE_ID},
        -- Paladin
        [HEALBOT_BLESSING_OF_KINGS] = {HEALBOT_STATS_ID},
        [HEALBOT_BLESSING_OF_MIGHT] = {HEALBOT_MASTERY_ID},
        [HEALBOT_SANCTITY_AURA] = {HEALBOT_VERSATILITY_ID},
        -- Priest
        [HEALBOT_POWER_WORD_FORTITUDE] = {HEALBOT_STAMINA_ID},
        [HEALBOT_MIND_QUICKENING] = {HEALBOT_HASTE_ID, HEALBOT_MULTISTRIKE_ID},
        -- Warlock
        [HEALBOT_BLOOD_PACT] = {HEALBOT_STAMINA_ID},
        [HEALBOT_DARK_INTENT] = {HEALBOT_SPELL_POWER_ID, HEALBOT_MULTISTRIKE_ID},
        -- Warrior
        [HEALBOT_COMMANDING_SHOUT] = {HEALBOT_STAMINA_ID},
        [HEALBOT_BATTLE_SHOUT] = {HEALBOT_ATTACK_POWER_ID},
        [HEALBOT_INSPIRING_PRESENCE] = {HEALBOT_VERSATILITY_ID},
        -- Rogue
        [HEALBOT_SWIFTBLADES_CUNNING] = {HEALBOT_HASTE_ID, HEALBOT_MULTISTRIKE_ID},
        -- Shaman
        [HEALBOT_GRACE_OF_AIR] = {HEALBOT_MASTERY_ID, HEALBOT_HASTE_ID},
    }
    
    if HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_PRIEST] then
        HealBot_ShortBuffs[HEALBOT_LEVITATE]=true
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_DRUID] then
        -- short buffs
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_PALADIN] then
        HealBot_ShortBuffs[HEALBOT_BEACON_OF_LIGHT]=true
        HealBot_ShortBuffs[HEALBOT_SACRED_SHIELD]=true
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_MONK] then
        -- short buffs
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_WARRIOR] then
        -- short buffs
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_MAGE] then
        HealBot_ShortBuffs[HEALBOT_ICE_WARD]=true
	elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_WARLOCK] then
        -- short buffs
	elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_DEATHKNIGHT] then
		HealBot_ShortBuffs[HEALBOT_HORN_OF_WINTER]=true
	elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_HUNTER] then
        -- short buffs
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_SHAMAN] then
        -- short buffs
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_ROGUE] then
        -- short buffs
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_DEMONHUNTER] then
        -- short buffs
    end

    HealBot:RegisterEvent("PLAYER_ENTERING_WORLD");
    HealBot:RegisterEvent("PLAYER_LEAVING_WORLD");
    HealBot_luVars["hbLoaded"]=true
    g=_G["HealBot_SkinsSubFrameSelectHealRaidFrameb"]
    g:LockHighlight()
    HealBot_Options_Init(11)
    HealBot_Action_SetResSpells()
end

local function HealBot_OnEvent_ItemInfoReceived(self)
    local allInfoReceived = true
    if HEALBOT_ORALIUS_WHISPERING_CRYSTAL=="--Oralius' Whispering Crystal" then
        HEALBOT_ORALIUS_WHISPERING_CRYSTAL = GetItemInfo(118922) or "--Oralius' Whispering Crystal"
        allInfoReceived = false
    end
    if HEALBOT_EVER_BLOOMING_FROND=="--Ever-Blooming Frond" then
        HEALBOT_EVER_BLOOMING_FROND = GetItemInfo(118935) or "--Ever-Blooming Frond"
        allInfoReceived = false
    end
    if HEALBOT_REPURPOSED_FEL_FOCUSER=="--Repurposed Fel Focuser" then
        HEALBOT_REPURPOSED_FEL_FOCUSER = GetItemInfo(147707) or "--Repurposed Fel Focuser"
        allInfoReceived = false
    end
    if allInfoReceived then
        HealBot:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
        HealBot_OnEvent_VariablesLoaded(self)
        HealBot_AddDebug("Oralius Whispering Crystal Found")
    else
        HealBot_Options_InitBuffList()
        HealBot_AddDebug("Oralius Whispering Crystal NOT Found")
    end
end

local function HealBot_OnEvent_RaidRosterUpdate()
    HealBot_Data["REFRESH"]=true;
end

local function HealBot_CheckLowMana(unit)
    if unit then
        HealBot_Action_CheckUnitLowMana(unit)
    else
        for xGUID,xUnit in pairs(hbManaPlayers) do
            local xButton=HealBot_Unit_Button[xUnit]
            if xButton and xGUID==xButton.guid then
                HealBot_Action_CheckUnitLowMana(xUnit)
            else
                hbManaPlayers[xGUID]=nil
            end
        end
    end
end

local function HealBot_SetAggro(unit)
    local xButton = HealBot_Unit_Button[unit]
    if xButton then
        local z, y=HealBot_CalcThreat(unit)
        local x=y+z
        if x>0 then 
            HealBot_Action_UpdateAggro(unit,true,y,z) 
        end
    end
end

local function HealBot_OnEvent_UnitMana(unit)
    local xUnit,_,xButton = HealBot_UnitID(unit)
    if xUnit and xButton.status.enemy < 0 then
        xButton.mana.current=UnitPower(xUnit, 0)
        xButton.mana.max=UnitPowerMax(xUnit, 0)
        if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["LOWMANA"]>1 then
            HealBot_CheckLowMana(xUnit)
        end
        HealBot_Action_SetBar3Value(xButton)
    end
end

local function HealBot_GetTalentInfo(hbGUID, unit)

    if HealBot_UnitData[hbGUID] then
        local s,r,i=nil,nil,nil
        if hbGUID==HealBot_Data["PGUID"] then
            i = GetSpecialization()
            if i then
                _, s, _, _, _, r = GetSpecializationInfo(i,false,false) 
                if HealBot_Config.CurrentSpec~=i or HealBot_Data["PLEVEL"]~=UnitLevel("player") then 
                    HealBot_Config.CurrentSpec=i 
                    HealBot_Data["PLEVEL"]=UnitLevel("player")
                    HealBot_InitSpells()
                    HealBot_Options_ResetDoInittab(50)
                    HealBot_Options_ResetDoInittab(40)
                    HealBot_Options_ResetDoInittab(10)
                    HealBot_Options_ResetDoInittab(5)
                    HealBot_Options_ResetDoInittab(4)
                    HealBot_setHbStanceBuffs()
                    HealBot_Options_setDebuffTypes()
                    HealBot_setOptions_Timer(5)
                    HealBot_setOptions_Timer(15)
                    HealBot_setOptions_Timer(40)
                    HealBot_setOptions_Timer(50)
                    HealBot_ClearAllBuffs()
                    HealBot_ClearAllDebuffs()
                    HealBot_setOptions_Timer(400)
                    HealBot_setOptions_Timer(10)
                    HealBot_Action_setpcClass()
                end
            end
        else
            i = GetInspectSpecialization(unit)
            if i then
                _, s, _, _, _, r = GetSpecializationInfoByID(i) 
            end
        end
        if s and HealBot_UnitData[hbGUID] then
            HealBot_UnitData[hbGUID]["SPEC"] = s.." " 
            if r and r=="TANK" or r=="HEALER" or r=="DAMAGER" then
                HealBot_UnitData[hbGUID]["ROLE"] = r
            end
            if HealBot_Data["TIPUSE"] then HealBot_talentSpam(hbGUID,"update",0) end
        end
    end
end

local function HealBot_SetAddonComms()
    if not HealBot_luVars["inBG"] then
        if GetNumGroupMembers()>5 then
            HealBot_luVars["AddonMsgType"]=2;
        elseif GetNumGroupMembers()>0 then
            HealBot_luVars["AddonMsgType"]=3;
        else
            HealBot_luVars["AddonMsgType"]=4;
        end
    else
        HealBot_luVars["AddonMsgType"]=1;
    end
end

local function HealBot_Options_Update()
    if HealBot_Options_Timer[150] then
        HealBot_Options_Timer[150]=nil
        HealBot_Action_ResetSkin("init")
    elseif HealBot_Options_Timer[5] then
        HealBot_Options_Timer[5]=nil
        if HEALBOT_ORALIUS_WHISPERING_CRYSTAL=="--Oralius' Whispering Crystal" or HEALBOT_REPURPOSED_FEL_FOCUSER=="--Repurposed Fel Focuser" then 
            HealBot_OnEvent_ItemInfoReceived() 
        else
            HealBot_Options_InitBuffList()
        end
    elseif HealBot_Options_Timer[10] then
        HealBot_Options_Timer[10]=nil
        if HealBot_Config_Buffs.NoAuraWhenRested and not IsResting() then HealBot_CheckAllBuffs() end
    elseif HealBot_Options_Timer[15] then
        HealBot_Options_Timer[15]=nil
        HealBot_Options_ComboClass_Text()
    elseif  HealBot_Options_Timer[405] then
        HealBot_Options_Timer[405]=nil
        HealBot_MountsPets_InitUse()
    elseif  HealBot_Options_Timer[410] then
        HealBot_Options_Timer[410]=nil
        HealBot_MountsPets_InitMount()
    elseif HealBot_Options_Timer[20] then
        HealBot_Options_Timer[20]=nil
        HealBot_CheckAllDebuffs()
    elseif HealBot_Options_Timer[25] then
        HealBot_Options_Timer[25]=nil
        if HealBot_Globals.HealBot_Enable_MouseWheel then
            for i=1, 10 do
                local g = _G["f"..i.."_HealBot_Action"]
                g:EnableMouseWheel(1)  
                g:SetScript("OnMouseWheel", function(self, delta)
                    HealBot_Action_HealUnit_Wheel(self, delta)
                end)
            end
        end
    elseif HealBot_Options_Timer[30] then
        HealBot_Options_Timer[30]=nil
        HealBot_CheckAllBuffs()
    elseif HealBot_Options_Timer[40] then
        HealBot_Options_Timer[40]=nil
        HealBot_Options_BuffDebuff_Reset("buff")
        HealBot_Options_ResetDoInittab(5)
    elseif HealBot_Options_Timer[50] then
        HealBot_Options_Timer[50]=nil
        HealBot_Options_BuffDebuff_Reset("debuff")
        HealBot_Options_ResetDoInittab(4)
    elseif HealBot_Options_Timer[60] then
        HealBot_Options_Timer[60]=nil
        HealBot_Options_EmergencyFilter_Reset()
    elseif HealBot_Options_Timer[80] then
        HealBot_Options_Timer[80]=nil
        HealBot_setLuVars("ResetAllUnitStatus", GetTime()+2)
        HealBot_Action_sethbNumberFormat()
        HealBot_Action_sethbAggroNumberFormat()
    elseif HealBot_Options_Timer[90] then
        HealBot_Options_Timer[90]=nil
        HealBot_SetSkinColours();
    elseif HealBot_Options_Timer[100] then
        HealBot_Options_Timer[100]=nil
        HealBot_SetBuffBarColours()
    elseif HealBot_Options_Timer[110] then
        HealBot_Options_Timer[110]=nil
        HealBot_Action_setRegisterForClicks()
    elseif HealBot_Options_Timer[120] then
        HealBot_Options_Timer[120]=nil
        HealBot_CheckZone();
    elseif HealBot_Options_Timer[125] then
        HealBot_Options_Timer[125]=nil
        hbRequestTime=GetTime()+4
        HealBot_setOptions_Timer(130)
    elseif HealBot_Options_Timer[130] and hbRequestTime<GetTime() then
        HealBot_Options_Timer[130]=nil
        HealBot_Comms_SendAddonMsg("HealBot", "R", HealBot_luVars["AddonMsgType"], HealBot_Data["PNAME"])
        hbRequestTime=GetTime()+8
    elseif HealBot_Options_Timer[140] and hbRequestTime<GetTime() then
        HealBot_Options_Timer[140]=nil
        if GetGuildInfo("player") then HealBot_Comms_SendAddonMsg("HealBot", "G", 5, HealBot_Data["PNAME"]) end
        local x=GetNumFriends()
        if x>0 then
            for y=1,x do
                local uName, _, _, _, z = GetFriendInfo(y)
                if z then HealBot_Comms_SendAddonMsg("HealBot", "F", 4, uName) end
            end
        end
        HealBot_GetTalentInfo(HealBot_Data["PGUID"], "player")
        hbRequestTime=GetTime()+8
    elseif HealBot_Options_Timer[155] then
        HealBot_Options_Timer[155]=nil
        HealBot_Panel_ResetClassIconTexture()
    elseif HealBot_Options_Timer[160] then
        HealBot_Options_Timer[160]=nil
        HealBot_Options_SetSkinBars()
    elseif HealBot_Options_Timer[170] then
        HealBot_Options_Timer[170]=nil                        
        HealBot_configClassHoT()
    elseif  HealBot_Options_Timer[180] then
        HealBot_Options_Timer[180]=nil
        if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDEPARTYF"] then
            HealBot_trackHiddenFrames["PARTY"]=true
            HealBot_Options_DisablePartyFrame()
            HealBot_Options_PlayerTargetFrames:Enable();
            if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDEPTF"] then
                HealBot_trackHiddenFrames["PLAYER"]=true
                HealBot_Options_DisablePlayerFrame()
                HealBot_Options_DisablePetFrame()
                HealBot_Options_DisableTargetFrame()
            elseif HealBot_trackHiddenFrames["PLAYER"] then 
                HealBot_Options_ReloadUI(HEALBOT_OPTIONS_HIDEPARTYFRAMES.." ("..HEALBOT_OPTIONS_HIDEPLAYERTARGET..") - "..HEALBOT_WORD_OFF)
            end
            if HealBot_luVars["ReloadUI"]>GetTime() then
                HealBot_Options_ReloadUI(HEALBOT_OPTIONS_HIDEPARTYFRAMES.." - "..HEALBOT_WORD_ON)
            end
        elseif HealBot_trackHiddenFrames["PARTY"] then
            HealBot_Options_ReloadUI(HEALBOT_OPTIONS_HIDEPARTYFRAMES.." - "..HEALBOT_WORD_OFF)
        end
    elseif  HealBot_Options_Timer[185] then
        HealBot_Options_Timer[185]=nil
        if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDEBOSSF"] then
            HealBot_trackHiddenFrames["MINIBOSS"]=true
            HealBot_Options_DisableMiniBossFrame()
            if HealBot_luVars["ReloadUI"]>GetTime() then
                HealBot_Options_ReloadUI(HEALBOT_OPTIONS_HIDEMINIBOSSFRAMES.." - "..HEALBOT_WORD_ON)
            end
        elseif HealBot_trackHiddenFrames["MINIBOSS"] then
            HealBot_Options_ReloadUI(HEALBOT_OPTIONS_HIDEMINIBOSSFRAMES.." - "..HEALBOT_WORD_OFF)
        end
    elseif  HealBot_Options_Timer[188] then
        HealBot_Options_Timer[188]=nil
        if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDERAIDF"] then
            HealBot_trackHiddenFrames["RAID"]=true
            HealBot_Options_DisableRaidFrame()
            if HealBot_luVars["ReloadUI"]>GetTime() then
                HealBot_Options_ReloadUI(HEALBOT_OPTIONS_HIDERAIDFRAMES.." - "..HEALBOT_WORD_ON)
            end
        elseif HealBot_trackHiddenFrames["RAID"] then
            if HealBot_Globals.RaidHideMethod==0 then
                HealBot_Options_ReloadUI(HEALBOT_OPTIONS_HIDERAIDFRAMES.." - "..HEALBOT_WORD_OFF)
            elseif HealBot_Globals.RaidHideMethod>1 then
                if HealBot_Globals.RaidHideMethod>2 then
                    if HealBot_Globals.RaidHideMethod==4 then
                        Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDERAIDF"]=true
                    end
                    HealBot_Globals.RaidHideMethod=0
                end
                local _, _, _, enabledCRF, _, _, _ = GetAddOnInfo("Blizzard_CompactRaidFrames")
                local _, _, _, enabledCUF, _, _, _ = GetAddOnInfo("Blizzard_CUFProfiles")
                if not enabledCRF or not enabledCUF then 
                    EnableAddOn("Blizzard_CompactRaidFrames")
                    EnableAddOn("Blizzard_CUFProfiles")
                    HealBot_Options_ReloadUI(HEALBOT_OPTIONS_HIDERAIDFRAMES.." - "..HEALBOT_WORD_OFF)
                end
            end
        end
    elseif HealBot_Options_Timer[190] then
        HealBot_Options_Timer[190]=nil
        HealBot_setOptions_Timer(195)
        HealBot_luVars["CheckSkin"]=true
    elseif HealBot_Options_Timer[195] then
        HealBot_Options_InitSub(318)
        HealBot_Options_Timer[195]=nil
    elseif HealBot_Options_Timer[200] then
        HealBot_GetTalentInfo(HealBot_Data["PGUID"], "player")
        HealBot_Options_Timer[200]=nil
    elseif  HealBot_Options_Timer[400] then
        HealBot_Options_Timer[400]=nil
        HealBot_Action_SetAllAttribs()
    elseif  HealBot_Options_Timer[415] then
        local fNo, fType=HealBot_Options_FrameAlias_retUpdates()
        if fNo then
            if fType=="T" then
                HealBot_Action_SetAlias(fNo)
            else
                HealBot_Action_SetAliasFontSize(fNo)
            end
        else
            HealBot_Options_Timer[415]=nil
        end
    elseif  HealBot_Options_Timer[419] then
        HealBot_Options_Timer[419]=nil
        HealBot_Options_FrameAlias_initFrameSel()
    elseif  HealBot_Options_Timer[420] then
        HealBot_Options_Timer[420]=nil
        HealBot_OnEvent_RaidRosterUpdate();
    elseif HealBot_Options_Timer[500] or HealBot_Options_Timer[501] or HealBot_Options_Timer[502] then
        if HealBot_Options_Timer[500] then
         --   HealBot_SetResetFlag("SOFT")
            HealBot_Register_Events()
            HealBot_nextRecalcParty(0.1);
            HealBot_Options_Timer[500]=nil
        elseif HealBot_Options_Timer[501] then
            HealBot_Config.DisabledNow=1
            HealBot_nextRecalcParty(0.1);
            HealBot_Options_Timer[501]=nil
            HealBot_Options_Timer[502]=true
        else
            HealBot_UnRegister_Events()
            HealBot_Register_Events()
            for j=1,10 do
                HealBot_Action_HidePanel(j)
            end
            HealBot_Options_Timer[502]=nil
            HealBot_Set_Timers()
        end
    elseif HealBot_Options_Timer[550] then
        HealBot_Options_Timer[550]=nil
        HealBot_InitSpells()
    elseif  HealBot_Options_Timer[950] then
        HealBot_Options_Timer[950]=nil
        local _,z = GetNumMacros()
        if z>12 then
            HealBot_useCrashProtection()
        end
    elseif  HealBot_Options_Timer[990] then
        HealBot_Options_Timer[990]=nil
        HealBot_AddChat("  "..HEALBOT_ADDON .. HEALBOT_LOADED);
        HealBot_AddChat(HEALBOT_HELP[1])
    elseif HealBot_Options_Timer[4910] then
        HealBot_Options_Timer[4910]=nil
        HealBot_Action_setLowManaTrig()
        HealBot_CheckLowMana()
    elseif HealBot_Options_Timer[7950] then
        if GetTime()>HealBot_luVars["hbInsNameCheck"] then
            HealBot_Options_Timer[7950]=nil
            HealBot_luVars["hbInsNameCheck"]=nil
            local mapAreaID = C_Map.GetBestMapForUnit("player")
            HealBot_setOptions_Timer(30)
            local y,z = IsInInstance()
            local mapName=HEALBOT_WORD_OUTSIDE
            if mapAreaID and mapAreaID>0 and C_Map.GetMapInfo(mapAreaID).name then
                mapName=C_Map.GetMapInfo(mapAreaID).name
            elseif z and z=="arena" then 
                mapName="Arena"
            end
            if z and (z=="pvp" or z=="arena") then 
                HealBot_luVars["inBG"]=true 
            else
                HealBot_luVars["inBG"]=nil
            end                            
            HealBot_Data["MAPID"]=mapAreaID
            HealBot_Options_SetEnableDisableCDBtn()
            HealBot_SetAddonComms()
            HealBot_Set_Timers()
        end
    elseif HealBot_Options_Timer[8000] then
        HealBot_Options_Timer[8000]=HealBot_Options_idleInit()
        if HealBot_Options_Timer[8000] then
            HealBot_luVars["Timer8000"]=(HealBot_luVars["Timer8000"] or 0)+1
        else
            HealBot_AddDebug("Timer 8000 called #"..HealBot_luVars["Timer8000"])
            HealBot_luVars["Timer8000"]=0
            HealBot_setqaFR()
            HealBot_Set_Timers()
            HealBot_CheckAllBuffs("player")
        end
    else
        HealBot_luVars["HealBot_Options_Timer"]=nil
    end
end

local function HealBot_NoVehicle(unit)
    local HBvUnits=HealBot_VehicleUnit[unit]
    for xUnit,_ in pairs(HBvUnits) do
        if HealBot_UnitInVehicle[xUnit] then HealBot_UnitInVehicle[xUnit]=nil end
    end
	if HealBot_VehicleUnit[unit] then HealBot_VehicleUnit[unit]=nil end
    local vGUID=HealBot_UnitGUID(unit)
    if vGUID and HealBot_UnitData[vGUID] and HealBot_UnitData[vGUID]["VEHICLE"] then
        HealBot_UnitData[vGUID]=nil
    end
end

local function HealBot_OnEvent_UnitThreat(unit)
    local xUnit,xGUID,xButton = HealBot_UnitID(unit)
    if xUnit and not UnitIsDeadOrGhost("player") then
        if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Current_Skin]["SHOW"] and UnitAffectingCombat(xUnit) and xButton.status.enemy < 0 then
            HealBot_SetAggro(xUnit)
        end
    end
end

local function HealBot_OnEvent_UnitHealth(unit)
    local xUnit,xGUID,xButton = HealBot_UnitID(unit)
    if xUnit then
        local health,healthMax=UnitHealth(xUnit),HealBot_UnitMaxHealth(xUnit)
        if HealBot_VehicleUnit[xUnit] then
            if not HealBot_UnitData[xGUID] then
                HealBot_UnitData[xGUID] = {}
                HealBot_UnitData[xGUID]["UNIT"]=xUnit 
                HealBot_UnitData[xGUID]["VEHICLE"]=true 
            end
            local HBvUnits=HealBot_VehicleUnit[xUnit]
            for rUnit,_ in pairs(HBvUnits) do
                HealBot_Action_Refresh(xButton)
            end
        end  
        if (health~=xButton.health.current) or (healthMax~=xButton.health.max) then
            if health<xButton.health.current then HealBot_OnEvent_UnitThreat(xUnit) end
            xButton.health.current=health
            xButton.health.max=healthMax
            HealBot_Action_setHealthText(xButton)
            HealBot_Action_UpdateHealthButton(xButton)
        end
    end
end

local function HealBot_OnEvent_VehicleChange(self, unit, enterVehicle)
    local xUnit = HealBot_UnitID(unit)
    local xButton=HealBot_Unit_Button[xUnit]
    if xButton then
        HealBot_Action_setHealthText(xButton)
        local doRefresh=false
        if enterVehicle then
            local vUnit=HealBot_UnitPet(xUnit)
            if vUnit and UnitHasVehicleUI(xUnit) then
                if HealBot_VehicleCheck[xUnit] then HealBot_VehicleCheck[xUnit]=nil end
                if not HealBot_VehicleUnit[vUnit] then HealBot_VehicleUnit[vUnit]={} end
                HealBot_VehicleUnit[vUnit][xUnit]=true
                HealBot_UnitInVehicle[xUnit]=vUnit
                local xGUID=HealBot_UnitGUID(vUnit)
                if xGUID and not HealBot_UnitData[xGUID] then 
                    HealBot_UnitData[xGUID] = {}
                    HealBot_UnitData[xGUID]["UNIT"]=vUnit 
                    HealBot_UnitData[xGUID]["VEHICLE"]=true 
                end
                HealBot_OnEvent_UnitHealth(vUnit)
                doRefresh=true
            elseif self then
                HealBot_VehicleCheck[xUnit]=1
            end
        elseif HealBot_UnitInVehicle[xUnit] then
            local vUnit=HealBot_UnitInVehicle[xUnit]
            HealBot_NoVehicle(vUnit)
            doRefresh=true
        end
        if doRefresh then
            HealBot_Action_Refresh(xButton)
            HealBot_Data["REFRESH"]=true;
        end
    end
end

local function HealBot_RaidTargetChecked(iconID, hbCurFrame)
    local z=nil
    if iconID==1 then
        if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][hbCurFrame]["STAR"] then z=true end
    elseif iconID==2 then
        if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][hbCurFrame]["CIRCLE"] then z=true end
    elseif iconID==3 then
        if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][hbCurFrame]["DIAMOND"] then z=true end
    elseif iconID==4 then
        if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][hbCurFrame]["TRIANGLE"] then z=true end
    elseif iconID==5 then
        if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][hbCurFrame]["MOON"] then z=true end
    elseif iconID==6 then
        if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][hbCurFrame]["SQUARE"] then z=true end
    elseif iconID==7 then
        if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][hbCurFrame]["CROSS"] then z=true end
    elseif iconID==8 then
        if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][hbCurFrame]["SKULL"] then z=true end
    end
    return z
end

function HealBot_OnEvent_RaidTargetUpdate(self)
    for xUnit,xButton in pairs(HealBot_Unit_Button) do
        if UnitExists(xUnit) then 
            local x=GetRaidTargetIndex(xUnit)
            if x and HealBot_RaidTargetChecked(x, xButton.frame) then
                HealBot_TargetIcons[xUnit]=x
                HealBot_RaidTargetUpdate(xButton, x)
            elseif HealBot_TargetIcons[xUnit] then
                HealBot_TargetIcons[xUnit]=nil
                HealBot_RaidTargetUpdate(xButton, nil)
            end
        elseif HealBot_TargetIcons[xUnit] then
            HealBot_TargetIcons[xUnit]=nil
            HealBot_RaidTargetUpdate(xButton, nil)
        end
    end
end

local function HealBot_IC_PartyMembersChanged()
    if HealBot_luVars["InCombatUpdTime"]<GetTime() then
        for x,_ in pairs(HealBot_UpUnitInCombat) do
            HealBot_UpUnitInCombat[x]=nil
        end
        HealBot_UpUnitInCombat["nil"]=true
        for xGUID,_ in pairs(HealBot_UnitData) do
            if not HealBot_UpUnitInCombat[xGUID] then
                xUnit=HealBot_UnitData[xGUID]["UNIT"]
                if UnitExists(xUnit) then
                    local zGUID=HealBot_UnitGUID(xUnit) or "nk"
                    if zGUID~=xGUID and not HealBot_UpUnitInCombat[zGUID] then
                        HealBot_UpUnitInCombat[xGUID]=true
                        HealBot_UpUnitInCombat[zGUID]=true
                        HealBot_PrepUnitNameUpdate(xUnit, zGUID, xGUID)
                    end
                end
            end
        end
        for xUnit,xButton in pairs(HealBot_Unit_Button) do
            if UnitExists(xUnit) then
                if not HealBot_UpUnitInCombat[xButton.guid] then
                    local zGUID=HealBot_UnitGUID(xUnit) or "nk"
                    if xButton.guid~=zGUID and not HealBot_UpUnitInCombat[zGUID] then
                        HealBot_UpUnitInCombat[xButton.guid]=true
                        HealBot_UpUnitInCombat[zGUID]=true
                        HealBot_PrepUnitNameUpdate(xUnit, zGUID, xButton.guid)
                    end
                end
            elseif not HealBot_UnknownUnitUpdated[xUnit] then
                HealBot_PrepUnitNameUpdate(xUnit)
                HealBot_UnknownUnitUpdated[xUnit]=true
            end
        end
        if #HealBot_UpUnitInCombat>1 then
            local doRaidTargetUpd=false
            for j=1,10 do
                if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][j]["SHOW"] then doRaidTargetUpd=true end
            end
            if doRaidTargetUpd then HealBot_OnEvent_RaidTargetUpdate(nil) end
        end
    else
        return
    end
    HealBot_luVars["InCombatUpdate"]=false
    HealBot_luVars["InCombatUpdTime"]=GetTime()+0.5
end

local function HealBot_PartyUpdate_CheckSkin()
    local _,z = IsInInstance()
    local PrevSolo=HealBot_luVars["IsSolo"]
    local LastAutoSkinChangeType="None"
    local newSkinName="_-none-_"
    HealBot_luVars["IsSolo"]=nil
    HealBot_luVars["CheckSkin"]=nil
    if z == "arena" then
        for x in pairs (Healbot_Config_Skins.Skins) do
            if HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_ARENA] then
                    LastAutoSkinChangeType="Arena"
                    newSkinName=Healbot_Config_Skins.Skins[x]
                break
            end
        end
    elseif z=="pvp" then
        local y=GetRealZoneText()
        if GetNumGroupMembers()>29 or y==HEALBOT_ZONE_AV or y==HEALBOT_ZONE_IC then
            for x in pairs (Healbot_Config_Skins.Skins) do
                if HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_BG40] then
                    LastAutoSkinChangeType="BG40"
                    newSkinName=Healbot_Config_Skins.Skins[x]
                    break
                end
            end
        elseif GetNumGroupMembers()>11 or y==HEALBOT_ZONE_SA or y==HEALBOT_ZONE_ES or y==HEALBOT_ZONE_AB then
            for x in pairs (Healbot_Config_Skins.Skins) do
                if HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_BG15] then
                    LastAutoSkinChangeType="BG15"
                    newSkinName=Healbot_Config_Skins.Skins[x]
                    break
                end
            end
        else
            for x in pairs (Healbot_Config_Skins.Skins) do
                if HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_BG10] then
                    LastAutoSkinChangeType="BG10"
                    newSkinName=Healbot_Config_Skins.Skins[x]
                    break
                end
            end
        end
    elseif IsInRaid() then
        if GetNumGroupMembers()>29 then
            for x in pairs (Healbot_Config_Skins.Skins) do
                if HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_OPTIONS_RAID40] then
                    LastAutoSkinChangeType="Raid40"
                    newSkinName=Healbot_Config_Skins.Skins[x]
                    break
                end
            end
        elseif GetNumGroupMembers()>15 then
            for x in pairs (Healbot_Config_Skins.Skins) do
                if HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_OPTIONS_RAID25] then
                    LastAutoSkinChangeType="Raid25"
                    newSkinName=Healbot_Config_Skins.Skins[x]
                    break
                end
            end
        else
            for x in pairs (Healbot_Config_Skins.Skins) do
                if HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_OPTIONS_RAID10] then
                    LastAutoSkinChangeType="Raid10"
                    newSkinName=Healbot_Config_Skins.Skins[x]
                    break
                end
            end
        end
    elseif IsInGroup() and GetNumGroupMembers()>0 then
        for x in pairs (Healbot_Config_Skins.Skins) do
            if HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_PARTY] then
                LastAutoSkinChangeType="Party"
                newSkinName=Healbot_Config_Skins.Skins[x]
                break
            end
        end
    elseif C_PetBattles.IsInBattle() and HealBot_luVars["lastPetBattleEvent"]~="PET_BATTLE_OVER" then
        for x in pairs (Healbot_Config_Skins.Skins) do
            if HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_PETBATTLE] then
                LastAutoSkinChangeType="Pet"
                newSkinName=Healbot_Config_Skins.Skins[x]
                break
            end
        end
    else
        for x in pairs (Healbot_Config_Skins.Skins) do
            if HealBot_Config.SkinDefault[Healbot_Config_Skins.Skins[x]][HEALBOT_WORD_SOLO] then
                LastAutoSkinChangeType="Solo"
                newSkinName=Healbot_Config_Skins.Skins[x]
                break
            end
        end
        HealBot_luVars["IsSolo"]=true
        HealBot_Options_DisableCheck()
    end
    if LastAutoSkinChangeType~=HealBot_Config.LastAutoSkinChangeType or HealBot_Config.LastAutoSkinChangeTime<GetTime() then
        if newSkinName~="_-none-_" and newSkinName~=Healbot_Config_Skins.Current_Skin then
            HealBot_Options_Set_Current_Skin(newSkinName)
        end
        HealBot_Config.LastAutoSkinChangeType=LastAutoSkinChangeType
    end
    if (PrevSolo or "nil")~=(HealBot_luVars["IsSolo"] or "nil") then
        HealBot_SetAuraChecks()
    end
end

local function HealBot_Not_Fighting()
    HealBot_Data["UILOCK"]=false
    HealBot_nextRecalcParty(0.8)
    HealBot_Data["REFRESH"]=true
    if needReset then
        HealBot_luVars["ResetFlag"]=1 
        needReset=nil
    else
        HealBot_luVars["ResetAllUnitStatus"]=GetTime()+0.2
        if HealBot_Config_Buffs.BuffWatch and HealBot_Config_Buffs.BuffWatchInCombat==false then
            HealBot_CheckAllBuffs()
        end
        if HealBot_Config_Cures.DebuffWatch and HealBot_Config_Cures.DebuffWatchInCombat==false then
            HealBot_CheckAllDebuffs()
        end
    end
    if HealBot_Globals.DisableToolTipInCombat and HealBot_Data["TIPUSE"] and HealBot_Data["TIPUNIT"] then
        HealBot_Action_RefreshTooltip();
    end
    HealBot_EndAggro()
    if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["LOWMANA"]>1 and Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["LOWMANACOMBAT"]==false then
        HealBot_CheckLowMana()
    end
    if HealBot_luVars["MessageReloadUI"]>0 then
        HealBot_MessageReloadUI(HealBot_luVars["MessageReloadUI"])
    end
    if HealBot_luVars["27YardsOnly"] then
        HealBot_luVars["27YardsOnly"]=false
    end
    HealBot_Action_ResetUnitStatus()
end

local function HealBot_OnEvent_ReadyCheckClear()
    local doRaidTargetUpd=false
    for _,xButton in pairs(HealBot_Unit_Button) do
        local bar = _G["HealBot_Action_HealUnit"..xButton.id.."Bar"]
        if bar then
            local iconName = _G[bar:GetName().."Icon16"];
            iconName:SetAlpha(0);
            if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][xButton.frame]["SHOW"] then
                doRaidTargetUpd=true
            end
        end
    end
    if doRaidTargetUpd then HealBot_OnEvent_RaidTargetUpdate(nil) end
end

local function HealBot_Update_Slow()
    if HealBot_luVars["rcEnd"] and HealBot_luVars["rcEnd"]<GetTime() then
        HealBot_luVars["rcEnd"]=nil
        HealBot_OnEvent_ReadyCheckClear()
    end
    if not HealBot_Data["UILOCK"] and not InCombatLockdown() then
        if HealBot_luVars["ResetFlag"] then
            if HealBot_luVars["ResetFlag"]==1 then
                HealBot_Reset()
            elseif HealBot_luVars["ResetFlag"]==2 then
                HealBot_ResetCustomDebuffs()
            elseif HealBot_luVars["ResetFlag"]==3 then
                HealBot_ResetSkins()
            end
            HealBot_luVars["ResetFlag"]=false
        elseif HealBot_luVars["UseCrashProtection"] and HealBot_luVars["UseCrashProtection"]<GetTime() then 
                HealBot_luVars["UseCrashProtection"]=nil
                HealBot_Data["REFRESH"]=true;
        elseif HealBot_Data["REFRESH"] then
            if HealBot_luVars["CheckSkin"] then
                HealBot_PartyUpdate_CheckSkin()
            elseif HealBot_luVars["nextRecalcParty"]<GetTime() then
                HealBot_luVars["nextRecalcParty"]=GetTime()+(HealBot_Globals.RangeCheckFreq)
                if HealBot_luVars["InCombatUpdate"] then 
                    HealBot_luVars["InCombatUpdate"]=false
                end
                HealBot_RecalcParty();
            end
        elseif HealBot_luVars["CheckTalents"] then
            HealBot_luVars["CheckTalents"]=false; 
            HealBot_GetTalentInfo(HealBot_Data["PGUID"], "player")
        elseif HealBot_luVars["CheckPlayerBuffsGUID"] and HealBot_luVars["CheckPlayerBuffsTime"]<GetTime() then
            local PlayerBuffsGUID=HealBot_PlayerBuff[HealBot_luVars["CheckPlayerBuffsGUID"]]
            if PlayerBuffsGUID then
                HealBot_CheckAllBuffs(HealBot_Panel_RaidUnit(HealBot_luVars["CheckPlayerBuffsGUID"]))
            else
                HealBot_luVars["ResetCheckBuffsTime"]=GetTime()+5
            end
        elseif HealBot_luVars["ResetCheckBuffsTime"] and HealBot_luVars["ResetCheckBuffsTime"]<GetTime() then
            HealBot_luVars["ResetCheckBuffsTime"]=false
            HealBot_ResetCheckBuffsTime()
        elseif HealBot_ReCheckBuffsTime and HealBot_ReCheckBuffsTime<GetTime() then
            HealBot_CheckAllBuffs(HealBot_Panel_RaidUnit(HealBot_ReCheckBuffsTimed[HealBot_ReCheckBuffsTime]))
            HealBot_ReCheckBuffsTimed[HealBot_ReCheckBuffsTime]=nil
            local z=HealBot_ReCheckBuffsTime+1000000
            HealBot_ReCheckBuffsTime=nil 
            for Time,_ in pairs (HealBot_ReCheckBuffsTimed) do
                if Time < z then
                    z=Time
                    HealBot_ReCheckBuffsTime=Time
                end
            end
        elseif HealBot_luVars["cpMacro"] and HealBot_luVars["cpMacro"]<GetTime() then 
                HealBot_cpSaveAll()
        elseif HealBot_luVars["VersionRequest"] then
                HealBot_Comms_SendAddonMsg("HealBot", "S:"..HEALBOT_VERSION, HealBot_luVars["AddonMsgType"], HealBot_Data["PNAME"])
                HealBot_luVars["VersionRequest"]=false;
        elseif HealBot_DebugMsg[1] and (HealBot_luVars["nextDebugMsg"] or 0)<GetTime() then
            HealBot_luVars["nextDebugMsg"]=GetTime()+1
            local hbDebugChan=HealBot_Comms_GetChan("HBmsg");
            if hbDebugChan then
                SendChatMessage(HealBot_DebugMsg[1] , "CHANNEL", nil, hbDebugChan);
            end
            table.remove(HealBot_DebugMsg,1)
        end
        if HealBot_luVars["HealBot_Options_Timer"] then
            HealBot_Options_Update()
        end
        if hbShareSkins[1] then
            local unitName,tMsg=string.split("!",hbShareSkins[1])
            HealBot_Comms_SendAddonMsg("HealBot", tMsg, 4, unitName)
            table.remove(hbShareSkins,1)
            HealBot_luVars["shareSkinsSent"]=HealBot_luVars["shareSkinsSent"]+1
            local tabSize=HealBot_luVars["shareSkinsTabSize"]
            if tabSize<47 then tabSize=47 end
            local pctDone=floor((HealBot_luVars["shareSkinsSent"]/tabSize)*100)
            HealBot_Options_ShareSkinStatus:SetValue(pctDone)
            HealBot_Options_ShareSkinStatusf:SetText(pctDone.."%")
        elseif (HealBot_luVars["shareSkinsSent"] or 0)>0 then
            HealBot_Options_ShareSkinStatusf:SetTextColor(1,1,1,0)
            HealBot_Options_ShareSkinStatus:SetStatusBarColor(0.3,0.3,0.9,0)
            HealBot_luVars["shareSkinsSent"]=0
        end
        if HealBot_luVars["DoUpdates"] then
            HealBot_luVars["slowSwitch"]=HealBot_luVars["slowSwitch"]+1
            if HealBot_luVars["slowSwitch"]<2 then
                HealBot_setqaFR()
            else
                for xGUID,xTime in pairs(HealBot_cleanGUIDs) do
                    HealBot_ClearLocalArr(xGUID, xTime)
                    HealBot_cleanGUIDs[xGUID]=nil
                end
                HealBot_luVars["slowSwitch"]=0
            end
        end
        for xGUID,xUnit in pairs(HealBot_notVisible) do
            if UnitIsVisible(xUnit) then
                HealBot_Data["REFRESH"]=true;
                HealBot_notVisible[xGUID]=nil
            end
        end
    elseif HealBot_luVars["IsReallyFighting"] then
        if not InCombatLockdown() then
            HealBot_luVars["IsReallyFighting"] = nil
            HealBot_Not_Fighting()
        end
    elseif not InCombatLockdown() then
        if not HealBot_luVars["DelayLockdownCheck"] then
            HealBot_luVars["IsReallyFighting"]=true
        elseif HealBot_luVars["DelayLockdownCheck"]<GetTime() then
            HealBot_luVars["DelayLockdownCheck"]=nil
        end
    end
    for xUnit, huIcons in pairs(HealBot_UnitIcons) do
        local xButton=HealBot_Unit_Button[xUnit]
        if xButton then
            for buffID in pairs(huIcons) do
                if floor(huIcons[buffID]["EXPIRE"]-GetTime())<=Healbot_Config_Skins.IconText[Healbot_Config_Skins.Current_Skin][xButton.frame]["DURTHRH"] then
                    HealBot_HoT_Update(HealBot_Unit_Button[xUnit], buffID)
                end
            end
        else
            HealBot_UnitIcons[xUnit]={}
        end
    end
    for xUnit,z in pairs(HealBot_VehicleCheck) do
        if z<9 then
            HealBot_VehicleCheck[xUnit]=HealBot_VehicleCheck[xUnit]+1
        else
            HealBot_VehicleCheck[xUnit]=nil
        end
        HealBot_OnEvent_VehicleChange(nil, xUnit, true)
    end
    for xUnit,updTime in pairs(HealBot_NameTextUpdate) do
        if updTime<GetTime() then
            local xButton=HealBot_Unit_Button[xUnit]
            if xButton then
                HealBot_Action_setNameText(xButton)
                HealBot_Action_Refresh(xButton)
            end
            HealBot_NameTextUpdate[xUnit]=nil
        end
    end
    if HealBot_luVars["InCombatUpdate"] then
        HealBot_IC_PartyMembersChanged()
    elseif HealBot_luVars["mapUpdate"] and HealBot_luVars["mapUpdate"]<GetTime() then
        HealBot_luVars["mapUpdate"]=nil
        local mapAreaID = C_Map.GetBestMapForUnit('player')
        HealBot_Data["MAPID"]=mapAreaID or 0
        --HealBot_AddDebug("mapID="..HealBot_Data["MAPID"])
    elseif HealBot_luVars["ResetAllUnitStatus"] and HealBot_luVars["ResetAllUnitStatus"]<GetTime() then
        HealBot_luVars["ResetAllUnitStatus"]=false
        HealBot_Action_ResetUnitStatus()
    elseif HealBot_luVars["HelpCnt1"] then
        HealBot_luVars["HelpCnt1"]=HealBot_luVars["HelpCnt1"]+1
        if HealBot_luVars["HelpCnt1"]>#HEALBOT_HELP then
            HealBot_luVars["HelpCnt1"]=nil
        else
            HealBot_AddChat(HEALBOT_HELP[HealBot_luVars["HelpCnt1"]])
        end
    elseif HealBot_luVars["HelpCnt2"] then
        HealBot_luVars["HelpCnt2"]=HealBot_luVars["HelpCnt2"]+1
        if HealBot_luVars["HelpCnt2"]>#HEALBOT_HELP2 then
            HealBot_luVars["HelpCnt2"]=nil
        else
            HealBot_AddChat(HEALBOT_HELP2[HealBot_luVars["HelpCnt2"]])
        end
    end
end

local function HealBot_doClearAggro()
    HealBot_luVars["DelayClearAggro"]=nil
    for xUnit,xButton in pairs(HealBot_Unit_Button) do
        if xButton.aggro.finish then
            HealBot_ClearUnitAggro(xButton)
            xButton.aggro.finish = false
        end
    end
end

local curDebuffs={}
local prevDebuff={}
local DebuffClass=nil
                        
local function HealBot_addCurDebuffs(dName,deBuffTexture,bCount,debuff_type,debuffDuration,expirationTime,spellId,unitCaster,unit,isBossDebuff,button)
    local dNamePriority, dTypePriority=HealBot_Options_retDebuffPriority(dName, debuff_type)
    if dTypePriority>dNamePriority then
        local castByListIndexed = HealBot_Options_getCDebuffCasyByIndexed()
        local hbCastByEveryone = castByListIndexed[HEALBOT_CUSTOM_CASTBY_EVERYONE] or -1
        local hbCastByEnemy = castByListIndexed[HEALBOT_CUSTOM_CASTBY_ENEMY] or -1
        local hbCastByFriend = castByListIndexed[HEALBOT_CUSTOM_CASTBY_FRIEND] or -1
        local hbCastBySelf = castByListIndexed[HEALBOT_OPTIONS_SELFHEALS] or -1
 
        local hbCasterID=HealBot_Globals.FilterCustomDebuff[dName] or 0
        if hbCasterID==0 then
            if HealBot_Globals.CureCustomDefaultCastBy=="ALL" then
                hbCasterID = hbCastByEveryone
            elseif HealBot_Globals.CureCustomDefaultCastBy=="ENEMY" then
                hbCasterID = hbCastByEnemy
            end
        end
        if HealBot_Globals.IgnoreCustomDebuff[dName] and HealBot_Globals.IgnoreCustomDebuff[dName][HealBot_luVars["hbInsName"]] then 
            dNamePriority=dTypePriority+100
        elseif hbCasterID~=hbCastByEveryone then
            local unitCasterID=0
            if unitCaster and unitCaster=="player" then
                unitCasterID=hbCastBySelf --4
            elseif unitCaster and not UnitIsEnemy("player",unitCaster) then
                unitCasterID=hbCastByFriend --3
            else
                unitCasterID=hbCastByEnemy --2
            end
            if unitCasterID~=hbCasterID then 
                dNamePriority=dTypePriority+100
            end
        end
    end
    if dTypePriority>dNamePriority or HealBot_Config_Cures.HealBot_Custom_Defuffs_All[debuff_type] then
        curDebuffs[dName]={}
        debuff_type=HEALBOT_CUSTOM_en
        curDebuffs[dName]["priority"]=dNamePriority
        curDebuffs[dName]["isCustom"]=true
        if prevDebuff["name"]==dName then prevDebuff["priority"]=dNamePriority end
    else
        local checkthis=true;        
        if HealBot_luVars["MaskAuraDCheck"]>GetTime() then
            checkthis=false;
            prevDebuff["name"]="x" 
        elseif HealBot_Config_Cures.IgnoreFriendDebuffs and unitCaster and unitCaster~=unit and UnitIsFriend("player",unitCaster) then
            checkthis=false;
        elseif HealBot_Config_Cures.IgnoreMovementDebuffs and HealBot_Ignore_Debuffs["Movement"][dName] then
            checkthis=false;
        elseif prevDebuff["name"]~=dName and HealBot_Config_Cures.IgnoreFastDurDebuffs and debuffDuration and debuffDuration>0 
          and (debuffDuration<HealBot_Config_Cures.IgnoreFastDurDebuffsSecs or expirationTime<GetTime()+HealBot_Config_Cures.IgnoreFastDurDebuffsSecs) then
            checkthis=false;
        elseif HealBot_Config_Cures.IgnoreNonHarmfulDebuffs and HealBot_Ignore_Debuffs["NonHarmful"][dName] then
            checkthis=false;
        elseif HealBot_Config_Cures.IgnoreClassDebuffs and HealBot_Ignore_Debuffs["Class"][strsub(DebuffClass,1,4)][dName] then
            checkthis=false;
        end
        if checkthis then
            curDebuffs[dName]={}
            curDebuffs[dName]["priority"]=dTypePriority
            curDebuffs[dName]["isCustom"]=false
           -- if prevDebuff["name"]==dName then prevDebuff["priority"]=dTypePriority end
        elseif dNamePriority<21 or (isBossDebuff and HealBot_Config_Cures.AlwaysShowBoss) then
            curDebuffs[dName]={}
            debuff_type=HEALBOT_CUSTOM_en
            curDebuffs[dName]["priority"]=dNamePriority
            curDebuffs[dName]["isCustom"]=true
           -- if prevDebuff["name"]==dName then prevDebuff["priority"]=dNamePriority end
        end
    end
    if curDebuffs[dName] then
        curDebuffs[dName]["type"]=debuff_type
        curDebuffs[dName]["duration"]=debuffDuration
        curDebuffs[dName]["texture"]=deBuffTexture
        curDebuffs[dName]["bCount"]=bCount
        curDebuffs[dName]["expirationTime"]=expirationTime
        curDebuffs[dName]["spellId"]=spellId
        if HealBot_Globals.HealBot_Custom_Debuffs_RevDur[dName] then
            if not HealBot_CustomDebuff_RevDurLast[dName] then HealBot_CustomDebuff_RevDurLast[dName]={} end
            if not HealBot_CustomDebuff_RevDurLast[dName][unit] or HealBot_CustomDebuff_RevDurLast[dName][unit]<(expirationTime-debuffDuration) then
                HealBot_CustomDebuff_RevDurLast[dName][unit]=GetTime()
            end
        end
        if prevDebuff["name"]==dName then
            button.aura.debuff.type=curDebuffs[dName]["type"]
            button.aura.debuff.name=dName
            button.aura.debuff.iconId="DEBUFF!"..dName.."!"..curDebuffs[dName]["spellId"]
            button.aura.debuff.priority=curDebuffs[dName]["priority"]
        end
    end
end
 
local function HealBot_CheckUnitDebuffs(button)
    local xUnit=button.unit
    local xGUID=button.guid
    if not xUnit or not UnitExists(xUnit) then return end
    _,DebuffClass=UnitClass(xUnit)
    if not DebuffClass then DebuffClass=HealBot_Class_En[HEALBOT_WARRIOR] end

    prevDebuff["name"]=button.aura.debuff.name or "x"
    prevDebuff["type"]=button.aura.debuff.type or "x"
    prevDebuff["iconid"]=button.aura.debuff.iconId or "x"
    prevDebuff["priority"]=button.aura.debuff.priority or 99
    button.aura.debuff.type=false
    button.aura.debuff.priority=99
    for x,_ in pairs(curDebuffs) do
        curDebuffs[x]=nil;
    end
    local z=1
    if not UnitIsDeadOrGhost(xUnit) or UnitIsFeignDeath(xUnit) then
        while true do
            local dName,deBuffTexture,bCount,debuff_type,debuffDuration,expirationTime,unitCaster,_,_,spellId,_,isBossDebuff = UnitDebuff(xUnit,z)
            if dName then
                z = z +1
                HealBot_addCurDebuffs(dName,deBuffTexture,bCount,debuff_type,debuffDuration,expirationTime,spellId,unitCaster,xUnit,isBossDebuff,button)
            else
                break
            end 
        end
        z=1
        while true do
            local dName,deBuffTexture,bCount,debuff_type,debuffDuration,expirationTime,unitCaster,_,_,spellId,_,isBossDebuff  = UnitBuff(xUnit,z)
            if dName then
                z = z +1
                if HealBot_Globals.HealBot_Custom_Debuffs[dName] then 
                    HealBot_addCurDebuffs(dName,deBuffTexture,bCount,debuff_type,debuffDuration,expirationTime,spellId,unitCaster,xUnit,isBossDebuff,button)
                end
            else
                break
            end 
        end
        for dName,_ in pairs(HealBot_CustomDebuff_RevDurLast) do
            if not curDebuffs[dName] and HealBot_CustomDebuff_RevDurLast[dName][xUnit] then HealBot_CustomDebuff_RevDurLast[dName][xUnit]=nil end
        end
    end
    local dPrio = button.aura.debuff.priority
    for dName,_ in pairs(curDebuffs) do
        local checkthis=false;
        local spellCD=0
 
        if HealBot_Config_Cures.IgnoreOnCooldownDebuffs and not curDebuffs[dName]["isCustom"] then 
            spellCD=HealBot_Options_retDebuffWatchTargetCD(curDebuffs[dName]["type"])
            if spellCD>1.5 and spellCD<12 then 
                local nCheck=(GetTime()+spellCD)-0.1
                HealBot_luVars["MaskAuraDCheck"]=nCheck
                HealBot_luVars["MaskAuraReCheck"]=true
                for _,dButton in pairs(HealBot_Unit_Button) do
                    if dButton.unit~=xUnit and dButton.aura.debuff.name and dButton.aura.debuff.type~=HEALBOT_CUSTOM_en then
                        dButton.aura.checks=1
                    end
                end
            end
        end
        if curDebuffs[dName]["priority"]<dPrio then
            if dName~=prevDebuff["name"] then
                local WatchTarget, WatchGUID=nil,nil
                if curDebuffs[dName]["isCustom"] then
                    checkthis=true --WatchTarget={["Raid"]=true,} 
                elseif spellCD<=1.5 then
                    WatchTarget, WatchGUID=HealBot_Options_retDebuffWatchTarget(curDebuffs[dName]["type"],xGUID);
                else
                    WatchTarget=nil
                end
 
                if WatchTarget then 
                    if WatchTarget["Raid"] then
                        checkthis=true;
                    elseif WatchTarget["Party"] and (UnitInParty(xUnit) or xGUID==HealBot_Data["PGUID"]) then
                        checkthis=true;
                    elseif WatchTarget["Self"] and xGUID==HealBot_Data["PGUID"] then
                        checkthis=true
                    elseif WatchTarget[strsub(DebuffClass,1,4)] then
                        checkthis=true;
                    elseif WatchTarget["PvP"] and UnitIsPVP("player") then
                        checkthis=true;
                    elseif WatchTarget["Name"] and xGUID==WatchGUID then
                        checkthis=true;
                    elseif WatchTarget["Focus"] and UnitIsUnit(xUnit, "focus") then
                        checkthis=true;
                    elseif WatchTarget["MainTanks"] and HealBot_Panel_IsTank(xGUID) then
                        checkthis=true;
                    elseif WatchTarget["MyTargets"] then
                        local myhTargets=HealBot_GetMyHealTargets();
                        for i=1, #myhTargets do
                            if xGUID==myhTargets[i] then
                                checkthis=true;
                                break
                            end
                        end
                    end
                end
            else
                checkthis=true
            end
        end 
        if checkthis then
            button.aura.debuff.type=curDebuffs[dName]["type"]
            button.aura.debuff.name=dName
            button.aura.debuff.iconId="DEBUFF!"..dName.."!"..curDebuffs[dName]["spellId"]
            button.aura.debuff.priority=curDebuffs[dName]["priority"]
            dPrio=curDebuffs[dName]["priority"]
        end
    end
 
    if not button.aura.debuff.type then 
        HealBot_ClearDebuff(button)
    end
 
    if button.aura.debuff.name then
        if button.aura.debuff.name~=prevDebuff["name"] or button.aura.debuff.type~=prevDebuff["type"] then
            local inSpellRange = HealBot_UnitInRange(button, HealBot_luVars["dSpell"])
            if HealBot_Config_Cures.CDCshownAB and (HealBot_Globals.HealBot_Custom_Debuffs_ShowBarCol[button.aura.debuff.name]==nil) then
                if inSpellRange>(HealBot_Config_Cures.HealBot_CDCWarnRange_Aggro-3) then
                    HealBot_Action_UpdateAggro(xUnit,"debuff",debuffCodes[button.aura.debuff.type], 0)
                end
            end
            if HealBot_Config_Cures.ShowDebuffWarning and inSpellRange>(HealBot_Config_Cures.HealBot_CDCWarnRange_Screen-3) then
                if HealBot_Globals.CDCBarColour[button.aura.debuff.name] then
                    UIErrorsFrame:AddMessage(HealBot_GetUnitName(xUnit, xGUID).." suffers from "..button.aura.debuff.name, 
                                             HealBot_Globals.CDCBarColour[button.aura.debuff.name].R,
                                             HealBot_Globals.CDCBarColour[button.aura.debuff.name].G,
                                             HealBot_Globals.CDCBarColour[button.aura.debuff.name].B,
                                             1, UIERRORS_HOLD_TIME);
                elseif button.aura.debuff.type == HEALBOT_CUSTOM_en then
                    local customDebuffPriority=HEALBOT_CUSTOM_en.."10"
                    if HealBot_GlobalsDefaults.HealBot_Custom_Debuffs[button.aura.debuff.name] then
                        customDebuffPriority=HEALBOT_CUSTOM_en..HealBot_GlobalsDefaults.HealBot_Custom_Debuffs[button.aura.debuff.name]
                    end
                    UIErrorsFrame:AddMessage(HealBot_GetUnitName(xUnit, xGUID).." suffers from "..button.aura.debuff.name,                                             
                                             HealBot_Globals.CDCBarColour[customDebuffPriority].R,
                                             HealBot_Globals.CDCBarColour[customDebuffPriority].G,
                                             HealBot_Globals.CDCBarColour[customDebuffPriority].B,
                                             1, UIERRORS_HOLD_TIME);
                else
                    UIErrorsFrame:AddMessage(HealBot_GetUnitName(xUnit, xGUID).." suffers from "..button.aura.debuff.name, 
                                             HealBot_Config_Cures.CDCBarColour[button.aura.debuff.type].R,
                                             HealBot_Config_Cures.CDCBarColour[button.aura.debuff.type].G,
                                             HealBot_Config_Cures.CDCBarColour[button.aura.debuff.type].B,
                                             1, UIERRORS_HOLD_TIME);
                end
            end
            if HealBot_Config_Cures.SoundDebuffWarning and inSpellRange>(HealBot_Config_Cures.HealBot_CDCWarnRange_Sound-3) then
                HealBot_PlaySound(HealBot_Config_Cures.SoundDebuffPlay)
            end
 
            if inSpellRange >-1 then
                HealBot_Action_UpdateDebuffButton(button)
            else
                HealBot_Action_ResetUnitStatus(button)
            end
        end
        if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Current_Skin][button.frame]["SHOWDEBUFF"] and (HealBot_Data["PGUID"]==xGUID or UnitIsVisible(xUnit)) then
            if button.aura.debuff.name and curDebuffs[button.aura.debuff.name]["texture"] then
                local debuffID=button.aura.debuff.iconId
                if button.aura.debuff.iconId and HealBot_UnitIcons[xUnit][prevDebuff["iconid"]] and button.aura.debuff.iconId~=prevDebuff["iconid"] then
                    HealBot_UnitIcons[xUnit][prevDebuff["iconid"]]["EXPIRE"]=1
                    HealBot_HoT_Update(button, prevDebuff["iconid"])
                end
                if (curDebuffs[button.aura.debuff.name]["expirationTime"] or 0)==0 then curDebuffs[button.aura.debuff.name]["expirationTime"]=hbNoEndTime end
                if not curDebuffs[button.aura.debuff.name]["bCount"] then curDebuffs[button.aura.debuff.name]["bCount"]=1 end
                if not HealBot_UnitIcons[xUnit][debuffID] then 
                    HealBot_UnitIcons[xUnit][debuffID]={} 
                    HealBot_UnitIcons[xUnit][debuffID]["TEXTURE"]=curDebuffs[button.aura.debuff.name]["texture"]
                    HealBot_UnitIcons[xUnit][debuffID]["DEBUFF"]=true
                end
                if (HealBot_UnitIcons[xUnit][debuffID]["COUNT"] or -1)~=curDebuffs[button.aura.debuff.name]["bCount"] then
                    HealBot_UnitIcons[xUnit][debuffID]["COUNT"]=curDebuffs[button.aura.debuff.name]["bCount"]
                    if not HealBot_Globals.HealBot_Custom_Debuffs_RevDur[button.aura.debuff.name] then
                        HealBot_UnitIcons[xUnit][debuffID]["EXPIRE"]=curDebuffs[button.aura.debuff.name]["expirationTime"]+1
                    else
                        HealBot_UnitIcons[xUnit][debuffID]["EXPIRE"]=99
                    end
                elseif not HealBot_UnitIcons[xUnit][debuffID]["EXPIRE"] then 
                    if HealBot_Globals.HealBot_Custom_Debuffs_RevDur[button.aura.debuff.name] then
                        HealBot_UnitIcons[xUnit][debuffID]["EXPIRE"]=99
                    else
                        HealBot_UnitIcons[xUnit][debuffID]["EXPIRE"]=curDebuffs[button.aura.debuff.name]["expirationTime"]+1 
                    end
                end
                if not HealBot_UnitIcons[xUnit][debuffID]["ICON"] then HealBot_UnitIcons[xUnit][debuffID]["ICON"]=0 end
                if HealBot_Globals.HealBot_Custom_Debuffs_RevDur[button.aura.debuff.name] then
                    if HealBot_UnitIcons[xUnit][debuffID]["EXPIRE"]==99 then
                        HealBot_UnitIcons[xUnit][debuffID]["EXPIRE"]=HealBot_CustomDebuff_RevDurLast[button.aura.debuff.name][xUnit]
                        HealBot_HoT_Update(button, debuffID)
                    end
                else
                    if HealBot_UnitIcons[xUnit][debuffID]["EXPIRE"]~=curDebuffs[button.aura.debuff.name]["expirationTime"] then
                        HealBot_UnitIcons[xUnit][debuffID]["EXPIRE"]=curDebuffs[button.aura.debuff.name]["expirationTime"]
                        HealBot_HoT_Update(button, debuffID)
                    end
                end
            end
        end
        HealBot_OnEvent_UnitThreat(xUnit)
    end
end

local function HealBot_doAuraDebuffUnit(button)
    if HealBot_luVars["DebuffCheck"] and (HealBot_Config_Cures.DebuffWatchInCombat or not HealBot_Data["UILOCK"]) then
        if UnitIsFriend("player",button.unit) then
            HealBot_CheckUnitDebuffs(button)
        elseif Healbot_Config_Skins.Icons[Healbot_Config_Skins.Current_Skin][button.frame]["SHOWBUFF"] then
            HealBot_HasMyBuffs(button) 
        end
    end
end

local function HealBot_SetUnitBuffTimer(hbGUID,buffName,endtime)
    if not HealBot_PlayerBuff[hbGUID] then
        HealBot_PlayerBuff[hbGUID]={}
    end
    if HealBot_ShortBuffs[buffName] then 
        HealBot_PlayerBuff[hbGUID][buffName] = endtime-HealBot_Config_Buffs.ShortBuffTimer
    else
        HealBot_PlayerBuff[hbGUID][buffName] = endtime-HealBot_Config_Buffs.LongBuffTimer
    end
    if not HealBot_luVars["CheckPlayerBuffsTime"] or HealBot_PlayerBuff[hbGUID][buffName] < HealBot_luVars["CheckPlayerBuffsTime"] then
        HealBot_luVars["CheckPlayerBuffsTime"]=HealBot_PlayerBuff[hbGUID][buffName]
        HealBot_luVars["CheckPlayerBuffsGUID"]=hbGUID
    end
end

local function HealBot_HasBuffTypes(spellName, pBuffTypes)
    local hasBuffTypes = false
    if (HealBot_BuffNameTypes[spellName]) then
        local index = 0
        local name = nil
        local found = false
        for _,v in pairs(HealBot_BuffNameTypes[spellName]) do
            index = index + 1
            if (pBuffTypes[v]) then
                found = true
            else
                found = false
            end
            --print("v:"..v.." found:"..tostring(found))
            if index == 1 then
                hasBuffTypes = found
            else
                hasBuffTypes = hasBuffTypes and found
            end
        end
    end
    return hasBuffTypes
end

local function HealBot_CheckUnitBuffs(button)
    local xGUID=button.guid
    local xUnit=button.unit
    if not xUnit or not UnitExists(xUnit) or not UnitIsPlayer(xUnit) then return end
    local _,BuffClass=UnitClass(xUnit)
    if not BuffClass then BuffClass=HealBot_Class_En[HEALBOT_WARRIOR] end
    local y = 1;

    for x,_ in pairs(PlayerBuffs) do
        PlayerBuffs[x]=nil;
    end
    for x,_ in pairs(PlayerBuffTypes) do
        PlayerBuffTypes[x]=nil;
    end

    while true do
        local bName,_,_,_,_,w,_,_,_, spellID, canApplyAura = UnitAura(xUnit,y,"HELPFUL") -- Done
        if bName then
            y = y + 1;
            if (HealBot_BuffNameTypes[bName]) then
                for _,v in pairs(HealBot_BuffNameTypes[bName]) do
                    PlayerBuffTypes[v]=true
                end
            end
            
            if not hbExcludeBuffSpells[spellID] then
                if HealBot_Buff_Aura2Item[bName] then 
                    bName=HealBot_Buff_Aura2Item[bName] 
                end
                PlayerBuffs[bName]=true
                if HealBot_CheckBuffs[bName] then
                    if w-GetTime()>0 then
                        HealBot_SetUnitBuffTimer(xGUID,bName,w)
                    elseif HealBot_PlayerBuff[xGUID] and HealBot_PlayerBuff[xGUID][bName] then
                        if HealBot_PlayerBuff[xGUID][bName]==HealBot_luVars["CheckPlayerBuffsTime"] then
                            HealBot_PlayerBuff[xGUID][bName]=nil
                            HealBot_luVars["ResetCheckBuffsTime"]=GetTime()+5
                        else
                            HealBot_PlayerBuff[xGUID][bName]=nil
                        end
                    end
                end
            end
        else
            break
        end
    end 

    if HealBot_PlayerBuff[xGUID] then
        local PlayerBuffsGUID=HealBot_PlayerBuff[xGUID]
        for z,_ in pairs (PlayerBuffsGUID) do
            if not PlayerBuffs[z] then
                if PlayerBuffsGUID[z]==HealBot_luVars["CheckPlayerBuffsTime"] then
                    PlayerBuffsGUID[z]=nil
                    HealBot_luVars["ResetCheckBuffsTime"]=GetTime()+5
                else
                    PlayerBuffsGUID[z]=nil
                end
            end
        end
        for x,_ in pairs(PlayerBuffs) do
            if HealBot_PlayerBuff[xGUID][x] and HealBot_PlayerBuff[xGUID][x] < GetTime() then
                PlayerBuffs[x]=nil
            end
        end
    end
    
    local bName=nil;
    for k in pairs(HealBot_BuffWatch) do
        if not PlayerBuffs[HealBot_BuffWatch[k]] then
            local checkthis=false;
            local WatchTarget, WatchGUID=HealBot_Options_retBuffWatchTarget(HealBot_BuffWatch[k], xGUID);
            local z, x = nil, nil
            if HealBot_GetSpellId(HealBot_BuffWatch[k]) then
                z, x = GetSpellCooldown(HealBot_BuffWatch[k]);
            elseif UnitIsUnit("player",xUnit) and HealBot_Buff_ItemID[HealBot_BuffWatch[k]] then
                local getCD = false
                if HealBot_BuffWatch[k]~=HEALBOT_EVER_BLOOMING_FROND then
                    getCD = true
                elseif not IsInRaid() and not UnitAffectingCombat("player") then
                    getCD = true
                    local mPct, hPct = 100, 100
                    if button.mana.max>1000 then
                        mPct=floor((button.mana.current/button.mana.max)*100)
                    end
                    if button.health.current>button.health.max and button.health.max>1000 then
                        hPct=floor((button.health.current/button.health.max)*100)
                    end
                    if mPct>HealBot_Globals.minManaBloom and hPct>HealBot_Globals.minHealthBloom then
                        getCD=false
                    else
                        local mCheck=GetTime()+1
                        if not HealBot_ReCheckBuffsTime or HealBot_ReCheckBuffsTime>mCheck then
                            HealBot_ReCheckBuffsTime=mCheck
                            HealBot_ReCheckBuffsTimed[HealBot_ReCheckBuffsTime]=xGUID
                        elseif HealBot_ReCheckBuffsTime<mCheck then
                            HealBot_ReCheckBuffsTimed[mCheck]=xGUID
                        end
                    end
                end
                if getCD then
                    z, x = GetItemCooldown(HealBot_Buff_ItemID[HealBot_BuffWatch[k]]) -- Using the name returns errors
                end
            end
            if not x then
                -- Spec change within that last few secs - buff outdated so do nothing
                -- HealBot_AddDebug("HealBot_CheckUnitBuffs spec change")
            elseif x<2 then
                if hbStanceBuffs[HealBot_BuffWatch[k]] then
                    local index = GetShapeshiftForm() or 0
                    if hbStanceBuffs[HealBot_BuffWatch[k]]~=index then checkthis=true end
                elseif WatchTarget["Raid"] then
                    checkthis=true;
                elseif WatchTarget["Party"] then 
                    if (UnitInParty(xUnit) or xGUID==HealBot_Data["PGUID"]) then checkthis=true; end
                elseif WatchTarget["Self"] then
                    if xGUID==HealBot_Data["PGUID"] then checkthis=true end
                elseif WatchTarget[strsub(BuffClass,1,4)] then
                    checkthis=true
                elseif WatchTarget["PvP"] then
                    if UnitIsPVP(xUnit) then checkthis=true; end
                elseif WatchTarget["PvE"] then
                    if not UnitIsPVP(xUnit) then checkthis=true; end
                elseif WatchTarget["Name"] then
                    if xGUID==WatchGUID then checkthis=true; end
                elseif WatchTarget["Focus"] then
                    if UnitIsUnit(xUnit, "focus") then checkthis=true; end
                elseif WatchTarget["MainTanks"] and HealBot_Panel_IsTank(xGUID) then
                    checkthis=true;
                elseif WatchTarget["MyTargets"] then
                    local myhTargets=HealBot_GetMyHealTargets();
                    for i=1, #myhTargets do
                        if xGUID==myhTargets[i] then
                            checkthis=true;
                            break;
                        end
                    end
                end
            elseif not HealBot_ReCheckBuffsTime or HealBot_ReCheckBuffsTime>z+x then
                HealBot_ReCheckBuffsTime=z+x
                HealBot_ReCheckBuffsTimed[HealBot_ReCheckBuffsTime]=xGUID
            elseif HealBot_ReCheckBuffsTime<z+x then
                HealBot_ReCheckBuffsTimed[z+x]=xGUID
            end
            if checkthis then
                if HealBot_HasBuffTypes(HealBot_BuffWatch[k], PlayerBuffTypes) then
                    altActive=true
                else
                    bName=HealBot_BuffWatch[k];
                    break
                end
            end
        end
    end
    if bName then
        if button.aura.buff.name~=bName then
            button.aura.buff.name=bName;
            if HealBot_UnitInRange(button, bName) >-1 then
                HealBot_Action_UpdateBuffButton(button)
            else
                HealBot_Action_ResetUnitStatus(button)
            end
        end
    elseif button.aura.buff.name then 
        HealBot_ClearBuff(button)
    end 
end

local function HealBot_doAuraBuff(button)
    if UnitExists(button.unit) then 
        HealBot_CheckUnitBuffs(button)
    end
end

local function HealBot_doAuraHoT(button)
    if UnitExists(button.unit) then
        HealBot_HasMyBuffs(button) 
    end
end

local function HealBot_qClearUnitAggro(button)
    button.aggro.finish=true
    HealBot_luVars["DelayClearAggro"]=true
end

local function HealBot_CheckAggroUnits(button)
    if UnitExists(button.unit) then
        local z, y=HealBot_CalcThreat(button.unit)
        local x=y+z
        if x==0 then
            HealBot_qClearUnitAggro(button)
        elseif z~=button.aggro.threatpct then
            HealBot_Action_UpdateAggro(button.unit,true,y,z)
        end
    else
        HealBot_qClearUnitAggro(button)
    end
end

local function HealBot_Update_Fast()
    HealBot_luVars["fastSwitch"]=HealBot_luVars["fastSwitch"]+1
    
    if HealBot_luVars["fastSwitch"]<2 then
        for xUnit,xButton in pairs(HealBot_Unit_Button) do
            if not xButton.status.reserved then
                if UnitExists(xUnit) then
                    if xButton.aura.checks<2 then
                        HealBot_doAuraDebuffUnit(xButton)
                        xButton.aura.checks=2
                    elseif xButton.checks.range < GetTime() then 
                        HealBot_Range_CheckTime(xButton)
                        if xButton.aggro.threatpct > 0 then 
                            HealBot_CheckAggroUnits(xButton) 
                        end
                        if xButton.status.update>0 then
                            if xButton.status.update<2 then
                                xButton.status.update=0
                                HealBot_Action_Refresh(xButton)
                            else
                                HealBot_Action_ResetUnitAttribs(xButton)
                                xButton.status.update=1
                            end
                        elseif xButton.status.current>4 then
                            local uRange=HealBot_UnitInRange(xButton)
                            if uRange~=xButton.status.range then
                                HealBot_Action_Refresh(xButton)
                                HealBot_Action_UpdateHealsInButton(xButton)
                                HealBot_Action_UpdateAbsorbsButton(xButton)
                            elseif xButton.status.dirarrow>-998 then
                                HealBot_Action_ShowDirectionArrow(xButton)
                            end
                        end
                    elseif xButton.aura.checks<4 then
                        if xButton.aura.checks<2 then 
                            HealBot_doAuraDebuffUnit(xButton) 
                        elseif xButton.aura.checks<3 and Healbot_Config_Skins.Icons[Healbot_Config_Skins.Current_Skin][xButton.frame]["SHOWBUFF"] then 
                            HealBot_doAuraHoT(xButton)
                        elseif (HealBot_Config_Buffs.BuffWatchInCombat or not HealBot_Data["UILOCK"]) then 
                            HealBot_doAuraBuff(xButton) 
                        end
                        xButton.aura.checks=xButton.aura.checks+1
                    elseif xButton.checks.health < GetTime() then
                        HealBot_Health_CheckTime(xButton)
                        if xButton.status.offline and UnitIsConnected(xUnit) then
                            xButton.status.offline = false
                            HealBot_Action_setNameText(xButton) 
                        elseif not xButton.status.offline and not UnitIsConnected(xUnit) then
                            xButton.status.offline = GetTime()
                            if not HealBot_NameTextUpdate[xButton.unit] then
                                HealBot_NameTextUpdate[xButton.unit] = GetTime()+15
                            end
                        elseif xButton.status.dead then
                            HealBot_Action_UpdateTheDeadButton(xButton)
                        else
                            if xButton.health.incoming>0 then HealBot_HealsInUpdate(xButton) end
                            if xButton.health.absorbs>0 then HealBot_AbsorbsUpdate(xButton) end
                            HealBot_Reset_UnitHealth(xButton)
                        end
                    end
                else
                    HealBot_Action_Refresh(xButton)
                    HealBot_Action_UpdateHealsInButton(xButton)
                    HealBot_Action_UpdateAbsorbsButton(xButton)
                    xButton.status.reserved=true
                end
            elseif UnitExists(xUnit) then
                xButton.status.reserved=false
                xButton.status.update=2
            end
        end
    else
        if HealBot_luVars["EnemyBarsOn"] then
            for xUnit,xButton in pairs(HealBot_Unit_Button) do
                if xButton then
                    if xButton.status.enemy > -1 then
                        if UnitExists(xUnit) then
                            if UnitIsDeadOrGhost(xUnit) then
                                xButton.health.current=0
                                HealBot_RecalcHeals(xButton)
                            else
                                local hlth=UnitHealth(xUnit)
                                local maxhlth=HealBot_UnitMaxHealth(xUnit)
                                local xGUID=UnitGUID(xUnit)
                                if xGUID then
                                    if xGUID~=xButton.guid then
                                        if HealBot_UnitData[xGUID] then
                                            HealBot_UnitData[xGUID]["NAME"]=HealBot_GetUnitName(xUnit)
                                            HealBot_UnitData[xGUID]["UNIT"]=xUnit
                                        end
                                        xButton.guid=xGUID
                                        xButton.health.current=hlth
                                        xButton.health.max=maxhlth
                                        HealBot_AbsorbsUpdate(xButton)
                                        HealBot_HealsInUpdate(xButton)
                                        HealBot_RecalcHeals(xButton)
                                    else
                                        local name, _, _, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(xUnit) 
                                        if name and HealBot_luVars["EnemyBarsCastOn"]==1 then
                                            if GetTime()+0.01>endTime and xButton.spells.castpct>-1 then
                                                xButton.spells.castpct=-1
                                                HealBot_Action_SetBar3Value(xButton)
                                            else
                                                local l=endTime-startTime
                                                local c=((GetTime()*1000)-startTime)
                                                local pct=ceil((c/l)*100)
                                                if xButton.spells.castpct~=pct then
                                                    xButton.spells.castpct=pct
                                                    HealBot_Action_SetBar3Value(xButton, name)
                                                end
                                            end
                                        elseif xButton.spells.castpct>-1 then
                                            xButton.spells.castpct = -1
                                            HealBot_Action_SetBar3Value(xButton)
                                        end
                                        if xButton.health.incoming~=(UnitGetIncomingHeals(xUnit) or 0) then
                                            xButton.health.incoming=(UnitGetIncomingHeals(xUnit) or 0)
                                            HealBot_Action_setHealthText(xButton)
                                            HealBot_Action_UpdateHealsInButton(xButton)
                                        end
                                        if xButton.health.absorbs~=UnitGetTotalAbsorbs(xUnit) then
                                            xButton.health.absorbs=UnitGetTotalAbsorbs(xUnit)
                                            HealBot_Action_setHealthText(xButton)
                                            HealBot_Action_UpdateAbsorbsButton(xButton)
                                        end
                                        if hlth~=xButton.health.current or maxhlth~=xButton.health.max then
                                            xButton.health.current=hlth
                                            xButton.health.max=maxhlth
                                            HealBot_Action_setHealthText(xButton)
                                            HealBot_Action_UpdateHealthButton(xButton)
                                        end
                                    end
                                else
                                    xButton.status.enemy = 0
                                    HealBot_AbsorbsUpdate(xButton)
                                    HealBot_HealsInUpdate(xButton)
                                    HealBot_Action_ResetUnitStatus(xButton)
                                end
                            end
                        else
                            xButton.status.enemy = 0
                            HealBot_AbsorbsUpdate(xButton)
                            HealBot_HealsInUpdate(xButton)
                            HealBot_Action_ResetUnitStatus(xButton)
                        end
                    end
                end
            end
        end
        if HealBot_Data["TIPUSE"] and HealBot_Globals.TooltipUpdate and HealBot_Data["TIPUNIT"] then HealBot_Action_RefreshTooltip() end
        if HealBot_luVars["MaskAuraDCheck"]<GetTime() and HealBot_luVars["MaskAuraReCheck"] then
            HealBot_luVars["MaskAuraReCheck"]=nil
            HealBot_CheckAllDebuffs()
        end
        if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Current_Skin]["SHOW"] and HealBot_luVars["DelayClearAggro"] then 
            HealBot_doClearAggro() 
        end
        HealBot_luVars["fastSwitch"]=0
    end
end

local lTimer,eTimer=0,GetTime()
function HealBot_OnUpdate(self)
    if HealBot_luVars["hbLoaded"] and not HealBot_Data["UNITSLOCK"] then
        lTimer=GetTime()-eTimer
        eTimer=GetTime()
        HealBot_Timers["HB1Inc"] = HealBot_Timers["HB1Inc"]+lTimer;
        HealBot_Timers["HB2Inc"] = HealBot_Timers["HB2Inc"]+lTimer;
        HealBot_Timers["HBaInc"] = HealBot_Timers["HBaInc"]+lTimer;
        if HealBot_Data["PGUID"] and HealBot_Timers["HB1Inc"]>=HealBot_Timers["HB1Th"] then
            HealBot_Timers["HB1Inc"] = 0;
            HealBot_Update_Slow()
        end
        if HealBot_Timers["HB2Inc"]>HealBot_Timers["HB2Th"] then
            HealBot_Timers["HB2Inc"]=0
            HealBot_Update_Fast()
        end
        if HealBot_Timers["HBaInc"]>HealBot_Timers["HBaTh"] then
            HealBot_Timers["HBaInc"]=0
            HealBot_Action_UpdateBars()
        end
    end
end

function HealBot_useCrashProtection()
    local y,z = GetNumMacros()
    local maxMacroSlots=18
    if Healbot_Config_Skins.Protection[Healbot_Config_Skins.Current_Skin]["GENERALMACRO"] then
        maxMacroSlots=100
        z=y
    end
    local x=maxMacroSlots-z
    if Healbot_Config_Skins.Protection[Healbot_Config_Skins.Current_Skin]["CRASH"] then
        for z=0,5 do
            local w=GetMacroBody(HealBot_Config.CrashProtMacroName.."_"..z)
            if w then
                x=x+1
            end
        end
    end
    if x<5 then
        Healbot_Config_Skins.Protection[Healbot_Config_Skins.Current_Skin]["CRASH"]=false
        HealBot_Options_CrashProt:SetChecked(Healbot_Config_Skins.Protection[Healbot_Config_Skins.Current_Skin]["CRASH"])
        HealBot_Options_CrashProt:Disable();
    else
        HealBot_Options_CrashProt:Enable();
    end
end

function HealBot_Register_Aggro()
    HealBot:RegisterEvent("UNIT_COMBAT")
    HealBot:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    HealBot:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
end

function HealBot_UnRegister_Aggro()
    HealBot:UnregisterEvent("UNIT_COMBAT")
    HealBot:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    HealBot:UnregisterEvent("UNIT_THREAT_LIST_UPDATE")
    HealBot_EndAggro() 
end

function HealBot_Register_IncHeals()
    HealBot:RegisterEvent("UNIT_HEAL_PREDICTION")
end

function HealBot_UnRegister_IncHeals()
    HealBot:UnregisterEvent("UNIT_HEAL_PREDICTION")
    HealBot_IncHeals_ClearAll()
end


function HealBot_Register_ReadyCheck()
    HealBot:RegisterEvent("READY_CHECK")
    HealBot:RegisterEvent("READY_CHECK_CONFIRM")
    HealBot:RegisterEvent("READY_CHECK_FINISHED")
end

function HealBot_UnRegister_ReadyCheck()
    HealBot:UnregisterEvent("READY_CHECK")
    HealBot:UnregisterEvent("READY_CHECK_CONFIRM")
    HealBot:UnregisterEvent("READY_CHECK_FINISHED")
    HealBot_luVars["rcEnd"]=GetTime()
end

function HealBot_Register_Mana()
    HealBot:RegisterEvent("UNIT_POWER_UPDATE")
    HealBot:RegisterEvent("UNIT_MAXPOWER")
end

function HealBot_UnRegister_Mana()
    HealBot:UnregisterEvent("UNIT_POWER_UPDATE")
    HealBot:UnregisterEvent("UNIT_MAXPOWER")
end

local hbTankUnit=nil
function HealBot_SetTankUnit(unit)
    hbTankUnit=unit
end

function HealBot_CalcThreat(unit)
    local z,y=0,0
    if hbTankUnit and UnitExists(hbTankUnit.."target") and UnitIsEnemy(hbTankUnit, hbTankUnit.."target") then 
        _, _, z, _, _ = UnitDetailedThreatSituation(unit, hbTankUnit.."target")
        z=floor(z or 0)
        y = UnitThreatSituation(unit, hbTankUnit.."target")
    elseif UnitExists(unit.."target") and UnitIsEnemy(unit, unit.."target") then 
        _, _, z, _, _ = UnitDetailedThreatSituation(unit, unit.."target")
        z=floor(z or 0)
        y = UnitThreatSituation(unit, unit.."target")
    elseif UnitExists("playertarget") and UnitIsEnemy("player", "playertarget") then 
        _, _, z, _, _ = UnitDetailedThreatSituation(unit, "playertarget") 
        z=floor(z or 0)
        y = UnitThreatSituation(unit, "playertarget")
    else
        z=0
        y = UnitThreatSituation(unit)
    end
    if not y then y=0 end
    if z>=HealBot_Globals.aggro3pct then
        y=3
        if z>100 then z=100 end
    elseif z>=HealBot_Globals.aggro2pct and y<2 then
        y=2 
    elseif z>0 and y<1 then
        y=1
    end
    return z, y
end

local function HealBot_UnitNameOnly(unitName)
    local uName=nil
    if unitName then
        uName=strtrim(string.match(unitName, "^[^-]*"))
    end
    return uName
end

local function HealBot_OnEvent_ReadyCheckUpdate(unit,response)
    local xButton=HealBot_Unit_Button[unit]
    if HealBot_luVars["rcEnd"] and xButton and Healbot_Config_Skins.Icons[Healbot_Config_Skins.Current_Skin][xButton.frame]["SHOWRC"] then 
        local bar = _G["HealBot_Action_HealUnit"..xButton.id.."Bar"]
        if bar then
            local iconName = _G[bar:GetName().."Icon16"];
            if response=="Y" then
                iconName:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
            elseif response=="W" then
                iconName:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
            else
                iconName:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
            end
            iconName:SetAlpha(1);
        end
    end
end

local function HealBot_OnEvent_hbReadyCheck(unitName,timer)
    local uName=HealBot_UnitNameOnly(unitName)
    local lUnit=HealBot_Panel_RaidUnit(nil,unitName)
    if not HealBot_luVars["rcEnd"] or HealBot_luVars["rcEnd"]<GetTime()+timer then
        if lUnit then
            HealBot_luVars["rcEnd"]=GetTime()+timer
            if HealBot_Unit_Button[lUnit] then HealBot_OnEvent_ReadyCheckUpdate(lUnit,"Y") end
            for xUnit,xButton in pairs(HealBot_Unit_Button) do
                if xUnit~=lUnit and UnitIsPlayer(xUnit) then
                    HealBot_OnEvent_ReadyCheckUpdate(xUnit,"W")
                end
            end
        end
    end
end

local function HealBot_OnEvent_hbReadyCheckConfirmed(hbGUID,response)
    local xUnit=hbGUID
    if HealBot_UnitData[hbGUID] then 
        xUnit=HealBot_UnitData[hbGUID]["UNIT"]
    end
    if HealBot_Unit_Button[xUnit] then
        HealBot_OnEvent_ReadyCheckUpdate(xUnit,response)
    end
end

local HealBotAddonSummary={}
local HealBotAddonIncHeals={}
local hbExtra1, hbExtra2=nil, nil
local function HealBot_OnEvent_AddonMsg(self,addon_id,msg,distribution,sender_id)
    local inc_msg=msg
    local sender_id = HealBot_UnitNameOnly(sender_id)
    if not HealBotAddonSummary[sender_id..": "..addon_id] then
        HealBotAddonSummary[sender_id..": "..addon_id]=string.len(inc_msg)
    else
        HealBotAddonSummary[sender_id..": "..addon_id]=HealBotAddonSummary[sender_id..": "..addon_id]+string.len(inc_msg)
    end
    if addon_id=="HealBot" then
        local datatype, datamsg, hbExtra1, hbExtra2 = string.split(":", inc_msg)
        if datatype=="R" then
            HealBot_luVars["VersionRequest"]=sender_id
            if HealBot_Options_Timer[130] then HealBot_Options_Timer[130]=nil end
        elseif datatype=="S" then
            HealBot_Vers[sender_id]=datamsg
            HealBot_AddDebug(sender_id..":  "..datamsg);
            HealBot_Comms_CheckVer(sender_id, datamsg)
        elseif datatype=="G" then
            HealBot_Comms_SendAddonMsg("HealBot", "H:"..HEALBOT_VERSION, 4, sender_id)
            if not HealBot_Vers[sender_id] then
                HealBot_Comms_SendAddonMsg("HealBot", "G", 4, sender_id)
            end
        elseif datatype=="F" then
            HealBot_Comms_SendAddonMsg("HealBot", "C:"..HEALBOT_VERSION, 4, sender_id)
            if not HealBot_Vers[sender_id] then
                HealBot_Comms_SendAddonMsg("HealBot", "F", 4, sender_id)
            end
        elseif datatype=="H" then
            HealBot_Vers[sender_id]=datamsg
            HealBot_AddDebug(sender_id..":  "..datamsg);
            HealBot_Options_setMyGuildMates(sender_id)
            HealBot_Comms_CheckVer(sender_id, datamsg)
        elseif datatype=="C" then
            HealBot_Vers[sender_id]=datamsg
            HealBot_AddDebug(sender_id..":  "..datamsg);
            HealBot_Options_setMyFriends(sender_id)
            HealBot_Comms_CheckVer(sender_id, datamsg)
        elseif datatype=="X" and HealBot_Globals.AcceptSkins==1 then
            HealBot_Options_ShareSkinRec("X", sender_id.."!"..datamsg)
        elseif datatype=="Y" then
            HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_SHARESKINACPT..sender_id);
            HealBot_Options_ShareSkinSend("Z", datamsg, sender_id)
        elseif datatype=="Z" then
            HealBot_Options_ShareSkinRec("Z", hbExtra1, datamsg, hbExtra2)
        elseif datatype=="RC" then
            local doRC=false
            for j=1,10 do
                if Healbot_Config_Skins.Icons[Healbot_Config_Skins.Current_Skin][j]["SHOWRC"] then
                    doRC=true
                end
            end
            if doRC then
                if datamsg=="I" then
                    HealBot_OnEvent_hbReadyCheck(hbExtra1,hbExtra2)
                else
                    HealBot_OnEvent_hbReadyCheckConfirmed(hbExtra1,hbExtra2)
                end
            end
        end
    end
end

local extShareSkin={}
function HealBot_ShareSkinSendMsg(cmd, msg, unitName)
    if unitName==HEALBOT_ABOUT_URL then
        if cmd=="Init" then
            extShareSkin={[1]=msg}
            HealBot_luVars["saveSkinsTabSize"]=1
            HealBot_AddChat(HEALBOT_SHARE_INSTRUCTION)
        elseif cmd and msg then
            HealBot_luVars["saveSkinsTabSize"]=HealBot_luVars["saveSkinsTabSize"]+1
            extShareSkin[HealBot_luVars["saveSkinsTabSize"]]=cmd.."!"..msg
            if cmd=="Complete" then
                local ssStr=extShareSkin[1]
                for j=2,#extShareSkin do
                    ssStr=ssStr.."\n"..extShareSkin[j] 
                end
                HealBot_Options_ShareExternalEditBox:SetText(ssStr)
            end
        end
    else
        if cmd=="Init" then
            HealBot_luVars["shareSkinsTabSize"]=0
            HealBot_Options_ShareSkinStatus:SetValue(0)
            HealBot_Options_ShareSkinStatusf:SetText("0%")
            HealBot_Options_ShareSkinStatusf:SetTextColor(1,1,1,1)
            HealBot_Options_ShareSkinStatus:SetStatusBarColor(0.3,0.3,0.9,1)
        else
            if string.len(msg)>200 then
                local p1=strsub(msg,1,200)
                local p2=strsub(msg,201)
                table.insert(hbShareSkins,unitName.."!".."Z:1:"..cmd..":"..p1);
                table.insert(hbShareSkins,unitName.."!".."Z:2:"..cmd..":"..p2);
                HealBot_luVars["shareSkinsTabSize"]=HealBot_luVars["shareSkinsTabSize"]+1
            else
                table.insert(hbShareSkins,unitName.."!".."Z:0:"..cmd..":"..msg);
            end
            HealBot_luVars["shareSkinsTabSize"]=HealBot_luVars["shareSkinsTabSize"]+1
        end
    end
end

function HealBot_GetInfo()
    return HealBot_Vers
end

function HealBot_Split(msg, char)
    local x,y=nil,nil
    for x,_ in pairs(arrg) do
        arrg[x]=nil;
    end
    while (strfind(msg, char) ) do
        x, y = strfind(msg, char);
        tinsert(arrg, strsub(msg, 1, x-1));
        msg = strsub(msg, y+1, strlen(msg));
    end
    if ( strlen(msg) > 0 ) then
        tinsert(arrg, msg);
    end
    return arrg;
end

function HealBot_VehicleHealth(unit)
    local vGUID=HealBot_UnitGUID(unit)
    if not vGUID then
        HealBot_NoVehicle(unit)
        return 100,100
    end
    return UnitHealth(unit), UnitHealthMax(unit)  
end

local function HealBot_OnEvent_LeavingVehicle(self, unit)
    local xUnit = HealBot_UnitID(unit)
    if xUnit and HealBot_UnitInVehicle[xUnit] then
        HealBot_SetAggro(xUnit)
    end
end

function HealBot_retIsInVehicle(unit)
    return HealBot_UnitInVehicle[unit]
end

function HealBot_CheckAllUnitVehicle(unit)
    if unit then
        HealBot_VehicleCheck[unit]=2
    else
        for xUnit,_ in pairs(HealBot_Unit_Button) do
            HealBot_VehicleCheck[xUnit]=1
        end
    end
end

local function HealBot_OnEvent_UnitAura(unit)
    local _,_,xButton = HealBot_UnitID(unit)
    if xButton then
        HealBot_AuraChecks(xButton)
    end
end

local function HealBot_OnEvent_PlayerTargetChanged(doRecalc)
    if HealBot_luVars["TargetHealsOn"] then
        if (Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["TALWAYSSHOW"] or not HealBot_Data["UILOCK"]) and 
           (Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["TONLYFRIEND"]==false or UnitIsFriend("target", "player")) and doRecalc then
            HealBot_nextRecalcParty(0); HealBot_Data["REFRESH"]=true;
        end
        local xButton=HealBot_Unit_Button["target"]
        if xButton then
            if UnitExists("target") then
                if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["TONLYFRIEND"]==false or UnitIsFriend("target", "player") then
                    if HealBot_UnitData["target"] then HealBot_UnitData["target"]["EEXCLUDE"]=nil end
                    HealBot_OnEvent_UnitAura("target") 
                    HealBot_OnEvent_UnitHealth("target");
                elseif Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["TONLYFRIEND"] then
                    if not HealBot_UnitData["target"] then HealBot_UnitData["target"]={} end
                    HealBot_UnitData["target"]["EEXCLUDE"]=true
                end
            elseif Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["TALWAYSSHOW"] then
                if not HealBot_UnitData["target"] then HealBot_UnitData["target"]={} end
                HealBot_UnitData["target"]["NAME"]=HEALBOT_WORD_RESERVED..":".."target"
            end
            HealBot_Action_setNameText(xButton)
            HealBot_RecalcHeals(xButton) 
        end
    end
    if UnitName("target") and HealBot_retHbFocus("target") then
        HealBot_Panel_clickToFocus("Show")
    end
    if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Current_Skin]["TBAR"] then
        if not HealBot_Data["UILOCK"] or Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Current_Skin]["TBARCOMBAT"] then
            for xUnit,xButton in pairs(HealBot_Unit_Button) do
                if UnitExists("target") and not UnitIsEnemy("target", "player") and UnitIsUnit(xUnit, "target") then
                    HealBot_Action_UpdateAggro(xUnit,"target",xButton.aggro.status,0)
                elseif xButton.aggro.status==-2 then
                     HealBot_Action_UpdateAggro(xUnit,"off",nil,0)
                end
            end
        end
    end
    if HealBot_Unit_Button["playertarget"] then 
        HealBot_Action_setNameText(HealBot_Unit_Button["playertarget"])
        HealBot_RecalcHeals(HealBot_Unit_Button["playertarget"]) 
    end
end

local function HealBot_ClearLowMana()
    for xUnit,xButton in pairs(HealBot_Unit_Button) do
        local bar = _G["HealBot_Action_HealUnit"..xButton.id.."Bar"]
        if bar then
            local iconName = _G[bar:GetName().."Icontm1"];
            iconName:SetAlpha(0)
            iconName = _G[bar:GetName().."Icontm2"];
            iconName:SetAlpha(0)
            iconName = _G[bar:GetName().."Icontm3"];
            iconName:SetAlpha(0)
        end
    end
end

local needReset=nil
local function HealBot_OnEvent_PlayerRegenDisabled(self)
    HealBot_Data["UILOCK"]=true
    HealBot_luVars["DelayLockdownCheck"]=GetTime()+5
    local y,z = IsInInstance()
    if y and z=="raid" and UnitExists("boss1") then
        local _, _, _, _, _, _, _, instanceMapID, _ = GetInstanceInfo()
        if instanceMapID==1861 then
            if UnitName("boss1") and UnitName("boss1")=="MOTHER" then  -- This needs localizing at some point
                HealBot_luVars["27YardsOnly"]=true
                HealBot_AddDebug("27YardsOnly=true")
            end
        end
    end
    if not HealBot_Data["PGUID"] then
        HealBot_Load("playerRD")      
        needReset=true
    else
        HealBot_RecalcParty();
    end
    if HealBot_Config_Buffs.BuffWatch and HealBot_Config_Buffs.BuffWatchInCombat==false then
        for xUnit,xButton in pairs(HealBot_Unit_Button) do
            if xButton.aura.buff.name then
                HealBot_ClearBuff(xButton)
            end
        end
    end
    if HealBot_Config_Cures.DebuffWatch and HealBot_Config_Cures.DebuffWatchInCombat==false then
        for xUnit,xButton in pairs(HealBot_Unit_Button) do
            if xButton.aura.debuff.name then 
                HealBot_ClearDebuff(xButton)
            end
        end
    end
    if Healbot_Config_Skins.Highlight[Healbot_Config_Skins.Current_Skin]["TBARCOMBAT"]==false and HealBot_luVars["HighlightTarget"] then
        HealBot_OnEvent_PlayerTargetChanged(false)
    end        
    if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["LOWMANACOMBAT"]==false then HealBot_ClearLowMana() end
    HealBot_Options_RaidTargetUpdate()
end

local function HealBot_OnEvent_UnitCombat(unit)
    local xUnit,xGUID,xButton = HealBot_UnitID(unit)
    if xUnit and not UnitIsDeadOrGhost("player") then
        if UnitAffectingCombat(xUnit) and UnitIsVisible(xUnit) then
            if not HealBot_Data["UILOCK"] and HealBot_Globals.EnAutoCombat then
                local z, y=HealBot_CalcThreat(xUnit)
                local x=y+z
                if x>0 then 
                    HealBot_OnEvent_PlayerRegenDisabled()
                end
            end
            if Healbot_Config_Skins.Aggro[Healbot_Config_Skins.Current_Skin]["SHOW"] and xButton.status.enemy < 0 then
                HealBot_SetAggro(xUnit)
            end
        end
    end
end

function HealBot_HasUnitBuff(buffName, unit, casterUnitID)
    if UnitExists(unit) then
        local k = 1
        while true do
            local x,_,_,_,_,expirationTime, caster,_,_,spellID = UnitAura(unit, k, "HELPFUL"); 
            if x then
                if casterUnitID then
                    if x==buffName and casterUnitID==(caster or "0") and not hbExcludeSpells[spellID] then
                        return true, expirationTime
                    end
                elseif x==buffName and not hbExcludeSpells[spellID] then
                    return true, expirationTime
                end
                k=k+1
            else
                break
            end
        end
    end
    return false;
end

function HealBot_HasDebuff(debuffSpellID, unit)
    local x,_,_,_,_,_,_,_ = UnitDebuff(unit,debuffSpellID)
    if x then
        return true;
    end
    return false;
end

function HealBot_BuffsCheck(button)
    if HealBot_luVars["BuffCheck"] and (HealBot_Config_Buffs.BuffWatchInCombat or not HealBot_Data["UILOCK"]) and UnitIsFriend("player",button.unit) and button.aura.checks>3 then
        button.aura.checks=3
    end
end

function HealBot_CheckAllBuffs(unit)
    if unit then
        if HealBot_Unit_Button[unit] then
            HealBot_BuffsCheck(HealBot_Unit_Button[unit])
        end
    else
        for _,xButton in pairs(HealBot_Unit_Button) do
            HealBot_BuffsCheck(xButton)
        end
    end
end

function HealBot_AuraChecks(button)
    if HealBot_luVars["DebuffCheck"] and (HealBot_Config_Cures.DebuffWatchInCombat or not HealBot_Data["UILOCK"]) then
        button.aura.checks=1
    elseif Healbot_Config_Skins.Icons[Healbot_Config_Skins.Current_Skin][button.frame]["SHOWBUFF"] then
        button.aura.checks=2
    elseif HealBot_Config_Buffs.BuffWatchInCombat or not HealBot_Data["UILOCK"] then
        button.aura.checks=3
    end
end

function HealBot_CheckAllDebuffs(unit)
    if unit then
        if HealBot_Unit_Button[unit] then
            HealBot_AuraChecks(HealBot_Unit_Button[unit])
        end
    else
        for _,xButton in pairs(HealBot_Unit_Button) do
            HealBot_AuraChecks(xButton)
        end
    end
end

function HealBot_ClearDebuff(button)
	if button.aura.debuff.name then
		button.aura.debuff.type = false;
		button.aura.debuff.name = false;
		button.aura.debuff.priority = 99;
        if HealBot_UnitIcons[button.unit] and button.aura.debuff.iconId then
            if HealBot_UnitIcons[button.unit][button.aura.debuff.iconId] then
                HealBot_UnitIcons[button.unit][button.aura.debuff.iconId]["EXPIRE"]=1
                HealBot_HoT_Update(button, button.aura.debuff.iconId)
            end
            if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Current_Skin][button.frame]["CLASSONBAR"] then
                HealBot_Action_SetClassIconTexture(button)
            end
        end
		button.aura.debuff.iconId = false;
        if button.aggro.status>4 then
            HealBot_Action_UpdateAggro(button.unit,false,nil,0)
        end
        HealBot_Action_UpdateDebuffButton(button)
	end
end

function HealBot_ClearBuff(button)
    button.aura.buff.name=false
    HealBot_Action_UpdateBuffButton(button)
end

function HealBot_CheckPlayerMana(hbGUID, unit)
    if ((UnitPowerType(unit) or 1)==0) then
        hbManaPlayers[hbGUID]=unit
    else
        local _,uClass=UnitClass(unit)
        uClass=strsub((uClass or "XXXX"),1,4)
        if uClass=="DRUI" then
            hbManaPlayers[hbGUID]=unit
        end
    end
end

function HealBot_EnteringCombat()
    if HealBot_Globals.DisableToolTipInCombat and HealBot_Data["TIPUNIT"] then
        HealBot_Action_HideTooltipFrame()
    end
    HealBot_Data["UILOCK"]=true
end

local function HealBot_OnEvent_UnitNameUpdate(self,unit)
    if HealBot_Unit_Button[unit] then
        local xGUID=HealBot_UnitGUID(unit)
        if xGUID then
            local xButton=HealBot_Unit_Button[unit]
            if xButton then
                if xButton.guid~=xGUID then 
                    HealBot_PrepUnitNameUpdate(unit, xGUID, xButton.guid) 
                else
                    HealBot_PrepUnitNameUpdate(unit, xGUID)
                end
            end
        end
    end
 end

function HealBot_GetUnitName(unit, hbGUID)
    local uName=nil
    if unit and UnitExists(unit) then
        local xGUID=hbGUID or "0"
        uName=HealBot_customTempUserName[xGUID] or (UnitName(unit))
    end
    return uName
end

function HealBot_setFocusHeals(id)
    if id and Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["NAME"]==HEALBOT_FOCUS_en then
        HealBot_luVars["FocusHealsOn"]=Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["STATE"]
    else
        for id=1,11 do
            if Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["NAME"]==HEALBOT_FOCUS_en then
                HealBot_luVars["FocusHealsOn"]=Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["STATE"]
                break
            end
        end
    end
    HealBot_Panel_focusHeal(HealBot_luVars["FocusHealsOn"])
end

function HealBot_setPetHeals(id)
    if id and Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["NAME"]==HEALBOT_OPTIONS_PETHEALS_en then
        HealBot_luVars["PetHealsOn"]=Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["STATE"]
    else
        for id=1,11 do
            if Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["NAME"]==HEALBOT_OPTIONS_PETHEALS_en then
                HealBot_luVars["PetHealsOn"]=Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["STATE"]
                break
            end
        end
    end
end

function HealBot_setTargetHeals(id)
    if id and Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["NAME"]==HEALBOT_OPTIONS_TARGETHEALS_en then
        HealBot_luVars["TargetHealsOn"]=Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["STATE"]
    else
        for id=1,11 do
            if Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["NAME"]==HEALBOT_OPTIONS_TARGETHEALS_en then
                HealBot_luVars["TargetHealsOn"]=Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["STATE"]
                break
            end
        end
    end
end

function HealBot_setEnemyBars(id)
    HealBot_luVars["EnemyBarsCastOn"]=0
    if id and Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["NAME"]==HEALBOT_CUSTOM_CASTBY_ENEMY_en then
        local fId=Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["FRAME"]
        HealBot_luVars["EnemyBarsOn"]=Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["STATE"]
        if HealBot_luVars["EnemyBarsOn"] and Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Current_Skin][fId]["POWERSIZE"]>0 then
            HealBot_luVars["EnemyBarsCastOn"]=1
        end
    else
        for id=1,11 do
            if Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["NAME"]==HEALBOT_CUSTOM_CASTBY_ENEMY_en then
                local fId=Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["FRAME"]
                HealBot_luVars["EnemyBarsOn"]=Healbot_Config_Skins.HealGroups[Healbot_Config_Skins.Current_Skin][id]["STATE"]
                if HealBot_luVars["EnemyBarsOn"] and Healbot_Config_Skins.HealBar[Healbot_Config_Skins.Current_Skin][fId]["POWERSIZE"]>0 then
                    HealBot_luVars["EnemyBarsCastOn"]=1
                end
                break
            end
        end
    end
    if HealBot_luVars["EnemyBarsOn"] then
        HealBot:RegisterEvent("UNIT_TARGET")
    else
        HealBot:UnregisterEvent("UNIT_TARGET")
    end
end

local cUnitGUID={}
function HealBot_UnitGUID(unit)
    if unit and UnitExists(unit) then
        local xGUID=UnitGUID(unit)
        if not UnitIsPlayer(unit) then
            if unit=="pet" then
                local s=string.gsub(HealBot_GetUnitName(unit), " ", "")
                xGUID=UnitGUID("player")..s
            elseif UnitPlayerOrPetInRaid(unit) and strsub(unit,1,7)=="raidpet" then
                local raidId=strsub(unit,8)
                if raidId and UnitGUID("raid"..raidId) then
                    local s=string.gsub(HealBot_GetUnitName(unit), " ", "")
                    xGUID=UnitGUID("raid"..raidId)..s
                end
            elseif UnitPlayerOrPetInParty(unit) and strsub(unit,1,8)=="partypet" then
                local partyId=strsub(unit,9)
                if partyId and UnitGUID("party"..partyId) then
                    local s=string.gsub(HealBot_GetUnitName(unit), " ", "")
                    xGUID=UnitGUID("party"..partyId)..s
                end
            end
        end
        return xGUID
    end
    return nil
end

function HealBot_UnitPet(unit)
    local vUnit=nil
    if unit=="player" then
        vUnit="pet"
    elseif strsub(unit,1,4)=="raid" then
        vUnit="raidpet"..strsub(unit,5)
    elseif strsub(unit,1,5)=="party" then
        vUnit="partypet"..strsub(unit,6)
    end
    return vUnit
end

function HealBot_OnEvent_PartyMembersChanged(self)
    if HealBot_Data["UILOCK"] then HealBot_luVars["InCombatUpdate"]=true end
    HealBot_luVars["CheckSkin"]=true
    if HealBot_luVars["IsSolo"] and HealBot_Config.DisableSolo then
        HealBot_Options_DisableCheck()
    end
    HealBot_Data["REFRESH"]=true;
    if Healbot_Config_Skins.Protection[Healbot_Config_Skins.Current_Skin]["COMBAT"] then
        for xUnit,xButton in pairs(HealBot_Unit_Button) do
            if not UnitExists(xUnit) and HealBot_UnitData[xUnit] then
                HealBot_UnitData[xUnit]["NAME"]=HEALBOT_WORD_RESERVED..":"..xUnit
                HealBot_Action_ResetUnitStatus(xButton) 
            end
        end
    end
    HealBot_Action_CheckReserved()
end

function HealBot_retHighlightTarget()
    return HealBot_luVars["HighlightTarget"] or "nil"
end

function HealBot_retHbFocus(unit)
    local unitName=HealBot_GetUnitName(unit)
    if HealBot_Globals.FocusMonitor[unitName] then
        if HealBot_Globals.FocusMonitor[unitName]=="all" then
            return true
        else
            local _,z = IsInInstance()
            if z=="pvp" or z == "arena" then 
                if HealBot_Globals.FocusMonitor[unitName]=="bg" then
                    return true
                end
            elseif z==HealBot_Globals.FocusMonitor[unitName] then
                return true
            else
                z = GetRealZoneText()
                if z==HealBot_Globals.FocusMonitor[unitName] then
                    return true
                end
            end
        end
    end
    return false
end

local function HealBot_OnEvent_ReadyCheck(self,unitName,timer)
    local isLeader = UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")
    if isLeader then
        HealBot_luVars["rcEnd"]=nil
        HealBot_luVars["isLeader"]=true
        HealBot_Comms_SendAddonMsg("HealBot", "RC:I:"..unitName..":"..timer, HealBot_luVars["AddonMsgType"], HealBot_Data["PNAME"])
    else
        HealBot_luVars["isLeader"]=false
    end
end

local function HealBot_OnEvent_ReadyCheckConfirmed(self,unit,response)
    local xUnit,xGUID = HealBot_UnitID(unit)
    if xUnit then 
		local hbResponse="N"
        if response then hbResponse="Y" end
        HealBot_Comms_SendAddonMsg("HealBot", "RC:U:"..xGUID..":"..hbResponse, HealBot_luVars["AddonMsgType"], HealBot_Data["PNAME"])
    end
end

function HealBot_RaidTargetToggle(switch)
    if switch then
        HealBot:RegisterEvent("RAID_TARGET_UPDATE")
        HealBot_OnEvent_RaidTargetUpdate(nil)
    else
        HealBot:UnregisterEvent("RAID_TARGET_UPDATE")
        for xUnit,xButton in pairs(HealBot_Unit_Button) do
            if HealBot_TargetIcons[xUnit] then
                HealBot_TargetIcons[xUnit]=nil
                HealBot_RaidTargetUpdate(xButton,nil)
            end
        end
    end
end

local function HealBot_OnEvent_FocusChanged(self)
    if HealBot_luVars["FocusHealsOn"] then 
        HealBot_nextRecalcParty(0); HealBot_Data["REFRESH"]=true;
        local xButton=HealBot_Unit_Button["focus"]
        if xButton then
            if UnitExists("focus") then
                if Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["FONLYFRIEND"]==false or UnitIsFriend("focus", "player") then
                    if HealBot_UnitData["focus"] then HealBot_UnitData["focus"]["EEXCLUDE"]=nil end
                    HealBot_OnEvent_UnitAura("focus") 
                    HealBot_OnEvent_UnitHealth("focus");
                elseif Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["FONLYFRIEND"] then
                    if not HealBot_UnitData["focus"] then HealBot_UnitData["focus"]={} end
                    HealBot_UnitData["focus"]["EEXCLUDE"]=true
                end
            elseif Healbot_Config_Skins.Healing[Healbot_Config_Skins.Current_Skin]["FALWAYSSHOW"] then
                if not HealBot_UnitData["focus"] then HealBot_UnitData["focus"]={} end
                HealBot_UnitData["focus"]["NAME"]=HEALBOT_WORD_RESERVED..":".."focus"
            end
            HealBot_RecalcHeals(xButton)
        end
    end
end

local function HealBot_OnEvent_SystemMsg(self,msg)
    if type(msg)=="string" then
        if (string.find(msg, HB_ONLINE)) or (string.find(msg, HB_OFFLINE)) then
            msg = gsub(msg, "|Hplayer:([^%c^%d^%s^%p]+)|h(.+)|h", "%1")
            local uName = msg:match("([^%c^%d^%s^%p]+)")
            local xGUID=HealBot_RetUnitNameGUIDs(uName)
            if HealBot_UnitData[xGUID] and UnitExists(HealBot_UnitData[xGUID]["UNIT"]) then
                local xButton=HealBot_Unit_Button[HealBot_UnitData[xGUID]["UNIT"]]
                if xButton then 
                    if (string.find(msg, HB_ONLINE)) then
                        xButton.status.offline = false
                    else
                        xButton.status.offline = GetTime()
                        if not HealBot_NameTextUpdate[xButton.unit] then
                            HealBot_NameTextUpdate[xButton.unit] = GetTime()+15
                        end
                    end
                    HealBot_Action_setNameText(xButton) 
                    HealBot_Action_ResetUnitStatus(xButton);
                end
            end
        end
    end
end

function HealBot_OnEvent_TalentsChanged(self)
    if HealBot_UnitData[HealBot_Data["PGUID"]] then HealBot_UnitData[HealBot_Data["PGUID"]]["SPEC"] = " " end
    HealBot_luVars["CheckTalents"]=true
end

function HealBot_OnEvent_SpellsChanged(self, arg1)
    if arg1==0 then return; end
    if UnitIsDeadOrGhost("player") then return end
    HealBot_OnEvent_TalentsChanged(self)
    HealBot_setOptions_Timer(550)
end

function HealBot_OnEvent_PlayerEnteringWorld(self)
    if not HealBot_Data["PGUID"] then
        HealBot_Load("playerEW")      
    else
        for _,xButton in pairs(HealBot_Unit_Button) do
            if not xButton.status.reserved then
                if xButton.checks.health < GetTime() then HealBot_Health_CheckTime(xButton) end
                if xButton.checks.range < GetTime() then HealBot_Range_CheckTime(xButton) end
            end
        end
    end
    HealBot_luVars["DoUpdates"]=true
	HealBot_luVars["IsReallyFighting"]=true
    
    if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDEPARTYF"] then
        HealBot_trackHiddenFrames["PARTY"]=true
        HealBot_Options_DisablePartyFrame()
        HealBot_Options_PlayerTargetFrames:Enable();
        if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDEPTF"] then
            HealBot_trackHiddenFrames["PLAYER"]=true
            HealBot_Options_DisablePlayerFrame()
            HealBot_Options_DisablePetFrame()
            HealBot_Options_DisableTargetFrame()
        end
    end
    if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDEBOSSF"] then
        HealBot_trackHiddenFrames["MINIBOSS"]=true
        HealBot_Options_DisableMiniBossFrame()
    end
    if Healbot_Config_Skins.General[Healbot_Config_Skins.Current_Skin]["HIDERAIDF"] then
        HealBot_trackHiddenFrames["RAID"]=true
        HealBot_Options_DisableRaidFrame()
    end
    HealBot_setOptions_Timer(180)
    HealBot_setOptions_Timer(185)
    HealBot_setOptions_Timer(188)
    HealBot_setOptions_Timer(190)
    HealBot_Register_Events()
    HealBot_setOptions_Timer(120)
    HealBot_CheckAllUnitVehicle()
    for x=1,10 do
        HealBot_Action_setPoint(x)
    end
    HealBot_nextRecalcParty(0.2)
end

function HealBot_OnEvent_PlayerLeavingWorld(self)
    if HealBot_Config.Profile==2 then
        HealBot_Options_hbProfile_saveClass()
    end
    HealBot_luVars["DoUpdates"]=false
    HealBot_EndAggro() 
    HealBot_UnRegister_Events();
    HealBot_nextRecalcParty(20)
end

local function HealBot_OnEvent_UnitSpellcastSent(self,caster,unitName,spellRank,spellID)
    local xUnit=nil
    local uscName = HealBot_UnitNameOnly(unitName)
    local spellName = GetSpellInfo(spellID)
    if uscName=="" then
        if spellName==HEALBOT_MENDPET and UnitExists("pet") then
            uscName=HealBot_GetUnitName("pet")
            xUnit=pet
        elseif not IsAttackSpell(spellName) and HealBot_luVars["TargetUnitID"] and UnitExists(HealBot_luVars["TargetUnitID"]) then
            uscName=HealBot_GetUnitName(HealBot_luVars["TargetUnitID"])
            xUnit=HealBot_luVars["TargetUnitID"]
        end
    elseif HealBot_luVars["TargetUnitID"] and UnitExists(HealBot_luVars["TargetUnitID"]) and uscName==HealBot_GetUnitName(HealBot_luVars["TargetUnitID"]) then
        xUnit=HealBot_luVars["TargetUnitID"]
    end
    if caster=="player" and uscName == HEALBOT_WORDS_UNKNOWN then
        uscName = HealBot_GetCorpseName(uscName)
    end
    if not uscName and HealBot_luVars["TargetUnitID"] and UnitExists(HealBot_luVars["TargetUnitID"]) then
        uscName=HealBot_GetUnitName(HealBot_luVars["TargetUnitID"])
        if UnitExists("target") and HealBot_GetUnitName("target")==uscName then
            xUnit="target"
        else
            xUnit=HealBot_luVars["TargetUnitID"]
        end
    end
    if (spellName==HEALBOT_MASS_RESURRECTION or spellName==HEALBOT_ABSOLUTION or spellName==HEALBOT_ANCESTRAL_VISION or spellName==HEALBOT_REAWAKEN or spellName==HEALBOT_REVITALIZE or 
        spellName==HEALBOT_RESURRECTION or spellName==HEALBOT_ANCESTRALSPIRIT or spellName==HEALBOT_REBIRTH or spellName==HEALBOT_REDEMPTION or spellName==HEALBOT_REVIVE or spellName==HEALBOT_RESUSCITATE)
        and UnitExists(xUnit) and HealBot_Unit_Button[xUnit]  then
        local xButton=HealBot_Unit_Button[xUnit]
        xButton.status.update=1
        if caster=="player" and uscName then
            if Healbot_Config_Skins.Chat[Healbot_Config_Skins.Current_Skin]["NOTIFY"]>1 and Healbot_Config_Skins.Chat[Healbot_Config_Skins.Current_Skin]["RESONLY"] then
                if spellName==HEALBOT_MASS_RESURRECTION or spellName==HEALBOT_ABSOLUTION or spellName==HEALBOT_ANCESTRAL_VISION or spellName==HEALBOT_REAWAKEN or spellName==HEALBOT_REVITALIZE then           
                    HealBot_CastNotify(HEALBOT_OPTIONS_GROUPHEALS,spellName,xUnit)
                else
                    HealBot_CastNotify(uscName,spellName,xUnit)
                end
            end
        elseif HealBot_Spells[spellName] then
            HealBot_luVars["CastingTarget"] = xUnit;
            if Healbot_Config_Skins.Chat[Healbot_Config_Skins.Current_Skin]["NOTIFY"]>1 and Healbot_Config_Skins.Chat[Healbot_Config_Skins.Current_Skin]["RESONLY"]==false then
                HealBot_CastNotify(uscName,spellName,xUnit)
            end
        end
    end
end

function HealBot_GetCorpseName(cName)
    local z = _G["GameTooltipTextLeft1"];
    local x = z:GetText();
    if (x) then
        cName = string.gsub(x, HEALBOT_TOOLTIP_CORPSE, "")
    end
    return cName
end

function HealBot_ResetCheckBuffsTime()
    HealBot_luVars["CheckPlayerBuffsTime"]=GetTime()+10050000
    for z,_ in pairs(HealBot_PlayerBuff) do
        local PlayerBuffsGUID=HealBot_PlayerBuff[z]
        for y,_ in pairs (PlayerBuffsGUID) do
            if PlayerBuffsGUID[y]<0 then
                PlayerBuffsGUID[y]=nil
            elseif PlayerBuffsGUID[y] < HealBot_luVars["CheckPlayerBuffsTime"] then
                HealBot_luVars["CheckPlayerBuffsTime"]=PlayerBuffsGUID[y]
                HealBot_luVars["CheckPlayerBuffsGUID"]=z
            end
        end
    end
    if HealBot_luVars["CheckPlayerBuffsTime"]>GetTime()+10000000 then
        HealBot_luVars["CheckPlayerBuffsTime"]=nil
        HealBot_luVars["CheckPlayerBuffsGUID"]=false
    end
end

function HealBot_CastNotify(unitName,spell,unit)
    local z = Healbot_Config_Skins.Chat[Healbot_Config_Skins.Current_Skin]["NOTIFY"];
    local s = gsub(Healbot_Config_Skins.Chat[Healbot_Config_Skins.Current_Skin]["MSG"],"#s",spell)
    s = gsub(s,"#l",GetSpellLink(spell, ""))
    s = gsub(s,"#n",unitName)
    local w=nil;
    if z==6 then
        w=HealBot_Comms_GetChan(Healbot_Config_Skins.Chat[Healbot_Config_Skins.Current_Skin]["CHAN"]) 
        if not w then z=2 end
    end
    if z==5 and not IsInRaid() then z = 4 end
    if z==4 and GetNumGroupMembers()==0 then z = 2 end
    if z==3 and UnitIsPlayer(HealBot_luVars["CastingTarget"]) and UnitPlayerControlled(HealBot_luVars["CastingTarget"]) and HealBot_luVars["CastingTarget"]~="player" then
        s = gsub(s,unitName,HEALBOT_WORDS_YOU)
        SendChatMessage(s,"WHISPER",nil,unitName);
    elseif z==4 then
        local chanId=HealBot_Comms_GetChan(INSTANCE_CHAT)
        if not chanId then
            chanId=HealBot_Comms_GetChan(PARTY)
        end
        if chanId then
            SendChatMessage(s,"CHANNEL",nil,chanId);
        else
            local inInst=IsInInstance()
            if inInst and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
                SendChatMessage(s,"INSTANCE_CHAT",nil,nil);
            else
                SendChatMessage(s,"PARTY",nil,nil);
            end
        end
    elseif z==5 then
        local chanId=HealBot_Comms_GetChan(INSTANCE_CHAT)
        if not chanId then
            chanId=HealBot_Comms_GetChan(RAID)
        end
        if chanId then
            SendChatMessage(s,"CHANNEL",nil,chanId);
        else
            local inInst=IsInInstance()
            if inInst and IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
                SendChatMessage(s,"INSTANCE_CHAT",nil,nil);
            else
                SendChatMessage(s,"RAID",nil,nil);
            end
        end
    elseif z==6 then
        SendChatMessage(s,"CHANNEL",nil,w);
    else
        HealBot_AddChat(s);
    end
end

function HealBot_retHoTdetails(unit)
    return HealBot_UnitIcons[unit]
end

function HealBot_HoT_RemoveIconButton(button,removeAll)
    local huIcons=HealBot_UnitIcons[button.unit]
    if huIcons then
        for hotID,_ in pairs(huIcons) do
            HealBot_HoT_RemoveIcon(button, huIcons, hotID)
        end
    end
    for i=1,15 do
        HealBot_HoT_UpdateIcon(button, i, -1)
    end
    if removeAll then
        if button.aura.debuff.iconId then
            if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][button.frame]["SHOW"] and HealBot_TargetIcons[button.unit] then HealBot_RaidTargetUpdate(button, nil) end
        end
        if Healbot_Config_Skins.BarText[Healbot_Config_Skins.Current_Skin][button.frame]["CLASSONBAR"] and Healbot_Config_Skins.BarText[Healbot_Config_Skins.Current_Skin][button.frame]["CLASSTYPE"]==1 then
            if Healbot_Config_Skins.RaidIcon[Healbot_Config_Skins.Current_Skin][button.frame]["SHOW"] and HealBot_TargetIcons[button.unit] then HealBot_RaidTargetUpdate(button, nil) end
        end
    end
end

function HealBot_ToggelFocusMonitor(unit, zone)
    local unitName=HealBot_GetUnitName(unit)
    if HealBot_Globals.FocusMonitor[unitName] then
        if UnitExists("target") and unitName==HealBot_GetUnitName("target") then HealBot_Panel_clickToFocus("hide") end
        HealBot_Globals.FocusMonitor[unitName] = nil
    else
        HealBot_Globals.FocusMonitor[unitName] = zone
        if UnitExists("target") and HealBot_Globals.FocusMonitor[HealBot_GetUnitName("target")] then HealBot_Panel_clickToFocus("Show") end
    end
end

function HealBot_PlaySound(id)
    PlaySoundFile(LSM:Fetch('sound',id));
end

function HealBot_InitSpells()
    local sName,sRank,x = nil,nil,nil
    for x,_ in pairs(HealBot_SmartCast_Spells) do
        HealBot_SmartCast_Spells[x]=nil;
    end
  
    HealBot_Init_Spells_Defaults();

    if HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_PRIEST] then
        if HealBot_GetSpellId(HEALBOT_HEAL) then
            HealBot_SmartCast_Spells[HEALBOT_HEAL]="L"
        end
        if HealBot_GetSpellId(HEALBOT_FLASH_HEAL) then
            HealBot_SmartCast_Spells[HEALBOT_FLASH_HEAL]="S"
        end
	elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_DRUID] then
        if HealBot_GetSpellId(HEALBOT_HEALING_TOUCH) then
            HealBot_SmartCast_Spells[HEALBOT_HEALING_TOUCH]="L"
        end
        if HealBot_GetSpellId(HEALBOT_REJUVENATION) then
            HealBot_SmartCast_Spells[HEALBOT_REJUVENATION]="S"
        end
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_PALADIN] then
        if HealBot_GetSpellId(HEALBOT_HOLY_LIGHT) then
            HealBot_SmartCast_Spells[HEALBOT_HOLY_LIGHT]="L"
        end
        if HealBot_GetSpellId(HEALBOT_FLASH_OF_LIGHT) then
            HealBot_SmartCast_Spells[HEALBOT_FLASH_OF_LIGHT]="S"
        end
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_SHAMAN] then
        if HealBot_GetSpellId(HEALBOT_HEALING_SURGE) then
            HealBot_SmartCast_Spells[HEALBOT_HEALING_SURGE]="S"
        end
        if HealBot_GetSpellId(HEALBOT_HEALING_WAVE) then
            HealBot_SmartCast_Spells[HEALBOT_HEALING_WAVE]="L"
        end
    elseif HealBot_Data["PCLASSTRIM"]==HealBot_Class_En[HEALBOT_MONK] then
        if HealBot_GetSpellId(HEALBOT_ENVELOPING_MIST) then
            HealBot_SmartCast_Spells[HEALBOT_ENVELOPING_MIST]="L"
        end
        if HealBot_GetSpellId(HEALBOT_REVIVAL) then
            HealBot_SmartCast_Spells[HEALBOT_REVIVAL]="S"
        elseif HealBot_GetSpellId(HEALBOT_SOOTHING_MIST) then
            HealBot_SmartCast_Spells[HEALBOT_SOOTHING_MIST]="S"
        end
    end
    HealBot_Action_SetrSpell()
    HealBot_Init_SmartCast();
    HealBot_Options_ResetDoInittab(8)
end

function HealBot_Cycle_Skins()
    local n=getn(Healbot_Config_Skins.Skins)
    if n==Healbot_Config_Skins.Skin_ID then
        n=1
    else
        n=Healbot_Config_Skins.Skin_ID+1
    end
    HealBot_Options_Set_Current_Skin(Healbot_Config_Skins.Skins[n])
end

local ldb=nil
function HealBot_MMButton_Init()
    if LDBIcon and ldb and not LDBIcon:IsRegistered(HEALBOT_HEALBOT) then
        LDBIcon:Register(HEALBOT_HEALBOT, ldb, HealBot_Globals.MinimapIcon)
        HealBot_MMButton_Toggle()
    end
end

if LDB11 then
	ldb = LDB11:NewDataObject(HEALBOT_HEALBOT, {
		type = "launcher",
		label = HEALBOT_HEALBOT,
		icon = "Interface\\AddOns\\HealBot\\Images\\HealBot",
	})

	function ldb.OnClick(self, button)
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                HealBot_Cycle_Skins()
            else
                HealBot_TogglePanel(HealBot_Options)
            end
        elseif button == "RightButton" then
            if IsShiftKeyDown() then
                if HealBot_Config.DisableHealBot then
                    HealBot_Config.DisableHealBot=false
                else
                    HealBot_Config.DisableHealBot=true
                end
                HealBot_Options_DisableHealBotOpt:SetChecked(HealBot_Config.DisableHealBot)
                HealBot_Options_DisableCheck()
            else
                HealBot_SetResetFlag("SOFT")
            end
        else
            HealBot_TogglePanel(HealBot_Options)
        end
    end

	function ldb.OnTooltipShow(tt)
        tt:AddLine(HEALBOT_ADDON)
        tt:AddLine(" ")
        tt:AddLine(HEALBOT_LDB_LEFT_TOOLTIP)
        tt:AddLine(HEALBOT_LDB_SHIFTLEFT_TOOLTIP)
        tt:AddLine(" ")
        tt:AddLine(HEALBOT_LDB_RIGHT_TOOLTIP)
        tt:AddLine(HEALBOT_LDB_SHIFTRIGHT_TOOLTIP)
    end
end

function HealBot_MMButton_Toggle()
    if LDBIcon then
        if HealBot_Globals.MinimapIcon.hide==false then
            LDBIcon:Show(HEALBOT_HEALBOT)
        else
            LDBIcon:Hide(HEALBOT_HEALBOT)
        end
    end
end

local sSwitch=UnitLevel("player")*50
function HealBot_SmartCast(hlthDelta)
    local s=nil
    for sName,sType in pairs(HealBot_SmartCast_Spells) do
        if (HealBot_Spells[sName]) then
            if sType=="L" then
                if hlthDelta>sSwitch then s=sName end
            elseif not s then
                s=sName
            end
        end
    end
    return s;
end

function HealBot_UnitInRange(button, spellNameOveride) -- added by Diacono of Ursin
    local uRange=0
    if UnitGUID(button.unit)==HealBot_Data["PGUID"] then
        uRange = 1
    elseif CheckInteractDistance(button.unit,1) then
        uRange = 1
    elseif not HealBot_luVars["27YardsOnly"] then
        local spellName = spellNameOveride or button.spells.rangecheck
        if IsSpellInRange(spellName, button.unit) ~= nil then
            uRange = IsSpellInRange(spellName, button.unit)
        elseif IsItemInRange(spellName, button.unit) ~= nil then
            uRange = IsItemInRange(spellName, button.unit)
        elseif UnitInRange(button.unit) then
            uRange = 1
        else
            uRange = 0
        end
    else
        uRange = 0
    end
    if uRange==1 and not UnitInPhase(button.unit) then 
        uRange=0
    end
    if uRange==0 and not UnitIsVisible(button.unit) then 
        uRange=-1 
    end
    return uRange
end

local hbPi = math.pi
local hbaTan2 = math.atan2
local hbdMod = 108 / math.pi / 2;
function HealBot_Direction_Check(unit) 
    local direction, hbX, hbY = nil,nil,nil
    local px, py = HealBot_getUnitCoords("player")
    if px then
        local tx, ty = HealBot_getUnitCoords(unit)
        if tx then
            local pFacing = GetPlayerFacing();
            pFacing = pFacing < 0 and pFacing + hbPi * 2 or pFacing;
            direction = hbPi - hbaTan2(px - tx, ty - py) - pFacing;
            direction = floor(direction * hbdMod + 0.5) % 108
            hbX, hbY = (direction % 9) * 0.109375, floor(direction / 9) * 0.08203125;
        end
    elseif not HealBot_luVars["mapUpdate"] then
        HealBot_luVars["mapUpdate"]=GetTime()+5
    end
    return hbX, hbY, direction;
end

function HealBot_getUnitCoords(unit)
    if UnitIsPlayer(unit) then
        local uiMapID=C_Map.GetBestMapForUnit(unit)
        if uiMapID then
            local pos=C_Map.GetPlayerMapPosition(uiMapID, unit)
            if pos and pos.x and pos.y and pos.x > 0 and pos.y > 0 then
                return pos.x, pos.y
            end
        end
    end
    return nil, nil
end

function HealBot_getCurrentMapContinent()
    local mapInfo = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))

    while mapInfo.mapType~=2 do
        mapInfo = C_Map.GetMapInfo(mapInfo.parentMapID)
    end

    return mapInfo.mapID
end

function HealBot_ClearLocalArr(hbGUID, getTime)
    if HealBot_UnitData[hbGUID] then
        if (HealBot_UnitData[hbGUID]["TIME"] or 0)<getTime then
            if HealBot_PlayerBuff[hbGUID] then HealBot_PlayerBuff[hbGUID]=nil end
            if HealBot_luVars["CheckPlayerBuffsGUID"]==hbGUID then HealBot_luVars["ResetCheckBuffsTime"]=GetTime()+5 end
            if hbManaPlayers[hbGUID] then hbManaPlayers[hbGUID]=nil end
            if HealBot_Data["TIPUSE"] then HealBot_talentSpam(hbGUID,"remove",nil) end
            HealBot_UnitData[hbGUID]=nil
        end
    end
end

function HealBot_immediateClearLocalArr(hbGUID)
    if HealBot_UnitData[hbGUID] then
        if HealBot_UnitData[hbGUID]["UNIT"] then
            local xButton=HealBot_Unit_Button[HealBot_UnitData[hbGUID]["UNIT"]]
            if xButton then
                HealBot_ClearUnitAggro(xButton) 
            end
        end
        HealBot_cleanGUIDs[hbGUID]=GetTime()
    end
end

function HealBot_delClearLocalArr(hbGUID)
    HealBot_cleanGUIDs[hbGUID]=nil
end

function HealBot_ReloadUI()
    local msg="HealBot Requires UI Reload\n\nDue to Migrations from a version older than 5.0.x"
    StaticPopupDialogs["HEALBOT_OPTIONS_RELOADUI"] = {
        text = msg,
        button1 = HEALBOT_WORDS_YES,
        button2 = HEALBOT_WORDS_NO,
        OnAccept = function()
            ReloadUI();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1
    };

    StaticPopup_Show ("HEALBOT_OPTIONS_RELOADUI");
end

function HealBot_Options_ResetSetting(resetTab)
    if resetTab=="BUFF" then
        local msg="Healbot recommends resetting the buffs tab \n\n Continue?"
        StaticPopupDialogs["HEALBOT_OPTIONS_RESETSETTING"] = {
            text = msg,
            button1 = HEALBOT_WORDS_YES,
            button2 = HEALBOT_WORDS_NO,
            OnAccept = function()
                HealBot_Reset_Buffs()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1
        };
    elseif resetTab=="CUSTOM" then
        local msg="Healbot recommends resetting the custom debuffs tab \n\n Continue?"
        StaticPopupDialogs["HEALBOT_OPTIONS_RESETSETTING"] = {
            text = msg,
            button1 = HEALBOT_WORDS_YES,
            button2 = HEALBOT_WORDS_NO,
            OnAccept = function()
                HealBot_ResetCustomDebuffs()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1
        };
    end

    StaticPopup_Show ("HEALBOT_OPTIONS_RESETSETTING");
end

function HealBot_Copy_SpellCombos()
    local combo,button=nil,nil
    for x=1,3 do
        if x==1 then
            combo = HealBot_Config_Spells.EnabledKeyCombo;
        elseif x==2 then
            combo = HealBot_Config_Spells.DisabledKeyCombo;
        else
            combo = HealBot_Config_Spells.EnemyKeyCombo;
        end
        for y=1,15 do
            button = HealBot_Options_ComboClass_Button(y)
            if combo then
                combo[button] = combo[button..HealBot_Config.CurrentSpec]
                combo["Shift"..button] = combo["Shift"..button..HealBot_Config.CurrentSpec]
                combo["Ctrl"..button] = combo["Ctrl"..button..HealBot_Config.CurrentSpec]
                combo["Alt"..button] = combo["Alt"..button..HealBot_Config.CurrentSpec]
                combo["Ctrl-Shift"..button] = combo["Ctrl-Shift"..button..HealBot_Config.CurrentSpec]
                combo["Alt-Shift"..button] = combo["Alt-Shift"..button..HealBot_Config.CurrentSpec]
            end
        end
    end
    HealBot_Update_SpellCombos()
    HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_CONFIRMSPELLCOPY)
end

function HealBot_Reset_Spells()
    HealBot_DoReset_Spells(HealBot_Data["PCLASSTRIM"])
    HealBot_Globals.SmartCast=HealBot_GlobalsDefaults.SmartCast
    HealBot_Globals.SmartCastDebuff=HealBot_GlobalsDefaults.SmartCastDebuff
    HealBot_Globals.SmartCastBuff=HealBot_GlobalsDefaults.SmartCastBuff
    HealBot_Globals.SmartCastHeal=HealBot_GlobalsDefaults.SmartCastHeal
    HealBot_Globals.SmartCastRes=HealBot_GlobalsDefaults.SmartCastRes
    HealBot_Config.EnableHealthy=HealBot_ConfigDefaults.EnableHealthy
    HealBot_Update_SpellCombos()
    HealBot_Options_ResetDoInittab(2)
    HealBot_Options_Init(2)
    HealBot_Options_ComboClass_Text()
    HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_CONFIRMSPELLRESET)
end

function HealBot_Reset_Buffs()
    HealBot_DoReset_Buffs(HealBot_Data["PCLASSTRIM"])
    HealBot_Config_Buffs.BuffWatch=HealBot_Config_BuffsDefaults.BuffWatch
    HealBot_Config_Buffs.BuffWatchInCombat=HealBot_Config_BuffsDefaults.BuffWatchInCombat
    HealBot_Config_Buffs.BuffWatchWhenGrouped=HealBot_Config_BuffsDefaults.BuffWatchWhenGrouped
    HealBot_Config_Buffs.ShortBuffTimer=HealBot_Config_BuffsDefaults.ShortBuffTimer
    HealBot_Config_Buffs.LongBuffTimer=HealBot_Config_BuffsDefaults.LongBuffTimer
    HealBot_Update_BuffsForSpec("Buff")
    HealBot_Options_ResetDoInittab(5)
    HealBot_Options_Init(5)
    HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_CONFIRMBUFFSRESET)
    HealBot_setOptions_Timer(40)
end

function HealBot_Reset_Cures()
    HealBot_DoReset_Cures(HealBot_Data["PCLASSTRIM"])
    HealBot_Config_Cures.SoundDebuffWarning=HealBot_Config_CuresDefaults.SoundDebuffWarning
    HealBot_Config_Cures.DebuffWatch=HealBot_Config_CuresDefaults.DebuffWatch
    HealBot_Config_Cures.IgnoreClassDebuffs=HealBot_Config_CuresDefaults.IgnoreClassDebuffs
    HealBot_Config_Cures.IgnoreNonHarmfulDebuffs=HealBot_Config_CuresDefaults.IgnoreNonHarmfulDebuffs
    HealBot_Config_Cures.IgnoreFastDurDebuffs=HealBot_Config_CuresDefaults.IgnoreFastDurDebuffs
    HealBot_Config_Cures.IgnoreFastDurDebuffsSecs=HealBot_Config_CuresDefaults.IgnoreFastDurDebuffsSecs
    HealBot_Config_Cures.IgnoreOnCooldownDebuffs=HealBot_Config_CuresDefaults.IgnoreOnCooldownDebuffs
    HealBot_Config_Cures.IgnoreMovementDebuffs=HealBot_Config_CuresDefaults.IgnoreMovementDebuffs
    HealBot_Config_Cures.SoundDebuffPlay=HealBot_Config_CuresDefaults.SoundDebuffPlay
    HealBot_Config_Cures.DebuffWatchInCombat=HealBot_Config_CuresDefaults.DebuffWatchInCombat
    HealBot_Config_Cures.DebuffWatchWhenGrouped=HealBot_Config_CuresDefaults.DebuffWatchWhenGrouped
    HealBot_Config_Cures.ShowDebuffWarning=HealBot_Config_CuresDefaults.ShowDebuffWarning
    HealBot_Config_Cures.CDCshownHB=HealBot_Config_CuresDefaults.CDCshownHB
    HealBot_Config_Cures.CDCshownAB=HealBot_Config_CuresDefaults.CDCshownAB
    HealBot_Update_BuffsForSpec("Debuff")
    HealBot_Options_ResetDoInittab(4)
    HealBot_Options_Init(4)
    HealBot_AddChat(HEALBOT_CHAT_ADDONID..HEALBOT_CHAT_CONFIRMCURESRESET)
    HealBot_setOptions_Timer(50)
end

function HealBot_IsItemInBag(itemName)
    for bag = 0,4 do
        for slot = 1,GetContainerNumSlots(bag) do
            local item = GetContainerItemLink(bag,slot)
            if item and item:find(itemName) then
                return true
            end
        end
    end
    return false
end

function HealBot_runDefaults()
    HealBot_InitNewChar()
    HealBot_Update_BuffsForSpec()
    HealBot_Update_SpellCombos()
    HealBot_ClearAllBuffs()
    HealBot_ClearAllDebuffs()
end

local function HealBot_DoOnEvent(self, event, ...)
    local arg1,arg2,arg3,arg4 = ...;
    if (event=="CHAT_MSG_ADDON") then
        HealBot_OnEvent_AddonMsg(self,arg1,arg2,arg3,arg4);
    elseif (event=="COMBAT_LOG_EVENT_UNFILTERED") then
        HealBot_OnEvent_Combat_Log(self,...)
    elseif (event=="UNIT_AURA") then
        HealBot_OnEvent_UnitAura(arg1);
    elseif (event=="UNIT_HEALTH") or (event=="UNIT_MAXHEALTH") then
        if (arg1) then HealBot_OnEvent_UnitHealth(arg1); end
    elseif (event=="UNIT_ABSORB_AMOUNT_CHANGED") then
        local _,_,xButton = HealBot_UnitID(arg1)
        if xButton then
            HealBot_AbsorbsUpdate(xButton)
        end
    elseif (event=="UNIT_COMBAT") then 
        if arg1 then HealBot_OnEvent_UnitCombat(arg1); end
    elseif (event=="UNIT_THREAT_SITUATION_UPDATE") or (event=="UNIT_THREAT_LIST_UPDATE") then
        if arg1 then HealBot_OnEvent_UnitThreat(arg1) end
    elseif (event=="UNIT_HEAL_PREDICTION") then
        local _,_,xButton = HealBot_UnitID(arg1)
        if xButton then
            HealBot_HealsInUpdate(xButton) 
        end
    elseif (event=="UNIT_SPELLCAST_START") or (event=="UNIT_SPELLCAST_SUCCEEDED") then
        if arg1 then HealBot_OnEvent_UnitThreat(arg1) end
    elseif (event=="UNIT_SPELLCAST_FAILED") or (event=="UNIT_SPELLCAST_INTERRUPTED") or (event=="UNIT_SPELLCAST_STOP") then
        if arg1 then HealBot_OnEvent_UnitThreat(arg1) end
    elseif (event=="UNIT_SPELLCAST_SENT") then
        HealBot_OnEvent_UnitSpellcastSent(self,arg1,arg2,arg3,arg4);  
    elseif (event=="PLAYER_REGEN_DISABLED") then
        HealBot_OnEvent_PlayerRegenDisabled(self);
    elseif (event=="PLAYER_REGEN_ENABLED") then
        HealBot_luVars["IsReallyFighting"] = true
    elseif (event=="UNIT_NAME_UPDATE") then
        HealBot_OnEvent_UnitNameUpdate(self,arg1)
    elseif (event=="UNIT_POWER_UPDATE") then
        HealBot_OnEvent_UnitMana(arg1);
    elseif (event=="UNIT_MAXPOWER") then 
        local xUnit,xGUID,xButton = HealBot_UnitID(arg1)
        if xUnit and HealBot_Data["TIPUSE"] and xButton.status.enemy < 0 then
            HealBot_talentSpam(xGUID,"update",1) 
        end
    elseif (event=="CHAT_MSG_SYSTEM") then
        HealBot_OnEvent_SystemMsg(self,arg1);
    elseif (event=="GROUP_ROSTER_UPDATE") then
        HealBot_OnEvent_PartyMembersChanged(self);
    elseif (event=="RAID_TARGET_UPDATE") then
        HealBot_OnEvent_RaidTargetUpdate(self);
    elseif (event=="UNIT_TARGET") then
        local xUnit,xGUID,xButton = HealBot_UnitID(arg1)
        if xButton and UnitExists(xUnit.."target") and UnitIsEnemy(xUnit, xUnit.."target") then
            HealBot_Action_ResetUnitStatus(xButton)
        end
    elseif (event=="PLAYER_TARGET_CHANGED") then
        HealBot_OnEvent_PlayerTargetChanged(true);
    elseif (event=="PLAYER_FOCUS_CHANGED") then
        HealBot_OnEvent_FocusChanged(self);
    elseif (event=="MODIFIER_STATE_CHANGED") then
        if HealBot_Data["TIPUSE"] and HealBot_Data["TIPUNIT"] then
            HealBot_Action_RefreshTooltip();
        end
    elseif (event=="PLAYER_CONTROL_GAINED") then
        if HealBot_Data["UILOCK"] then
            HealBot_CheckAllDebuffs();
        end
    elseif (event=="UNIT_PET") then
        if HealBot_luVars["PetHealsOn"] then
            HealBot_Data["REFRESH"]=true;
        end
    elseif (event=="ROLE_CHANGED_INFORM") then
        HealBot_setOptions_Timer(420)
    elseif (event=="UNIT_ENTERED_VEHICLE") then
        HealBot_OnEvent_VehicleChange(self, arg1, true)
    elseif (event=="UNIT_EXITED_VEHICLE") then
        HealBot_OnEvent_VehicleChange(self, arg1, nil)
    elseif (event=="UNIT_EXITING_VEHICLE") then
        HealBot_OnEvent_LeavingVehicle(self, arg1)
    elseif (event=="PLAYER_ENTERING_WORLD") then
        HealBot_OnEvent_PlayerEnteringWorld(self);
    elseif (event=="PLAYER_LEAVING_WORLD") then
        HealBot_OnEvent_PlayerLeavingWorld(self);
    elseif (event=="INSPECT_READY") then
        local xUnit=nil
        if HealBot_UnitData[arg1] then
            xUnit=HealBot_UnitData[arg1]["UNIT"]
        end
        if xUnit and UnitExists(xUnit) and arg1==HealBot_UnitGUID(xUnit) then HealBot_GetTalentInfo(arg1, xUnit) end
    elseif (event=="UNIT_CONNECTION") then
        local xButton=HealBot_Unit_Button[arg1]
        if xButton then 
            HealBot_Action_ResetUnitStatus(xButton) 
        end
    elseif (event=="ZONE_CHANGED_NEW_AREA") or (event=="ZONE_CHANGED")  or (event=="ZONE_CHANGED_INDOORS") then
        HealBot_setOptions_Timer(120)
    elseif (event=="PET_BATTLE_OPENING_START") or (event=="PET_BATTLE_OVER") then
        HealBot_luVars["lastPetBattleEvent"]=event
        HealBot_luVars["CheckSkin"]=true
        HealBot_nextRecalcParty(0); HealBot_Data["REFRESH"]=true;
    elseif (event=="READY_CHECK") then
        HealBot_OnEvent_ReadyCheck(self,arg1,arg2);
    elseif (event=="READY_CHECK_CONFIRM") then
        HealBot_OnEvent_ReadyCheckConfirmed(self,arg1,arg2);
    elseif (event=="READY_CHECK_FINISHED") then
        HealBot_luVars["rcEnd"]=GetTime()
    elseif (event=="UPDATE_MACROS") then
        HealBot_setOptions_Timer(950)
    elseif (event=="LEARNED_SPELL_IN_TAB") then
        HealBot_OnEvent_SpellsChanged(self,arg1);
        HealBot_setOptions_Timer(405)
    elseif (event=="PLAYER_TALENT_UPDATE") or (event=="CHARACTER_POINTS_CHANGED") then
        HealBot_OnEvent_TalentsChanged(self)
    elseif (event=="COMPANION_LEARNED") then
        HealBot_setOptions_Timer(405)
    elseif (event=="VARIABLES_LOADED") then
        HealBot_OnEvent_VariablesLoaded(self);
    elseif (event=="GET_ITEM_INFO_RECEIVED") then
        HealBot_OnEvent_ItemInfoReceived(self);
    else
        HealBot_AddDebug("OnEvent (" .. event .. ")");
    end
end

function HealBot_OnEvent(self, event, ...)
    HealBot_DoOnEvent(self, event, ...)
end
