 
 /*------------------------------------------------------------------------
    File        : FileService
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class FileService:

    {ds/dsFile.i}
    {ds/dsTree.i}
    
    method public void listFiles (systemName as character, itemName as character, fileType as character, output dataset dsFile):
        case fileType:
            when "Procedure" then findProcedure(itemName, systemName, output dataset dsFile).
            when "Class" then findClass(itemName, systemName, output dataset dsFile).
            when "Include" then findInclude(itemName, systemName, output dataset dsFile).
            when "All" then findAllFiles(itemName, systemName, output dataset dsFile).
        end case.
    end method.
    
    method public void listFileDetails (compileUnit as character, systemName as character, itemName as character, fileType as character, output dataset dsFile):
        case fileType:
            when "Procedure" then findProcedureDetails(compileUnit, itemName, systemName, output dataset dsFile).
            when "Class" then findClassDetails(compileUnit, itemName, systemName, output dataset dsFile).
            when "Include" then findIncludeDetails(compileUnit, itemName, systemName, output dataset dsFile).
            when "All" then findAllFilesDetails(compileUnit, itemName, systemName, output dataset dsFile).
        end case.
    end method.
    
    method public void listIsUsing (usingName as character, 
                                    usingSystem as character,
                                    output dataset dsFile):
        define buffer bFile for file.
        dataset dsFile:empty-dataset().
        
        usingName = replace(usingName,".cls","").
        for each bFile no-lock where 
                 (bFile.compileunit matches ("*/" + usingName) or
                 bFile.compileunit matches ("*/" + usingName + "~~.*")) and
                 (bFile.type = "RUN" or
                 bFile.type = "INCLUDE" or
                 bFile.type = "NEW" or 
                 bFile.type = "CLASS" or 
                 bFile.type = "INVOKE" or 
                 bFile.type = "IMPLICIT INVOKE") and
                 bFile.system = usingSystem
                 by bFile.info:
            find first ttfile where 
                       ttfile.fileName = FileUtility:getMethodNameFromPath(bFile.info) no-error.
            if not available ttFile
            then do:
                create ttFile.
                ttFile.fileName = FileUtility:getMethodNameFromPath(bFile.info).
                ttFile.type = bFile.type.
            end. 
        end.
        dataset dsFile:accept-changes ().
    end method.   

    method public void listUsedBy (usedName as character, 
                                   usedSystem as character, 
                                   output dataset dsFile):
        define buffer bFile for file.
        dataset dsFile:empty-dataset().
        
        usedName = replace(usedName,".cls","").
        for each bFile no-lock where 
                 bFile.system = usedSystem and
                 ((bFile.type = "NEW" or 
                 bFile.type = "CLASS" or 
                 bFile.type = "INVOKE" or 
                 bFile.type = "IMPLICIT INVOKE" or 
                 bFile.type = "ACCESS" or 
                 bFile.type = "UPDATE") and
                 (bFile.info matches("*~~." + usedName) or
                 bFile.info = usedName or
                 bFile.info matches ("*~~." + usedName + ":*"))
                 or
                 (bFile.type = "RUN" and
                 (bFile.info matches("*/" + usedName) or
                 bFile.info matches("*/" + usedName + ".p") or
                 bFile.info = usedName or
                 bFile.info matches (usedName + ".p")))
                 or
                 (bFile.type = "INCLUDE" and 
                 (bFile.info matches ("*/" + usedName) or
                 bFile.info matches("*/" + usedName + ".i") or
                 bFile.info = usedName or
                 bFile.info matches(usedName + ".i"))))
                 by bFile.compileUnit:
            create ttfile.
            ttfile.fileName = FileUtility:getMethodNameFromPath(bFile.compileUnit).
            ttfile.info = bFile.info.
            ttfile.type = bFile.type.
        end.
        dataset dsFile:accept-changes().
    end method.
    
    method public void findProcedure (itemName as character, 
                                      systemName as character, 
                                      output dataset dsFile):
        define buffer bFile for file.
        dataset dsFile:empty-dataset().
        
        itemName = replace(itemName,".p","").
        for each bFile no-lock where
                 bFile.system = systemName and
                 bFile.type = "RUN" and
                 (bFile.info matches("*/" + itemName) or
                 bFile.info matches("*/" + itemName + "~~.p") or
                 bFile.info = itemName or
                 bFile.info matches (itemName + "~~.p")) 
                 by bFile.compileUnit:
            do:
                find first ttFile where 
                           ttFile.compileUnit = bFile.compileUnit no-error.
                if not available ttFile
                then do:
                    create ttFile.
                    ttFile.compileUnit = bFile.compileUnit.
                end.
            end.
        end.
        dataset dsFile:accept-changes().
    end method.
    
    method public void findProcedureDetails (compUnit as character, 
                                             itemName as character, 
                                             systemName as character, 
                                             output dataset dsFile):
        define buffer bFile for file.
        dataset dsFile:empty-dataset().
        
        itemName = replace(itemName,".p","").
        for each bFile no-lock where
                 bFile.system = systemName and
                 bFile.type = "RUN" and
                 (bFile.info matches("*/" + itemName) or
                 bFile.info matches("*/" + itemName + "~~.p") or
                 bFile.info = itemName or
                 bFile.info matches (itemName + "~~.p"))
                 by bFile.compileUnit:
                
            if compUnit = bFile.compileUnit 
            then do:
                create ttFile.
                ttFile.system = bFile.system.
                ttFile.compileUnit = bFile.compileUnit.
                ttFile.fileName = bFile.fileName.
                ttFile.sourceName = bFile.sourceName.
                ttFile.sourcePath = bFile.sourcePath.
                ttFile.type = bFile.type.
                ttFile.line = bFile.line.
                ttFile.info = bFile.info.
            end.
        end.
        dataset dsFile:accept-changes().
    end method.
    
    method public void findClass (itemName as character, 
                                  systemName as character, 
                                  output dataset dsFile):
    define buffer bFile for file.
    dataset dsFile:empty-dataset().
    
    itemName = replace(itemName,".cls","").
    for each bFile no-lock where 
             bFile.system = systemName and
             (bFile.type = "NEW" or 
             bFile.type = "CLASS" or 
             bFile.type = "INVOKE" or 
             bFile.type = "IMPLICIT INVOKE" or 
             bFile.type = "ACCESS" or 
             bFile.type = "UPDATE") and
             (bFile.info matches("*~~." + itemName) or
             bFile.info = itemName or
             bFile.info matches ("*~~." + itemName + ":*"))
             by bFile.compileUnit:              
        do:
            find first ttFile where 
                       ttFile.compileUnit = bFile.compileUnit no-error.
            if not available ttFile
            then do:
                create ttFile.
                ttFile.compileUnit = bFile.compileUnit.
            end.
        end.
    end.
    dataset dsFile:accept-changes().
    end method.
    
    method public void findClassDetails (compUnit as character, 
                                         itemName as character, 
                                         systemName as character, 
                                         output dataset dsFile):
    define buffer bFile for file.
    dataset dsFile:empty-dataset().
    
    itemName = replace(itemName,".cls","").
    for each bFile no-lock where 
             bFile.system = systemName and
             (bFile.type = "NEW" or 
             bFile.type = "CLASS" or 
             bFile.type = "INVOKE" or 
             bFile.type = "IMPLICIT INVOKE" or 
             bFile.type = "ACCESS" or 
             bFile.type = "UPDATE") and
             (bFile.info matches("*~~." + itemName) or
             bFile.info = itemName or
             bFile.info matches ("*~~." + itemName + ":*"))
             by bFile.compileUnit:              

        if compUnit = bFile.compileUnit 
        then do:
            create ttFile.
            ttFile.system = bFile.system.
            ttFile.compileUnit = bFile.compileUnit.
            ttFile.fileName = bFile.fileName.
            ttFile.sourceName = bFile.sourceName.
            ttFile.sourcePath = bFile.sourcePath.
            ttFile.type = bFile.type.
            ttFile.line = bFile.line.
            ttFile.info = bFile.info.
        end.
    end.
    dataset dsFile:accept-changes(). 
    end method.
    
    method public void findInclude (itemName as character, 
                                    systemName as character, 
                                    output dataset dsFile):
        define buffer bFile for file.
        dataset dsFile:empty-dataset().
        
        itemName = replace(itemName,".i","").
        for each bFile no-lock where 
                 bFile.type = "INCLUDE" and 
                 bFile.system = systemName and
                 (bFile.info matches ("*/" + itemName) or
                 bFile.info matches("*/" + itemName + "~~.i") or
                 bFile.info = itemName or
                 bFile.info matches(itemName + "~~.i"))
                 by bFile.compileUnit:
            do:
                find first ttFile where 
                           ttFile.compileUnit = bFile.compileUnit no-error.
                if not available ttFile
                then do:
                    create ttFile.
                    ttFile.compileUnit = bFile.compileUnit.
                end.
            end.
        end.
        dataset dsFile:accept-changes(). 
    end method.

    method public void findIncludeDetails (compUnit as character, 
                                           itemName as character, 
                                           systemName as character, 
                                           output dataset dsFile):
        define buffer bFile for file.
        dataset dsFile:empty-dataset().
        
        itemName = replace(itemName,".i","").
        for each bFile no-lock where 
                 bFile.type = "INCLUDE" and 
                 bFile.system = systemName and
                 (bFile.info matches ("*/" + itemName) or
                 bFile.info matches("*/" + itemName + "~~.i") or
                 bFile.info = itemName or
                 bFile.info matches(itemName + "~~.i"))
                 by bFile.compileUnit:
                
            if compUnit = bFile.compileUnit 
            then do:
                create ttFile.
                ttFile.system = bFile.system.
                ttFile.compileUnit = bFile.compileUnit.
                ttFile.fileName = bFile.fileName.
                ttFile.sourceName = bFile.sourceName.
                ttFile.sourcePath = bFile.sourcePath.
                ttFile.type = bFile.type.
                ttFile.line = bFile.line.
                ttFile.info = bFile.info.
            end.
        end.
        dataset dsFile:accept-changes(). 
    end method.

    method public void findAllFiles (itemName as character, 
                                     systemName as character, 
                                     output dataset dsFile):  
        define buffer bFile for file.
        dataset dsFile:empty-dataset().
        
        itemName = replace(itemName,".p","").
        itemName = replace(itemName,".cls","").
        itemName = replace(itemName,".i","").
        
        for each bFile no-lock where 
                 bFile.system = systemName and //determine system
                 ((bFile.type = "RUN" and
                 (bFile.info matches("*/" + itemName) or
                 bFile.info matches("*/" + itemName + "~~.p") or
                 bFile.info = itemName or
                 bFile.info matches (itemName + "~~.p"))) or //end of procedures search
                 ((bFile.type = "NEW" or 
                 bFile.type = "CLASS" or 
                 bFile.type = "INVOKE" or 
                 bFile.type = "IMPLICIT INVOKE" or 
                 bFile.type = "ACCESS" or 
                 bFile.type = "UPDATE") and
                 (bFile.info matches("*~~." + itemName) or
                 bFile.info = itemName or
                 bFile.info matches ("*~~." + itemName + ":*"))) or //end of classes search
                 (bFile.type = "INCLUDE" and 
                 (bFile.info matches ("*/" + itemName) or
                 bFile.info matches("*/" + itemName + "~~.i") or
                 bFile.info = itemName or
                 bFile.info matches(itemName + "~~.i")))) //end of includes search
                 by bFile.compileUnit:
            do:
                find first ttFile where 
                           ttFile.compileUnit = bFile.compileUnit no-error.
                if not available ttFile
                then do:
                    create ttFile.
                    ttFile.compileUnit = bFile.compileUnit.
                end.
            end.
        end.
        dataset dsFile:accept-changes(). 
    end method.

    method public void findAllFilesDetails (compUnit as character, 
                                            itemName as character, 
                                            systemName as character, 
                                            output dataset dsFile):
        define buffer bFile for file.
        dataset dsFile:empty-dataset().
        
        itemName = replace(itemName,".p","").
        itemName = replace(itemName,".cls","").
        itemName = replace(itemName,".i","").
        
        for each bFile no-lock where 
                 bFile.system = systemName and //determine system
                 ((bFile.type = "RUN" and
                 (bFile.info matches("*/" + itemName) or
                 bFile.info matches("*/" + itemName + "~~.p") or
                 bFile.info = itemName or
                 bFile.info matches (itemName + "~~.p"))) or //end of procedures search
                 ((bFile.type = "NEW" or 
                 bFile.type = "CLASS" or 
                 bFile.type = "INVOKE" or 
                 bFile.type = "IMPLICIT INVOKE" or 
                 bFile.type = "ACCESS" or 
                 bFile.type = "UPDATE") and
                 (bFile.info matches("*~~." + itemName) or
                 bFile.info = itemName or
                 bFile.info matches ("*~~." + itemName + ":*"))) or //end of classes search
                 (bFile.type = "INCLUDE" and 
                 (bFile.info matches ("*/" + itemName) or
                 bFile.info matches("*/" + itemName + "~~.i") or
                 bFile.info = itemName or
                 bFile.info matches(itemName + "~~.i")))) //end of includes search
                 by bFile.compileUnit:
                
            if compUnit = bFile.compileUnit 
            then do:
                create ttFile.
                ttFile.system = bFile.system.
                ttFile.compileUnit = bFile.compileUnit.
                ttFile.fileName = bFile.fileName.
                ttFile.sourceName = bFile.sourceName.
                ttFile.sourcePath = bFile.sourcePath.
                ttFile.type = bFile.type.
                ttFile.line = bFile.line.
                ttFile.info = bFile.info.
            end.
        end.
        dataset dsFile:accept-changes(). 
    end method.
end class.