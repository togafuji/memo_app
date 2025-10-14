# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra/base'
require 'active_support'
require 'active_support/core_ext'
require_relative '../lib/memo_app'

Dir[File.expand_path('../app/**/*.rb', __dir__)].sort.each { |file| require file }

MemoApp::Application.boot!
