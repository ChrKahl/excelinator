# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/lib/excelinator/version"

Gem::Specification.new do |s|
  s.name        = 'excelinator'
  s.version     = Excelinator::VERSION
  s.authors     = %w[chrismo jwhitmire]
  s.email       = %w[chrismo@clabs.org jeff@jwhitmire.com]
  s.homepage    = 'https://github.com/livingsocial/excelinator'
  s.summary     = 'Excel Converter'
  s.description = 'convert your csv data and html tables to excel data'

  s.add_dependency('fastercsv') if RUBY_VERSION < '1.9'
  s.add_dependency('spreadsheet') # surpass another option here

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')

  s.files         = `git ls-files lib/* README.md`.split("\n")
  s.require_paths = %w[lib]
end
