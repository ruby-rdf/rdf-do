$:.unshift(File.join(File.dirname(__FILE__),'..','lib'))
$:.unshift(File.join(File.dirname(__FILE__),'..','..','rdf-spec','lib'))

require 'rdf'
require 'rdf/spec'
require 'rdf/spec/repository'
require 'rdf/do'
