 
 /*------------------------------------------------------------------------
    File        : SystemController
    Notes       : 
  ----------------------------------------------------------------------*/
  
@program FILE(name="SystemController.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="SystemController", URI="/info", schemaName="dsSystem", schemaFile="felix_shared/system/i/ds/dsSystem.i").

using Progress.Lang.*.
using Spark.Core.Service.SparkEntity.
block-level on error undo, throw.

class system.SystemController inherits SparkEntity:

    {ds/dsSystem.i}
    define variable systemService as class SystemService no-undo.
    
    constructor public SystemController ():
        systemService = new SystemService().
    end constructor.

    
    /*  Create new system */
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/create", alias="create", mediaType="application/json").
    method public void CreateSystem(input dataset dsSystem, 
                                    output vSuccess as logical, 
                                    output vMessage as character):
        systemService:createSystem(dataset dsSystem, output vSuccess, output vMessage).
    end method. 
    
    /*------------------------------------------------------------------------------
            Purpose:    Delete a record                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/delete", alias="delete", mediaType="application/json").
    method public void DeleteSystem(input pcSystem as character,
                                    output vSuccess as logical,
                                    output vMessage as character):
        systemService:deleteSystem(pcSystem, output vSuccess, output vMessage).
    end method.
    
    /*  System update */
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/update", alias="update", mediaType="application/json").
    method public void UpdateSystem(input dataset dsSystem,
                                    output vSuccess as logical,
                                    output vMessage as character):
        systemService:updateSystem(dataset dsSystem by-reference, output vSuccess, output vMessage).
    end method.
    
    /* Systems list */
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/list", alias="list", mediaType="application/json").
    method public void systemList(output dataset dsSystem):
        systemService:systemList(output dataset dsSystem).
    end method.    

    /* System info */
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/details", alias="details", mediaType="application/json").
    method public void systemInfo(input pcSystem as character,
                                  output dataset dsSystem):
        systemService:systemInfo(pcSystem, output dataset dsSystem).
    end method.
end class.
