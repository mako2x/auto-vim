class AutoVim {
  static NORMAL_MODE := 0
  static INSERT_MODE := 1
  static VISUAL_MODE := 2

  ; Initialize
  __New() {
    this.enabled := true
    this.config := {showModeOnToolTip: true, showModeOnToolTipTimeout: 1000}
    this.setNormalMode(false)
  }

  ; Enable AutoVim
  enable(showToolTip=true) {
    this.enabled := true
    if(showToolTip)
      toolTip("!! AutoVim is Enabled !!")
  }

  ; Disable AutoVim
  disable(showToolTip=true) {
    this.enabled := false
    if(showToolTip)
      toolTip("!! AutoVim is Disabled !!")
  }

  ; Toggle enable and disable state of AutoVim
  toggle() {
    this.enabled ? this.disable() : this.enable()
  }

  addExcludeWin(winTitle, winText="", label="", excludeTitle="", excludeText="") {
    GroupAdd, AutoVimExcludeWin, %winTitle%, %winText%, %label%, %excludeTitle%, %excludeText%
  }

  isExcludeWin() {
    ifWinActive, ahk_group AutoVimExcludeWin
      return true
    else
      return false
  }

  ;##############################
  ; IME
  ;##############################
  _imeSet(stat) {
    varSetCapacity(stGTI, 48, 0)
    numPut(48, stGTI, 0, "UInt")
    hwndFocus := dllCall("GetGUIThreadInfo", Uint, 0, Uint, &stGTI) ? numGet(stGTI, 12, "UInt") : winExist("A")
    return dllCall("SendMessage", UInt, dllCall("imm32\ImmGetDefaultIMEWnd", Uint, hwndFocus), UInt, 0x0283, Int, 0x006, Int, stat)
  }

  imeOff() {
    this._imeSet(0)
  }

  imeOn() {
    this._imeSet(1)
  }


  ;##############################
  ; Mode
  ;##############################
  isNormalMode() {
    return (this.mode == this.NORMAL_MODE)
  }

  isInsertMode() {
    return (this.mode == this.INSERT_MODE)
  }

  isVisualMode() {
    return (this.mode == this.VISUAL_MODE)
  }

  setNormalMode(showMode=true) {
    this.mode := this.NORMAL_MODE
    this.operator := ""
    this.count := ""
    this.hideCommand()
    if(showMode)
      this.showMode("-- Normal -- ")
		Menu, Tray, Icon, icon/normal.ico
  }

  setInsertMode(showMode=true) {
    this.mode := this.INSERT_MODE
    this.operator := ""
    this.count := ""
    this.command := ""
    if(showMode)
      this.showMode("-- Insert -- ")
		Menu, Tray, Icon, icon/insert.ico
  }

  setVisualMode(showMode=true) {
    if( this.isVisualMode() ) {
      this.setNormalMode()
    } else {
      this.mode := this.VISUAL_MODE
      if(showMode)
        this.showMode("-- Visual -- ")
      Menu, Tray, Icon, icon\visual.ico
    }
  }

  showMode(mode) {
    if(this.config.showModeOnToolTip)
      toolTip(mode, this.config.showModeOnToolTipTimeout)
  }

  insert() {
    this.setInsertMode()
  }

  insertImeOn() {
    this.setInsertMode()
    this.imeOn()
  }

  insertImeOff() {
    this.setInsertMode()
    this.imeOff()
  }

  insertAfter() {
    this.setNormalMode()
    this.right()
    this.setInsertMode()
  }

  insertlineTop() {
    this.setNormalMode(false)
    this.lineTop()
    this.setInsertMode()
  }

  insertLineEnd() {
    this.setNormalMode(false)
    this.lineEnd()
    this.setInsertMode()
  }

  replace() {
    this.deleteChar()
    this.setInsertMode()
  }

  newLine(){
    this.insertLineEnd()()
    send("{Enter}")
  }

  newLineAbove(){
    this.setNormalMode(false)
    this.up()
    this.newLine()
  }


  ;##############################
  ; Command
  ;##############################
  ; Get a character from the standard input
  getChar() {
    this.showCommand()
    this.disable(false)
    Input, char, L1 M
    this.enable(false)
    this.hideCommand()
    return char
  }

  showCommand() {
    if(A_TimeSinceThisHotkey < 100) {
      if(regExMatch(A_ThisHotKey, "\+(\w)", $)) {   ; Shift+[a-z]
        this.command := stringUpper($1)
      } else {
        this.command .= A_ThisHotKey
      }
    }
    toolTip(this.command, false, 25, 2)
  }

  hideCommand() {
    this.command := ""
    hideToolTip()
  }

  setCount() {
    this.count .= A_ThisHotkey
    this.showCommand()
  }


  ;##############################
  ; Move
  ;##############################
  _move(keys, shiftAll=false) {
    if( this.isNormalMode() && !this.operator ) {
      send(keys)
    } else {
      if(shiftAll)
        send("{Shift down}" . keys . "{Shift up}")
      else
        send("+" . keys)
      if(this.operator) {
        this.setVisualMode(false)
        this[this.operator]()
      }
    }
    this.hideCommand()
    this.count := ""
  }

  _moveChar(key) {
    if(this.count)
      this._move("{" . key . " " . this.count . "}")
    else
      this._move("{" . key . " down}")
  }

  up() {
    this._moveChar("Up")
  }

  down() {
    this._moveChar("Down")
  }

  left() {
    this._moveChar("Left")
  }

  right() {
    this._moveChar("Right")
  }

  nextWord() {
    this._move("^{Right " . this.count . "}")
  }

  previousWord() {
    this._move("^{Left " . this.count . "}")
  }

  lineTop() {
    this.count ? this.count-=1 : this.count:=0
    this._move("{Home}{Right " . this.count . "}", true)
  }

  lineEnd() {
    if( this.count >= 2 ) {
      this.count -= 1
      this.nextLine()
    }
    this._move("{End}", "+{End}")
  }

  nextLine() {
    this.count ? this.count-=1 : this.count:=0
    this._move("{Down}{Home}{Down " . this.count . "}", true)
  }

  previousLine() {
    this.count ? this.count-=1 : this.count:=0
    this._move("{Home}{Up}{Up " . this.count . "}", true)
  }

  pageUp(){
    this._move("{PgUp " . this.count . "}")
  }

  pageDown(){
    this._move("{PgDn " . this.count . "}")
  }

  top() {
    this.count ? this.count-=1 : this.count:=0
    this._move("^{Home}{Down " . this.count . "}", true)
  }

  bottom(){
    this._move("^{End}")
  }
  

  ;##############################
  ; Operating
  ;##############################
  operate(operator, keys, setInsertMode=false) {
    this.showCommand()
    if( this.isNormalMode() && !this.operator ) {
      this.operator := operator
    } else {
      if(this.isVisualMode()) {
        send(keys)
        if(setInsertMode)
          this.setInsertMode()
        else
          this.setNormalMode(false)
      } else if( this.operator == operator ) {
        this.operateLine(operator)
      } else {
        this.setNormalMode(false)
      }
    }
  }

  operateLine(operator, lineAll=true) {
    count := this.count
    this.setNormalMode(false)
    this.lineTop()
    this.setVisualMode(false)
    this.count := count
    this.lineEnd()
    if(lineAll)
      this.Right()
    this[operator]()
    this.setNormalMode(false)
    if(operator == "yank") {
      this.count := count
      this.up()
    }
  }

  operateUntilLineEnd(operator){
    if( this.isNormalMode() && !this.operator ) {
      this.setVisualMode(false)
      this.nextLine()
      this.left()
      this[operator]()
    } else if( this.isVisualMode() ) {
      this.operateLine(operator, false)
    } else {
      this.setNormalMode(false)
    }
  }

  yank() {
    this.operate("yank", "^{Ins}")
  }

  delete() {
    this.operate("delete", "^x")
  }

  deleteInsert() {
    this.operate("deleteInsert", "^x", true)
  }

  deleteUntilLineEnd(){
    this.operateUntilLineEnd("delete")
  }

  deleteInsertUntilLineEnd(){
    this.operateUntilLineEnd("deleteInsert")
  }


  ;##############################
  ; Misc
  ;##############################
  deleteChar(){
    send("{Del " . this.count . "}")
    this.setNormalMode(false)
  }

  deleteBackwordChar(){
    send("{BS " . this.count . "}")
    this.setNormalMode(false)
  }

  paste(){
    IfWinActive, ahk_class ConsoleWindowClass  ; Command Prompt
      send("!{Space}ep")
    else {
      if( RegExMatch(ClipBoard, "\n") ) {
        this.nextLine()
        send("+{Ins}")
        if(RegExMatch(ClipBoard, "m)\n$"))
          send("{Left}")
      } else {
        send("+{Ins}")
      }
    }
    this.setNormalMode(false)
  }

  pasteBefore(){
    IfWinActive, ahk_class ConsoleWindowClass ; Command Prompt
      send("{Left}!{Space}ep")
    else {
      if(RegExMatch(ClipBoard, "\n"))
        this.lineTop()
      else
        send("{Left}")
      send("+{Ins}")
    }
    this.setNormalMode(false)
  }

  undo() {
    send("^{z " . this.count . "}")
    this.setNormalMode(false)
  }

  redo() {
    send("^{y " . this.count . "}")
    this.setNormalMode(false)
  }

  refresh() {
    send("{F5}")
  }

  search() {
    ifWinActive, ahk_class ConsoleWindowClass   ; Command Prompt
      send("!{Space}ef")
    else
      send("^f")
  }

  searchForward() {
    send("{F3}")
  }

  searchBackward() {
    send("+{F3}")
  }

  joinLine() {
    this.setNormalMode(false)
    this.lineEnd()
    this.deleteChar()
  }

  indent() {
    count := this.count - 1
    this.count := ""
    this.lineTop()
    send("{Tab}")
    Loop, % count {
      this.lineTop()
      this.down()
      send("{Tab}")
    }
  }

  unindent() {
    count := this.count - 1
    this.count := ""
    this.lineTop()
    this.deleteChar()
    Loop, % count {
      this.lineTop()
      this.down()
      this.deleteChar()
    }
  }

  write() {
    send("^s")
  }

  quit() {
    PostMessage, 0x112, 0xF060,,,A
  }

  writeQuit(){
    this.save()
    this.quit()
  }


  ;##############################
  ; Window && Tab Operation
  ;##############################
  new() {
    send("^n")
  }

  winMin() {
    PostMessage, 0x112, 0xF020,,, A
  }

  winMax() {
    WinGet, State, MinMax, A
    if (State != 0)
      WinRestore, A
    else
      WinMaximize, A
  }

  tabRight() {
    if !this.count
      this.count := 1
    Loop, % this.count
      send("^{Tab}")
  }

  tabLeft() {
    if !this.count
      this.count := 1
    Loop, % this.count
      send("+^{Tab}")
  }

  tabClose() {
    send("^w")
  }
}
