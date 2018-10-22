  
 /*------------------------------------------------------------------------
    File        : ConnectSystem
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class ConnectSystem: 
  
    {tt/ttCompilerParameters.i}

    method public void systemConnect ():
        define variable cDbName as character no-undo.
        temp-table ttSystemInfo:read-json("file",os-getenv("JSON_LOCATION"),"empty").
        find ttSystemInfo.
        propath = propath + ":" + ttSystemInfo.systemPropath.
        if ttSystemInfo.systemDBparameters <> ""
        then do:
            createDB(ttSystemInfo.systemDBparameters, output cDbName).
            connect value(ttSystemInfo.systemDBparameters + "/" + cDbName) -1 no-error.
        end.
        os-create-dir value(os-getenv("TEMP") + "/" + ttSystemInfo.systemName).
        
        CompileXref(ttSystemInfo.localSourcePath, os-getenv("TEMP") + "/" + ttSystemInfo.systemName + "/").
        if ttSystemInfo.systemDBparameters <> ""
        then do:
            disconnect value(cDbName).
        end.
    end method.
    
    method public void createDB(cPth as character, output cDbName as character):
        
        define variable cDelDb as character no-undo.
        define variable cLoadSt as character no-undo.
        define variable cDelBi as character no-undo.
        define variable cTrunBi as character no-undo.
        define variable cFileStream as character no-undo format "x(200)".
        define variable cError as character no-undo.
        
        define variable cStName as character no-undo.
        define variable cDfName as character no-undo.
        
        define variable iStCounter as integer no-undo init 0.
        define variable iDfCounter as integer no-undo init 0.
        define variable iDbCounter as integer no-undo init 0.

        cError = os-getenv("TEMP") + "/DBerrors.txt".

        if substr(cPth, length(cPth)) <> "/" and index(cPth, "/") <> 0
        then do:
            cPth = cPth + "/".
        end.
            
        input from os-dir(cPth).
        repeat:
            import cFileStream.
            if cFileStream matches ("*.db")
            then do:
                cDbName = replace(cFileStream, ".db", "").
                iDbCounter = iDbCounter + 1.
            end.
            else if cFileStream matches ("*.df")
            then do:
                cDfName = cFileStream.
                iDfCounter = iDfCounter + 1.
            end.
            else if cFileStream matches ("*.st")
            then do:
                cStName = cFileStream.
                iStCounter = iStCounter + 1.
            end.
        end.
        input close.
        
        creation:
        do transaction:
            if cStName <> ""
            then do:
                if replace(cStName, ".st", "") <> replace(cDfName, ".df", "")
                then do:
                    output to value(cError).
                    output close.
                    undo creation, leave creation.
                end.
            end.
            if (iStCounter > 1) or (iDbCounter > 1) or (iDfCounter > 1)
            then do:
                output to value(cError).
                output close.
                undo creation, leave creation.
            end.

            cLoadSt = "$DLC/bin/prostrct add " + cPth + replace(cStName, ".st", "") + " " + cPth + cStName.
            if cDbName = ?
            then do:
                cDbName = replace(cDfName, ".df", "").
                cDelBi = "$DLC/bin/prostrct remove " + cPth + cDbName + " bi".
                cTrunBi = "$DLC/bin/proutil " + cPth + cDbName + ".db" + " -C truncate bi".

                create database cPth + cDbName from "EMPTY".
                if cStName <> ""
                then do:
                    os-command silent value(cTrunBi).
                    os-command silent value(cDelBi).
                    os-command silent value(cLoadSt).
                end.
                connect value(cPth + cDbName) -1.
                create alias DICTDB for database value(cDbName).
                run prodict/load_df.p (cPth + cDfName).
                disconnect value(cDbName).
            end.
            else do:
                cDbName = replace(cDfName, ".df", "").

                cDelBi = "$DLC/bin/prostrct remove " + cPth + cDbName + " bi".
                cTrunBi = "$DLC/bin/proutil " + cPth + cDbName + ".db" + " -C truncate bi".

                create database cPth + cDbName from "EMPTY".
                if cStName <> ""
                then do:
                    os-command silent value(cTrunBi).
                    os-command silent value(cDelBi).
                    os-command silent value(cLoadSt).
                end.
                connect value(cPth + cDbName) -1.
                create alias DICTDB for database value(cDbName).
                run prodict/load_df.p (cPth + cDfName).
                disconnect value(cDbName).
            end.
        end.
    end method.
    
    method public void compileXref(cInputDir as character, cOutputDir as character):
        define variable cInputPath as character no-undo.
        cInputPath = cInputDir.
        input from os-dir(cInputDir).
        output to value(cOutputDir + os-getenv("FELIX_SYSTEM_NAME") + ".txt").
            compileFiles (cInputDir, cOutputDir, cInputPath).
        input close.
        output close.
    end method.
    
    method public integer compileFiles (cInputDirectory as character, cOutputDir as character, cInputPath as character):
        define variable cFileStream as character no-undo.
        define variable cFileType as character no-undo.
        define variable cPath as character no-undo.
        
        import cFileStream.
        import cFileStream.
        
        repeat:
            import cFileStream.
            file-info:file-name = cInputDirectory + "/" + cFileStream.
            cFileType = substring (cFileStream, r-index(cFileStream, ".") + 1).
            if index (file-info:file-type, "D") > 0
            then do:
                input from os-dir(cInputDirectory + "/" + cFileStream).
                    compileFiles (cInputDirectory + "/" + cFileStream, cOutputDir, cInputPath).
                input close.
            end.       
            else if cFileType = "p" or cFileType = "cls" or cFileType = "w"
            then do:
                do on error undo, next:
                    cPath = cFileStream.
                    cPath = replace (cPath, "/", "_").
                    cPath = replace (cPath, " ", "").
                    compile value(cInputDirectory + "/" + cFileStream) save xref value(cOutputDir + subst("&1.xref", cPath)).
                    
                    catch eSystemError as Progress.Lang.Error :
                        os-delete value(cOutputDir + subst("&1.xref", cPath)).
                        message replace(cInputDirectory + "/" + cFileStream, cInputPath,"").
                        message eSystemError:GetMessage(1).
                        undo, next.
                    end catch.
                end.
            end.
        end.
    end method.
end class.