
#
# Ye Olde Camerra Hack - Another fine Harmattan Hack Powered by Python(tm)!
# 2012-01-12; Thomas Perl <thp.io/about>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This package is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# On Debian systems, the complete text of the GNU General
# Public License version 3 can be found in "/usr/share/common-licenses/GPL-3".
#


from QmSystem import *
from PySide.QtGui import *
from PySide.QtDeclarative import *

import sys
import subprocess
import re
import time

app = QApplication(sys.argv)
keys = QmKeys()
last_time = time.time()

WAIT_BETWEEN_CLICKS = 3
WINID_REGEX = r'_NET_ACTIVE_WINDOW\(WINDOW\): window id # (0x[0-9a-f]*)'
CAMERA_REGEX = r'WM_CLASS\(STRING\) = "camera-ui"'

def camera_app_on_top():
    # Is the window of the camera app currently on top or some other app?
    root = subprocess.Popen(['xprop', '-root'], stdout=subprocess.PIPE)
    stdout, stderr = root.communicate()
    win_id = re.search(WINID_REGEX, stdout).group(1)

    win_info = subprocess.Popen(['xprop', '-id', win_id],
            stdout=subprocess.PIPE)
    stdout, stderr = win_info.communicate()

    return re.search(CAMERA_REGEX, stdout) is not None

def keyEvent(key, state):
    # Callback for QmKeys key events
    global last_time

    if time.time() - last_time < WAIT_BETWEEN_CLICKS:
        # Avoid hammering the cam app when Vol+ is being kept pressed
        return

    if key == state == 2 and camera_app_on_top():
        last_time = time.time()
        p = subprocess.Popen(['xresponse', '-d', '820x240,820x240', '-w', '1'],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        p.wait()

keys.keyEvent.connect(keyEvent)

view = QDeclarativeView()
view.setSource('/opt/camerra/camerra.qml')
view.showFullScreen()

app.exec_()

