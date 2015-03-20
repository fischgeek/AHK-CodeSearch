/*
	TODO:
		- Add ability to double-click open a file to that line number
		- Add progress bar
		- Add right-click context menu
			- Add option to open file location
		- Add Anchor()
		- Add whole word search
		- Account for additional extensions
		- Possibly add an extension manager?
		- Find an icon
		- Add pre-search checks (extension selection, directory)
		- Add finished notification (statusbar?)
*/

#Include Classes/Config.ahk
config := new Config()

Gui, Color, White
Gui, Font, s11, Segoe UI Light
Gui, Add, Text,, % "Initial Directory:"
Gui, Add, Edit, Section w300 h27 -Wrap vtxtInitialDirectory, % config.getValue("LastDir") ? config.getValue("LastDir") : ""
Gui, Add, Button, hp+1 w40 ys-1 gbtnDirectoryBrowse_Click vbtnDirectoryBrowse, % "..."
Gui, Add, Text, xm, % "String to search for:"
Gui, Add, Edit, Section w300 vtxtSearchString
Gui, Add, Button, ys-1 hp+1 vbtnSearch gbtnSearch_Click, % "Search"
Gui, Add, Checkbox, Section xm w30 h30 0x1000 vcbxRecurse, % "R"
Gui, Add, Checkbox, ys wp hp 0x1000 vcbxWholeWord, % "W"
Gui, Add, Checkbox, ys wp hp 0x1000 vcbxCase, % "C"
Gui, Add, GroupBox, ym w500 h120, % "File Types"
Gui, Add, Checkbox, yp+30 xp+15 Section vcbxAhk, % ".ahk"
Gui, Add, Checkbox, ys vcbxHtml, % ".html"
Gui, Add, Checkbox, ys vcbxCss, % ".css"
Gui, Add, Checkbox, ys vcbxJs, % ".js"
Gui, Add, Checkbox, ys vcbxIni, % ".ini"
Gui, Add, Checkbox, ys vcbxTxt, % ".txt"
Gui, Add, Text, xs, % "Additional extension (ex. xml,cs,aspx)"
Gui, Add, Edit, w300 vtxtAdditionalExtensions
Gui, Font, s11, Consolas
Gui, Add, ListView, xm w1000 r20 glvResults_Click vlvResults, % "File|Line Text|Line #|Position"
Gui, Show, AutoSize Center, Code Search
return

btnDirectoryBrowse_Click:
{
	Gui, Submit, NoHide
	FileSelectFolder, targetDir, *C:\, 3, % "Select a starting directory."
	if (ErrorLevel) {
		return
	}
	if (targetDir != "") {
		GuiControl,, txtInitialDirectory, %targetDir%
		config.setValue(targetDir, "LastDir")
	}
	return
}

btnSearch_Click:
{
	Gui, Submit, NoHide
	LV_Delete()
	keyword := txtSearchString
	extensions := getExtensions()
	recurse := 0
	if (cbxRecurse)
		recurse := 1
    SetWorkingDir, %txtInitialDirectory%
	Loop, *.*,, %recurse%
	{
		if A_LoopFileAttrib contains H,S,R
			continue
		if A_LoopFileExt not in %extensions%
			continue
		file := A_LoopFileFullPath
		Loop, Read, %file%
		{
			line := A_LoopReadLine
			RegExMatch(line, getRegExOptions(cbxCase) getExpression(keyword, cbxWholeWord), obj)
			if (obj.Len() > 0) {
				LV_Add("", file, truncate(line), A_Index, obj.Pos())
				;~ msgbox, % "Found a match on line: " A_Index "`nIn file: " file "`n`n" line
				adjHdrs("lvResults")
			}
		}
	}
	return
}

lvResults_Click:
{
	Gui, Submit, NoHide
	dir := txtInitialDirectory
	LV_GetText(fileName, A_EventInfo)
	Run Edit %dir%\%fileName%
	return
}

GuiClose:
{
	ExitApp
}

adjHdrs(listView="") {
	Gui, ListView, %listView%
	Loop, % LV_GetCount("Col")
		LV_ModifyCol(A_Index, "autoHdr")
	LV_ModifyCol(1,"Integer Left")
	return
}
truncate(s, c="50") {
	if (StrLen(s) > c) {
		return SubStr(s, 1, c) " (...)"
	}
	return s
}
getExtensions() {
	global
	e := ""
	if (cbxAhk)
		e := "ahk,"
	if (cbxTxt)
		e .= "txt,"
	if (cbxIni)
		e .= "ini,"
	if (cbxHtml)
		e .= "html,"
	if (cbxCss)
		e .= "css,"
	if (cbxJs)
		e .= "js,"
	StringTrimRight, e, e, 1
	return e
}
getExpression(keyword, wholeWord) {
	if (wholeWord) {
		expression := "[\s|\W]?" keyword "[\s|\W]"
	} else {
		expression := keyword
	}
	return expression
}
getRegExOptions(caseSense) {
	options := "O" ; return regex match result as an object
	if (!caseSense) {
		options := options "i" ; case sensitive searching
	}
	return options ")"
}