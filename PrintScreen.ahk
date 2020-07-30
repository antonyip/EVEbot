;------------------------------
;  AHK Screen Capture Tool
;
;  Author: FeiYue
;  Version: 2.5
;  Introduction:
;  This is a convenient screen capture tool for coordinates and colors
;------------------------------
Goto, _Start

;======== Hotkey ========

;-- Press PrintScreen Hotkey to Capture Screen

*PrintScreen::
IfWinExist, ahk_id %gui_id%
{
  WinMinimize
  Gui, Main: Hide
  WinWaitClose, ahk_id %gui_id%
  Sleep, 200
}
PrintScreen(nX, nY, nW, nH, bits)
SetImage(nW, nH, bits)
Gui, Main: Show
return

#If MouseIsOver()

MouseIsOver() {
  global hPic, gui_id
  ListLines, Off
  MouseGetPos, px, py, id
  if (id!=gui_id)
    return, 0
  WinGetPos, x, y, w, h, ahk_id %hPic%
  return, (px>=x && px<x+w && py>=y && py<y+h)
}

;-- Directional keys can be used for fine-tuning when capturing

*Left::
*Right::
*Up::
*Down::
key:=SubStr(A_ThisLabel, 2)
if (!kk)
  kk:={ "Left":[-1,0], "Right":[1,0], "Up":[0,-1], "Down":[0,1] }
MouseMove, kk[key].1, kk[key].2,, R
return

;-- You can use ALT+[0-9] combination hotkeys to capture points

*!1::
*!2::
*!3::
*!4::
*!5::
*!6::
*!7::
*!8::
*!9::
*!0::
n:=RegExReplace(A_ThisLabel, "\D+")
MouseGetPos, px, py
Gosub, CaptureN
return

#If

;======== Main Script ========

_Start:

#NoEnv
#SingleInstance force
Critical
SetBatchLines, 10ms
;----------------------
ToolName:="AHK Screen Capture Tool"
Version:="2.5"
WindowColor:="0xDDEEFF"
SysGet, nX, 76
SysGet, nY, 77
SysGet, nW, 78
SysGet, nH, 79
VarSetCapacity(bits, nW*nH*4+8, 0xFF)
;----------------------
CoordMode, Mouse
CoordMode, Pixel
CoordMode, ToolTip
CoordMode, Menu
Menu, Tray, Add
Menu, Tray, Add, %ToolName%, MainShow
Menu, Tray, Default, %ToolName%
Menu, Tray, Tip, %ToolName%
Menu, Tray, Click, 1
Loop, 10
  Menu, MyMenu, Add, % "Capture &" Mod(A_Index,10), RunMenu
;-------------------------------------
Gui, Main: Default
Gui, +AlwaysOnTop +Hwndgui_id -DPIScale +LabelGui
Gui, Margin, 15, 15
Gui, Color, %WindowColor%, White
Gui, Add, Text, w452 h402 +Border
Gui, Add, Picture, xp+1 yp+1 wp-2 hp-2 HwndhPic Section
Gui, Add, Slider, ys h400 vMySlider2 gMovePic
  +Center Page10 Line10 +Vertical NoTicks AltSubmit
Gui, Add, Slider, xs w450 vMySlider1 gMovePic
  +Center Page10 Line10 NoTicks AltSubmit
;--------------------
Gui, Font, s12
Loop, 8 {
  i:=A_Index, j:=i=1 ? "xm":"x+0"
  Gui, Add, Button, %j% h25 gSaveLoad, Save%i%
}
Loop, 8 {
  i:=A_Index, j:=i=1 ? "xm y+0":"x+0"
  Gui, Add, Button, %j% h25 gSaveLoad, Del_%i%
}
Loop, 8 {
  i:=A_Index, j:=i=1 ? "xm y+0":"x+0"
  j.=FileExist(A_Temp "\~pic" i ".tmp") ? "":" Disabled"
  Gui, Add, Button, %j% h25 gSaveLoad, Load%i%
}
;--------------------
LineNumber:=n:=11, w:=15, k:=n*(n//2)+(n//2)+1, C_:=[]
Loop, % n*n {
  i:=A_Index, j:=i=1 ? "ym Section" : Mod(i,n)=1 ? "xs y+0" : "x+0"
  j.=i=k-n ? " +Border cRed +BackgroundWhite Vertical"
    : i=k+n ? " +Border cWhite +BackgroundRed Vertical"
    : i=k-1 ? " +Border cWhite +BackgroundRed"
    : i=k+1 ? " +Border cRed +BackgroundWhite" : ""
  r:=i=k+n ? 70 : i=k-n ? 35 : i=k-1 ? 70 : i=k+1 ? 35 : 0
  Gui, Add, Progress, w%w% h%w% %j% Hwndid -E0x20000, %r%
  C_.Push(id)
}
;--------------------
Gui, Font, s12 cGreen bold
Gui, Add, Edit, ym w306 h125 ReadOnly
  , % "`nAHK Screen Capture Tool`n`n<FeiYue Share>"
  . "`n`n1.Press PrintScreen to screenshot first, then "
  . "use the right-click menu+[0-9] key to capture points."
  . "`n`n2.You can use ALT+[0-9] combination hotkeys to capture points."
  . "`n`n3.Directional keys can be used for fine-tuning when capturing.`n"
;-------------------------------------
Gui, Font, s12 cBlue norm
Gui, Add, Edit, w180 ReadOnly
Gui, Add, Button, x+10 yp-3 gRunButton, Clear Group
;-------------------------------------
Gui, Font, s14 cEE6600 bold
Gui, Add, Tab3, xs vMyTab gRunTab AltSubmit -Wrap Section
  , Group1|Group2|Group3|Group4|Group5
Gui, Font, s12 cBlue norm
C2_:=[]
Loop, 5 {
  Gui, Tab, %A_Index%
  Loop, 10 {
    i:=Mod(A_Index,10), j:=i=1 ? "xs+15 y+15":"xs+15 y+3"
    Gui, Add, Text, %j%, Capture %i%
    Gui, Add, Edit, x+10 w200 +Hwndid
    C2_.Push(id)
    Gui, Add, Progress, x+0 w25 hp +Border
      +Hwndid Background%WindowColor%
    C2_.Push(id)
    Gui, Add, Button, x+10 yp-3 gRunButton, Copy %i%
    Gui, Add, Button, x+0 gRunButton, Clear %i%
  }
}
Gui, Tab
MySlider1:=MySlider2:=0, MyTab:=1
;-------------------------------------
Gui, SubPic: Default
Gui, +Parent%hPic% -Caption +ToolWindow -DPIScale +LabelGui
Gui, Margin, 0, 0
Gui, Color, White
Gui, Add, Picture, x0 y0 w%nW% h%nH% +HwndhPic2 +0xE
Gui, Show, NA x0 y0 w%nW% h%nH%, SubPic
;-------------------------------------
Gui, Main: Show,, %ToolName% v%Version% - By FeiYue
OnMessage(0x201, Func("LButton_Down"))
OnMessage(0x200, Func("Mouse_Move"))
return

LButton_Down() {
  global hPic, hPic2, nW, nH
  ListLines, Off
  Critical
  MouseGetPos, px, py
  WinGetPos, x, y, w, h, ahk_id %hPic%
  if !(px>=x && px<x+w && py>=y && py<y+h)
  {
    if (A_Gui="Main" && A_GuiControl="")
      SendMessage, 0xA1, 2
    return
  }
  WinGetPos, winx, winy,,, ahk_id %hPic2%
  winx-=x, winy-=y, x1:=px, y1:=py
  While GetKeyState("LButton", "P")
  {
    MouseGetPos, x2, y2
    x:=winx+x2-x1, y:=winy+y2-y1
    x:=x<-(nW-w) ? -(nW-w) : x>0 ? 0 : x
    y:=y<-(nH-h) ? -(nH-h) : y>0 ? 0 : y
    Gui, SubPic: Show, NA x%x% y%y%
    GuiControl, Main:, MySlider1, % Round(-x/(nW-w)*100)
    GuiControl, Main:, MySlider2, % Round(-y/(nH-h)*100)
    Sleep, 10
  }
}

Mouse_Move() {
  ListLines, Off
  SetTimer, ReDraw, -10
}

ReDraw() {
  global LineNumber, C_
  static C3_:=[]
  ListLines, Off
  Critical
  SetTimer, ReDraw, Off
  if !MouseIsOver()
    return
  MouseGetPos, px, py
  c:=GetPosAndColor(px, py, x, y)
  if (C3_[0]=x "," y)
    return
  C3_[0]:=x "," y, c:=Format("0x{:06X}", c)
  GuiControl, Main:, Edit2, %x%`, %y%`, %c%
  n:=LineNumber, k:=n*(n//2)+(n//2)+1, i:=0
  Loop, %n% {
    py:=y-(n//2)+A_Index-1
    Loop, %n% {
      px:=x-(n//2)+A_Index-1, i++
      if !(i=k-1||i=k+1||i=k-n||i=k+n)
        if (c:=GetColor(px,py))!=C3_[i]
          C3_[i]:=c, SetColor(c, C_[i])
    }
  }
}

GuiEscape:
Gui, Main: Hide
return

MainShow:
Gui, Main: Show
return

RunTab:
GuiControlGet, MyTab, Main:, MyTab
return

GuiContextMenu:
if (A_Gui="SubPic")
{
  MouseGetPos, px, py
  Menu, MyMenu, Show, %px%, %py%
}
return

RunMenu:
n:=A_ThisMenuItemPos
CaptureN:
Gosub, RunTab
c:=GetPosAndColor(px, py, x, y)
n:=(MyTab-1)*20+2*n-1+20*(!n)
c:=Format("0x{:06X}", c)
GuiControl, Main:, % C2_[n], %x%`, %y%`, %c%
SetColor(c, C2_[n+1])
MouseMove, px, py
return

MovePic:
ListLines, Off
WinGetPos,,, w, h, ahk_id %hPic%
x:=-(nW-w)*MySlider1//100
y:=-(nH-h)*MySlider2//100
Gui, SubPic: Show, NA x%x% y%y%
return

RunButton:
Gosub, RunTab
k:=A_GuiControl, n:=RegExReplace(k, "\D+")
n:=(MyTab-1)*20+2*n-1+20*(!n)
if InStr(k, "Group")
{
  Loop, 10 {
    n:=(MyTab-1)*20+2*A_Index-1
    GuiControl, Main:, % C2_[n]
    SetColor(WindowColor, C2_[n+1])
  }
}
else if InStr(k, "Copy")
{
  GuiControlGet, r, Main:, % C2_[n]
  Clipboard:=r
}
else
{
  GuiControl, Main:, % C2_[n]
  SetColor(WindowColor, C2_[n+1])
}
ToolTip, %k% OK !
SetTimer, Tip_Off, -500
return
Tip_Off:
ToolTip
return

SaveLoad:
SaveLoad()
return

SaveLoad() {
  global bits, nW, nH
  k:=A_GuiControl, i:=RegExReplace(k, "\D+")
  f:=A_Temp "\~pic" i ".tmp"
  ToolTip, %k% OK !
  SetTimer, Tip_Off, -500
  if InStr(k,"Save")
  {
    file:=FileOpen(f, "w")
    file.RawWrite(bits, nW*nH*4)
    file.Close()
    GuiControl, Main: Enable, Load%i%
  }
  else if InStr(k,"Del")
  {
    FileDelete, %f%
    GuiControl, Main: Disable, Load%i%
  }
  else if FileExist(f)
  {
    file:=FileOpen(f, "r")
    file.RawRead(bits, nW*nH*4)
    file.Close()
    SetImage(nW, nH, bits)
  }
}

SetColor(c, hwnd)
{
  c:=((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
  SendMessage, 0x2001, 0, c,, ahk_id %hwnd%
}

GetPosAndColor(px, py, ByRef x="", ByRef y="")
{
  global
  VarSetCapacity(pt,8), NumPut(py,NumPut(px,pt,"int"),"int")
  DllCall("ScreenToClient", "ptr",hPic2, "ptr",&pt)
  x:=NumGet(pt,0,"int")+nX, y:=NumGet(pt,4,"int")+nY
  return, GetColor(x, y)
}

GetColor(x, y, bpp=32)
{
  global
  return, (x<nX or y<nY or x>nX+nW-1 or y>nY+nH-1)
    ? 0xFFFFFF : NumGet(bits,(y-nY)*(((nW*bpp+31)//32)*4)
    +(x-nX)*(bpp//8),"uint")&0xFFFFFF
}

PrintScreen(x, y, w, h, ByRef bits, bpp=32)
{
  Ptr:=A_PtrSize ? "UPtr" : "UInt"
  Scan0:=&bits, Stride:=((w*bpp+31)//32)*4
  win:=DllCall("GetDesktopWindow", Ptr)
  hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
  mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
  if (hBM:=CreateDIBSection(w, -h, mDC, bpp, ppvBits))
  {
    oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
    DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
      , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
    hBrush:=DllCall("CreateSolidBrush", "uint",0xFFFFFF, Ptr)
    oBrush:=DllCall("SelectObject", Ptr,mDC, Ptr,hBrush, Ptr)
    DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
      , Ptr,mDC, "int",0, "int",0, "uint",0xC000CA)
    DllCall("RtlMoveMemory", Ptr,Scan0, Ptr,ppvBits, Ptr,Stride*h)
    DllCall("SelectObject", Ptr,mDC, Ptr,oBrush)
    DllCall("DeleteObject", Ptr,hBrush)
    DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
    DllCall("DeleteObject", Ptr,hBM)
  }
  DllCall("DeleteDC", Ptr,mDC)
  DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
}

SetImage(w, h, ByRef bits, bpp=32)
{
  global hPic2
  static hBM
  Ptr:=A_PtrSize ? "UPtr" : "UInt"
  if (hBM)
    DllCall("DeleteObject", Ptr,hBM)
  Scan0:=&bits, Stride:=((w*bpp+31)//32)*4
  if (hBM:=CreateDIBSection(w, -h, 0, bpp, ppvBits))
    DllCall("RtlMoveMemory",Ptr,ppvBits,Ptr,Scan0,Ptr,Stride*h)
  SendMessage, 0x172, 0x0, hBM,, ahk_id %hPic2%
  if (E:=ErrorLevel)
    DllCall("DeleteObject", Ptr,E)
  WinSet, ReDraw,, ahk_id %hPic2%
}

CreateDIBSection(w, h, hdc=0, bpp=32, ByRef ppvBits=0)
{
  Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr "*"
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  NumPut(w, bi, 4, "int"), NumPut(h, bi, 8, "int")
  NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
  hbm:=DllCall("CreateDIBSection", Ptr,hdc, Ptr,&bi
    , "int",0, PtrP,ppvBits, Ptr,0, "uint",0, Ptr)
  return, hbm
}

;======== Script End ========

;