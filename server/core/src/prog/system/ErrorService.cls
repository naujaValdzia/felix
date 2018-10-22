 
 /*------------------------------------------------------------------------
    File        : ErrorService
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class ErrorService: 
    {ds/dsError.i}

    method public void getError(sysName as character, 
                                output dataset dsError):
        define buffer bError for error.
        dataset dsError:empty-dataset().
        
        for each bError no-lock where 
                 bError.systemName = sysName:
            create ttError.
            ttError.filePath = bError.filePath.
            ttError.systemName = bError.systemName.
            ttError.errorMessage = bError.errorMessage.
            ttError.id = bError.id.
        end.
        dataset dsError:accept-changes ().
    end method.    
end class.