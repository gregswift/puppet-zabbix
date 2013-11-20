module Puppet::Parser::Functions
  newfunction(:zabbix_syncusers) do |args|
    require 'rubygems'
    require 'socket'
    require 'parseconfig'
    require 'rest_client'
    require 'json'
    require 'resolv'
    mod = 'zabbix_usersync'
    debug = true
    begin
      config = ParseConfig.new("/etc/puppet/zabbix_host.conf")
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
    users = args[0]
    endpoint = args[1].to_s
    base_uri = "#{config.params[endpoint]['uri']}"
    username = config.params[endpoint]['username']
    password = config.params[endpoint]['password']
    function_debug(["#{mod}(#{endpoint}): Syncing Users"])
    zabbixapi = Zabbix.new(base_uri,username,password)
    token = zabbixapi.token()

    users.each do |user|
      payload = { 'jsonrpc' => '2.0', 'method' => 'user.get', 'params' => { 'filter' => { 'alias' => [ user ]}, 'output' => 'extend' }, 'auth' => token, 'id' =>2 }.to_json
      ret = zabbixapi.request(payload)
      begin
        user_alias = ret['result'][0]['alias']
      rescue => e
        case e
          when NoMethodError
            user_alias = ''
        end
      end
      if user_alias == user
        function_debug(["#{mod}(#{endpoint}): #{user} Already Exists"])
      else
        payload = { 'jsonrpc'=>'2.0', 'method'=>'user.create', 'params'=>[{ 'usrgrps'=>[{ 'usrgrpid'=>'7', 'name'=>'Zabbix administrators' }], 'alias'=>user, 'name'=>'', 'surname'=>'', 'passwd'=>'zabbix',     'url'=>'', 'autologin'=>'0', 'autologout'=>'600', 'lang'=>'en_US', 'refresh'=>'90', 'type'=>'3', 'theme'=>'default', 'attempt_failed'=>'0', 'attempt_ip'=>'0', 'attempt_clock'=>'0', 'rows_per_page'=>'50' }], 'auth'=> token, 'id'=>3 }.to_json
        ret = zabbixapi.request(payload)
        if ret['result']
          function_debug(["#{mod}(#{endpoint}): #{user} Added Successfully"])
        else
          function_debug(["#{mod}(#{endpoint}): #{user} Couldn't be added"])
        end
      end
    end
  end
end
