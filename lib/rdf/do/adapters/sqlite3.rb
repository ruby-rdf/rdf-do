require 'rdf/do/adapters/defaults'

module RDF::DataObjects
  module Adapters
    class Sqlite3

      self.extend Defaults

      def self.migrate?(do_repository, opts = {})
        do_repository.exec('CREATE TABLE IF NOT EXISTS quads (`subject` varchar(255), `predicate` varchar(255), `object` varchar(255), `context` varchar(255), UNIQUE (`subject`, `predicate`, `object`, `context`))')
        begin do_repository.exec('CREATE INDEX `quads_context_index` ON `quads` (`context`)') rescue nil end
        begin do_repository.exec('CREATE INDEX `quads_object_index` ON `quads` (`object`)') rescue nil end
        begin do_repository.exec('CREATE INDEX `quads_predicate_index` ON `quads` (`predicate`)') rescue nil end
        begin do_repository.exec('CREATE INDEX `quads_subject_index` ON `quads` (`subject`)') rescue nil end
      end

    end
  end
end

