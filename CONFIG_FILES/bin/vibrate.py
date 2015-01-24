#!/usr/bin/python
#vibrate.py
#Copyright 2012,2015 Elliot Wolk
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
from PySide.QtGui import *
from PySide.QtCore import *
from PySide.QtDeclarative import *

import sys
import tempfile

VIBRATE_MILLIS = 500
SLEEP_MILLIS = 500

def main():
  args = sys.argv
  args.pop(0)

  soundFile = None
  if len(args) > 0:
    soundFile = args.pop()

  if len(args) > 0:
    print >> sys.stderr, "Usage: " + sys.argv[0] + " [SOUND_FILE]\n"
    sys.exit(2)

  qml = QmlGenerator(soundFile=soundFile, vibrateMillis=VIBRATE_MILLIS).getQml()
  fd, qmlFile = tempfile.mkstemp(prefix="vibrate_", suffix=".qml")
  fh = open(qmlFile, 'w')
  fh.write(qml)
  fh.close()

  app = QApplication([])
  widget = MainWindow(qmlFile)
  widget.rootObject().play()
  QTimer.singleShot(SLEEP_MILLIS, QCoreApplication.instance().quit)
  app.exec_()

class MainWindow(QDeclarativeView):
  def __init__(self, qmlFile):
    super(MainWindow, self).__init__(None)
    self.setSource(qmlFile)

class QmlGenerator():
  def __init__(self, soundFile=None, vibrateMillis=None):
    self.soundFile = soundFile
    self.vibrateMillis = vibrateMillis

  def getQml(self):
    return (""
      + self.indent(0, self.getHeader())
      + self.indent(1, self.getMain())
      + self.indent(1, self.getSound())
      + self.indent(1, self.getVibrate())
      + self.indent(0, self.getFooter())
    )

  def getHeader(self):
    return """
      import QtQuick 1.1
      import QtMultimediaKit 1.1
      import QtMobility.feedback 1.1
      import QtMobility.systeminfo 1.1

      Item {
    """
  def getFooter(self):
    return """
      }
    """

  def getMain(self):
    if self.vibrateMillis == None:
      vibrateFct = "//no vibrate/haptics function"
    else:
      vibrateFct = "vibration.start()"

    if self.soundFile == None:
      soundFct = "//no sound function"
    else:
      soundFct = "sound.play()"

    return """
      function play() {
        %(vibrateFct)s
        %(soundFct)s
      }
    """ % {'vibrateFct': vibrateFct, 'soundFct': soundFct}


  def getSound(self):
    if self.soundFile == None:
      return """
        //no sound effect
      """
    else:
      return """
        SoundEffect {
          id: sound
          source: "%(soundFile)s"
        }
      """ % {'soundFile': self.soundFile}

  def getVibrate(self):
    if self.vibrateMillis == None:
      return """
        //no vibrate/haptics effect
      """
    else:
      return """
        HapticsEffect {
          id: vibration
          attackIntensity: 0.0
          attackTime: %(halfMillis)i
          intensity: 1.0
          duration: %(vibrateMillis)i
          fadeTime: %(halfMillis)i
          fadeIntensity: 0.0
        }
      """ % {'vibrateMillis': self.vibrateMillis, 'halfMillis': int(self.vibrateMillis/2)}

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

if __name__ == "__main__":
  sys.exit(main())
