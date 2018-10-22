 
 /*------------------------------------------------------------------------
    File        : AnalysisUtility
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : ppacevicius
    Created     : Tue Sep 11 13:44:22 EEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class AnalysisUtility: 
    method public character getNameFromPath (cPath as character):
        do while index (cPath, '/') > 0:
            cPath = substring(cPath, index(cPath, '/') + 1).
        end.
        if index (cPath, ":") > 0 
            then do:
                cPath = substring(cPath, 1, index(cPath, ":") - 1).
            end.
        do while num-entries(cPath, ".") > 1 and not 
                 (entry(2, cPath, ".") = "cls" or 
                 entry(2, cPath, ".") = "p" or 
                 entry(2, cPath, ".") = "i"):
            cPath = substring(cPath, index(cPath, ".") + 1).
        end.     
        return cPath.
    end method.
    
    method public static character fixInput (userInput as character, isEnabled as logical):
        if isEnabled = false
        then do:
            return userInput.
        end.
        else do:
            userInput = replace(userInput,"~\","/").
            userInput = replace(userInput,";",",").
            userInput = replace(userInput,":",",").
            userInput = replace(userInput,"//","/").
            userInput = replace(userInput," ","").
            return userInput.
        end.
    end method.
    
    method public static character fixPropathInput (userInput as character, isEnabled as logical):
        if isEnabled = false
        then do:
            return userInput.
        end.
        else do:
            userInput = replace(userInput,"~\","/").
            userInput = replace(userInput,";",":").
            userInput = replace(userInput,",",":").
            userInput = replace(userInput,"//","/").
            userInput = replace(userInput," ","").
            return userInput.
        end.
    end method.
    
    method public static character addPropathPath (path as character):
        define variable numEntriesCounter as integer.
        define variable cEntry as character no-undo.
        define variable outPath as character no-undo.
        
        path = deleteLastSymbol(path,":").
        path = deleteLastSymbol(path,"/").
        repeat numEntriesCounter = 1 to num-entries(path,":"):
            cEntry = entry(numEntriesCounter,path,":").
            if index(cEntry,"/") = 1
            then do:
                cEntry = substring(cEntry,2,length(cEntry)).
            end.
            if numEntriesCounter = num-entries(path,":")
            then do:
                cEntry = "/usr/sources/" + cEntry.
            end.
            else do:
                cEntry = "/usr/sources/" + cEntry + ":".
            end.
            outPath = outPath + cEntry.
        end.
        outPath = deleteLastSymbol(outPath,":").
        return outPath.
    end method.
    
    method public static character addPath (path as character):
        define variable numEntriesCounter as integer.
        define variable cEntry as character no-undo.
        define variable outPath as character no-undo.
        
        path = deleteLastSymbol(path,",").
        path = deleteLastSymbol(path,"/").
        repeat numEntriesCounter = 1 to num-entries(path,","):
            cEntry = entry(numEntriesCounter,path,",").
            if index(cEntry,"/") = 1
            then do:
                cEntry = substring(cEntry,2,length(cEntry)).
            end.
            cEntry = "/usr/sources/" + cEntry + ",".
            outPath = outPath + cEntry.
        end.
        outPath = deleteLastSymbol(outPath,",").
        return outPath.
    end method.
    
    method public static character deleteLastSymbol (theLine as character, symbol as character):
        if length(theLine) = r-index(theLine,symbol)
        then theLine = substring(theLine,1,length(theLine) - 1).
        return theLine.
    end method.    
end class.