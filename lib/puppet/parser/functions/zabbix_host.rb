module Puppet::Parser::Functions
  newfunction(:zabbix_host) do |args|
    require 'rubygems'
    require 'socket'
    require 'parseconfig'
    require 'rest_client'
    require 'json'
    require 'resolv'
    mod = 'zabbix_host'
    debug = true
    begin
      config = ParseConfig.new("/etc/puppet/#{mod}.conf")
    rescue Exception => e
      abort "Unable to read config file #{config} with exception: #{e}"
    end
    class Zabbix
      @@token=nil
      @@zabbix_uri=nil
      def initialize(zabbix_uri,username,password)
        @@zabbix_uri=zabbix_uri
        payload = { 'jsonrpc' => '2.0', 'method' => 'user.login', 'params' => { 'user' => username, 'password' => password }, 'id' => 1 }.to_json
        ret     = self.request(payload)
        @@token = ret['result']
      end
      def token()
        return @@token
      end
      def request(payload)
        begin
          response = RestClient.post @@zabbix_uri, payload, :content_type => :json, :accept => :json
          json     = JSON.parse(response.to_str)
        rescue => e
          case e
            when RestClient::ResourceNotFound
              error = 'Resource Not Found'
            when SocketError
              error = 'Socket Error'
            when Errno::ECONNREFUSED
              error = 'Connection Refused'
          end
        end
        if error.nil?
          return json
        else
          return error
        end
      end
    end
    host = args[0].to_s
    endpoint = args[1].to_s
    username = config.params[endpoint]['username']
    password = config.params[endpoint]['password']
    base_uri = "#{config.params[endpoint]['uri']}"
    function_debug(["#{mod}(#{endpoint}): Adding #{host}"])
    zabbixapi = Zabbix.new(base_uri,username,password)
    token = zabbixapi.token()

    payload = { 'jsonrpc'=> '2.0', 'method'=> 'host.exists', 'params'=> { 'host'=> host }, 'auth'=> token, 'id'=> 1 }.to_json
    ret = zabbixapi.request(payload)
    exists = ret['result']
    if exists
      function_debug(["#{mod}(#{endpoint}): #{host} Already Exists"])
    else
      payload = { 'jsonrpc'=> '2.0', 'method'=> 'host.create', 'params'=> { 'host'=> host, 'interfaces'=> [{ 'type'=> 1,  'main'=> 1, 'useip'=> 0, 'ip'=> '', 'dns'=> host, 'port'=> '10050' }], 'groups'=> [{ 'groupid'=> '2' }], 'templates' => [{ 'templateid' => '10001' }]}, 'auth'=> token ,'id'=> 1 }.to_json
      ret = zabbixapi.request(payload)
      if ret['result']
        function_debug(["#{mod}(#{endpoint}): #{host} Added Successfully"])
      else
        function_debug(["#{mod}(#{endpoint}): #{host} Couldn't be added"])
      end
    end
  end
end
