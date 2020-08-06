#SingleInstance, force
#include GDIP.ahk
#include Print.ahk
#include Ant_Common.ahk

SetTitleMatchMode, 2
SetDefaultMouseSpeed, 5
LoopActive := False



; Variables
Global InventoryFullPosition := [350, 500, 5, 5]
Global InventoryFullSignature := Ant_LoadSignature("InventoryFullSignature.txt")
Global HomeCheckPosition := [1844,98,1880-1844,109-98]
Global HomeCheckPositionSignature := Ant_LoadSignature("HomeCheckPosition.txt")
Global InventoryEmptyPosition := [63, 500, 5, 5]
Global InventoryEmptyPositionSignature := Ant_LoadSignature("InventoryEmptyPosition.txt")
Global JakkBasePosX := 1290
Global JakkBasePosY := 104
Global JakkWarpPosX := JakkBasePosX + 33
Global JakkWarpPosY := JakkBasePosY + 11
Global BackToSpotPosX := JakkBasePosX
Global BackToSpotPosY := JakkBasePosY + 20
Global BackToSpotWarpPosX := BackToSpotPosX + 33
Global BackToSpotWarpPosY := BackToSpotPosY + 11
Global MainTabX := 1534
Global MainTabY := 195
Global TopOrePositionX := 1545
Global TopOrePositionY := 245
Global Laser1X := 1079
Global Laser1Y := 917
Global Laser1Pos := [Laser1X, Laser1Y, 2, 2]
Global Laser1PosContrast := [Laser1X + 2, Laser1Y, 2, 2]
Global Laser2X := 1130
Global Laser2Y := 917
Global Laser2Pos := [Laser2X, Laser2Y, 2, 2]
Global Laser2PosContrast := [Laser2X + 2, Laser2Y, 2, 2]
Global OpenCargoX := 1593 
Global OpenCargoY := 128
Global InventoryPositionX := 419
Global InventoryPositionY := 544
Global CargoDropPosX := 975
Global CargoDropPosY := 500
Global TransferButtonX := 1068
Global TransferButtonY := 714
Global OresTabX := 1709
Global OresTabY := 195
Global NoMoreOres := [1646, 233, 20, 20]
Global NoMoreOresSignature := Ant_LoadSignature("NoMoreOresSig.txt")


Numpad6::
!v::
; Test code.
pToken := Gdip_Startup()
Stdout("Saving Sig To File - Start")
debugToFileArray := Ant_CaptureScreenToArrayUsingArray(NoMoreOres)
DebugStringToFile("debugToFileArray.txt", Ant_PrintArrayToString(debugToFileArray))
Stdout(Format("Saving Sig To File - End {1:d}", 0xff))
Gdip_Shutdown(pToken)
return

!b::
pToken := Gdip_Startup()
LoopActive := True
MainLoopCounter := 0
myTimeStarted := A_Now
While(LoopActive)
{
    WinActivate, EVE -
    Sleep, 750
    StateMachineLogic()
    MainLoopCounter += 1
    if (MainLoopCounter > 60)
    {
        ; Hopefully restarting doesn't kill it.
        Gdip_Shutdown(pToken)
        Sleep 5000
        pToken := Gdip_Startup()
        MainLoopCounter := 0
    }
}
Gdip_Shutdown(pToken)
return

!n::
LoopActive := False
return

!m::

ExitApp
return

; Weights is ARGB, lower or increase it to have higher weightage
Ant_ArrayCompare(ByRef iLeft, ByRef iRight, how=1, weights=0x00888888)
{
    if (intparse(iLeft[1]) != intparse(iRight[1]))
    {
        return 0.1314
    }
    if (intparse(iLeft[2]) != intparse(iRight[2]))
    {
        return 0.1315
    }

    i := 1
    
    ;Stdout(Format("ileft: {1:f} {2:f}",iLeft[1] , iLeft[2]))
    myW := intparse(iLeft[1])
    myH := intparse(iLeft[2])
    l := (myW * myH) + 2

    corrects := 0
    wrongs := 0
    ;Stdout(Format("length: {1:f} ",l))
    while (i <= l) ; <= because array start from 1 and not :(
    {
        oldCorrect := corrects
        myLeft := intparse(iLeft[i])
        myRight := intparse(iRight[i])
        LA := (myLeft & 0xff000000) >> 24
        LR := (myLeft & 0x00ff0000) >> 16
        LG := (myLeft & 0x0000ff00) >> 8
        LB := (myLeft & 0x000000ff) 
        RA := (myRight & 0xff000000) >> 24
        RR := (myRight & 0x00ff0000) >> 16
        RG := (myRight & 0x0000ff00) >> 8
        RB := (myRight & 0x000000ff) 
        

        if (how == 0)
        {
            corrects += (0.3333 - ((Abs(LR - RR) / 255.0) / 3))
            corrects += (0.3333 - ((Abs(LG - RG) / 255.0) / 3))
            corrects += (0.3333 - ((Abs(LB - RB) / 255.0) / 3))
        }

        if (how == 1)
        {
            ColorMultiplier := 4
            if (Abs(LR - RR) < (16 * ColorMultiplier))
            {
                corrects += (0.3333 - ((Abs(LR - RR) / 255.0) / 3))
            }

            if (Abs(LG - RG) < (16 * ColorMultiplier))
            {
                corrects += (0.3333 - ((Abs(LG - RG) / 255.0) / 3))
            }

            if (Abs(LB - RB) < (16 * ColorMultiplier))
            {
                corrects += (0.3333 - ((Abs(LB - RB) / 255.0) / 3))
            }
        }

        if (how == 2)
        {
            if ( (LR + LB / 2) < LG )
                corrects += 1
        }

        if (how == 3)
        {
            CA := (weights & 0xff000000) >> 24
            CR := (weights & 0x00ff0000) >> 16
            CG := (weights & 0x0000ff00) >> 8
            CB := (weights & 0x000000ff) 
            calculatedWeights := CR + CG + CB + CA
            PA := CA / calculatedWeights ; say this is 255/1020 = 0.25
            PR := CR / calculatedWeights 
            PG := CG / calculatedWeights
            PB := CB / calculatedWeights

            ColorMultiplier := 4 ; anything more then 64 is super different
            if (Abs(LR - RR) < (16 * ColorMultiplier))
            {
                ; score - ((abs(color diff)/255) * (filterWeight / sumWeight))
                corrects += (PR - ( (Abs(LR - RR) / 255.0) / (CR / calculatedWeights) ))
            }

            if (Abs(LG - RG) < (16 * ColorMultiplier))
            {
                corrects += (PG - ( (Abs(LG - RG) / 255.0) / (CG / calculatedWeights) ))
            }

            if (Abs(LB - RB) < (16 * ColorMultiplier))
            {
                corrects += (PB - ( (Abs(LB - RB) / 255.0) / (CB / calculatedWeights) ))
            }

            if (Abs(LA - RA) < (16 * ColorMultiplier))
            {
                corrects += (PA - ( (Abs(LA - RA) / 255.0) / (CA / calculatedWeights) ))
            }

        }

        if (how == 4)
        {
            ColorMultiplier := 4 ; anything more then 64 is super different
            isWrong := 0
            if (Abs(LR - RR) < (16 * ColorMultiplier))
            {
                isWrong := 1
            }

            if (Abs(LG - RG) < (16 * ColorMultiplier))
            {
                isWrong := 1
            }

            if (Abs(LB - RB) < (16 * ColorMultiplier))
            {
                isWrong := 1
            }

            if (Abs(LA - RA) < (16 * ColorMultiplier))
            {
                isWrong := 1
            }

            if (isWrong == 0)
            {
                corrects += 1
            }
        }

        if (Abs(corrects - oldCorrect) < 0.99 )
        {
            ;Stdout(Format("diff: {1:x} {2:x}",myLeft, myRight))
        }
        i += 1
    }

    return corrects / l

}

/* 
0 = Idle
1 = Mining
2 = WaitingToReachBase
3 = I have reached home
4 = Deposit Loop
5 = Going back to spot.
*/

StateMachineLogic()
{
    static enStateMachine := 1
    if (enStateMachine == 1)
    {
        ; okay, done once.
        SigCheck := Ant_CaptureScreenToArrayUsingArray(InventoryFullPosition)
        ComparedPercentage := Ant_ArrayCompare(InventoryFullSignature, SigCheck, 3, 0x00ffffff)
        DebugStringToFile("MinerFullCheck.txt", Ant_PrintArrayToString(SigCheck))
        Stdout(Format("WaitingForMinerFull: {1:s}", ComparedPercentage))
        if (ComparedPercentage > 0.80) ; calculated in excel.
        {
            Click, Right, %JakkBasePosX%, %JakkBasePosY%
            Sleep, 500
            Click, Left, %JakkWarpPosX% , %JakkWarpPosY%
            enStateMachine := 2
            Stdout("Going Home")
        }
        else
        {

            ; no more ores check
            NoMoreOresCheck := Ant_CaptureScreenToArrayUsingArray(NoMoreOres)
            ComparedPercentage := Ant_ArrayCompare(NoMoreOresCheck, NoMoreOresSignature, 3, 0x00ffffff)
            Stdout(Format("NoMoreORes?: {1:s}", ComparedPercentage))
            if (ComparedPercentage > 0.88)
            {
                enStateMachine := 5
            }

            Laser1PosTest := Ant_CaptureScreenToArrayUsingArray(Laser1Pos)
            Laser1PosTestContrast := Ant_CaptureScreenToArrayUsingArray(Laser1PosContrast)
            CompareLaser1 := Ant_ArrayCompare(Laser1PosTest, Laser1PosTestContrast, 3, 0x00ffffff)
            Stdout(Format("Laser1: {1:s}", CompareLaser1))
            
            static Laser1Errors := 6 ; start from 6 so it triggers faster
            if (CompareLaser1 > 0.40)
            {
                Stdout(Format("I think this is Laser 1 not mining {1:d}", Laser1Errors))
                Stdout(Format("Laser1Debug: {1:s} {2:d} {3:d} {4:d} {5:d}", CompareLaser1, Laser1PosTest[3], Laser1PosTest[4], Laser1PosTest[5], Laser1PosTest[6]))
                Laser1Errors += 1
                if (Laser1Errors > 5) ; More than 5 seconds not mining
                {
                    l1x := Laser1X
                    l1y := Laser1Y - 20
                    Click, Left, %l1x% , %l1y% ; start mining
                    Sleep 500
                    Click, Left, %TopOrePositionX%, %TopOrePositionY% ; click top ore
                    Sleep 500
                    Click, Left, 100 , 1000 ; click chatbox
                    Laser1Errors := 0
                }
            }
            else
            {
                Laser1Errors := 0
            }

            Laser2PosTest := Ant_CaptureScreenToArrayUsingArray(Laser2Pos)
            Laser2PosTestConstrast := Ant_CaptureScreenToArrayUsingArray(Laser2PosContrast)
            CompareLaser2 := Ant_ArrayCompare(Laser2PosTest, Laser2PosTestConstrast, 3, 0x00ffffff)
            Stdout(Format("Laser2: {1:s}", CompareLaser2))

            static Laser2Errors := 4 ; start from 6 so it triggers faster
            if (CompareLaser2 > 0.4)
            {
                Stdout(Format("I think this is Laser 2 not mining {1:d}", Laser2Errors))
                Stdout(Format("Laser2Debug: {1:s} {2:d} {3:d} {4:d} {5:d}", CompareLaser2, Laser2PosTest[3], Laser2PosTest[4], Laser2PosTest[5], Laser2PosTest[6]))
                Laser2Errors += 1
                if (Laser2Errors > 5) ; More than 5 seconds not mining
                {        
                    l2x := Laser2X
                    l2y := Laser2Y - 20
                    Click, Left, %l2x% , %l2y% ; start mining
                    Sleep 500
                    Click, Left, %TopOrePositionX%, %TopOrePositionY% ; click top ore
                    Sleep 500
                    Click, Left, 100 , 1000 ; click chatbox
                    Laser2Errors := 0
                }
            }
            else
            {
                Laser2Errors := 0
            }
            
            ; not full yet
            ; TODO ; check for rats?
            ; if (laser 1 is still mining)

            ; do nothing
            ; else
            ; look for new asteriod to mine
        }
    }
    else if (enStateMachine == 2)
    {
        Stdout("Waiting to reach home")

        Click, Left , %MainTabX%, %MainTabY% ; click main tab
        Sleep 12000
        ; TODO: add signature check to see if tab was switched
        enStateMachine := 3
        
    }
    else if (enStateMachine == 3)
    {
        SigCheck := Ant_CaptureScreenToArrayUsingArray(HomeCheckPosition)
        ComparedPercentage := Ant_ArrayCompare(HomeCheckPositionSignature, SigCheck)
        Stdout(Format("Assume home.. Check: {1:f}", ComparedPercentage))

        ; TODO: If jark was clicked already, The scanners fail.

        if (ComparedPercentage > 0.88)
        {
            ; I'm Home, start deposit
            enStateMachine := 4
        }
    }
    else if (enStateMachine == 4)
    {
        Click, Left , %TopOrePositionX%, %TopOrePositionY%
        Click, Left , %OpenCargoX%, %OpenCargoY%
        Click, Left, %InventoryPositionX%, %InventoryPositionY%
        MouseClickDrag, Left, %InventoryPositionX%, %InventoryPositionY%, %CargoDropPosX%, %CargoDropPosY%
        Click, Left , %TransferButtonX%, %TransferButtonY%
        SigCheck := Ant_CaptureScreenToArrayUsingArray(InventoryEmptyPosition)
        ComparedPercentage := Ant_ArrayCompare(InventoryEmptyPositionSignature, SigCheck)
        Stdout(Format("EmptyInventory Check: {1:d} {2:f}", InventoryEmptyPositionSignature[4], ComparedPercentage))
        if (ComparedPercentage > 0.88)
        {
            enStateMachine := 5
        }
        
    }
    else if (enStateMachine == 5)
    {
        Stdout("Back To Mining")
        Click, Right , %BackToSpotPosX%, %BackToSpotPosY%
        Sleep 500
        Click, Left , %BackToSpotWarpPosX%, %BackToSpotWarpPosY%
        Sleep 500
        Click, Left, %OresTabX%, %OresTabY% ; click the ores tab
        Sleep 12000 ; witing to go back
        enStateMachine := 1
        
    }
    else
    {
        Stdout("I'm Lost")
    }

    
}
