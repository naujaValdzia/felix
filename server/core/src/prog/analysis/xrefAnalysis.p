define variable readXfref as class ReadXref no-undo.
readXfref = new ReadXref().
readXfref:waitForXrefs().

define variable findUnused as class FindUnused no-undo.
findUnused = new FindUnused().
findUnused:getUnused().