 
 /*------------------------------------------------------------------------
    File        : DbFieldService
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class DbFieldService: 
    
    {ds/dsDbFieldDto.i}
    {ds/dsDbField.i}
    
    method public void getDbFields (fieldName as character, 
                                    systemName as character, 
                                    fieldType as character, 
                                    output dataset dsDbField):
        case fieldType:
            when "ACCESS" or 
            when "UPDATE" or 
            when "DELETE" or 
            when "REFERENCE" or 
            when "INDEX" then findDbField(fieldName, systemName, fieldType, output dataset dsDbField by-reference).
            when "ALL" then findAllDbFields(fieldName, systemName, output dataset dsDbField by-reference).
        end case.
    end method.

    method public void getDbFieldDetails (compileUnit as character, 
                                          fieldName as character, 
                                          systemName as character, 
                                          fieldType as character, 
                                          output dataset dsDbField):
        case fieldType:
            when "ACCESS" or 
            when "UPDATE" or 
            when "DELETE" or 
            when "REFERENCE" or 
            when "INDEX" then findDbFieldDetails(compileUnit, fieldName, systemName, fieldType, output dataset dsDbField by-reference).
            when "ALL" then findAllDbFieldsDetails(compileUnit, fieldName, systemName, output dataset dsDbField by-reference).
        end case.
    end method.

    method public void findDbField (fieldName as character, 
                                   systemName as character, 
                                   fieldType as character,
                                   output dataset dsDbField):
        define buffer bDbField for dbField.
        dataset dsDbField:empty-dataset().
        
        for each bDbField no-lock where
                 bDbField.system = systemName and
                 bDbField.type = fieldType and
                 bDbField.info = fieldName 
                 by bDbField.compileUnit:
                
            find first ttDbField where 
                       ttDbField.compileUnit = bDbField.compileUnit no-error.
            if not available ttDbField
            then do:
                create ttDbField.
                ttDbField.compileUnit = bDbField.compileUnit.
            end. 
        end.
        dataset dsDbField:accept-changes().
    end method.
    
    method public void findDbFieldDetails (compUnit as character, 
                                          fieldName as character, 
                                          systemName as character, 
                                          fieldType as character,
                                          output dataset dsDbField):
        define buffer bDbField for dbField.
        dataset dsDbField:empty-dataset().
        
        for each bDbField no-lock where
                 bDbField.system = systemName and
                 bDbField.type = fieldType and
                 bDbField.info = fieldName 
                 by bDbField.compileUnit:
                
            if compUnit = bDbField.compileUnit
            then do:
                create ttDbField.
                ttDbField.system = bDbField.system.
                ttDbField.compileUnit = bDbField.compileUnit.
                ttDbField.fileName = bDbField.fileName.
                ttDbField.sourceName = bDbField.sourceName.
                ttDbField.sourcePath = bDbField.sourcePath.
                ttDbField.type = bDbField.type.
                ttDbField.line = bDbField.line.
                ttDbField.info = bDbField.info.
            end.
        end.
        dataset dsDbField:accept-changes().
    end method.

    method public void findAllDbFields (fieldName as character, 
                                        systemName as character, 
                                        output dataset dsDbField):
        define buffer bDbField for dbField.
        dataset dsDbField:empty-dataset().
        
        for each bDbField no-lock where
                 bDbField.system = systemName and
                 bDbField.type <> "INDEX" and
                 (bDbField.info matches("*~~." + fieldName) or
                 bDbField.info = fieldName or
                 bDbField.info matches ("*~~." + fieldName + ":*"))
                 by bDbField.compileUnit:
                
            find first ttDbField where 
                       ttDbField.compileUnit = bDbField.compileUnit no-error.
            if not available ttDbField
            then do:
                create ttDbField.
                ttDbField.compileUnit = bDbField.compileUnit.
            end. 
        end.
        dataset dsDbField:accept-changes().
    end method.
    
    method public void findAllDbFieldsDetails (compUnit as character, 
                                               fieldName as character, 
                                               systemName as character, 
                                               output dataset dsDbField):
        define buffer bDbField for dbField.
        dataset dsDbField:empty-dataset().
        
        for each bDbField no-lock where
                 bDbField.system = systemName and
                 bDbField.type <> "INDEX" and
                 (bDbField.info matches("*~~." + fieldName) or
                 bDbField.info = fieldName or
                 bDbField.info matches ("*~~." + fieldName + ":*"))
                 by bDbField.compileUnit:
                
            if compUnit = bDbField.compileUnit
            then do:
                create ttDbField.
                ttDbField.system = bDbField.system.
                ttDbField.compileUnit = bDbField.compileUnit.
                ttDbField.fileName = bDbField.fileName.
                ttDbField.sourceName = bDbField.sourceName.
                ttDbField.sourcePath = bDbField.sourcePath.
                ttDbField.type = bDbField.type.
                ttDbField.line = bDbField.line.
                ttDbField.info = bDbField.info.
            end.
        end.
        dataset dsDbField:accept-changes().
    end method.
end class.