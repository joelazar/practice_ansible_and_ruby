#!/usr/bin/ruby

require 'sinatra'
require_relative 'cli_script.rb'

m = AwsCli.new()

set :bind, '0.0.0.0'

def with_captured_stdout
  old_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = old_stdout
end

get '/list' do
  stdoutput = with_captured_stdout { return status 500 if not m.list_instances() }
  content_type 'text/plain;charset=utf8'
  halt stdoutput
end

get '/healthcheck' do
  stdoutput = with_captured_stdout { m.healthcheck() }
  content_type 'text/plain;charset=utf8'
  halt stdoutput
end

delete '/suspend/:iid' do
  stdoutput = with_captured_stdout { return status 500 if not m.suspend_instance(params[:iid]) }
  content_type 'text/plain;charset=utf8'
  halt stdoutput
end

post '/create' do
  stdoutput = with_captured_stdout { return status 500 if not m.create_instance() }
  content_type 'text/plain;charset=utf8'
  halt stdoutput
end