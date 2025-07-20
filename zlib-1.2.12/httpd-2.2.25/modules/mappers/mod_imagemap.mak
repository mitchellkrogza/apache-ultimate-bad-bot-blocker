# Microsoft Developer Studio Generated NMAKE File, Based on mod_imagemap.dsp
!IF "$(CFG)" == ""
CFG=mod_imagemap - Win32 Release
!MESSAGE No configuration specified. Defaulting to mod_imagemap - Win32 Release.
!ENDIF 

!IF "$(CFG)" != "mod_imagemap - Win32 Release" && "$(CFG)" != "mod_imagemap - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "mod_imagemap.mak" CFG="mod_imagemap - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "mod_imagemap - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "mod_imagemap - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "mod_imagemap - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
DS_POSTBUILD_DEP=$(INTDIR)\postbld.dep
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

!IF "$(RECURSE)" == "0" 

ALL : "$(OUTDIR)\mod_imagemap.so" "$(DS_POSTBUILD_DEP)"

!ELSE 

ALL : "libhttpd - Win32 Release" "libaprutil - Win32 Release" "libapr - Win32 Release" "$(OUTDIR)\mod_imagemap.so" "$(DS_POSTBUILD_DEP)"

!ENDIF 

!IF "$(RECURSE)" == "1" 
CLEAN :"libapr - Win32 ReleaseCLEAN" "libaprutil - Win32 ReleaseCLEAN" "libhttpd - Win32 ReleaseCLEAN" 
!ELSE 
CLEAN :
!ENDIF 
	-@erase "$(INTDIR)\mod_imagemap.obj"
	-@erase "$(INTDIR)\mod_imagemap.res"
	-@erase "$(INTDIR)\mod_imagemap_src.idb"
	-@erase "$(INTDIR)\mod_imagemap_src.pdb"
	-@erase "$(OUTDIR)\mod_imagemap.exp"
	-@erase "$(OUTDIR)\mod_imagemap.lib"
	-@erase "$(OUTDIR)\mod_imagemap.pdb"
	-@erase "$(OUTDIR)\mod_imagemap.so"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /MD /W3 /Zi /O2 /Oy- /I "../../include" /I "../../srclib/apr/include" /I "../../srclib/apr-util/include" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\mod_imagemap_src" /FD /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

MTL=midl.exe
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
RSC=rc.exe
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\mod_imagemap.res" /i "../../include" /i "../../srclib/apr/include" /d "NDEBUG" /d BIN_NAME="mod_imagemap.so" /d LONG_NAME="imagemap_module for Apache" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\mod_imagemap.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib /nologo /subsystem:windows /dll /incremental:no /pdb:"$(OUTDIR)\mod_imagemap.pdb" /debug /out:"$(OUTDIR)\mod_imagemap.so" /implib:"$(OUTDIR)\mod_imagemap.lib" /base:@..\..\os\win32\BaseAddr.ref,mod_imagemap.so /opt:ref 
LINK32_OBJS= \
	"$(INTDIR)\mod_imagemap.obj" \
	"$(INTDIR)\mod_imagemap.res" \
	"..\..\srclib\apr\Release\libapr-1.lib" \
	"..\..\srclib\apr-util\Release\libaprutil-1.lib" \
	"..\..\Release\libhttpd.lib"

"$(OUTDIR)\mod_imagemap.so" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

TargetPath=.\Release\mod_imagemap.so
SOURCE="$(InputPath)"
PostBuild_Desc=Embed .manifest
DS_POSTBUILD_DEP=$(INTDIR)\postbld.dep

# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

"$(DS_POSTBUILD_DEP)" : "$(OUTDIR)\mod_imagemap.so"
   if exist .\Release\mod_imagemap.so.manifest mt.exe -manifest .\Release\mod_imagemap.so.manifest -outputresource:.\Release\mod_imagemap.so;2
	echo Helper for Post-build step > "$(DS_POSTBUILD_DEP)"

!ELSEIF  "$(CFG)" == "mod_imagemap - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
DS_POSTBUILD_DEP=$(INTDIR)\postbld.dep
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

!IF "$(RECURSE)" == "0" 

ALL : "$(OUTDIR)\mod_imagemap.so" "$(DS_POSTBUILD_DEP)"

!ELSE 

ALL : "libhttpd - Win32 Debug" "libaprutil - Win32 Debug" "libapr - Win32 Debug" "$(OUTDIR)\mod_imagemap.so" "$(DS_POSTBUILD_DEP)"

!ENDIF 

!IF "$(RECURSE)" == "1" 
CLEAN :"libapr - Win32 DebugCLEAN" "libaprutil - Win32 DebugCLEAN" "libhttpd - Win32 DebugCLEAN" 
!ELSE 
CLEAN :
!ENDIF 
	-@erase "$(INTDIR)\mod_imagemap.obj"
	-@erase "$(INTDIR)\mod_imagemap.res"
	-@erase "$(INTDIR)\mod_imagemap_src.idb"
	-@erase "$(INTDIR)\mod_imagemap_src.pdb"
	-@erase "$(OUTDIR)\mod_imagemap.exp"
	-@erase "$(OUTDIR)\mod_imagemap.lib"
	-@erase "$(OUTDIR)\mod_imagemap.pdb"
	-@erase "$(OUTDIR)\mod_imagemap.so"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /MDd /W3 /Zi /Od /I "../../include" /I "../../srclib/apr/include" /I "../../srclib/apr-util/include" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\mod_imagemap_src" /FD /EHsc /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

MTL=midl.exe
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /win32 
RSC=rc.exe
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\mod_imagemap.res" /i "../../include" /i "../../srclib/apr/include" /d "_DEBUG" /d BIN_NAME="mod_imagemap.so" /d LONG_NAME="imagemap_module for Apache" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\mod_imagemap.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib /nologo /subsystem:windows /dll /incremental:no /pdb:"$(OUTDIR)\mod_imagemap.pdb" /debug /out:"$(OUTDIR)\mod_imagemap.so" /implib:"$(OUTDIR)\mod_imagemap.lib" /base:@..\..\os\win32\BaseAddr.ref,mod_imagemap.so 
LINK32_OBJS= \
	"$(INTDIR)\mod_imagemap.obj" \
	"$(INTDIR)\mod_imagemap.res" \
	"..\..\srclib\apr\Debug\libapr-1.lib" \
	"..\..\srclib\apr-util\Debug\libaprutil-1.lib" \
	"..\..\Debug\libhttpd.lib"

"$(OUTDIR)\mod_imagemap.so" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

TargetPath=.\Debug\mod_imagemap.so
SOURCE="$(InputPath)"
PostBuild_Desc=Embed .manifest
DS_POSTBUILD_DEP=$(INTDIR)\postbld.dep

# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

"$(DS_POSTBUILD_DEP)" : "$(OUTDIR)\mod_imagemap.so"
   if exist .\Debug\mod_imagemap.so.manifest mt.exe -manifest .\Debug\mod_imagemap.so.manifest -outputresource:.\Debug\mod_imagemap.so;2
	echo Helper for Post-build step > "$(DS_POSTBUILD_DEP)"

!ENDIF 


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("mod_imagemap.dep")
!INCLUDE "mod_imagemap.dep"
!ELSE 
!MESSAGE Warning: cannot find "mod_imagemap.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "mod_imagemap - Win32 Release" || "$(CFG)" == "mod_imagemap - Win32 Debug"

!IF  "$(CFG)" == "mod_imagemap - Win32 Release"

"libapr - Win32 Release" : 
   cd ".\..\..\srclib\apr"
   $(MAKE) /$(MAKEFLAGS) /F ".\libapr.mak" CFG="libapr - Win32 Release" 
   cd "..\..\modules\mappers"

"libapr - Win32 ReleaseCLEAN" : 
   cd ".\..\..\srclib\apr"
   $(MAKE) /$(MAKEFLAGS) /F ".\libapr.mak" CFG="libapr - Win32 Release" RECURSE=1 CLEAN 
   cd "..\..\modules\mappers"

!ELSEIF  "$(CFG)" == "mod_imagemap - Win32 Debug"

"libapr - Win32 Debug" : 
   cd ".\..\..\srclib\apr"
   $(MAKE) /$(MAKEFLAGS) /F ".\libapr.mak" CFG="libapr - Win32 Debug" 
   cd "..\..\modules\mappers"

"libapr - Win32 DebugCLEAN" : 
   cd ".\..\..\srclib\apr"
   $(MAKE) /$(MAKEFLAGS) /F ".\libapr.mak" CFG="libapr - Win32 Debug" RECURSE=1 CLEAN 
   cd "..\..\modules\mappers"

!ENDIF 

!IF  "$(CFG)" == "mod_imagemap - Win32 Release"

"libaprutil - Win32 Release" : 
   cd ".\..\..\srclib\apr-util"
   $(MAKE) /$(MAKEFLAGS) /F ".\libaprutil.mak" CFG="libaprutil - Win32 Release" 
   cd "..\..\modules\mappers"

"libaprutil - Win32 ReleaseCLEAN" : 
   cd ".\..\..\srclib\apr-util"
   $(MAKE) /$(MAKEFLAGS) /F ".\libaprutil.mak" CFG="libaprutil - Win32 Release" RECURSE=1 CLEAN 
   cd "..\..\modules\mappers"

!ELSEIF  "$(CFG)" == "mod_imagemap - Win32 Debug"

"libaprutil - Win32 Debug" : 
   cd ".\..\..\srclib\apr-util"
   $(MAKE) /$(MAKEFLAGS) /F ".\libaprutil.mak" CFG="libaprutil - Win32 Debug" 
   cd "..\..\modules\mappers"

"libaprutil - Win32 DebugCLEAN" : 
   cd ".\..\..\srclib\apr-util"
   $(MAKE) /$(MAKEFLAGS) /F ".\libaprutil.mak" CFG="libaprutil - Win32 Debug" RECURSE=1 CLEAN 
   cd "..\..\modules\mappers"

!ENDIF 

!IF  "$(CFG)" == "mod_imagemap - Win32 Release"

"libhttpd - Win32 Release" : 
   cd ".\..\.."
   $(MAKE) /$(MAKEFLAGS) /F ".\libhttpd.mak" CFG="libhttpd - Win32 Release" 
   cd ".\modules\mappers"

"libhttpd - Win32 ReleaseCLEAN" : 
   cd ".\..\.."
   $(MAKE) /$(MAKEFLAGS) /F ".\libhttpd.mak" CFG="libhttpd - Win32 Release" RECURSE=1 CLEAN 
   cd ".\modules\mappers"

!ELSEIF  "$(CFG)" == "mod_imagemap - Win32 Debug"

"libhttpd - Win32 Debug" : 
   cd ".\..\.."
   $(MAKE) /$(MAKEFLAGS) /F ".\libhttpd.mak" CFG="libhttpd - Win32 Debug" 
   cd ".\modules\mappers"

"libhttpd - Win32 DebugCLEAN" : 
   cd ".\..\.."
   $(MAKE) /$(MAKEFLAGS) /F ".\libhttpd.mak" CFG="libhttpd - Win32 Debug" RECURSE=1 CLEAN 
   cd ".\modules\mappers"

!ENDIF 

SOURCE=..\..\build\win32\httpd.rc

!IF  "$(CFG)" == "mod_imagemap - Win32 Release"


"$(INTDIR)\mod_imagemap.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) /l 0x409 /fo"$(INTDIR)\mod_imagemap.res" /i "../../include" /i "../../srclib/apr/include" /i ".\..\..\build\win32" /d "NDEBUG" /d BIN_NAME="mod_imagemap.so" /d LONG_NAME="imagemap_module for Apache" $(SOURCE)


!ELSEIF  "$(CFG)" == "mod_imagemap - Win32 Debug"


"$(INTDIR)\mod_imagemap.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) /l 0x409 /fo"$(INTDIR)\mod_imagemap.res" /i "../../include" /i "../../srclib/apr/include" /i ".\..\..\build\win32" /d "_DEBUG" /d BIN_NAME="mod_imagemap.so" /d LONG_NAME="imagemap_module for Apache" $(SOURCE)


!ENDIF 

SOURCE=.\mod_imagemap.c

"$(INTDIR)\mod_imagemap.obj" : $(SOURCE) "$(INTDIR)"



!ENDIF 

