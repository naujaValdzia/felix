 /*------------------------------------------------------------------------
    File        : ReadXref
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class ReadXref: 

    {tt/ttCompilerParameters.i}

    method public void waitForXrefs ():
        temp-table ttSystemInfo:read-json("file",os-getenv("TEMP") + "/" + os-getenv("FELIX_SYSTEM_NAME") + "Info.json","empty").
        find ttSystemInfo.    
        readFromXrefDir(os-getenv("TEMP") + "/" + ttSystemInfo.systemName + "/", ttSystemInfo.systemName).
        os-delete value(os-getenv("JSON_LOCATION")).
    end method.

    method public void readFromXrefDir (cDir as character, 
                                        cSystem as character):
        define variable cFileStream as character no-undo format "x(200)".
        define variable cPath as character no-undo format "x(200)".

        deleteOldData(cSystem).
        
        input from os-dir(cDir).
        repeat:
            import cFileStream.
            if cFileStream matches "*.xref"
            then do:
                cPath = cDir + cFileStream.
                importXref(cPath,cSystem).
            end.
        end.
        input close.
    end method.

    method public void importXref(cPath as character, cSystem as character):
        define variable cWholeLine as character no-undo.
        define variable cSourceName as character no-undo.
        define variable cFileName as character no-undo.
        define variable cLineNumber as character no-undo.
        define variable cXrefType as character no-undo.
        define variable cXrefInformation as character no-undo.
        define variable cCompileUnit as character no-undo.
        define variable i as integer no-undo.
        define variable i2 as integer no-undo.
        define variable i3 as integer no-undo.
        define variable numEntriesCounter as integer no-undo.
        define variable cSourcePath as character no-undo.
        define variable cEntry as character no-undo.
        define variable temp as character no-undo. //used for temporary data
        define buffer bFile for file.
        define buffer bDbField for dbField.
        
        input from value(cPath).
        repeat:
            import unformatted cWholeLine.
            cWholeLine = cWholeLine.
            cSourceName = substring(cWholeLine, 1, index(cWholeLine, " ")).
            cWholeLine = substring(cWholeLine, index(cWholeLine, " ") + 1).
            cFileName = substring(cWholeLine, 1, index(cWholeLine, " ")).
            cWholeLine = substring(cWholeLine, index(cWholeLine, " ") + 1).
            cLineNumber = substring(cWholeLine, 1, index(cWholeLine, " ")).
            cWholeLine = substring(cWholeLine, index(cWholeLine, " ") + 1).
            cXrefType = substring(cWholeLine, 1, index(cWholeLine, " ")).
            
            if cXrefType = "INCLUDE"
            then do:
                cXrefInformation = substring(cWholeLine, r-index(cWholeLine, "INCLUDE"), length(cWholeLine)).
                cXrefInformation = replace(cXrefInformation,"INCLUDE","").
                cXrefInformation = replace(cXrefInformation,"~"","").
                cXrefInformation = replace(cXrefInformation," ","").
                cXrefInformation = substring(cXrefInformation, 1, index(cXrefInformation, ".i") + 1).
            end.
            else do:
                cXrefInformation = substring(cWholeLine, index(cWholeLine, " ") + 1).
                cXrefInformation = trim(cXrefInformation, "~"").
            end.
                
            temp = cSourceName.
            repeat numEntriesCounter = 1 to num-entries(ttSystemInfo.systemPropath, ":").
                cEntry = entry(numEntriesCounter,ttSystemInfo.systemPropath,":") + "/".
                temp = replace(temp,cEntry,"").
            end.
            cSourcePath = temp.

            repeat i = 0 to num-entries(cFileName, "/"):
            end.
            repeat i2 = 0 to num-entries(cSourceName, "/"):
            end.

            if cXrefType = "RUN" or 
               cXrefType = "NEW" or 
               cXrefType = "INCLUDE" or 
               cXrefType = "COMPILE"
            then do:
                if index(cXrefInformation, " ") <> 0 or 
                   index(cXrefInformation, ",") <> 0
                then do:
                    cXrefInformation = entry (1, cXrefInformation, " ").
                    cXrefInformation = entry (1, cXrefInformation, ",").
                end.
                if cXrefType = "COMPILE"
                then do:
                    repeat numEntriesCounter = 1 to num-entries(ttSystemInfo.systemPropath, ":").
                        cEntry = entry(numEntriesCounter,ttSystemInfo.systemPropath,":") + "/".
                        cXrefInformation = replace(cXrefInformation,cEntry,"").
                    end.  
                    cCompileUnit = cXrefInformation.
                end.
                create bFile.
                assign
                    bFile.fileName = entry(i - 1, cFileName, "/")
                    bFile.sourceName = entry(i2 - 1, cSourceName, "/")
                    bFile.sourcePath = cSourcePath
                    bFile.line = integer(cLineNumber)
                    bFile.type = cXrefType
                    bFile.info = cXrefInformation
                    bFile.compileUnit = cCompileUnit
                    bFile.systemName = cSystem.
            end.
            else if cXrefType = "CLASS" and (cXrefInformation matches ("*INHERITS*") or cXrefInformation matches ("*IMPLEMENTS*"))
            then do:
                if cXrefInformation matches ("*INHERITS*")
                then do:
                    cXrefInformation = substring(cXrefInformation, index(cXrefInformation, "INHERITS")).
                    cXrefInformation = substring(cXrefInformation, 1, index(cXrefInformation, ",") - 1).
                end.
                else if cXrefInformation matches ("*IMPLEMENTS*")
                then do:
                    cXrefInformation = substring(cXrefInformation, index(cXrefInformation, "IMPLEMENTS")).
                    cXrefInformation = substring(cXrefInformation, 1, index(cXrefInformation, ",") - 1).
                end.
                create bFile.
                assign
                    bFile.fileName = entry(i - 1, cFileName, "/")
                    bFile.sourceName = entry(i2 - 1, cSourceName, "/")
                    bFile.sourcePath = cSourcePath
                    bFile.line = integer(cLineNumber)
                    bFile.type = cXrefType
                    bFile.info = cXrefInformation
                    bFile.compileUnit = cCompileUnit
                    bFile.systemName = cSystem.
            end.
            else if cXrefType = "SEARCH"
            then do:
                cXrefInformation = replace(cXrefInformation,"DATA-MEMBER ","").
                cXrefInformation = replace(cXrefInformation,"INHERITED-DATA-MEMBER ","").
                cXrefInformation = replace(cXrefInformation," TEMPTABLE","").
                cXrefInformation = replace(cXrefInformation," WHOLE-INDEX","").
                cXrefInformation = replace(cXrefInformation," TABLE-SCAN","").
                cXrefInformation= trim(cXrefInformation).
                cXrefInformation = entry(2,cXrefInformation," ").

                create bDbField.
                assign
                    bDbField.fileName = entry(i - 1, cFileName, "/")
                    bDbField.sourceName = entry(i2 - 1, cSourceName, "/")
                    bDbField.sourcePath = cSourcePath
                    bDbField.line = integer(cLineNumber)
                    bDbField.type = "INDEX"
                    bDbField.info = cXrefInformation
                    bDbField.compileUnit = cCompileUnit
                    bDbField.systemName = cSystem.
            end.
            else if cXrefType = "INVOKE"
            then do:
                if index(cXrefInformation, ",") <> 0
                then do:
                    cXrefInformation = substring(cXrefInformation, 1, index(cXrefInformation, ",") - 1).
                end.
                if cLineNumber = "IMPLICIT"
                then do:
                    cLineNumber = "0".
                    cXrefType = "IMPLICIT " + cXrefType.
                end.
                create bFile.
                assign
                    bFile.fileName = entry(i - 1, cFileName, "/")
                    bFile.sourceName = entry(i2 - 1, cSourceName, "/")
                    bFile.sourcePath = cSourcePath
                    bFile.line = integer(cLineNumber)
                    bFile.type = cXrefType
                    bFile.info = cXrefInformation
                    bFile.compileUnit = cCompileUnit
                    bFile.systemName = cSystem.
            end.
            else if cXrefType = "ACCESS" or cXrefType = "UPDATE" or cXrefType = "REFERENCE" or cXrefType = "DELETE"
            then do:
                if index(cXrefInformation, "INHERITED") <> 0 or
                   index(cXrefInformation, "PUBLIC") <> 0
                then do:
                    create bFile.
                    assign
                        bFile.fileName = entry(i - 1, cFileName, "/")
                        bFile.sourceName = entry(i2 - 1, cSourceName, "/")
                        bFile.sourcePath = cSourcePath
                        bFile.line = integer(cLineNumber)
                        bFile.type = cXrefType
                        bFile.info = cXrefInformation
                        bFile.compileUnit = cCompileUnit
                        bFile.systemName = cSystem.
                end.
                else if index(cXrefInformation, "TEMPTABLE") = 0 and
                        index(cXrefInformation, "SHARED") = 0 and
                        index(cXrefInformation, "DATA-MEMBER") = 0 and
                        index(cXrefInformation, "WORKFILE") = 0 and
                        index(cXrefInformation, "SEQUENCE") = 0 and
                        index(cXrefInformation, "PROPERTY") = 0
                then do:
                    cXrefInformation = trim(cXrefInformation).
                    if index(cXrefInformation, ".") <> 0
                    then cXrefInformation = substring(cXrefInformation, index(cXrefInformation,".") + 1).
                    cXrefInformation = replace(cXrefInformation," ",".").

                    create bDbField.
                    assign
                        bDbField.fileName = entry(i - 1, cFileName, "/")
                        bDbField.sourceName = entry(i2 - 1, cSourceName, "/")
                        bDbField.sourcePath = cSourcePath
                        bDbField.line = integer(cLineNumber)
                        bDbField.type = cXrefType
                        bDbField.info = cXrefInformation
                        bDbField.compileUnit = cCompileUnit
                        bDbField.systemName = cSystem.
                end.
            end.
        end.
        input close.
    end method.
    
    method public void deleteOldData (vSystem as character):
        define buffer bFile for file.
        define buffer bDbField for dbField.
        
        for each bFile where bFile.systemName = vSystem exclusive-lock:
            delete bFile.
        end.
        for each bDbField where bDbField.systemName = vSystem exclusive-lock:
            delete bDbField.
        end.
    end method.
end class.