#!/usr/bin/python
#N9 Button Monitor
#Copyright 2012 Elliot Wolk
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

from PySide.QtGui import *
from PySide.QtCore import *
from collections import deque

import os
import sys
import subprocess
import signal

signal.signal(signal.SIGINT, signal.SIG_DFL)

def main():
  if len(sys.argv) != 2:
    print >> sys.stderr, "Usage: " + sys.argv[0] + " conf-file"
    sys.exit(2)
  confFile = sys.argv[1]

  commandThread = CommandThread()

  app = QApplication([])
  grid = SimpleGrid(7)
  for cmd in Config(confFile).readConfFile():
    if cmd.infobar:
      infobar = Infobar(cmd)
      grid.newRow()
      grid.add(infobar)
      commandThread.addInfobar(infobar)
    else:
      grid.add(CommandButton(cmd, commandThread))

  widget = QWidget()
  widget.setLayout(grid)
  widget.showFullScreen()

  commandThread.start(QThread.HighestPriority)

  app.exec_()

class CommandEntry():
  def __init__(self, name, icon, command, infobar=False):
    self.name = name
    self.icon = icon
    self.command = command
    self.infobar = infobar

class CommandButton(QToolButton):
  def __init__(self, cmd, commandThread):
    QToolButton.__init__(self)
    self.cmd = cmd
    self.commandThread = commandThread

    self.setText(cmd.name)
    icon = self.createIcon(self.cmd.icon)
    if icon != None:
      self.setIcon(icon)
      self.setIconSize(QSize(80,80))
      self.setToolButtonStyle(Qt.ToolButtonStyle.ToolButtonTextUnderIcon)

    self.setFixedSize(QSize(120,120))
    self.setStyleSheet("font-size: 16pt")

    self.clicked.connect(self.run)

  def createIcon(self, iconPath):
    if os.path.isfile(iconPath) and os.path.isabs(iconPath):
      return QIcon(iconPath)
    elif os.path.exists(self.wrapIcon(iconPath)):
      return QIcon(self.wrapIcon(iconPath))
    else:
      return None
  def wrapIcon(self, iconPath):
    if iconPath.endswith(".png"):
      iconPath = icon[:-4]
    return "/usr/share/themes/blanco/meegotouch/icons/" + iconPath + ".png"
  def run(self):
    self.commandThread.addCmd(self.cmd.command)

class CommandThread(QThread):
  def __init__(self):
    QThread.__init__(self)
    self.commands = deque()
    self.infobars = []
    self.mutex = QMutex()
    self.waitCond = QWaitCondition()
  def run(self):
    self.updateInfobars()
    while(True):
      while len(self.commands) > 0:
        self.runCmd()
        self.updateInfobars()
      self.waitCond.wait(self.mutex)
      print "WOKE UP"
  def addCmd(self, cmd):
    self.mutex.lock()
    self.commands.append(cmd)
    self.mutex.unlock()
    self.waitCond.wakeAll()
  def addInfobar(self, infobar):
    self.infobars.append(infobar)
  def runCmd(self):
    self.mutex.lock()
    cmd = self.commands.popleft()
    self.mutex.unlock()
    print "RUNNING " + cmd
    proc = subprocess.Popen(['sh', '-c', cmd])
    proc.wait()
  def updateInfobars(self):
    print "UPDATING INFOBARS"
    for infobar in self.infobars:
      infobar.update()

class Infobar(QLabel):
  def __init__(self, cmd):
    QLabel.__init__(self, cmd.command)
    self.cmd = cmd
    self.setFixedHeight(25)
    self.setFixedWidth(850)
    self.setStyleSheet("font-size: 16pt")
  def update(self):
    self.setText(self.cmd.command)
    try:
      proc = subprocess.Popen(['sh', '-c', self.cmd.command],
        stdout=subprocess.PIPE)
      self.setText(proc.stdout.readline())
      proc.terminate()
    except:
      self.setText("ERROR")

class Config():
  def __init__(self, confFile):
    self.confFile = confFile
  def readConfFile(self):
    if not os.path.exists(self.confFile):
      print >> sys.stderr, self.confFile + " is missing"
      sys.exit(1)
    cmds = []
    for line in file(self.confFile).readlines():
      line = line.partition('#')[0]
      line = line.strip()
      if len(line) > 0:
        csv = line.split(',', 3)
        if len(csv) == 2 and csv[0].strip() == "infobar":
          cmd = csv[1].strip()
          cmds.append(CommandEntry(None, None, cmd, True))
        elif len(csv) == 3:
          name = csv[0].strip()
          icon = csv[1].strip()
          cmd = csv[2].strip()
          cmds.append(CommandEntry(name, icon, cmd))
        else:
          raise Exception("Error parsing config line: " + line)
    return cmds

class SimpleGrid(QVBoxLayout):
  def __init__(self, cols):
    QVBoxLayout.__init__(self)
    self.cols = cols
    self.col = 0
    self.row = 0
    self.curRow = None
  def add(self, w):
    if self.col >= self.cols or self.curRow == None:
      self.newRow()
    self.col += 1
    self.curRow.addWidget(w)
  def newRow(self):
    self.col = 0
    self.row += 1
    self.curRow = QHBoxLayout()
    self.addLayout(self.curRow)

if __name__ == "__main__":
  sys.exit(main())
