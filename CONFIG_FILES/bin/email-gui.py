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

import os
import os.path
import re
import signal
import sys
import subprocess

PLATFORM_OTHER = 0
PLATFORM_HARMATTAN = 1

signal.signal(signal.SIGINT, signal.SIG_DFL)

PAGE_INITIAL_SIZE = 200
PAGE_MORE_SIZE = 200

UNREAD_COUNTS = os.getenv("HOME") + "/.unread-counts"
EMAIL_DIR = os.getenv("HOME") + "/.cache/email"

def main():
  issue = open('/etc/issue').read().strip().lower()
  platform = None
  if "harmattan" in issue:
    platform = PLATFORM_HARMATTAN
  else:
    platform = PLATFORM_OTHER

  if platform == PLATFORM_HARMATTAN:
    qmlFile = "/opt/email-gui/harmattan.qml"
  else:
    qmlFile = "/opt/email-gui/desktop.qml"

  emailManager = EmailManager()
  accountModel = AccountModel()
  headerModel = HeaderModel()
  controller = Controller(emailManager, accountModel, headerModel)

  controller.setupAccounts()

  app = QApplication([])
  widget = MainWindow(qmlFile, controller, accountModel, headerModel)
  if platform == PLATFORM_HARMATTAN:
    widget.window().showFullScreen()
  else:
    widget.window().show()

  app.exec_()

class EmailManager():
  def getAccounts(self):
    if not os.path.isfile(UNREAD_COUNTS):
      return []
    f = open(UNREAD_COUNTS, 'r')
    counts = f.read()
    f.close()
    accounts = []
    for line in counts.splitlines():
      m = re.match('^(\d+):(\w+)', line)
      if not m:
        return []
      accounts.append(Account(m.group(2), m.group(1)))
    return accounts
  def getUids(self, accName, fileName):
    filePath = EMAIL_DIR + "/" + accName + "/" + fileName
    if not os.path.isfile(filePath):
      return []
    f = open(filePath, 'r')
    uids = f.read()
    f.close()
    return map(int, uids.splitlines())
  def fetchHeaders(self, accName, limit=None, exclude=[]):
    uids = self.getUids(accName, "all")
    uids.sort()
    uids.reverse()
    if len(exclude) > 0:
      exUids = set(map(lambda header: header.uid_, exclude))
      uids = filter(lambda uid: uid not in exUids, uids)
    if limit != None:
      uids = uids[0:limit]
    return map(lambda uid: self.getHeader(accName, uid), uids)
  def getHeader(self, accName, uid):
    filePath = EMAIL_DIR + "/" + accName + "/" + "headers/" + str(uid)
    if not os.path.isfile(filePath):
      return None
    f = open(filePath, 'r')
    header = f.read()
    f.close()
    hdrDate = ""
    hdrFrom = ""
    hdrSubject = ""
    for line in header.splitlines():
      m = re.match('(\w+): (.*)', line)
      if not m:
        return None
      field = m.group(1)
      val = m.group(2)
      if field == "Date":
        hdrDate = val
      elif field == "From":
        hdrFrom = val
      elif field == "Subject":
        hdrSubject = val
    return Header(uid, hdrDate, hdrFrom, hdrSubject)
  def getBody(self, accName, uid):
    process = subprocess.Popen(["email.pl", "--body-html", accName, str(uid)],
      stdout=subprocess.PIPE)
    (stdout, stderr) = process.communicate()
    return stdout

class Controller(QObject):
  def __init__(self, emailManager, accountModel, headerModel):
    QObject.__init__(self)
    self.emailManager = emailManager
    self.accountModel = accountModel
    self.headerModel = headerModel
    self.currentAccount = None
  @Slot()
  def setupAccounts(self):
    self.accountModel.setItems(self.emailManager.getAccounts())
  @Slot(QObject)
  def accountSelected(self, account):
    print 'clicked acc: ', account.Name
    self.currentAccount = account.Name
    headers = self.emailManager.fetchHeaders(self.currentAccount,
      limit=PAGE_INITIAL_SIZE, exclude=[])
    self.headerModel.setItems(headers)
  @Slot()
  def moreHeaders(self):
    headers = self.emailManager.fetchHeaders(self.currentAccount,
      limit=PAGE_MORE_SIZE, exclude=self.headerModel.getItems())
    self.headerModel.appendItems(headers)
  @Slot(QObject, result=str)
  def getBodyText(self, header):
    print 'clicked uid:', str(header.uid_)
    return self.emailManager.getBody(self.currentAccount, header.uid_)

class BaseListModel(QAbstractListModel):
  def __init__(self):
    QAbstractListModel.__init__(self)
    self.items = []
  def getItems(self):
    return self.items
  def setItems(self, items):
    self.clear()
    self.beginInsertRows(QModelIndex(), 0, 0)
    self.items = items
    self.endInsertRows()
  def appendItems(self, items):
    self.beginInsertRows(QModelIndex(), len(self.items), len(self.items))
    self.items.extend(items)
    self.endInsertRows()
  def rowCount(self, parent=QModelIndex()):
    return len(self.items)
  def data(self, index, role):
    if role == Qt.DisplayRole:
      return self.items[index.row()]
  def clear(self):
    self.removeRows(0, len(self.items))
  def removeRows(self, firstRow, rowCount, parent = QModelIndex()):
    self.beginRemoveRows(parent, firstRow, firstRow+rowCount-1)
    while rowCount > 0:
      del self.items[firstRow]
      rowCount -= 1
    self.endRemoveRows()

class AccountModel(BaseListModel):
  COLUMNS = ('account',)
  def __init__(self):
    BaseListModel.__init__(self)
    self.setRoleNames(dict(enumerate(AccountModel.COLUMNS)))

class HeaderModel(BaseListModel):
  COLUMNS = ('header',)
  def __init__(self):
    BaseListModel.__init__(self)
    self.setRoleNames(dict(enumerate(HeaderModel.COLUMNS)))

class Account(QObject):
  def __init__(self, name_, unread_):
    QObject.__init__(self)
    self.name_ = name_
    self.unread_ = unread_
  def Name(self):
    return str(self.name_)
  def Unread(self):
    return str(self.unread_)
  changed = Signal()
  Name = Property(unicode, Name, notify=changed)
  Unread = Property(unicode, Unread, notify=changed)

class Header(QObject):
  def __init__(self, uid_, date_, from_, subject_):
    QObject.__init__(self)
    self.uid_ = uid_
    self.date_ = date_
    self.from_ = from_
    self.subject_ = subject_
  def Uid(self):
    return str(self.uid_)
  def Date(self):
    return str(self.date_)
  def From(self):
    return str(self.from_)
  def Subject(self):
    return str(self.subject_)
  changed = Signal()
  Uid = Property(unicode, Uid, notify=changed)
  Date = Property(unicode, Date, notify=changed)
  From = Property(unicode, From, notify=changed)
  Subject = Property(unicode, Subject, notify=changed)

class MainWindow(QDeclarativeView):
  def __init__(self, qmlFile, controller, accountModel, headerModel):
    super(MainWindow, self).__init__(None)
    context = self.rootContext()
    context.setContextProperty('accountModel', accountModel)
    context.setContextProperty('headerModel', headerModel)
    context.setContextProperty('controller', controller)
    self.setResizeMode(QDeclarativeView.SizeRootObjectToView)
    self.setSource(qmlFile)

if __name__ == "__main__":
  sys.exit(main())
