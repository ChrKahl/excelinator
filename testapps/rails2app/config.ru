# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/config/environment"
run ActionController::Dispatcher.new
