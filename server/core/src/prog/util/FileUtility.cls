 
 /*------------------------------------------------------------------------
    File        : FileUtility
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : ppacevicius
    Created     : Wed Sep 05 15:46:48 EEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class FileUtility: 
    method public static character getMethodNameFromPath(cPath as character):
        do while index (cPath, '/') > 0:
            cPath = substring(cPath, index(cPath, '/') + 1).
        end.
        if not cPath matches ('*.cls')
        then do:
            if (index (cPath, ".") > 0) and 
               (index(cPath, ".") < length(cPath) - 2)
            then do:
                cPath = substring(cPath, index(cPath, ".") + 1).
            end.
        end.
        return cPath.
    end method.
end class.