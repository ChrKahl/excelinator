# frozen_string_literal: true

require 'excelinator_ruby3/xls'
require 'excelinator_ruby3/rails'
require 'excelinator_ruby3/version'
require 'spreadsheet'

def old_ruby?
  RUBY_VERSION.to_f < 1.9
end

if old_ruby?
  require 'fastercsv'
else
  require 'csv'
end

if defined?(Rails)
  ExcelinatorRuby3::Rails.setup
  module ActionController
    class Base
      include ExcelinatorRuby3::Rails::ACMixin
    end
  end
end
