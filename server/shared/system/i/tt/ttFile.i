
/*------------------------------------------------------------------------
    File        : ttFile.i
    Notes       :
  ----------------------------------------------------------------------*/

define temp-table ttFile
field fileNum as integer initial "0"
field fileName as character
field sourceName as character
field sourcePath as character
field line as integer initial "0"
field type as character
field info as character
field compileUnit as character
field systemName as character
index systemID is primary systemName ascending 
index typeID type ascending.
