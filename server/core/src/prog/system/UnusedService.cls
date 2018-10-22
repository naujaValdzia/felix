 
 /*------------------------------------------------------------------------
    File        : UnusedService
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class UnusedService: 
    
    {ds/dsUnused.i}
    
    method public void listUnused (systemName as character, fileType as character, output dataset dsUnused):
        case fileType:
            when "Procedure" then getUnusedProcedure(systemName, output dataset dsUnused).
            when "Class" then getUnusedClass(systemName, output dataset dsUnused).
            when "Include" then getUnusedInclude(systemName, output dataset dsUnused).
            when "All" then getUnusedAll(systemName, output dataset dsUnused).
        end case.
    end method.

    method public void getUnusedProcedure(sysName as character, 
                                          output dataset dsUnused):
        define buffer bUnused for unused.
        dataset dsUnused:empty-dataset().
        
        for each bUnused no-lock where 
                 bUnused.systemName = sysName and 
                 bUnused.info matches ("*" + ".p"):
            create ttUnused.
            ttUnused.fileName = bUnused.fileName.
            ttUnused.type = bUnused.type.
            ttUnused.compileUnit = bUnused.compileUnit.
            ttUnused.systemName = bUnused.systemName.
            ttUnused.info = bUnused.info.
            ttUnused.id = bUnused.id.
        end.
        dataset dsUnused:accept-changes ().
    end method.    
    
    method public void getUnusedClass(sysName as character, 
                                      output dataset dsUnused):
        define buffer bUnused for unused.
        dataset dsUnused:empty-dataset().
        
        for each bUnused no-lock where 
                 bUnused.systemName = sysName and
                 bUnused.info matches ("*" + ".cls"):
            create ttUnused.
            ttUnused.fileName = bUnused.fileName.
            ttUnused.type = bUnused.type.
            ttUnused.compileUnit = bUnused.compileUnit.
            ttUnused.systemName = bUnused.systemName.
            ttUnused.info = bUnused.info.
            ttUnused.id = bUnused.id.
        end.
        dataset dsUnused:accept-changes ().
    end method.  
    
    method public void getUnusedInclude(sysName as character, 
                                        output dataset dsUnused):
        define buffer bUnused for unused.
        dataset dsUnused:empty-dataset().
        
        for each bUnused no-lock where 
                 bUnused.systemName = sysName and 
                 bUnused.type = "INCLUDE":
            create ttUnused.
            ttUnused.fileName = bUnused.fileName.
            ttUnused.type = bUnused.type.
            ttUnused.compileUnit = bUnused.compileUnit.
            ttUnused.systemName = bUnused.systemName.
            ttUnused.info = bUnused.info.
            ttUnused.id = bUnused.id.
        end.
        dataset dsUnused:accept-changes ().
    end method.  
    
    method public void getUnusedAll(sysName as character, 
                                    output dataset dsUnused):
        define buffer bUnused for unused.
        dataset dsUnused:empty-dataset().
        
        for each bUnused no-lock where 
                 bUnused.systemName = sysName:
            create ttUnused.
            ttUnused.fileName = bUnused.fileName.
            ttUnused.type = bUnused.type.
            ttUnused.compileUnit = bUnused.compileUnit.
            ttUnused.systemName = bUnused.systemName.
            ttUnused.info = bUnused.info.
            ttUnused.id = bUnused.id.
        end.
        dataset dsUnused:accept-changes ().
    end method.  
end class.