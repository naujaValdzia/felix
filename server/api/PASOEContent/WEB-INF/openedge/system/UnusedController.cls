 
 /*------------------------------------------------------------------------
    File        : UnusedController
    Notes       : 
  ----------------------------------------------------------------------*/

@program FILE(name="UnusedController.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="UnusedController", URI="/unused", schemaName="dsUnused", schemaFile="felix_shared/system/i/ds/dsUnused.i").

using Progress.Lang.*.
using Spark.Core.Service.SparkEntity.
block-level on error undo, throw.

class system.UnusedController inherits SparkEntity:

    {ds/dsUnused.i}
    define variable unusedService as class UnusedService no-undo.
    
    constructor public UnusedController ():
        unusedService = new UnusedService().
    end constructor.

    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/getUnused", alias="getUnused", mediaType="application/json").
    
    method public void getUnused (input pcSystem as character,
                                  input pcType as character,
                                  output dataset dsUnused):
        unusedService:listUnused(pcSystem, pcType, output dataset dsUnused).
    end method.
end class.
