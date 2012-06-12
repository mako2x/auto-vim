send(keys) {
  Send, % keys
}

run(target, workingDir="", option="", pid="") {
  Run, %target%, %workingDir%, %option%, %pid%
}

sleep(delay) {
  Sleep, % delay
}

stringUpper(str) {
  StringUpper, result, str
  return result
}

stringLower(str) {
  StringLower, result, str
  return result
}

stringCamelize(str) {
  StringUpper, result, str, T
}

toolTip(text, timeOut=1500, x=0, y=0, coordMode="Relative", num=1) {
	CoordMode, ToolTip, %coordMode%
	ToolTip, %text%, %x%, %y%, %num%
  if(timeOut)
    SetTimer, hideToolTip, -%timeOut%
  return
  hideToolTip:
    hideToolTip()
	return
}

hideToolTip() {
  ToolTip,
}

groupAdd(groupName, winTitle, winText="", label="", excludeTitle="", excludeText="") {
  GroupAdd, %groupName%, %winTitle%, %winText%, %label%, %excludeTitle%, %excludeText%
}

groupActivate(groupName, R="") {
  GroupActivate, %groupName%, %R%
}
