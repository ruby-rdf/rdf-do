# RDF::DataObjects

DataObjects-backed RDF.rb repository, aiming for a simple use case and
compatibility with SQLite and MySQL.


Example:
    repository = RDF::DataObjects::Repository.new "sqlite3://test.db"
    repository.insert(statement)
    repository.count              #=> 1
    repository.delete(statement)


