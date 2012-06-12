#include ./common.ahk
#include ./autovim.ahk


avim := new AutoVim()
avim.addExcludeWin("ahk_class Vim")

#if
#Ins::avim.toggle()

#if (avim.enabled)
^[::avim.setNormalMode()
^i::avim.insertImeOff()
^j::avim.insertImeOn()

#if (avim.enabled && !avim.isExcludeWin() && (avim.isNormalMode() || avim.isVisualMode()) )
a::avim.insertAfter()
+a::avim.insertLineEnd()
b::avim.previousWord()
c::avim.deleteInsert()
+c::avim.deleteInsertUntilLineEnd()
d::avim.delete()
+d::avim.deleteUntilLineEnd()
^f::avim.pageDown()
g::
  char := avim.getChar()
  if(char == "g")
    avim.top()
  else if(char == "n")
    avim.new()
  else if(char == "m")
    avim.winMin()
  else if(char == "M")
    avim.winMax()
  else if(char == "t")
    avim.tabRight()
  else if(char == "T")
    avim.tabLeft()
  else if(char == "0")
    avim.lineTop()
  else if(char == "$")
    avim.lineEnd()
  else if(char == "_")
    avim.lineEnd()
  return
+g::avim.bottom()
h::avim.left()
i::avim.insert()
+i::avim.insertLineTop()
j::avim.down()
+j::avim.joinLine()
k::avim.up()
l::avim.right()
^l::avim.refresh()
n::avim.searchForward()
+n::avim.searchBackward()
o::avim.newLine()
+o::avim.newLineAbove()
p::avim.paste()
+p::avim.pasteBefore()
^p::avim.pageUp()
r::avim.replace()
^r::avim.redo()
u::avim.undo()
v::avim.setVisualMode()
w::avim.nextWord()
x::avim.deleteChar()
+x::avim.deleteBackwordChar()
y::avim.yank()
+y::avim.yankLine()
+z::
  char := avim.getChar()
  if(char == "Z")
    avim.writeQuit()
  return
Enter::avim.nextLine()
+sc027::avim.nextLine() ; "+"
-::avim.previousLine()
sc00D::avim.lineTop()   ; "|"
+4::avim.lineEnd()      ; "$"
/::avim.search()
>::avim.indent()
<::avim.unindent()
0::(avim.count) ? avim.setCount() : avim.lineTop()
1::
2::
3::
4::
5::
6::
7::
8::
9::
avim.setCount()
return

#if
