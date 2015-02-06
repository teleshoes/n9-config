#!/usr/bin/env python
# N9-Simple-Screenshot
# Copyright 2012 Elliot Wolk
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

import sys
from PySide import QtCore, QtGui

defaultDir = '/home/user/MyDocs'

name = sys.argv[0]
usage = ("Usage:\n"
  + "  " + name + " FILENAME  take a screenshot, save to FILENAME\n"
  + "  " + name + " -h        show this message\n"
)

def main():
  if len(sys.argv) != 2 or sys.argv[1] == "-h":
    print usage
    sys.exit(1)

  fileName = sys.argv[1]

  QtGui.QApplication(sys.argv)
  ss = getScreenShot()
  ss.save(fileName, 'png')

def getScreenShot():
  return QtGui.QPixmap.grabWindow(QtGui.QApplication.desktop().winId())


if __name__ == '__main__':
  main()
