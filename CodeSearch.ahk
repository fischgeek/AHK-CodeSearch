/*
	TODO:
		- Get browse button working
		- Add ability to double-click open a file to that line number
		- Add progress bar
		- Add file path to listview results
		- Add right-click context menu
			- Add option to open file location
		- Add Anchor()
		- Add case sensitive search
		- Add whole word search
		- Save and populate previous directory
*/

Gui, Color, White
Gui, Font, s11, Segoe UI Light
Gui, Add, Text,, % "Initial Directory:"
Gui, Add, Edit, Section w300 vtxtInitialDirectory
Gui, Add, Button, hp+1 w40 ys-1 vbtnDirectoryBrowse, % "..."
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
Gui, Add, ListView, xm w1000 r20 vlvResults, % "File|Line Text|Line #|Position"
Gui, Show, AutoSize Center, Code Search
return


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
			RegExMatch(line, "O)" keyword, obj)
			if (obj.Len() > 0) {
				LV_Add("", file, truncate(line), A_Index, obj.Pos())
				;~ msgbox, % "Found a match on line: " A_Index "`nIn file: " file "`n`n" line
				adjHdrs("lvResults")
			}
		}
	}
	return
}

GuiClose:
{
	ExitApp
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