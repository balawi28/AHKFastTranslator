#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force ; Ensures only one instance of the script is running.

; Update tray icon
Menu, Tray, Icon, % "HICON:" . Base64PNG_to_HICON(TrayIcon())

global Minimized := True
dict := GetLanguagesDict()
menuOptions := Join(dict, "|")

IniRead, defaultSourceLanguage, %A_ScriptFullPath%:Stream:$DATA, Settings, defaultSourceLanguage,English
IniRead, defaultTargetLanguage, %A_ScriptFullPath%:Stream:$DATA, Settings, defaultTargetLanguage,Arabic
IniRead, hotKeyPrevious, %A_ScriptFullPath%:Stream:$DATA, Settings, hotKeyPrevious, ^+t
IniRead, isRanAtStartup, %A_ScriptFullPath%:Stream:$DATA, Settings, Startup, error
IniRead, outputMethod, %A_ScriptFullPath%:Stream:$DATA, Settings, outputMethod, tooltip
IniRead, EnableClipboard, %A_ScriptFullPath%:Stream:$DATA, Settings, EnableClipboard, 0

; Initalize hotkey
if (StrLen(hotKeyPrevious) != 0)
    Hotkey, %hotKeyPrevious%, HotkeyPressed

; Initalize source and target languages
sourceIndex := FindLanguageIndex(dict, defaultSourceLanguage)
targetIndex := FindLanguageIndex(dict, defaultTargetLanguage)

; Tray menu
Menu, Tray, NoStandard ; Remove all standard tray menu options
Menu, Tray, Add, GUI, HotkeyPressed
Menu, Tray, Add, Run at Startup, StartupToggle
Menu, Tray, Add, Exit, ExitApplication
Menu, Tray, Icon, Exit, Shell32.dll, 132
Menu, Tray, Default, GUI
Gui, +AlwaysOnTop +ToolWindow +LastFound +Border +OwnDialogs
Gui, Color, White
Gui, Font, s11

; GUI configuration
Gui, Add, DropDownList, x10 y10 w150 choose%sourceIndex% vSourceLang gOnSourceLangChange, %menuOptions%
Gui, Add, Picture, x168 y14 w23 h16 gSwapLanguages, % "HICON:" . Base64PNG_to_HICON(SwapIcon())
Gui, Add, DropDownList, x200 y10 w150 choose%targetInde`x% vTargetLang gOnTargetLangChange, %menuOptions%

Gui, Add, Picture, x10 y50 w32 h32, % "HICON:" . Base64PNG_to_HICON(GoogleTranslateLogo())
Gui, Add, Edit, x55 y55 w295 vTextToTranslate

Gui, Add, Text, x10 y100 w200,GUI Popup Hotkey:
Gui, Add, Hotkey, x130 y97 w150 h25 vhotKeyCurrent
GuiControl,, hotKeyCurrent, %hotKeyPrevious%
Gui Add, Button, x290 y96 w60` h27, Save
Gui, Add, Text, x10 y130 w200,Prefered Output:
Gui, Add, Radio, x130 y130 vChoiceToolTip gRadioChoice, Tooltip
Gui, Add, Radio, x200 y130 vChoiceMsgBox gRadioChoice, Message Box
GuiControl,, % outputMethod = "tooltip" ? "ChoiceToolTip" : "ChoiceMsgBox", 1

Gui, Add, CheckBox, x10 y160 vEnableClipboard gCheckBox, Copy Translation to Clipboard
GuiControl,,EnableClipboard,%EnableClipboard%

Gui, Add, Text, x275 y200, [draggable]
Gui, Font, Underline cBlue
Gui, Add, Text, x10 y200 gAbout, About
Gui, Add, Text, x72 y200 gBugReport, Bug Report
Gui, Add, Text, x167 y200 gHowToUse, How to Use?

; Define the callback function to handle the WM_MOVE message
OnMessage(0x0232, "OnDragRelease")

; To enable drag on the main window
enableGuiDrag()
return

CheckBox:
    Gui, Submit, NoHide
    IniWrite, %EnableClipboard%, %A_ScriptFullPath%:Stream:$DATA, Settings,EnableClipboard
Return

; Save hotkey routine
ButtonSave:
    Gui, Submit, NoHide
    if (StrLen(hotKeyPrevious) != 0 and hotKeyPrevious != hotKeyCurrent){
        Hotkey, %hotKeyPrevious%, Off
    }
    if (StrLen(hotKeyCurrent) != 0){
        Hotkey, %hotKeyCurrent%, On, UseErrorLevel
        Hotkey, %hotKeyCurrent%, HotkeyPressed
    }
    IniWrite, %hotKeyCurrent%, %A_ScriptFullPath%:Stream:$DATA, Settings,hotKeyPrevious
    hotKeyPrevious := hotKeyCurrent
    MsgBox, 0x40000,, Hotkey Saved Successfully
return

About:
    MsgBox, 0x40000, , By: balawi28`n`nhttps://github.com/balawi28/AHKFastTranslator
return

BugReport:
    MsgBox, 0x40000,,https://github.com/balawi28/AHKFastTranslator/issues
return

HowToUse:
    MsgBox, 0x40000,, 1- Assign a hotkey then click "save" button.`n2- Whenever you need to translate something use that hotkey.`n3- Press Enter to receive the translation.
return

#IfWinActive, AHKFastTranslation ahk_class AutoHotkeyGUI
    Esc::
        Gui, Cancel
        Minimized := True
    return
    NumpadEnter::
    Enter::
        Gui, Submit
        Minimized := True
        url := TranslateURL(dict[SourceLang], dict[TargetLang], TextToTranslate)
        response := PostRequest(url)
        cleanResponse := SubStr(response, 3, StrLen(response) - 4)
        if (EnableClipboard)
            Clipboard := cleanResponse
        if (outputMethod = "tooltip"){
            ToolTip % cleanResponse
            Sleep, 2000 ; Display the tooltip for 2 seconds
            ToolTip ; Remove the tooltip
        } else
        MsgBox, 0x40000,, % cleanResponse
return
#IfWinActive

GuiClose:
    Minimized := True
    Gui, Cancel
return

ExitApplication(){
    ExitApp
    Exit
}

RadioChoice:
    gui, submit, nohide
    outputMethod := ChoiceToolTip ? "tooltip" : "msgbox"
    IniWrite, %outputMethod%, %A_ScriptFullPath%:Stream:$DATA, Settings,outputMethod
Return

HotkeyPressed(){
    if(Minimized){
        IniRead, defaultXPosition, %A_ScriptFullPath%:Stream:$DATA, Settings, defaultXPosition,Center
        IniRead, defaultYPosition, %A_ScriptFullPath%:Stream:$DATA, Settings, defaultYPosition,Center
        Gui, Show, x%defaultXPosition% y%defaultYPosition% w360 h230, AHKFastTranslation
        GuiControl, Focus, TextToTranslate
    }else{
        Gui, Cancel
    }
    Minimized := ! Minimized
    
}

StartupToggle()
{
    isRanAtStartup := !isRanAtStartup
    Menu, Tray, ToggleCheck, Run at Startup
    if(isRanAtStartup)
        FileCreateShortcut,%A_ScriptFullPath%,%A_AppData%\Microsoft\Windows\Start Menu\Programs\Startup\TrayAudioAnalyzer.lnk,%A_ScriptDir%
    else
        FileDelete, %A_AppData%\Microsoft\Windows\Start Menu\Programs\Startup\TrayAudioAnalyzer.lnk

    IniWrite, %isRanAtStartup%, %A_ScriptFullPath%:Stream:$DATA, Settings, Startup
}

PostRequest(url){
    response := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    response.Open("POST", url, false)
    response.Send()
    return response.ResponseText
}

TranslateURL(sourceLang, targetLang, textToTranslate)
{
    baseUrl := "http://translate.google.com/translate_a/t?"
    params := []
    params["sl"] := sourceLang
    params["tl"] := targetLang
    params["uptl"] := targetLang
    params["q"] := UriEncode(textToTranslate)
    params["client"] := "p"
    params["hl"] := "en"
    params["sc"] := "2"
    params["ie"] := "UTF-8"
    params["oe"] := "UTF-8"
    params["oc"] := "1"
    params["prev"] := "conf"
    params["psl"] := "auto"
    params["ptl"] := "en"
    params["otf"] := "1"
    params["it"] := "sel.8936"
    params["ssel"] := "0"
    params["tsel"] := "3"
    return baseUrl . EncodeParams(params)
}

Join(dict, delim) {
    result := ""
    for key in dict
    {
        if (result != "")
            result .= delim
        result .= key
    }
    return result
}

FindLanguageIndex(dict, language) {
    index := 1
    for key, value in dict
    {
        if (key == language)
            return index
        index += 1
    }
    return -1 ; Language not found, return -1
}

OnSourceLangChange() {
    GuiControlGet, selectedSourceLang, , SourceLang
    IniWrite, %selectedSourceLang%, %A_ScriptFullPath%:Stream:$DATA, Settings, defaultSourceLanguage
}

OnTargetLangChange() {
    GuiControlGet, selectedTargetLang, , TargetLang
    IniWrite, %selectedTargetLang%, %A_ScriptFullPath%:Stream:$DATA, Settings, defaultTargetLanguage
}

SwapLanguages(){
    GuiControlGet, selectedTargetLang, , TargetLang
    GuiControlGet, selectedSourceLang, , SourceLang
    temp := selectedSourceLang
    GuiControl, Choose, SourceLang, %selectedTargetLang%
    GuiControl, Choose, TargetLang, %temp%
    IniWrite, %selectedTargetLang%, %A_ScriptFullPath%:Stream:$DATA, Settings, defaultSourceLanguage
    IniWrite, %temp%, %A_ScriptFullPath%:Stream:$DATA, Settings, defaultTargetLanguage
}

EncodeParams(params)
{
    encodedParams := ""
    for key, value in params
    {
        encodedKey := key
        encodedValue := value
        encodedParams .= (encodedParams = "") ? encodedKey . "=" . encodedValue : "&" . encodedKey . "=" . encodedValue
    }
    return encodedParams
}

; UriEncode function is written by the-Automator
; https://www.the-automator.com/parse-url-parameters/
UriEncode(Uri, RE="[0-9A-Za-z]")
{
    VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0)
    StrPut(Uri, &Var, "UTF-8")
    While Code := NumGet(Var, A_Index-1, "UChar")
    {
        Res .= (Chr := Chr(Code)) ~= RE ? Chr : Format("%{:02X}", Code)
    }
    Return Res
}

; Define the MouseUp function to get the new x and y coordinates
OnDragRelease(wParam, lParam, msg, hwnd)
{
    WinGetPos, WinX, WinY, , , ahk_id %hwnd%
    IniWrite, %WinX%, %A_ScriptFullPath%:Stream:$DATA, Settings, defaultXPosition
    IniWrite, %WinY%, %A_ScriptFullPath%:Stream:$DATA, Settings, defaultYPosition
}

Base64PNG_to_HICON(Base64PNG, W:=0, H:=0){
    BLen:=StrLen(Base64PNG), Bin:=0, nBytes:=Floor(StrLen(RTrim(Base64PNG,"="))*3/4)
    Return DllCall("Crypt32.dll\CryptStringToBinary", "Str",Base64PNG, "UInt",BLen, "UInt",1,"Ptr",&(Bin:=VarSetCapacity(Bin,nBytes)), "UIntP",nBytes, "UInt",0, "UInt",0)? DllCall("CreateIconFromResourceEx", "Ptr",&Bin, "UInt",nBytes, "Int",True, "UInt",0x30000, "Int",W, "Int",H, "UInt",0, "UPtr") : 0
}

enableGuiDrag(GuiLabel=1) {
    WinGetPos,,,A_w,A_h,A
    Gui, %GuiLabel%:Add, Text, x0 y0 w%A_w% h%A_h% +BackgroundTrans gGUI_Drag
    return

    GUI_Drag:
        SendMessage 0xA1,2 ;-- Goyyah/SKAN trick
    ;http://autohotkey.com/board/topic/80594-how-to-enable-drag-for-a-gui-without-a-titlebar
    return
}

GetLanguagesDict(){
    global dict
    if !dict {
        dict := {}
        dict["Afrikaans"] := "af"
        dict["Albanian"] := "sq"
        dict["Amharic"] := "am"
        dict["Arabic"] := "ar"
        dict["Armenian"] := "hy"
        dict["Assamese"] := "as"
        dict["Aymara"] := "ay"
        dict["Azerbaijani"] := "az"
        dict["Bambara"] := "bm"
        dict["Basque"] := "eu"
        dict["Belarusian"] := "be"
        dict["Bengali"] := "bn"
        dict["Bhojpuri"] := "bho"
        dict["Bosnian"] := "bs"
        dict["Bulgarian"] := "bg"
        dict["Catalan"] := "ca"
        dict["Cebuano"] := "ceb"
        dict["Chinese (Simplified)"] := "zh-CN"
        dict["Chinese (Traditional)"] := "zh-TW"
        dict["Corsican"] := "co"
        dict["Croatian"] := "hr"
        dict["Czech"] := "cs"
        dict["Danish"] := "da"
        dict["Dhivehi"] := "dv"
        dict["Dogri"] := "doi"
        dict["Dutch"] := "nl"
        dict["English"] := "en"
        dict["Esperanto"] := "eo"
        dict["Estonian"] := "et"
        dict["Ewe"] := "ee"
        dict["Filipino (Tagalog)"] := "fil"
        dict["Finnish"] := "fi"
        dict["French"] := "fr"
        dict["Frisian"] := "fy"
        dict["Galician"] := "gl"
        dict["Georgian"] := "ka"
        dict["German"] := "de"
        dict["Greek"] := "el"
        dict["Guarani"] := "gn"
        dict["Gujarati"] := "gu"
        dict["Haitian Creole"] := "ht"
        dict["Hausa"] := "ha"
        dict["Hawaiian"] := "haw"
        dict["Hebrew"] := "he"
        dict["Hindi"] := "hi"
        dict["Hmong"] := "hmn"
        dict["Hungarian"] := "hu"
        dict["Icelandic"] := "is"
        dict["Igbo"] := "ig"
        dict["Ilocano"] := "ilo"
        dict["Indonesian"] := "id"
        dict["Irish"] := "ga"
        dict["Italian"] := "it"
        dict["Japanese"] := "ja"
        dict["Javanese"] := "jv"
        dict["Kannada"] := "kn"
        dict["Kazakh"] := "kk"
        dict["Khmer"] := "km"
        dict["Kinyarwanda"] := "rw"
        dict["Konkani"] := "gom"
        dict["Korean"] := "ko"
        dict["Krio"] := "kri"
        dict["Kurdish"] := "ku"
        dict["Kurdish (Sorani)"] := "ckb"
        dict["Kyrgyz"] := "ky"
        dict["Lao"] := "lo"
        dict["Latin"] := "la"
        dict["Latvian"] := "lv"
        dict["Lingala"] := "ln"
        dict["Lithuanian"] := "lt"
        dict["Luganda"] := "lg"
        dict["Luxembourgish"] := "lb"
        dict["Macedonian"] := "mk"
        dict["Maithili"] := "mai"
        dict["Malagasy"] := "mg"
        dict["Malay"] := "ms"
        dict["Malayalam"] := "ml"
        dict["Maltese"] := "mt"
        dict["Maori"] := "mi"
        dict["Marathi"] := "mr"
        dict["Meiteilon (Manipuri)"] := "mni-Mtei"
        dict["Mizo"] := "lus"
        dict["Mongolian"] := "mn"
        dict["Myanmar (Burmese)"] := "my"
        dict["Nepali"] := "ne"
        dict["Norwegian"] := "no"
        dict["Nyanja (Chichewa)"] := "ny"
        dict["Odia (Oriya)"] := "or"
        dict["Oromo"] := "om"
        dict["Pashto"] := "ps"
        dict["Persian"] := "fa"
        dict["Polish"] := "pl"
        dict["Portuguese"] := "pt"
        dict["Punjabi"] := "pa"
        dict["Quechua"] := "qu"
        dict["Romanian"] := "ru"
        dict["Samoan"] := "sm"
        dict["Sanskrit"] := "sa"
        dict["Scots Gaelic"] := "gd"
        dict["Sepedi"] := "nso"
        dict["Serbian"] := "sr"
        dict["Sesotho"] := "st"
        dict["Shona"] := "sn"
        dict["Sindhi"] := "sd"
        dict["Sinhala (Sinhalese)"] := "si"
        dict["Slovak"] := "sk"
        dict["Slovenian"] := "sl"
        dict["Somali"] := "so"
        dict["Spanish"] := "es"
        dict["Sundanese"] := "su"
        dict["Swahili"] := "sw"
        dict["Swedish"] := "sv"
        dict["Tagalog (Filipino)"] := "tl"
        dict["Tajik"] := "tg"
        dict["Tamil"] := "ta"
        dict["Tatar"] := "tt"
        dict["Telugu"] := "te"
        dict["Thai"] := "th"
        dict["Tigrinya"] := "ti"
        dict["Tsonga"] := "ts"
        dict["Turkish"] := "tr"
        dict["Turkmen"] := "tk"
        dict["Twi (Akan)"] := "ak"
        dict["Ukrainian"] := "uk"
        dict["Urdu"] := "ur"
        dict["Uyghur"] := "ug"
        dict["Uzbek"] := "uz"
        dict["Vietnamese"] := "vi"
        dict["Welsh"] := "cy"
        dict["Xhosa"] := "xh"
        dict["Yiddish"] := "yi"
        dict["Yoruba"] := "yo"
        dict["Zulu"] := "zu"
    }
    return dict
}

SwapIcon(){
    Base64PNG := ""
        . "iVBORw0KGgoAAAANSUhEUgAAACAAAAAVCAYAAAAnzezqAAAACXBIWXMAAA3XAAAN1wFCKJt4AAAFyWlU"
        . "WHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhp"
        . "SHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0"
        . "az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuYTg3MzFiOSwgMjAyMS8wOS8wOS0wMDozNzozOCAg"
        . "ICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJk"
        . "Zi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRw"
        . "Oi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1l"
        . "bnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4w"
        . "LyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0"
        . "PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVh"
        . "dG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjAgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAy"
        . "My0wNi0zMFQwMjowMToyNSswMzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjMtMDYtMzBUMDI6MjM6MzUr"
        . "MDM6MDAiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjMtMDYtMzBUMDI6MjM6MzUrMDM6MDAiIGRjOmZvcm1h"
        . "dD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAu"
        . "aWlkOjU5NjQ4M2ExLTBiYmQtM2M0Yi05YzMyLWEwZjE5NTRhYzdjNyIgeG1wTU06RG9jdW1lbnRJRD0i"
        . "YWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOmU1OWJmZTNjLWQ3ZjYtNzM0YS1hNjY3LWQzOWI1NmMxMmZmYSIg"
        . "eG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOmQwYmVhNDVkLTU0MTgtMTU0ZS1hNGQ1LTY4"
        . "N2UwZDYxODhiMiI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249"
        . "ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6ZDBiZWE0NWQtNTQxOC0xNTRlLWE0ZDUt"
        . "Njg3ZTBkNjE4OGIyIiBzdEV2dDp3aGVuPSIyMDIzLTA2LTMwVDAyOjAxOjI1KzAzOjAwIiBzdEV2dDpz"
        . "b2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjMuMCAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2"
        . "dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjU5NjQ4M2ExLTBiYmQtM2M0"
        . "Yi05YzMyLWEwZjE5NTRhYzdjNyIgc3RFdnQ6d2hlbj0iMjAyMy0wNi0zMFQwMjoyMzozNSswMzowMCIg"
        . "c3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIzLjAgKFdpbmRvd3MpIiBzdEV2dDpj"
        . "aGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4g"
        . "PC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PmOrIjcAAAEfSURBVEgNY2DA"
        . "DhKA+D8QL2YYAJAEtRyEXwAx20BZDsKZ9LQ8G83yOHpano9muQM9Lc9Ds/wxEPcA8Vog3gLEm0jAR4B4"
        . "AhAzkuKAF2gOoAb2IcUB09E0PwXinUB8F4jvAPFtEvAbID4MxEJI5nMBsRQhR8xEcsBvIDamYhTvg5pb"
        . "TYojvgKxFhUsZwXi50jm1hLSMAEtOuyo4Ah3NDPbCGnoRlL8DIhZqOAIKzRHdBPS0AlVeIqKacEMiP+S"
        . "4ghNIBZA4vMB8WYgvg/E50jA56H0KiB+QmpIIANfGpQXL0lxAKhWXAjEl4D4AAn4EDQrzoaWssgOqKZn"
        . "kW+JZnktPS0PRrO8lJ6Wx6BZnk9Py9nQKju6Wg4Da6CW52CTBADLm7B1N75ElAAAAABJRU5ErkJggg=="
    return Base64PNG
}

TrayIcon(){
    Base64PNG := ""
    . "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAGSWlU"
    . "WHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhp"
    . "SHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0"
    . "az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuYTg3MzFiOSwgMjAyMS8wOS8wOS0wMDozNzozOCAg"
    . "ICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJk"
    . "Zi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRw"
    . "Oi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94"
    . "YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9S"
    . "ZXNvdXJjZUV2ZW50IyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hv"
    . "cC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtcDpDcmVh"
    . "dG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjAgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAy"
    . "My0wNy0xMlQxNjoyMToxMiswMzowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wNy0xMlQxNjoyMTox"
    . "MiswMzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjMtMDctMTJUMTY6MjE6MTIrMDM6MDAiIHhtcE1NOklu"
    . "c3RhbmNlSUQ9InhtcC5paWQ6NzgyODIyMDEtYzYwYi05MzQxLTkwNzktMTA0NjI2YjA5MDFmIiB4bXBN"
    . "TTpEb2N1bWVudElEPSJhZG9iZTpkb2NpZDpwaG90b3Nob3A6ZGM5MjljYTItYjM5MS00ZTQ1LTkyZWIt"
    . "ODYyMWIzZmM3NGViIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6ZWZlYTBmN2MtNjQ4"
    . "MS1kYzRlLTg0MDgtYzlhNjBkNDAyYmJmIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiBkYzpmb3JtYXQ9"
    . "ImltYWdlL3BuZyI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249"
    . "ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6ZWZlYTBmN2MtNjQ4MS1kYzRlLTg0MDgt"
    . "YzlhNjBkNDAyYmJmIiBzdEV2dDp3aGVuPSIyMDIzLTA3LTEyVDE2OjIxOjEyKzAzOjAwIiBzdEV2dDpz"
    . "b2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjMuMCAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2"
    . "dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjc4MjgyMjAxLWM2MGItOTM0"
    . "MS05MDc5LTEwNDYyNmIwOTAxZiIgc3RFdnQ6d2hlbj0iMjAyMy0wNy0xMlQxNjoyMToxMiswMzowMCIg"
    . "c3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIzLjAgKFdpbmRvd3MpIiBzdEV2dDpj"
    . "aGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8cGhvdG9zaG9wOlRleHRMYXll"
    . "cnM+IDxyZGY6QmFnPiA8cmRmOmxpIHBob3Rvc2hvcDpMYXllck5hbWU9Iti5IiBwaG90b3Nob3A6TGF5"
    . "ZXJUZXh0PSLYuSIvPiA8L3JkZjpCYWc+IDwvcGhvdG9zaG9wOlRleHRMYXllcnM+IDwvcmRmOkRlc2Ny"
    . "aXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+WwrQuAAAAjtJ"
    . "REFUWMO9VztuwkAQNSeAipomkAIJxAmQ0lByBAoOQIdEhbgAhQ9ASRVRcACOABIFRSTo0xgSORRImfg5"
    . "HjOYtRfshZGm8O545+183mgtIrI8efH03dODp8TabDZpOBz62ul0SO5l0EPg6yXwbVU8dVTGcMzSbrdN"
    . "AWB1At8+GtIBQDQMAyDfd7fb/VksFqTS3W4XAlgulxRnV6/X0wL4tuQt00qm6MhCk8JrUsfjMW02myub"
    . "UqmUJQ3nj8lk4h+M0BeLxSvjWq1G8/nct+n1eqbq4PyBXEJOpxPZtn1hmMvlaDQa+fuO41ChUDAPAIqi"
    . "griuS+VyOVyvVqt0PB7D0BvshMsF5JMFKcHN8/l8GHqkx3ArJvd/q9Wifr//SD5Qb3Aq1ut1yAcG6TgZ"
    . "ANLAAKTMZrObWw5gYS+JDClVFO+lY/S6TnBQEhDpWEtaaL0oWoka+3Fsif0oEekucMUfqsOR82i+4YSJ"
    . "KipyFoAjmCuiZ8BOMTcs/yacY93YBRCA5n8kJyC8Kcb3/6FpmC36n+QQFVXj9ljHRbVtmFY5MhwdRAV1"
    . "IUc7OuxhAHBLroOkLnoYAOaAOEGEIvVh1jkOVxEYQMVwhznncCDDfyNzmgMgSSiS5+cA4Eq/c2SbAxDT"
    . "Zs8DIPN/B7GZAyBnBdrtxtF9+R7MonIW8EACKLSmKiKNRsNNfJpl7QSdTKfTDwB4jXucZiEjHR1DBoPB"
    . "mxU8kStBJL5MUzJSgK5gQPv9/ne1Wn1ut1sbvv8Akdi/PNdSy+EAAAAASUVORK5CYII="

    return Base64PNG
}

GoogleTranslateLogo(){
    Base64PNG := ""
        . "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAGlmlU"
        . "WHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhp"
        . "SHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0"
        . "az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuYTg3MzFiOSwgMjAyMS8wOS8wOS0wMDozNzozOCAg"
        . "ICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJk"
        . "Zi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRw"
        . "Oi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1l"
        . "bnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4w"
        . "LyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0"
        . "PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVh"
        . "dG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjAgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAy"
        . "My0wNi0yMFQyMDoyOToxNCswMzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjMtMDYtMjBUMjE6MTA6MTYr"
        . "MDM6MDAiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjMtMDYtMjBUMjE6MTA6MTYrMDM6MDAiIGRjOmZvcm1h"
        . "dD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAu"
        . "aWlkOjgwYjExNTNlLTRjN2EtMDg0YS04MzU3LTRiZWNhYzRkZTE3YyIgeG1wTU06RG9jdW1lbnRJRD0i"
        . "YWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjNkZmFjNDUxLThhZTQtOTc0MS04MmE1LTZiNTVkYmRhYzlkZCIg"
        . "eG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjUyYWI3YjQ2LTQwNzMtNTE0YS05NWM3LWQ3"
        . "YTU0Y2Y1OWI3OCI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249"
        . "ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6NTJhYjdiNDYtNDA3My01MTRhLTk1Yzct"
        . "ZDdhNTRjZjU5Yjc4IiBzdEV2dDp3aGVuPSIyMDIzLTA2LTIwVDIwOjI5OjE0KzAzOjAwIiBzdEV2dDpz"
        . "b2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjMuMCAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2"
        . "dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmIxZDI4M2JiLTU0MmQtOWE0"
        . "Yy1iOWQxLTdhODg2MjM2ODY3MyIgc3RFdnQ6d2hlbj0iMjAyMy0wNi0yMFQyMToxMDoxNiswMzowMCIg"
        . "c3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIzLjAgKFdpbmRvd3MpIiBzdEV2dDpj"
        . "aGFuZ2VkPSIvIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0i"
        . "eG1wLmlpZDo4MGIxMTUzZS00YzdhLTA4NGEtODM1Ny00YmVjYWM0ZGUxN2MiIHN0RXZ0OndoZW49IjIw"
        . "MjMtMDYtMjBUMjE6MTA6MTYrMDM6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hv"
        . "cCAyMy4wIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlz"
        . "dG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBl"
        . "bmQ9InIiPz5wF6l/AAAIGElEQVRYw5WXe4xcZRnGf9/3nXPmtrM7u9vt7raltmUpWGjlUtqUhhYqSsNF"
        . "BQ0kSFViJAaDIJoWLzH+04hAohgCjRgkSALRQIioBI2mFrSBQqWEBtpCAbvt3nd25z5zzve9/jGzl9lu"
        . "KT3JyTlzbu/zPe/leUb94sl3GKmmg49KbT8CWaqEEEAaO4BMnTTOBe0rV9mvo8LDaA8EtIH3By03XerY"
        . "/pU2SuWAV197jWx2lPb2Rfh+DyKWkZETZDJxli3rxVrwrJiWXBjsqDnzk0Bb3FSgWQCYc02UQmFuaLW1"
        . "h7WLECCqQbe2rF0eJwpPfvdUm3c41/HjfBS/19cA+hO+pnFeImNz2TWEk28pL0b/QIVtn+9iy+pWxgoQ"
        . "j3/CL2XD+FKFoJBpqudDP/uaEkGURyFYcIONpzleTtGzOMP1mxcwMmE5k037yhVm51nmBpT5wAhagZjk"
        . "TaOHj1PpP87d12VIxDyKFUGpMwAgs3N7modnF6OyNSTZvmqw3LXqxo3trFmZZDgboTUopVBKYa0liiKs"
        . "dTgnOCdEkcVaN1MDH0c186RkmiEnFGyM1Zd2/uCLV0Y/HJnANBaunHNYawmCgEQiQRD4eJ5CRJFIBCoI"
        . "vIpzMiqi8OZbtWrs2TJMlFSdUoGOFiEVA9d4ydVqBB1dt1k9eJuvPTwfwFGtVqhUyvT19TWYk+njsmUr"
        . "AJFazT5mrd3pzeVdK6hGMDCpWL1E2LYxYklGODig+de7mvGioiMpWIGWWMR72XYOnhjmkhVZ/HgXIoJz"
        . "DhFBa90ILtMgQKEUCrjdGCUnpaAawUhBcccWy21XhA3SFZ9dE/HdqxXfeypg31HNgpZ6IRaqhqMTbVxS"
        . "O0F2IkZ7phWlVBOQmRqqg6nfByDVlAKt4MSk4p7PRdxyeY0j/R4PvOSRKyvWLXesWeIYmlCkYlInTiDh"
        . "OQ6OJLm6pKlQRAGZTCsKsPa0LVltSkG+qji3R7hlY8TQuOH2JwNy5Tqwlw/VH13YKiQCiPmCAtKxkI8m"
        . "U/RP+pzV6SiVyvi+5qzeHgqlMrliCaNPPeCaGMgW4apVDrTwx30+g5PQ3QpfvsSyYaWlVFZYgYmi4ol/"
        . "G2oR+J4wXIrx1lCGT/eM4uLt9A8Nc/9Tz7Pl0ov4wuVrGc/lp9tYoeotL/W6aAJgBWJ+/TxXAV9Drgwr"
        . "u4W1KyyuqtCxOvXPvGbIV8AzkPAs+wfb+NIFE3SlEvQDu18/wLLuhfiJzSSqNcTVe19rTaUWUm20UlMR"
        . "JgM4Nlbv5o0rHL972WNFxvH4K4b7XvRQwPN3VhEHo4UGWIG2wDFp0zzw3H50+AJVCVjW28Pr7xzhjp0P"
        . "sbCjnTCyjE7kGM3l+NrWzWxdfyEj2UmaaqAjKew5rDlyzLB5dcT2axS/3eNxeFDRnhJ2XBPRmrb85h8B"
        . "YwXF0o4p/bCMV2Isbz2frStakHg32mjK1SqxwOOve99kLF9m29ZNjOXzLOnqpFiuIMxJgdbgG9jxrM+u"
        . "bwjf2hJy/RrLmx9ptqxyBAnH/vd9Htvj0dPaLF4uCkktuICzukNKtHD+2UswRmGM4ZFn/8bVGy7iuis3"
        . "IrUy2VyRyUIRo1Wz/jqBnjbheFaxbVeMP+z18QxsXWMZyCke3+1z99M+KR/iXvNozsQi/pdP8ad9A3zn"
        . "vl/z6sHDJDMd7HruJSJnuXbDRQwPDjA4NkG5WsUzutEFcyZhLYJFGSFXhp0veOza7RH3hXxFkStCd5uQ"
        . "DCByNA0YTzsODTlu3LSZrZNH+P2Le4jHfJ7++yvcdfO1LO3p4oPjQ8TjMYIgmJmWc9VQqH88GYOlnULM"
        . "CNZCOpD6b+/k4HUFUIhY3hoM2H7r9fiexz0PPcGNV6znhk3r6R8ew/MMURQRhiGqodmnnhANNJ6GwIDR"
        . "c33izHyfutYRjzgwEOeND0N86jJcKFdAQSIWYJ2blukwDOsMMB8FMr8XnJomswPPNi5xY6noODuePEBS"
        . "l/nV3d9k9xsHufeRp2hLJWlrSU6DmJJsrY32ToVhvhXLx/gGJ4pS2bF4+QZu3bqF9atW8uCdX2fv24f4"
        . "/sNPICIkYgEiMpMCiwTGN41VqeZVSzPVJ7tl1WRaBDCuAsk+Qm8hhz44yrmfWsyj22/nlQPv8stn/kx7"
        . "uqUJvPE7rxmLtaSvSKZT7S4Kpz81ZVTn8qGkcc9ZrA7QqQT4AcoPwAvwYz79Zc2SdJWLFxUYzkUs713I"
        . "Z/qW07ugg47WFNGMSv7XO7Ln7T2VirvwvKsuu6cW6XZBPt4aCmgcNa8lihXH17n+E5eLl5hmyTOK8Q8d"
        . "xzKK+MVxTKg4MZZldd9SrLVk80UC359RQ60cYsNcpRb+TFCIO401VVCWGAkTstbs7fzPweyojidRgDFw"
        . "9HjI6sUeN6/rY6SQBiUYrRmfzDcAmjkOzBi0MeiGT1LqNLsIFWKsS77HZefasZ5zeveVVQovnWYgn+Ds"
        . "lR3cv/M8Mp1JqpU61a6hhGqWX59iTJ/JnwiFUFRpeuU4bROHeHcoRToZPa6VYnjU0tqi+fmOXtpafcYn"
        . "LEYLIu6kvp4Kboz2zwhAlThtXon13l6qYYl8PsvCtvJfylVHZIWf3tXNgs6AkTGL56lZTaVOGl5Ga8Ja"
        . "aLwzWT9a0TtxkGKkKZpFaARr3bGFndF73/7qgr7zz4kxMBTiB7oRjHlTYIyiWKz+8+iHIw9+YgCiDXFb"
        . "hMksx2wKqxWIIl8Q1q5O7lx/YWLT0GjktNZT3qt+aDjkWZKvbeRKk7nKrnwxevv/sZ0p2Ci1PVEAAAAA"
        . "SUVORK5CYII="

    return Base64PNG
}
