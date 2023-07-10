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
			body{font-family:sans-serif;background-color:#dde4ec;}
			#title{font-size:36px;}
			#corner{font-size:10px;position:absolute;top:8px;right:8px;}
			p{font-size:16px;background-color:#efefef;border:solid 1px #666;padding:4px;}
			#footer{text-align:center;}
		</style>
	</head>
	<body>
		<div id="title">Lorem Ipsum</div>
		<div id="corner">Welcome!</div>
		<p>The standard Lorem Ipsum passage, used since the 1500s</p>
		<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
		<p>
			<input type="text" id="inputText" placeholder="Enter text here" />
			<button onclick="showMessageBox()">Show MsgBox</button>
			<button onclick="executeAHKFunction()">Execute AHK Function</button>
		</p>
		<p id="footer">
			<a href="%MYAPP_PROTOCOL%://msgbox/hello">Click me for a MsgBox</a>&nbsp;-&nbsp;
			<a href="NOPE://msgbox/hello">Click me for nothing</a>&nbsp;-&nbsp;
			<a href="%MYAPP_PROTOCOL%://soundplay/ding">Click me for a ding sound!</a>
		</p>
		<script>
			function showMessageBox() {
				var inputText = document.getElementById("inputText").value;
				alert(inputText);   
			}
			function executeAHKFunction() {
				var shell = new ActiveXObject("WScript.Shell");
				shell.Run("AutoHotkey.exe ExecuteAHKFunction.ahk");
			}
		</script>
	</body>
</html>
)

Gui Add, ActiveX, x0 y0 w640 h480 vWB, Shell.Explorer  ; The final parameter is the name of the ActiveX component.
WB.silent := true ;Surpress JS Error boxes
Display(WB,HTML_page)
ComObjConnect(WB, WB_events)  ; Connect WB's events to the WB_events class object.
Gui Show, w640 h480
return

GuiClose:
	msgbox % WB.document.getElementById("inputText").value
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
