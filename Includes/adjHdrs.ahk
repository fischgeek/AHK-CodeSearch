adjHdrs(listView="") {
	Gui, ListView, %listView%
	Loop, % LV_GetCount("Col")
		LV_ModifyCol(A_Index, "autoHdr")
	LV_ModifyCol(1,"Integer Left")
	return
}