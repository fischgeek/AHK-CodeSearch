class Config {

	Path := A_ScriptDir "\config.ini"
	
	setValue(value, key) {
		IniWrite, %value%, this.Path, Settings, %key%
	}
	
	getValue(key) {
		IniRead, value, this.Path, Settings, %key%, 0
		return value
	}
}