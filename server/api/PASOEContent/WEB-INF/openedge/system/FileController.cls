 
 /*------------------------------------------------------------------------
    File        : FileController
    Notes       : 
  ----------------------------------------------------------------------*/
  
@program FILE(name="FileController.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="FileController", URI="/file", schemaName="dsFile", schemaFile="felix_shared/system/i/ds/dsFile.i").

using Progress.Lang.*.
using Spark.Core.Service.SparkEntity.
block-level on error undo, throw.

class system.FileController inherits SparkEntity:

    {ds/dsFile.i}
    {ds/dsTree.i}
    {ds/dsFileDto.i}
    {ds/dsFileDetailDto.i}
    
    define variable fileService as class FileService no-undo.
    define variable treeDTO as class TreeDTO no-undo.
    define variable fileDTO as class FileDTO no-undo.

    constructor public FileController ():
        fileService = new FileService().
        treeDTO = new TreeDTO().
        fileDTO = new FileDTO().
    end constructor.


    /*------------------------------------------------------------------------------
            Purpose:  Get information of item usage: isUsing                                                                     
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/getIsUsingBranch", alias="getIsUsingBranch", mediaType="application/json"). 
    method public void getIsUsingBranch(input pcSystem as character,
                                        input pcFileName as character,
                                        output dataset dsTree):
        fileService:listIsUsing(pcFileName, pcSystem, output dataset dsFile by-reference).
        treeDTO:fromDomain(dataset dsFile, output dataset dsTree by-reference).
    end method.

    /*------------------------------------------------------------------------------
            Purpose:  Get information of item usage: usedBy                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/getUsedByBranch", alias="getUsedByBranch", mediaType="application/json"). 
    method public void getUsedByBranch(input pcSystem as character,
                                       input pcFileName as character,
                                       output dataset dsTree):
        fileService:listUsedBy(pcFileName, pcSystem, output dataset dsFile by-reference).
        treeDTO:fromDomain(dataset dsFile, output dataset dsTree by-reference).
    end method.

    /*------------------------------------------------------------------------------
            Purpose:  Get short information of file usage by type:                                                                         
            Notes:
            Parameters:
            @param pcSystem Target System name
    ------------------------------------------------------------------------------*/
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/getFile", alias="getFile", mediaType="application/json"). 
    method public void getFile(input pcSystem as character,
                               input pcFileName as character,
                               input pcType as character,
                               output dataset dsFileDto):
        fileService:listFiles(pcSystem, pcFileName, pcType, output dataset dsFile).
        fileDTO:fromDomain(dataset dsFile, output dataset dsFileDto).
    end method.

    /*------------------------------------------------------------------------------
            Purpose:  Get detailed information of file usage by type:                                                                         
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/getFileDetail", alias="getFileDetail", mediaType="application/json"). 
    method public void getFileDetail(input pcCompileUnit as character,
                                     input pcSystem as character,
                                     input pcType as character,
                                     input pcFileName as character,
                                     output dataset dsFileDetailDto):
        fileService:listFileDetails(pcCompileUnit, pcSystem, pcFileName, pcType, output dataset dsFile).
        fileDTO:fromDomainDetail(dataset dsFile, output dataset dsFileDetailDto).
    end method.
end class.
