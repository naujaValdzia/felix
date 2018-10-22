 
 /*------------------------------------------------------------------------
    File        : ErrorController
    Notes       : 
  ----------------------------------------------------------------------*/
  
@program FILE(name="ErrorController.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="ErrorController", URI="/error", schemaName="dsError", schemaFile="felix_shared/system/i/ds/dsError.i").

using Progress.Lang.*.
using Spark.Core.Service.SparkEntity.
block-level on error undo, throw.

class system.ErrorController inherits SparkEntity:
    
    {ds/dsError.i}
    define variable errorService as class ErrorService no-undo.
 
    constructor public ErrorController ():
        errorService = new ErrorService().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/getError", alias="getError", mediaType="application/json").
    
    method public void getError (input systemName as character,
                                 output dataset dsError):
        errorService:getError(systemName, output dataset dsError).
    end method.
end class.
