QT += qml quick widgets
CONFIG += c++11

# CONFIG += console

CONFIG += c++17  # Need this for std::filesystem to work

QT += 3dcore

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

#DEFINES += DEBUG
#DEFINES += USE_USB
DEFINES += USE_PYTHON

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        backend.cpp \
        behaviorcam.cpp \
        behaviortracker.cpp \
        behaviortrackerworker.cpp \
        controlpanel.cpp \
        datasaver.cpp \
        enumerate_devices.cpp \
        main.cpp \
        miniscope.cpp \
        newquickview.cpp \
        tracedisplay.cpp \
        videodevice.cpp \
        videodisplay.cpp \
        videostreamocv.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = C:\Qt\Qt5.14.2\5.14.2\msvc2017_64\qml
QML2_IMPORT_PATH = C:\Qt\Qt5.14.2\5.14.2\msvc2017_64\qml

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Add Icon
RC_ICONS = miniscope_icon.ico

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    backend.h \
    behaviorcam.h \
    behaviortracker.h \
    behaviortrackerworker.h \
    controlpanel.h \
    datasaver.h \
    enumerate_devices.h \
    miniscope.h \
    newquickview.h \
    tracedisplay.h \
    videodevice.h \
    videodisplay.h \
    videostreamocv.h

DISTFILES += \
    ../Python/DLCwrapper.py \
    ../Scripts/DLCwrapper.py \
    ../deviceConfigs/behaviorCams.json \
    ../deviceConfigs/miniscopes.json \
    ../deviceConfigs/userConfigProps.json \
    ../deviceConfigs/videoDevices.json

# Move user and device configs to build directory
CONFIG(release, debug|release) {
    DEST1 = Release
    DEST2 = release
    QT_SUFFIX = ""
}
CONFIG(debug, debug|release) {
    DEST1 = Debug
    DEST2 = debug
    QT_SUFFIX = "d"
}

MACHINE_ID = 0   # 0 for home PC, 1 for work PC, 2 for laptop

# The following folders are machine and installation-specific
equals (MACHINE_ID, 0) {
    # Home PC
    OPENCV_ROOT = ..\opencv412   # These are precompiled libraries and headers
    PYTHON_DIR = C:\Users\tomjh\mambaforge\envs\acq4
    QT_BASE_DIR = C:\Qt\Qt5.14.2\5.14.2\msvc2017_64    # This is used to find Qt DLLs to copy to build directory
    OPENCV_DLL_DIR = C:/Users/tomjh/TomJhou Dropbox/JhouLab/Installers/Miniscope/opencv412/bin/$$DEST1/  # No quotes here, but need quotes below after appending filename
}

equals (MACHINE_ID, 1) {
    # Work PC
    OPENCV_ROOT = ..\opencv411   # These are precompiled libraries and headers
    PYTHON_DIR = C:/ProgramData/miniforge3/envs/acq4
    QT_BASE_DIR = C:\Qt\Qt5.14.2\5.14.2\msvc2017_64    # This is used to find Qt DLLs to copy to build directory
    OPENCV_DLL_DIR = D:\TomJhou Dropbox\JhouLab\Installers\Miniscope\opencv411\bin\\$$DEST1\\  # Need double backslash at the end, but not before. Why???
}

equals (MACHINE_ID, 2) {
    # Laptop
    OPENCV_ROOT = ..\opencv411   # These are precompiled libraries and headers
    PYTHON_DIR = C:/ProgramData/miniforge3/envs/acq4
    QT_BASE_DIR = C:\Qt\Qt5.14.2\5.14.2\msvc2017_64    # This is used to find Qt DLLs to copy to build directory
}


OPENCV_LIB_DIR = $$OPENCV_ROOT\lib\\$$DEST1
OPENCV_FILE = opencv_world4120$$QT_SUFFIX

win32 {
    LIBS += -lole32 -lOleAut32 -lstrmiids  # Need this for enumerating cameras
    LIBS += -L$$OPENCV_LIB_DIR -l$$OPENCV_FILE
    INCLUDEPATH += $$OPENCV_ROOT\include
    INCLUDEPATH += $$PYTHON_DIR/include
    LIBS += -L$$PYTHON_DIR/libs -lpython38
    INCLUDEPATH += $$PYTHON_DIR/Lib/site-packages/numpy/core/include

} else {
    CONFIG += link_pkgconfig
    PKGCONFIG += opencv4
}


TARGET_DIR = $$shell_path($$OUT_PWD\\$$DEST2)

first.depends = $(first)
export(first.depends)
QMAKE_EXTRA_TARGETS += first


# QMAKE_MKDIR_CMD doesn't work since it converts to "if not exist %1 mkdir %1 & if not exist %1 exit 1", which fails because the %1 arguments somehow don't work.
# So instead we use a more complex combo of QMAKE_CHK_DIR_EXISTS and QMAKE_MKDIR. (We can't use the latter alone because if directory already exists, will
# produce error).
DIRLIST  = $$TARGET_DIR\\platforms
DIRLIST += $$TARGET_DIR\\QtQml
DIRLIST += $$TARGET_DIR\\QtQuick
DIRLIST += $$TARGET_DIR\\QtQuick.2

for(DIR, DIRLIST) {
    win32:DIR ~= s,/,\\,g
    $$basename(DIR).commands = $$QMAKE_CHK_DIR_EXISTS \"$$shell_path($$DIR)\" $$QMAKE_MKDIR \"$$shell_path($$DIR)\"
    export($$basename(DIR).commands)
    QMAKE_EXTRA_TARGETS += $$basename(DIR)
    first.depends += $$basename(DIR)   # Without this, the commands don't get executed.
}

copydata.commands  =    $(COPY_DIR)  \"$$shell_path($$PWD\\..\\deviceConfigs)\"  \"$$shell_path($$TARGET_DIR\\deviceConfigs)\"
copydata.commands += && $(COPY_DIR)  \"$$shell_path($$PWD\\..\\userConfigs)\"    \"$$shell_path($$TARGET_DIR\\userConfigs)\"
copydata.commands += && $(COPY_DIR)  \"$$shell_path($$PWD\\..\\Scripts)\"        \"$$shell_path($$TARGET_DIR\\Scripts)\"
copydata.commands += && $(COPY_FILE) \"$$shell_path($$QT_BASE_DIR\\plugins\\platforms\\qwindows$${QT_SUFFIX}.dll)\" \"$$shell_path($$TARGET_DIR\\platforms\\qwindows$${QT_SUFFIX}.dll)\"
copydata.commands += && $(COPY_DIR)  \"$$shell_path($$QT_BASE_DIR\\qml\\Qt\\labs\\platform)\" \"$$shell_path($$TARGET_DIR\\Qt\\labs\\platform)\"
copydata.commands += && $(COPY_DIR)  \"$$shell_path($$QT_BASE_DIR\\qml\\QtQml)\"          \"$$shell_path($$TARGET_DIR\\QtQml)\"
copydata.commands += && $(COPY_DIR)  \"$$shell_path($$QT_BASE_DIR\\qml\\QtQuick)\"      \"$$shell_path($$TARGET_DIR\\QtQuick)\"
copydata.commands += && $(COPY_DIR)  \"$$shell_path($$QT_BASE_DIR\\qml\\QtQuick.2)\"      \"$$shell_path($$TARGET_DIR\\QtQuick.2)\"

export(copydata.commands)

QMAKE_EXTRA_TARGETS += copydata
first.depends += copydata

# List of files to be copied to target directory
FILELIST  = "$$OPENCV_DLL_DIR$${OPENCV_FILE}.dll"   # Need quotes here or else it doesn't work.
FILELIST += $$OPENCV_ROOT\\opencv_videoio_ffmpeg4120_64.dll

FILELIST += $$PYTHON_DIR\\python38.dll

QT_DLL_DIR = $$QT_BASE_DIR\bin
FILELIST += $$QT_DLL_DIR\\Qt5Core$${QT_SUFFIX}.dll
FILELIST += $$QT_DLL_DIR\\Qt5Quick$${QT_SUFFIX}.dll
FILELIST += $$QT_DLL_DIR\\Qt5Widgets$${QT_SUFFIX}.dll
FILELIST += $$QT_DLL_DIR\\Qt5Gui$${QT_SUFFIX}.dll
FILELIST += $$QT_DLL_DIR\\Qt5Qml$${QT_SUFFIX}.dll
FILELIST += $$QT_DLL_DIR\\Qt5QmlModels$${QT_SUFFIX}.dll
FILELIST += $$QT_DLL_DIR\\Qt5Network$${QT_SUFFIX}.dll
FILELIST += $$QT_DLL_DIR\\Qt5QuickControls2$${QT_SUFFIX}.dll
FILELIST += $$QT_DLL_DIR\\Qt5QuickTemplates2$${QT_SUFFIX}.dll
FILELIST += $$QT_DLL_DIR\\Qt5QmlWorkerScript$${QT_SUFFIX}.dll

win32:TARGET_DIR ~= s,/,\\,g
for(FILE, FILELIST) {
    win32:FILE ~= s,/,\\,g
    $$basename(FILE).depends = $$quote($$FILE)   # For some reason, shell_quote here fails if path name has space
    $$basename(FILE).target = $${TARGET_DIR}/$$basename(FILE)
    $$basename(FILE).commands = $(COPY_FILE) $$shell_quote($$FILE) $$shell_quote($${TARGET_DIR})
    export($$basename(FILE).commands)
    first.depends += $$basename(FILE)
    QMAKE_EXTRA_TARGETS += $$basename(FILE)
    PRE_TARGETDEPS += $${TARGET_DIR}/$$basename(FILE)
}

res.files = $$shell_path($$QT_BASE_DIR\\qml\\QtQml\\)
# res.files += $$shell_path($$QT_BASE_DIR\\qml\\QtQml\\*)
res.path = $$TARGET_DIR/QtQml

INSTALLS += res
