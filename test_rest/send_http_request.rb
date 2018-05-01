#!/usr/bin/ruby

require 'thor'
require 'net/http'

def send_request(req)
    response = Net::HTTP.start('localhost', 4567, :read_timeout => 1000) { |http| http.request(req) } 
    puts response.code + " #{response.message}"
    puts response.body
end

class TestHttp < Thor

    map "-l" => :list
    map "-c" => :create
    map "-s" => :suspend
    map "-hc" => :healthcheck

    desc "list", "List instances"
    def list
        send_request(Net::HTTP::Get.new("/list"))
    end

    desc "create", "Create a new instance"
    def create
        send_request(Net::HTTP::Post.new("/create"))
    end

    desc "suspend", "Suspend an instance with the given id"
    option :iid, :required => true, :type => :string
    def suspend
        send_request(Net::HTTP::Delete.new("/suspend/#{options[:iid]}"))
    end

    desc "healthcheck", "Healthcheck instances"
    def healthcheck
        send_request(Net::HTTP::Get.new("/healthcheck"))
    end

end

TestHttp.start(ARGV)
