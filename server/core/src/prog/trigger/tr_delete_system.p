trigger procedure for delete of system.

for each file where 
         file.system = system.systemName exclusive-lock:
    delete file.
end.

for each dbField where 
         dbField.system = system.systemName exclusive-lock:
    delete dbField.
end.

for each error where
         error.systemName = system.systemName exclusive-lock:
    delete error.
end.

for each unused where
         unused.systemName = system.systemName exclusive-lock:
    delete unused.
end.