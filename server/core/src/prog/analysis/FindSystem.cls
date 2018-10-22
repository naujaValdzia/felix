 /*------------------------------------------------------------------------
    File        : FindSystem
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class FindSystem: 
    {tt/ttCompilerParameters.i}
    
    define variable iniFileName as character no-undo.
    define variable cDir as character no-undo.
    define variable cFileStream as character no-undo.
    
    method public void systemFind():
        define variable vSystem as character no-undo.
        define variable jsonLoc as character no-undo.
        define buffer bSystem for system.
        
        vSystem = os-getenv("FELIX_SYSTEM_NAME").
        cDir = os-getenv("CURRENT_DIR").
        jsonLoc = os-getenv("TEMP") + "/" + vSystem + "Info.json".
        
        find first bSystem where 
                   bSystem.systemName = vSystem exclusive-lock no-error.
        create ttSystemInfo.
               ttSystemInfo.systemName = bSystem.systemName.
               ttSystemInfo.localSourcePath = AnalysisUtility:addPath(bSystem.localSourcePath).
               ttSystemInfo.systemPropath = AnalysisUtility:addPropathPath(bSystem.systemPropath).
               ttSystemInfo.systemDBparameters = AnalysisUtility:addPath(bSystem.systemDBparameters).

        deleteOldDb(vSystem, cDir).
        os-delete value(os-getenv("TEMP") + "/" + ttSystemInfo.systemName) recursive.
        temp-table ttSystemInfo:write-json ("file", jsonLoc, yes).
        os-command silent value("./CompileSystem.sh " + jsonLoc).
    end method.
    
    method public void deleteOldDb (vSystem as character, cDir as character):
        input from os-dir (cDir).
        repeat:
            import cFileStream.
            if cFileStream matches ("*" + vSystem + "*")
            then do:
                 os-delete value(cDir + "/" + cFileStream).
            end.
        end.  
        os-delete value(ttSystemInfo.systemDBparameters + "/" + vSystem + ".db") no-error.
        os-delete value(ttSystemInfo.systemDBparameters + "/" + vSystem + ".lk") no-error.
    end method.
end class.