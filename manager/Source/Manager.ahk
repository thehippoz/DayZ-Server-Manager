; DZ Server Manager by Ben Barbre (benbarbre@gmail.com) Jan, 2023
; Update Feb 16 - Fixed a problem logging mods with spaces. Works with 1.20 update.
; Update Feb 15 - Fixed date bug in mod.ini. Moved some things around for reliability.
; Update Feb 12 - Cleaned up and renamed vars. Nothing important.

; ###########################################################################


#NoEnv
#include .\Gdip_All.ahk
#SingleInstance, Force
SetBatchLines, -1


; ########################################################################### !

filePath := A_ScriptDir "\Configure.ini"
mini := A_ScriptDir "\Mods.ini"

IniRead, ServerName, %filePath%, General, ServerName
IniRead, SpawnPosition, %mini%, Workshop, SpawnPosition

Myy := []
Mee := []
Mtt := []
Rtt := []
SDHours := []
Xpos=0
Ypos=0

If RegExMatch(SubStr(Spawnposition,1,1), "1|2|3|4|5|6|7|8|9|0")
{
Rtt := StrSplit(SpawnPosition, ",")
Xpos := Rtt[1]
Ypos := Rtt[2]
}

Menu,Tray,NoStandard
Menu,Tray,Add,Start,RestartIt
Menu,Tray,Add,Shutdown,SShutdown
Menu,Tray,Add,Close,Exit
Menu,Tray,NoDefault
Menu,Tray,Icon,running.ico, , 1

exStyles := (WS_EX_COMPOSITED := 0x02000000) | (WS_EX_LAYERED := 0x80000)
Gui, 3:New, +E%exStyles%
_Gui_ := A_DefaultGui
Gui, 3: +AlwaysOnTop +LastFound +ToolWindow
Gui, 3:Font, s8 c0000EF
Gui, 3:Add, edit, R1 w140 vPBox hwndHandle, Waiting for DaRT`n
Gui, 3:Show, x%Xpos% y%Ypos% w159 h33, %ServerName%
Gui, -SysMenu

Eint=0
LineVar=0
ModWait=0
Dllwait=0
KeptTime=0
MinimumStartupTime=0
StartTime := abs(A_TickCount)

IniRead, DayZServer, %filePath%, General, DayZServer
IniRead, Startup, %filePath%, General, Startup
IniRead, SteamWorkshopFolder, %filePath%, General, SteamWorkshopFolder
IniRead, DartName, %filePath%, General, DartName
IniRead, ShutdownHours, %filePath%, General, ShutdownHours
IniRead, Steamuser, %filePath%, General, Steamuser
IniRead, CheckForUpdatedMods, %filePath%, General, CheckForUpdatedMods
IniRead, MinimumStartupTime, %filePath%, General, MinimumStartupTime
IniRead, CancelModUp, %filePath%, General, CancelModUpdatesBeforeShutdown
IniRead, ModUpdateWarning, %filePath%, General, ModUpdateWarning
IniRead, CountdownSeconds, %filePath%, General, CountdownSeconds
IniRead, MessageShutdown, %filePath%, General, MessageShutdown
IniRead, MessageUpdatedMods, %filePath%, General, MessageUpdatedMods
IniRead, ShutDownDialog, %filePath%, General, ShutDownDialog
IniRead, MinBeforeShutdown, %filePath%, General, MinBeforeShutdown
IniRead, DartSayBox, %filePath%, General, DartSayBox
IniRead, DartSayBoxColor, %filePath%, General, DartSayBoxColor

pToken := Gdip_Startup()
OnExit, Exit

FoundPos := RegExMatch(SteamWorkshopFolder, "steamapps")
SteamFolder := SubStr(SteamWorkshopFolder,1,FoundPos-1)

If (!index && FileExist(A_ScriptDir "\..\" Startup))
{
FileReadLine, Raw, %A_ScriptDir%\..\%Startup%, ++LineVar
FoundPos := RegExMatch(Raw, "-mod=@")
If FoundPos
{
FoundPos += 5
Raw := SubStr(Raw,FoundPos,StrLen(Raw)-FoundPos)
FoundPos := RegExMatch(Raw, """")
Uvar := SubStr(Raw,1,FoundPos-1)
for index, FoundPos in StrSplit(uVar, ";")
Myy[index] := FoundPos
CheckForUpdatedMods := Floor((CheckForUpdatedMods*60)/index)
}
}

CurrentM := ""
CancelModUp := (60-(CancelModUp+MinBeforeShutdown))
TotalMods := index
Raw := TotalMods
SSFlag=0

While Raw
{
filePath := A_ScriptDir "\..\" Myy[Raw] "\meta.cpp"
LineVar=0
While (SubStr(uVar,1,11) != "publishedid" && FileExist(filePath))
FileReadLine, uVar, %filePath%, ++LineVar
uVar := SubStr(uVar,15,10)
Mee[Raw] := uVar
--Raw
}

for index, FoundPos in StrSplit(ShutdownHours, ",")
{
If !FoundPos
FoundPos=24
SDHours[index] := FoundPos
}
Hoursin := index

Rtt := StrSplit(ShutDownDialog, ",")
XValue := Rtt[1]
YValue := Rtt[2]

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

Raw := TotalMods

If (ShutDownDialog = "0,0")
{
Loop
{
MouseGetPos, msX, msY, msWin, msCtrl
msnt := "» X: " msX " Y: " msY
TMessage(msnt,Handle)
Sleep, 50
}
}
else
{
WinWait, ahk_exe %DartName%,
IfWinNotActive, ahk_exe %DartName%, , WinActivate, ahk_exe %DartName%,
WinWaitActive, ahk_exe %DartName%,

Loop
{
If ((A_Tickcount-1000) > KeptTime)
KeptTime := abs(A_TickCount)
else
Sleep, (KeptTime+1000)-A_TickCount
If (++Dllwait = 30)
{
Dllwait=0
DllCall("SetThreadExecutionState", UInt,0x80000003 )
}
KeptTime := abs(A_TickCount)
ServerLoc := "DayZServer_x64.exe"
Process, Exist, %ServerLoc%

If (ErrorLevel || (MinimumStartupTime*60000) > (A_TickCount-StartTime))
{
ShutCheck=0
jVal := Hoursin+1
While --jVal
{
erp := abs(SDHours[jVal])
HourHolder := A_Hour+1
If (HourHolder = erp)
ShutCheck=1
}
msnt := "» Idle"
TMessage(msnt,Handle)

MinHolder := abs(A_Min)

If ((MinimumStartupTime*60000) < (A_TickCount-StartTime) && (!ShutCheck || (CancelModUp > MinHolder && ShutCheck)) && !ModWait)
{
msnt := "» Update Checking"
TMessage(msnt,Handle)

chkr := Mee[Raw]
filePath := "https://steamcommunity.com/sharedfiles/filedetails/changelog/" chkr

If (++Eint >= CheckForUpdatedMods)
{
msnt := "» Comparing Data"
TMessage(msnt,Handle)
Eint=0

If (abs(A_TimeIdle) > 270000)
{
DaRT(DartName,DartSayBox,DartSayBoxColor,0)
Sleep, 100
WinMinimize, ahk_exe %DartName%
ifWinExist, ahk_exe DayZServer_x64.exe
{
WinWait, ahk_exe DayZServer_x64.exe,
IfWinNotActive, ahk_exe DayZServer_x64.exe, , WinActivate, ahk_exe DayZServer_x64.exe,
WinWaitActive, ahk_exe DayZServer_x64.exe,
}
Sleep, 100
MouseClick, left,  XValue, YValue
Sleep, 100
WinMaximize, ahk_exe %DartName%
BlockInput, Off
}

hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
ComObjError(false)
hObject.Open("GET",filePath)
hObject.Send()
Foundhead:=hObject.ResponseText
LineVar := InStr(Foundhead, "changelog headline")
FoundPos := SubStr(Foundhead,LineVar+37,20)
StringReplace, FoundPos, FoundPos, %A_Tab%, , A
Rtt := StrSplit(FoundPos, ",")
If (Rtt[1] = FoundPos)
{
Rtt := StrSplit(FoundPos, "@")
Mtt[Raw] := SubStr(Rtt[1],1,StrLen(Rtt[1])-1)
Mtt[Raw] := Mtt[Raw] ", " A_YYYY " @" Rtt[2]
FoundPos := Mtt[Raw]
}
else
Mtt[Raw] := FoundPos

If !FileExist(mini)
{
FileAppend, [Workshop]`nSpawnPosition=`n, %mini%
Sleep, 5
msnt := "`n» Create - Mod.ini"
TMessage(msnt,Handle)
}
KeyB := Mee[Raw]
IniRead, KeyA, %mini%, Workshop, %KeyB%
If (RegExMatch(FoundPos, "Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec") && RegExMatch(KeyA, "Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec") && FoundPos != KeyA && !ModWait)
{
ModWait := abs(A_TickCount)
ModWait += (ModUpdateWarning*1000)
ModWait += 1500
}
else
{
If (KeyA = "ERROR" && RegExMatch(FoundPos, "Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec"))
IniWrite, %FoundPos%, %mini%, Workshop, %KeyB%
--Raw
If !Raw
Raw := TotalMods
}
}
}
else
{
If ModWait
{
RTicks := (ModWait-A_TickCount)
If SSFlag
msnt := "» Shutdown Server"
else
msnt := "» Updating Mods..."
TMessage(msnt,Handle)
If (RTicks > (ModUpdateWarning*1000))
{
DaRT(DartName,DartSayBox,DartSayBoxColor,1)
dVar := SubStr(Myy[Raw],2,StrLen(Myy[Raw])-1)
cVar := "#mod#"
erp := StrReplace(MessageUpdatedMods, cVar, dVar)
cVar := "#tms#"
dVar := ModUpdateWarning " seconds"
If SSFlag
erp := MessageShutdown
erp := StrReplace(erp, cVar, dVar)
Send %erp%{Enter}
Sleep, 1500
BlockInput, Off
}
If (RTicks < (CountdownSeconds*1000) && CurrentM != Round(Floor(RTicks/1000), -1))
{
DaRT(DartName,DartSayBox,DartSayBoxColor,1)
dVar := SubStr(Myy[Raw],2,StrLen(Myy[Raw])-1)
cVar := "#mod#"
erp := StrReplace(MessageUpdatedMods, cVar, dVar)
cVar := "#tms#"
dVar := Round(Floor(RTicks/1000), -1)
CurrentM := dVar
dVar := dVar " seconds"
If SSFlag
erp := MessageShutdown
erp := StrReplace(erp, cVar, dVar)
If (dVar > -1)
Send %erp%{Enter}
Sleep, 100
BlockInput, Off
}
If (RTicks < 1)
{
DaRT(DartName,DartSayBox,DartSayBoxColor,1)
Sleep, 100
WinMinimize, ahk_exe %DartName%
ifWinExist, ahk_exe DayZServer_x64.exe
{
WinWait, ahk_exe DayZServer_x64.exe,
IfWinNotActive, ahk_exe DayZServer_x64.exe, , WinActivate, ahk_exe DayZServer_x64.exe,
WinWaitActive, ahk_exe DayZServer_x64.exe,
WinGet, ffs_id, ID, A
WinKill, ahk_id %ffs_id%,,10
Sleep, 15000
MouseMove,  XValue, YValue
Sleep, 50
MouseClick, left,  XValue, YValue
Sleep, 5000
}
cVar := Mee[Raw]
dVar := SubStr(Myy[Raw],2,StrLen(Myy[Raw])-1)
If !SSFlag
{
SetWorkingDir, %SteamFolder%
dVarS := dVar
dVar := StrReplace(dVar, " ", "_")
FileName := "ModUpdate-" dVar "-" cVar ".log"
Sleep, 50
RunWait, "C:\Windows\System32\cmd.exe" /c steamcmd +login %Steamuser% +workshop_download_item 221100 %cVar% +quit > %FileName%, %SteamFolder%
Random, rgs, 1000, 9999
Sleep, 500
SetWorkingDir, %A_ScriptDir%
Sleep, 500
Run, "C:\Windows\System32\cmd.exe"
Sleep, 500
WinGet, cmd_id, ID, A
Send move /Y "%SteamFolder%%FileName%" "..\profiles\Update-%dVar%-%cVar%-%rgs%.log"{Enter}
Sleep, 500
Send robocopy "%SteamWorkshopFolder%%cVar%" "..\@%dVarS%" /mir > RoboUpdate-%dVar%-%cVar%.log{Enter}
Sleep, 500
FileMove RoboUpdate-%dVar%-%cVar%.log, Robocopy-%dVar%-%cVar%.log
While ErrorLevel
{
Sleep, 1000
FileMove RoboUpdate-%dVar%-%cVar%.log, Robocopy-%dVar%-%cVar%.log
}
Sleep, 500
FileRead, erp, Robocopy-%dVar%-%cVar%.log
If (RegExMatch(erp, "New"))
IniWrite, %FoundPos%, %mini%, Workshop, %KeyB%
FileAppend, `n`n`nRobocopy -=-=-=-`n`n%erp%, ..\profiles\Update-%dVar%-%cVar%-%rgs%.log
Send copy /y /v "..\@%dVarS%\Keys\*.bikey" "..\keys\" > KeyUpdate-%dVar%-%cVar%.log{Enter}
Sleep, 500
FileMove KeyUpdate-%dVar%-%cVar%.log, Keys-%dVar%-%cVar%.log
While ErrorLevel
{
Sleep, 1000
FileMove KeyUpdate-%dVar%-%cVar%.log, Keys-%dVar%-%cVar%.log
}
Sleep, 500
FileRead, erp, Keys-%dVar%-%cVar%.log
FileAppend, `n`n`nCopied Keys -=-=-=-`n`n%erp%, ..\profiles\Update-%dVar%-%cVar%-%rgs%.log
Send del "*.log"{Enter}
Sleep, 2000
WinKill, ahk_id %cmd_id%,,10
BlockInput, Off
}
Sleep, 500
WinMaximize, ahk_exe %DartName%
BlockInput, Off
}
}
else
{
If (CancelModUp < MinHolder && ShutCheck && (MinimumStartupTime*60000) < (A_TickCount-StartTime))
{
RTicks := (60-MinBeforeShutdown-MinHolder)
If (RTicks && RTicks != CurrentM && (RTicks < 6 || RTicks = 20 || RTicks = 15 || RTicks = 10))
{
dVar := RTicks " minutes"

; Uncomment for rcon in seconds from one minute down

; If RTicks != 1
CurrentM := RTicks
; else
; {
; CurrentM := ""
; If abs(A_Sec)
; dVar := (60-A_Sec) " seconds"
; }

DaRT(DartName,DartSayBox,DartSayBoxColor,1)
cVar := "#tms#"
erp := StrReplace(MessageShutdown, cVar, dVar)
Send %erp%{Enter}
Sleep, 100
BlockInput, Off
}
If RTicks < 1
{
WinMinimize, ahk_exe %DartName%
ifWinExist, ahk_exe DayZServer_x64.exe
{
WinWait, ahk_exe DayZServer_x64.exe,
IfWinNotActive, ahk_exe DayZServer_x64.exe, , WinActivate, ahk_exe DayZServer_x64.exe,
WinWaitActive, ahk_exe DayZServer_x64.exe,
WinGet, ffs_id, ID, A
WinKill, ahk_id %ffs_id%,,10
ModWait=0
SSFlag=0
Sleep, 15000
MouseClick, left,  XValue, YValue
Sleep, 100
WinMaximize, ahk_exe %DartName%
Sleep, 5000
}
}
}
}
}
}
else
{
msnt := "» Restarting Server"
If SSFlag
{
msnt := "» Shutdown Server"
BlockInput, Off
}
TMessage(msnt,Handle)
If !SSFlag
{
Sleep, 15000
MouseClick, left,  XValue, YValue
Sleep, 5000
Run, "C:\Windows\System32\cmd.exe", ..\
Sleep, 500
WinGet, cmd_id, ID, A
Send %Startup%{Enter}
Sleep, 50
WinKill, ahk_id %cmd_id%,,10
ModWait=0
Sleep, (abs(MinBeforeShutdown-MinimumStartupTime)*60000)

If !FileExist(mini)
FileAppend, [Workshop]`n, %mini%
WinGetPos, Xpos, Ypos,,, %ServerName%
erp := Xpos "," Ypos
IniWrite, %erp%, %mini%, Workshop, SpawnPosition
Sleep 500

Reload
Sleep 1000 ; Restart
}
}
}
}

; *******************************

SShutdown:
SSFlag=1
ModWait := abs(A_TickCount)
ModWait += (ModUpdateWarning*1000)
ModWait += 1500

Return

RestartIt:
ModWait=0
SSFlag=0
msnt := "» Restarting Server"
TMessage(msnt,Handle)

Return

Exit:
If !FileExist(mini)
FileAppend, [Workshop]`n, %mini%
Sleep, 5
WinGetPos, Xpos, Ypos,,, %ServerName%
erp := Xpos "," Ypos
IniWrite, %erp%, %mini%, Workshop, SpawnPosition

ExitApp

Return

TMessage(Wmessage,WHandle) {
GuiControl, Text, PBox,%Wmessage%
GuiControl, Focus, PBox
SendMessage, 0xB1, -2, -1,, ahk_id %WHandle%
SendMessage, 0xB7,,,, ahk_id %WHandle%
Gui, Submit, NoHide
DllCall("HideCaret","Int",Win)
Return
}

DaRT(aVar,bVar,Dscolor,IdleMark) {
KeyCombination:=""
LineScn := []
ExcludeKeys := "{Shift Up}{Control Up}{Alt Up}{WheelUp Up}{WheelDown Up}"
Loop, 0xFF
{
If GetKeyState(Key:=Format("VK{:02X}",0x100-A_Index))
{
If !InStr(ExcludeKeys,Key:="{" GetKeyName(Key) " Up}")
KeyCombination .= RegexReplace(Key,"Numpad(\D+)","$1")
}
}
BlockInput, On
SendInput, %KeyCombination%
If IdleMark
{
Sleep, 5
pBitmaps := Gdip_BitmapFromScreen()
Gdip_GetDimensions(pBitmaps, w, h)

LineScn := StrSplit(bVar, ",")
OcX := LineScn[1]
OcY := LineScn[2]

ffile := "Pos.png"
cfile := "HexColorsFound.txt"

pBitmap3 := Gdip_CreateBitmap(w, h), G3 := Gdip_GraphicsFromImage(pBitmap3)
Gdip_DrawImage(G3, pBitmaps, 0, 0, w, h, OcX, OcY, w, h)
Gdip_DeleteGraphics(G3)
ccnt=0

While (ccnt < 10 && !RegExMatch(RGB, Dscolor))
{
ccnt++
ARGB := Gdip_GetPixel(pBitmap3, 0, ccnt)
VarSetCapacity( RGB,6,0 )
DllCall( "msvcrt.dll\sprintf", Str,RGB, Str,"%06X", UInt,ARGB<<8 )
}
Gdip_DisposeImage(pBitmap3)
Gdip_DisposeImage(pBitmaps)

If (ccnt = 10)
{
WinMinimize, ahk_exe %aVar%
Sleep, 1000
WinMaximize, ahk_exe %aVar%
Sleep, 1000
}

FileDelete, %cfile%
TabCheck=0
While !TabCheck
{
pBitmaps := Gdip_BitmapFromScreen()
Gdip_GetDimensions(pBitmaps, w, h)
pBitmap3 := Gdip_CreateBitmap(w, h), G3 := Gdip_GraphicsFromImage(pBitmap3)
Gdip_DrawImage(G3, pBitmaps, 0, 0, w, h, OcX, OcY, w, h)
Gdip_DeleteGraphics(G3)
ccnt=0

While (ccnt < 10 && !RegExMatch(RGB, Dscolor))
{
ccnt++
ARGB := Gdip_GetPixel(pBitmap3, 0, ccnt)
VarSetCapacity( RGB,6,0 )
DllCall( "msvcrt.dll\sprintf", Str,RGB, Str,"%06X", UInt,ARGB<<8 )
FileAppend, %RGB%`n, %cfile%
}
Gdip_SaveBitmapToFile(pBitmap3, ffile)
Gdip_DisposeImage(pBitmap3)
Gdip_DisposeImage(pBitmaps)

If (ccnt = 10)
{
SendInput {Tab}
Sleep, 70
}
else
TabCheck++
}
}

Return
}
