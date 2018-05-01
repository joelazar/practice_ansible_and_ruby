#!/usr/bin/ruby

require 'aws-sdk'
require 'thor'
require 'net/http'

def get_region
  File.open 'ansible/vars/external_variables.yml' do |file|
    return file.find { |line| line =~ /region:/ }.scan(/"([^"]*)"/).join(", ")
  end
  abort("No region found in external_variables.yml.")
end

class AwsCli < Thor

  map "-c" => :create
  map "-hc" => :healthcheck
  map "-l" => :list
  map "-s" => :suspend

  def initialize(*args)
    super
    @ec2 = Aws::EC2::Resource.new(region: "#{get_region}")
  end

  desc "create", "Create a new instance."
  long_desc <<-LONGDESC
   This will set up a new instance on your AWS account, but for that
   your ssh key needed for ansible to establish ssh connection between your
   machine and the newly created instance.
   However, there are two options to give the script the path of your ssh key.
   You can pass it with a --private_key option or you can set an enviroment
   variable, AWS_SSH_PRIVATE_KEY_PATH. If env variable set, then --private_key is an
   optional argument. Nonetheless, the option parameter always has higher priority
   than the enviroment variable.
   \x5 Example usage:
   \x5 $ cli_script.rb create --private_key=/home/user/.ssh/id_rsa
   \x5 or
   \x5 $ export AWS_SSH_PRIVATE_KEY_PATH="/home/user/.ssh/id_rsa"
   \x5 $ cli_script.rb create
  LONGDESC
  option :private_key, :required => !ENV['AWS_SSH_PRIVATE_KEY_PATH'], :type => :string
  def create_instance
    puts "Start creating a new instance"
    if options[:private_key]
      ssh_key = options[:private_key]
    else
      ssh_key = ENV['AWS_SSH_PRIVATE_KEY_PATH']
    end
    if !system("ansible-playbook -i ansible/hosts --private-key=#{ssh_key} ansible/setup-ec2.yml")
      puts "Something went wrong, check out ansible logs"
      return false
    end
    puts 'New instance created'
    healthcheck()
    return true
  end

  desc "suspend", "Suspend an instance with given instance id."
  option :iid, :required => true, :type => :string
  def suspend_instance(iid = options[:iid])
    begin
      i = @ec2.instance(iid)
      if i.exists?
        case i.state.name
        when "terminated"
          puts "#{iid} is already terminated."
        else
          i.terminate
          puts "#{iid} is terminated now."
        end
      end
      return true
    rescue Exception
      return false
    end
  end

  desc "list", "List instances."
  def list_instances
    begin
      @ec2.instances.each do |i|
        puts "ID:    #{i.id}"
        puts "State: #{i.state.name}"
        puts "Public ip address: #{i.public_ip_address}"
        puts "Public DNS: #{i.public_dns_name}"
      end
      return true
    rescue Exception
      return false
    end
  end

  desc "health", "Check running drupal servers availability."
  def healthcheck
    @ec2.instances.each do |i|
      if nil != i.tags.find {|f| f["value"] == "DrupalServer" } and i.state.name == "running"
        begin
          req = Net::HTTP::Get.new("/drupal/")
          response = Net::HTTP.start(i.public_ip_address, 80, :read_timeout => 5) {|http| http.request(req) }
          if response.code == "200"
            puts "DrupalServer with #{i.public_ip_address} ip is available."
          else
            puts "DrupalServer with #{i.public_ip_address} ip respond with #{response.code} response code."
          end
        rescue Net::ReadTimeout
          puts "DrupalServer with #{i.public_ip_address} ip is not available."
        end
      end
    end
  end

end

AwsCli.start(ARGV)
