unigraph_unit(MainEntry
  NAME PlatformDiff
  TYPE Executable
  DEPEND Threading
  SOURCES
    :windows
      main_win32.cpp
    :linux:darwin
      main_unix.cpp
  PROPERTIES
    :windows
      WIN32_EXECUTABLE=TRUE
    :darwin
      MACOSX_BUNDLE=TRUE
)
