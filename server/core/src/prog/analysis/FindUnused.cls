/*------------------------------------------------------------------------
    File        : FindUnused
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class FindUnused: 

    {tt/ttUsed.i}
    
    define variable vCompileUnit as character no-undo.
    define variable vSystem as character no-undo.
    define buffer bUsed for ttUsed.
    
    method public void getUnused ():
        define variable vEntryPoints as character format "x(100)" no-undo extent 100.
        define variable i as integer no-undo.
        define buffer bSystem for system.
        define buffer bUnused for unused.
        
        vSystem = os-getenv("FELIX_SYSTEM_NAME").
        deleteOldUnused(vSystem).
        allFiles(vSystem).
        
        find first bSystem where 
                   bSystem.systemName = vSystem no-lock no-error.
        do i = 1 to num-entries(bSystem.entryPoints, ","):
            vEntryPoints[i] = entry(i,bSystem.entryPoints,",").
            assignAsUsed(vEntryPoints[i],vSystem).
        end.
        
        for each bUsed where 
                 bUsed.isUsed = false no-lock:
            do:
                create bUnused.
                bUnused.compileUnit = bUsed.compileUnit.
                bUnused.fileName = bUsed.fileName.
                bUnused.type = bUsed.type.
                bUnused.systemName = bUsed.systemName.
                bUnused.info = bUsed.info.
            end.
        end.
    end.
    
    /*------------------------------------------------------------------------------
     Purpose: To assign files as "used"
     Notes: Recursion.
    ------------------------------------------------------------------------------*/
    method public void assignAsUsed (nextCompileUnit as character, vSystem as character):
        define buffer bFile for file.
        define buffer bbFile for file.

        do:
            find first bbFile where 
                       bbFile.compileUnit matches ("*" + nextCompileUnit + "*") and
                       bbFile.systemName = vSystem and
                       (bbFile.type = "COMPILE" or
                       bbFile.type = "INCLUDE") no-lock no-error.
            if available bbFile
            then do:
                vCompileUnit = bbFile.info. 
                for each bFile where 
                         (bFile.info <> vCompileUnit and
                         bFile.compileUnit = bbFile.compileUnit and
                         bFile.systemName = vSystem and
                         ((index(bFile.info, ".p") <> 0) or
                         (index(bFile.info, ".cls") <> 0) or
                         (index(bFile.info, ".i") <> 0))) no-lock:

                    find bUsed where 
                         bUsed.info = bFile.info exclusive-lock no-error.
                    if not available bUsed
                    then do:
                        create bUsed.
                        bUsed.compileUnit = bFile.info.
                        bUsed.fileName = bFile.fileName.
                        bUsed.type = bFile.type.
                        bUsed.systemName = bFile.systemName.
                        bUsed.info = "***PROGRESS SYSTEM FILE***".
                        bUsed.isUsed = true.
                    end.
                    bUsed.isUsed = true.
                    assignAsUsed(bFile.info, vSystem).
                end.
            end.
        end.
    end method.

     /*------------------------------------------------------------------------------
     Purpose: To check if file exists in temp-table ttUsed. If not, - then create temp-table
              ttUsed and add value "false" to ttUsed field isUsed. Basically it adds all files 
              matching COMPILE and INCLUDE from desired system.
     Notes:   In some cases "info" field may be empty, it is caused by xref analysis.
              If xref consists of include which is separated by two spaces, like this: " yourInclude.i " it
              is importing "space" symbol to info field, because our import delimiter is space.
              Problem solved in importXref file.
    ------------------------------------------------------------------------------*/

    method public void allFiles (vSystem as character):
        define buffer bFile for file.
        
        for each bFile where 
                 bFile.systemName = vSystem and bFile.type = "INCLUDE" no-lock:
        if available bFile
            then do:
                find first ttUsed where 
                           ttUsed.info = bFile.info exclusive-lock no-error.
                if not available ttUsed
                then do:
                    create ttUsed.
                    ttUsed.compileUnit = bFile.compileUnit.
                    ttUsed.fileName = bFile.fileName.
                    ttUsed.type = bFile.type.
                    ttUsed.systemName = bFile.systemName.
                    ttUsed.info = bFile.info.
                    ttUsed.isUsed = false.

                    if bFile.info = "" 
                    then ttUsed.info = "PROBLEM WITH XREF, CHECK GRAMMAR. INCLUDE MAY BE SEPARATED BY TWO SPACES".
                end.
            end.
        end.
        for each bFile where 
                 bFile.systemName = vSystem and bFile.type = "COMPILE" no-lock:
        if available bFile
        then do:
            create ttUsed.
            ttUsed.compileUnit = bFile.compileUnit.
            ttUsed.fileName = bFile.fileName.
            ttUsed.type = bFile.type.
            ttUsed.systemName = bFile.systemName.
            ttUsed.info = bFile.info.
            ttUsed.isUsed = false.

            if bFile.info = "" 
            then ttUsed.info = "PROBLEM WITH XREF, CHECK GRAMMAR. INCLUDE MAY BE SEPARATED BY TWO SPACES".
        end.
        end.
    end method.
    
    method public void deleteOldUnused (vSystem as character):
        define buffer bUnused for unused.
        for each bUnused where 
                 bUnused.systemName = vSystem exclusive-lock:
            delete bUnused.    
        end.
    end method.
end class.