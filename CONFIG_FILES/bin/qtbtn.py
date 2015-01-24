#!/usr/bin/python
#qtbtn.py
#Copyright 2012,2015 Elliot Wolk
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

from PySide.QtGui import *
from PySide.QtCore import *
from PySide.QtDeclarative import *
from collections import deque

import os
import sys
import subprocess
import signal
import tempfile
import time

PLATFORM_OTHER = 0
PLATFORM_HARMATTAN = 1

signal.signal(signal.SIGINT, signal.SIG_DFL)

usage = """Usage:
  %(exec)s CONFIG_FILE

  OPTIONS:
    --landscape
      force landscape view in harmattan
    --portrait
      force portrait view in harmattan
""" % {"exec": sys.argv[0]}

def main():
  args = sys.argv
  args.pop(0)

  orientation=None
  while len(args) > 0 and args[0].startswith("-"):
    arg = args.pop(0)
    if arg == "--landscape":
      orientation = "landscape"
    elif arg == "--portrait":
      orientation = "portrait"
    else:
      print >> sys.stderr, usage
      sys.exit(2)

  if len(args) != 1:
    print >> sys.stderr, usage
    sys.exit(2)

  configFile = args[0]

  issue = open('/etc/issue').read().strip().lower()
  platform = None
  if "harmattan" in issue:
    platform = PLATFORM_HARMATTAN
  else:
    platform = PLATFORM_OTHER

  qml = QmlGenerator(platform, orientation, configFile).getQml()
  fd, qmlFile = tempfile.mkstemp(prefix="qtbtn_", suffix=".qml")
  fh = open(qmlFile, 'w')
  fh.write(qml)
  fh.close()

  app = QApplication([])
  widget = MainWindow(qmlFile)
  widget.window().showFullScreen()

  app.exec_()

class QmlGenerator():
  def __init__(self, platform, orientation, configFile):
    self.entries = Config(configFile).readConfFile()
    self.platform = platform
    self.orientation = orientation
    self.landscapeMaxRowLen = 7
    self.portraitMaxRowLen = 4

  def getQml(self):
    qml = ""
    qml += self.indent(0, self.getHeader())
    qml += self.indent(1, self.getMain())
    qml += "\n"
    for entry in self.entries:
      if entry['infobar']:
        qml += self.indent(1, self.getInfobar(entry))
      else:
        qml += self.indent(1, self.getButton(entry))
      qml += "\n"
    qml += self.indent(0, self.getFooter())
    return qml

  def indent(self, level, msg):
    lines = msg.splitlines()
    while len(lines) > 0 and len(lines[-1].strip(' ')) == 0:
      lines.pop()
    while len(lines) > 0 and len(lines[0].strip(' ')) == 0:
      lines.pop(0)
    minspaces = sys.maxint
    for line in lines:
      if len(line.strip(' ')) == 0:
        continue
      spaces = len(line) - len(line.lstrip(' '))
      minspaces = min(spaces, minspaces)
    newlines = []
    for line in lines:
      newlines.append('  ' * level + line[minspaces:] + "\n")
    return ''.join(newlines)

  def getMain(self):
    if self.platform == PLATFORM_HARMATTAN:
      if self.orientation == "portrait":
        orientLock = "LockPortrait"
      elif self.orientation == "landscape":
        orientLock = "LockLandscape"

      qml = ""
      qml += "Page {\n"
      qml += "  id: portrait\n"
      if self.orientation:
        qml += "  orientationLock: PageOrientation." + orientLock + "\n"
      qml += self.indent(1, self.getLayout(self.portraitMaxRowLen))
      qml += "}\n"
      qml += "Page {\n"
      qml += "  id: landscape\n"
      if self.orientation:
        qml += "  orientationLock: PageOrientation." + orientLock + "\n"
      qml += self.indent(1, self.getLayout(self.landscapeMaxRowLen))
      qml += "}\n"
      if self.orientation:
        qml += "initialPage: " + self.orientation
      else:
        qml += self.indent(0, """
          initialPage: inPortrait ? portrait : landscape
          onInPortraitChanged: {
            if (inPortrait && pageStack.currentPage!==portrait) {
              pageStack.clear()
              pageStack.push(portrait);
            } else if (!inPortrait && pageStack.currentPage!==landscape) {
              pageStack.clear()
              pageStack.push(landscape)
            }
          }
        """)
      return qml
    else:
      return self.getLayout(self.landscapeMaxRowLen)

  def getLayout(self, maxRowLen):
    qmlRows = map(self.getRow, self.splitRows(maxRowLen))
    qml = ""
    qml += "Rectangle{\n"
    qml += "  anchors.centerIn: parent\n"
    qml += "  Column{\n"
    qml += "    spacing: 10\n"
    qml += "    anchors.centerIn: parent\n"
    qml +=      self.indent(2, "\n".join(qmlRows))
    qml += "  }\n"
    qml += "}\n"
    return qml

  def getRow(self, row):
    qml = ""
    qml += "Row{\n"
    qml += "  spacing: 10\n"
    for entry in row:
      qml += "  Loader { sourceComponent: " + entry['widgetId'] + " }\n"
    qml += "}"
    return qml


  def splitRows(self, maxRowLen):
    rows = []
    row = []
    for entry in self.entries:
      if entry['infobar']:
        if len(row) > 0:
          rows.append(row)
          row = []
        rows.append([entry])
      else:
        if len(row) >= maxRowLen:
          rows.append(row)
          row = []
        row.append(entry)
    if len(row) > 0:
      rows.append(row)
      row = []
    return rows

  def getHeader(self):
    if self.platform == PLATFORM_HARMATTAN:
      return """
        import QtQuick 1.1
        import com.nokia.meego 1.1

        PageStackWindow {
      """
    else:
      return """
        import QtQuick 1.1

        Rectangle {
      """
  def getFooter(self):
    return """
      }
    """

  def getInfobar(self, entry):
    return """
        Component{
          id: %(widgetId)s
          Text {
            property variant command: "%(command)s"
            objectName: "infobar"
            font.pointSize: 16
            width: 100
          }
        }
    """ % entry

  def getButton(self, entry):
    if self.platform == PLATFORM_HARMATTAN:
      return """
        Component{
          id: %(widgetId)s
          Button {
            onClicked: commandRunner.runCommand("%(command)s")
            Text {
              text: "%(name)s"
              font.pointSize: 16
              anchors.bottom: parent.bottom
              anchors.horizontalCenter: parent.horizontalCenter
            }
            Image {
              source: "%(icon)s"
              anchors.fill: parent
              anchors.topMargin: 10
              anchors.bottomMargin: 30
              anchors.leftMargin: 10
              anchors.rightMargin: 10
            }
            width: 100
            height: 120
          }
        }
       """ % entry
    else:
      return """
        Component{
          id: %(widgetId)s
          Rectangle {
            border.color: "black"
            border.width: 5
            property variant hover: false
            property variant buttonColorDefault: "gray"
            property variant buttonColorGradient: "white"
            property variant buttonColor: buttonColorDefault
            MouseArea {
              hoverEnabled: true
              anchors.fill: parent
              onClicked: commandRunner.runCommand("%(command)s")
              function setColor(){
                if(this.pressed){
                  parent.buttonColor = Qt.lighter(parent.buttonColorDefault)
                }else if(this.containsMouse){
                  parent.buttonColor = Qt.darker(parent.buttonColorDefault)
                }else{
                  parent.buttonColor = parent.buttonColorDefault
                }
              }
              onEntered: setColor()
              onExited: setColor()
              onPressed: setColor()
              onReleased: setColor()
            }
            gradient: Gradient {
              GradientStop { position: 0.0; color: buttonColor }
              GradientStop { position: 1.0; color: buttonColorGradient }
            }

            Text {
              text: "%(name)s"
              font.pointSize: 16
              anchors.bottom: parent.bottom
              anchors.horizontalCenter: parent.horizontalCenter
            }
            Image {
              source: "%(icon)s"
              anchors.fill: parent
              anchors.topMargin: 10
              anchors.bottomMargin: 30
              anchors.leftMargin: 10
              anchors.rightMargin: 10
            }
            width: 100
            height: 120
          }
        }
      """ % entry


class CommandRunner(QObject):
  def __init__(self, infobars):
    QObject.__init__(self)
    self.infobars = infobars
  @Slot(str)
  def runCommand(self, command):
    os.system(command)
    time.sleep(0.5)
    self.updateInfobars()
  def updateInfobars(self):
    for infobar in self.infobars:
      try:
        context = QDeclarativeEngine.contextForObject(infobar)
        cmd = context.contextProperty("command")
        print "  running infobar command: " + cmd
        proc = subprocess.Popen(['sh', '-c', cmd],
          stdout=subprocess.PIPE)
        infobar.setProperty("text", proc.stdout.readline())
        proc.terminate()
      except:
        infobar.setMessage("ERROR")

class MainWindow(QDeclarativeView):
  def __init__(self, qmlFile):
    super(MainWindow, self).__init__(None)
    self.setSource(qmlFile)

    infobars = self.rootObject().findChildren(QObject, "infobar")
    self.commandRunner = CommandRunner(infobars)
    self.commandRunner.updateInfobars()
    self.rootContext().setContextProperty("commandRunner", self.commandRunner)

class Config():
  def __init__(self, confFile):
    self.confFile = confFile
  def getEntry(self, number, name, icon, command, infobar=False):
    if infobar:
      widgetId = "infobar" + str(number)
    else:
      widgetId = "button" + str(number)
    return { "widgetId": widgetId
           , "name": name
           , "icon": self.getIconPath(icon)
           , "command": command
           , "infobar": infobar
           }
  def getIconPath(self, icon):
    if icon != None and os.path.isfile(icon) and os.path.isabs(icon):
      return icon
    elif icon != None and os.path.exists(self.wrapIconMeego(icon)):
      return self.wrapIconMeego(icon)
    else:
      return ""
  def wrapIconMeego(self, iconPath):
    if iconPath.endswith(".png"):
      iconPath = icon[:-4]
    return "/usr/share/themes/blanco/meegotouch/icons/" + iconPath + ".png"

  def readConfFile(self):
    if not os.path.exists(self.confFile):
      print >> sys.stderr, self.confFile + " is missing"
      sys.exit(1)
    cmds = []
    number = 0
    for line in file(self.confFile).readlines():
      line = line.partition('#')[0]
      line = line.strip()
      if len(line) > 0:
        csv = line.split(',', 3)
        if len(csv) == 2 and csv[0].strip() == "infobar":
          cmd = csv[1].strip()
          cmds.append(self.getEntry(number, None, None, cmd, True))
          number+=1
        elif len(csv) == 3:
          name = csv[0].strip()
          icon = csv[1].strip()
          cmd = csv[2].strip()
          cmds.append(self.getEntry(number, name, icon, cmd))
          number+=1
        else:
          raise Exception("Error parsing config line: " + line)
    return cmds

if __name__ == "__main__":
  sys.exit(main())
