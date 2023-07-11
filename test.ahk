;activex gui - test  joedf - 2014/07/04
#SingleInstance, off
OnExit,OnExit

MYAPP_PROTOCOL:="myapp"

HTML_page =
( Ltrim Join
<!DOCTYPE html>
<html>

<head>
    <style>
        body {
            font-family: sans-serif;
            background-color: #dde4ec;
            margin: 0;
            padding: 0;
        }

        select {

		}

        img {
			pointer-events: auto;
			position: absolute;
			left:0

        }
    </style>


</head>

<body>

    <div id="language-selection">

        <select name="cars" id="cars">
            <option value="English" selected>English</option>
            <option value="Arabic">Arabic</option>
        </select>
        
        <select name="cars" id="cars">
            <option value="English" selected>English</option>
            <option value="Arabic">Arabic</option>
        </select>
        <img unselectable="on" src="data:image/png;base64, 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"/>
    </div>

    <script>
    </script>


</body>

</html>
)

Gui Add, ActiveX, x0 y0 w400 h260 vWB, Shell.Explorer2  ; The final parameter is the name of the ActiveX component.
WB.silent := true ;Surpress JS Error boxes
Display(WB,HTML_page)
ComObjConnect(WB, WB_events)  ; Connect WB's events to the WB_events class object.
WB.document.body.style.overflow:="hidden"

Gui Show, w400 h260
return

GuiClose:
	WB.document.getElementById("inputText").value
ExitApp

OnExit:
	FileDelete,%A_Temp%\*.DELETEME.html ;clean tmp file
ExitApp

class WB_events
{
	;for more events and other, see http://msdn.microsoft.com/en-us/library/aa752085
	
	NavigateComplete2(wb) {
		wb.Stop() ;blocked all navigation, we want our own stuff happening
	}
	DownloadComplete(wb, NewURL) {
		wb.Stop() ;blocked all navigation, we want our own stuff happening
	}
	DocumentComplete(wb, NewURL) {
		wb.Stop() ;blocked all navigation, we want our own stuff happening
	}
	
	BeforeNavigate2(wb, NewURL)
	{
		wb.Stop() ;blocked all navigation, we want our own stuff happening
		;parse the url
		global MYAPP_PROTOCOL
		if (InStr(NewURL,MYAPP_PROTOCOL "://")==1) { ;if url starts with "myapp://"
			what := SubStr(NewURL,Strlen(MYAPP_PROTOCOL)+4) ;get stuff after "myapp://"
			if InStr(what,"msgbox/hello")
				MsgBox Hello world!
			else if InStr(what,"soundplay/ding")
				SoundPlay, %A_WinDir%\Media\ding.wav
		}
		;else do nothing
	}
}

Display(WB,html_str) {
	Count:=0
	while % FileExist(f:=A_Temp "\" A_TickCount A_NowUTC "-tmp" Count ".DELETEME.html")
		Count+=1
	FileAppend,%html_str%,%f%
	WB.Navigate("file://" . f)
}

ExecuteAHKFunction() {
    MsgBox, This is the AHK function that will be executed!
}