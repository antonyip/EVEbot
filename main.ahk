#SingleInstance, force
#include GDIP.ahk
#include Print.ahk

SetTitleMatchMode, 2
LoopActive := False

Numpad6::
; Test code.
a := Ant_CaptureScreenToArray()
Stdout(a[1]) ; arrays are 1 indexed
return

Numpad7::
pToken := Gdip_Startup()
LoopActive := True
While(LoopActive)
{
    Stdout("Loop Running")
    WinActivate, EVE
    ArrayBitmap := Ant_CaptureScreenToArray()
    StateMachineLogic(ArrayBitmap)
    Sleep, 500
}
Gdip_Shutdown(pToken)
return

Numpad8::
LoopActive := False
return

Numpad9::
ExitApp
return

Ant_CaptureScreenToArray()
{
    myArray := [4,2,3]
    pBitmap := Gdip_BitmapFromScreen()
    if (pBitmap != -1)
    {
        returnValue := Gdip_SaveBitmapToFile(pBitmap, "myBitmap.JPG")
        Stdout(returnValue)
    }
    Else
    {
        Stdout("not okay")
    }
    return myArray
}

StateMachineLogic(ArrayBitmap)
{
    Stdout("I'm Lost")
}
