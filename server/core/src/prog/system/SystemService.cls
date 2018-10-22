 
 /*------------------------------------------------------------------------
    File        : SystemService
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class SystemService: 
    
    {ds/dsSystem.i}
    define variable masterEnable as logical no-undo. //used to enable or disable system window auto correct 
    
    method public void createSystem (dataset dsSystem,
                                     output vSuccess as logical,
                                     output vMessage as character):
        define buffer bSystem for system.
        masterEnable = true.
        
        find ttSystem.
        if ttSystem.systemName <> "" 
        then do:
            find first bSystem where
                       bSystem.systemName = ttSystem.systemName exclusive-lock no-error.
            if available bSystem
            then do:
                vSuccess = false.
                vMessage = "System with with name " + ttSystem.systemName + " already exists. Please choose another one".
            end.
            else do:
                create bSystem.
                bSystem.systemName = ttSystem.systemName.
                bSystem.localSourcePath = AnalysisUtility:fixInput(ttSystem.localSourcePath,masterEnable).
                bSystem.systemPropath = AnalysisUtility:fixPropathInput(ttSystem.systemPropath,masterEnable).
                bSystem.systemDBparameters = AnalysisUtility:fixInput(ttSystem.systemDBparameters,masterEnable).
                bSystem.entryPoints = AnalysisUtility:deleteLastSymbol(AnalysisUtility:fixInput(ttSystem.entryPoints,masterEnable), ",").                
                vSuccess = true.
                vMessage = "System has been successfully created".
                
            end.
        end.
        else do:
            vSuccess = false.
            vMessage = "Unable to create system with no name. Please retry.".
        end.
    end method.
    
    method public void systemList (output dataset dsSystem):
        define buffer bSystem for system.
        dataset dsSystem:empty-dataset().
        
        for each bSystem no-lock:
            create ttSystem.
            ttSystem.systemName = bSystem.systemName.
            ttSystem.hasErrors = bSystem.hasErrors.
            ttSystem.id = bSystem.id.
        end.
        dataset dsSystem:accept-changes().
    end method.    
    
    method public void systemInfo (sysName as character, 
                                   output dataset dsSystem):
        define buffer bSystem for system.
        dataset dsSystem:empty-dataset().
        
        find first bSystem where 
                   bSystem.systemName = sysName no-lock no-error.
            create ttSystem.
            ttSystem.systemName = bSystem.systemName.
            ttSystem.systemPropath = bSystem.systemPropath.
            ttSystem.systemDBparameters = bSystem.systemDBparameters.
            ttSystem.localSourcePath = bSystem.localSourcePath.
            ttSystem.hasErrors = bSystem.hasErrors.
            ttSystem.entryPoints = bSystem.entryPoints.
            ttSystem.id = bSystem.id.
        dataset dsSystem:accept-changes().
    end method.
    
    method public void updateSystem (dataset dsSystem,
                                     output vSuccess as logical,
                                     output vMessage as character):
        masterEnable = true.
        define buffer bSystem for system.
        
        for each ttSystem: 
            find first bSystem where 
                       bSystem.systemName = ttSystem.systemName exclusive-lock no-error.
            if not available bSystem
            then do:
                vSuccess = false.
                vMessage = "Unable to find system with matching name".
            end.
            else do:
                buffer-copy ttSystem except ttSystem.systemName ttSystem.id ttSystem.hasErrors to bSystem.
                bSystem.systemPropath = AnalysisUtility:fixPropathInput(bSystem.systemPropath,masterEnable).
                bSystem.entryPoints = AnalysisUtility:deleteLastSymbol(AnalysisUtility:fixInput(bSystem.entryPoints,masterEnable),",").
                bSystem.systemDBparameters = AnalysisUtility:fixInput(bSystem.systemDBparameters,masterEnable).
                bSystem.localSourcePath = AnalysisUtility:fixInput(bSystem.localSourcePath,masterEnable).
                vSuccess = true.
                vMessage = "System has been successfully updated".
            end.
        end.
    end method.

    method public void deleteSystem (sysName as character,
                                     output vSuccess as logical,
                                     output vMessage as character):
        define buffer bSystem for system.
        
        find first bSystem where 
                   bSystem.systemName = sysName exclusive-lock no-error.
        if available bSystem
        then do:
            delete bSystem.
            vSuccess = true.
            vMessage = "System " + sysName + " has been deleted".
        end.
    end.
end class.