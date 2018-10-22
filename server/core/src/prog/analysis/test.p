
disable triggers for load of system.
disable triggers for dump of system.

define buffer bSystem for system.
define variable vSystem as character init "indigo" no-undo.
define variable vEntryPoints as character format "x(100)" no-undo extent 100.
define variable cEntryPointsList as character no-undo.
//define variable i as integer no-undo.


find first bSystem where 
           bSystem.systemName = vSystem no-lock no-error.
     
cEntryPointsList = bSystem.entryPoints.
           
do i = 1 to num-entries(cEntryPointsList, ","):
    vEntryPoints[i] = entry(i,cEntryPointsList,",").
    message vEntryPoints[i].
end.

message "lol" view-as alert-box.