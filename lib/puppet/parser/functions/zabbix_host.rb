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

    host = args[0].to_s
    endpoint = args[1].to_s
    base_uri = "#{config.params[endpoint]['uri']}"

    if debug
      function_notice(["#{host}: #{mod}(#{host}, )"])
      function_notice(["#{host}: #{mod}(#{host}) base_uri=#{base_uri}"])
    end

      if debug
        function_notice(["#{mod}(#{host}) has timed out, attempting to refresh"])
      end
      use_cache = false

      username = config.params[endpoint]['username']
      password = config.params[endpoint]['password']
      payload = { 'jsonrpc' => '2.0', 'method' => 'user.login', 'params' => { 'user' => username, 'password' => password }, 'id' => 1 }.to_json
      begin
        response = RestClient.post base_uri, payload, :content_type => :json, :accept => :json
        parsed = JSON.parse(response.to_str)
        token = parsed['result']
        if debug
          function_notice(["#{host}: #{mod}(#{host}, #{token})"])
        end
      rescue => e
        case e
          when RestClient::ResourceNotFound
            use_cache = true
            function_notice(["Resource not found with #{mod}(#{host}) RestClient.post(#{uri})"])
          when SocketError
            use_cache = true
            function_notice(["Socket error with #{mod}(#{host}) RestClient.post(#{uri})"])
        else
          raise e
        end
      rescue SystemCallError => e
        if e === Errno::ECONNRESET
          use_cache = true
          function_notice(["Unknown issue with #{mod}(#{host}) RestClient.get(#{uri})"])
        else
          raise Puppet::ParseError, e
        end
      end
    if token
      payload = { 'jsonrpc'=> '2.0', 'method'=> 'host.exists', 'params'=> { 'host'=> host }, 'auth'=> token, 'id'=> 1 }.to_json
      begin
        response = RestClient.post base_uri, payload, :content_type => :json, :accept => :json
        parsed = JSON.parse(response.to_str)
        exists = parsed['result']
        if debug
          function_notice(["#{host}: #{mod}(#{host}, #{exists})"])
        end
      rescue => e
        case e
          when RestClient::ResourceNotFound
            use_cache = true
            function_notice(["Resource not found with #{mod}(#{host}) RestClient.post(#{uri})"])
          when SocketError
            use_cache = true
            function_notice(["Socket error with #{mod}(#{host}) RestClient.post(#{uri})"])
        else
          raise e
        end
      rescue SystemCallError => e
        if e === Errno::ECONNRESET
          use_cache = true
          function_notice(["Unknown issue with #{mod}(#{host}) RestClient.get(#{uri})"])
        else
          raise Puppet::ParseError, e
        end
      end
      if exists
        function_notice(["#{host}: Already Exists"])
      else
        payload = { 'jsonrpc'=> '2.0', 'method'=> 'host.create', 'params'=> { 'host'=> host, 'interfaces'=> [{ 'type'=> 1,  'main'=> 1, 'useip'=> 0, 'ip'=> '', 'dns'=> host, 'port'=> '10050' }], 'groups'=> [{ 'groupid'=> '2' }], 'templates' => [{ 'templateid' => '10001' }]}, 'auth'=> token ,'id'=> 1 }.to_json
        begin
          response = RestClient.post base_uri, payload, :content_type => :json, :accept => :json
          parsed = JSON.parse(response.to_str)
          exists = parsed['result']
          function_notice(["#{host}: Added to Zabbix"])
          if debug
            function_notice(["#{host}: #{mod}(#{host}, #{exists})"])
          end
        rescue => e
          case e
            when RestClient::ResourceNotFound
              use_cache = true
              function_notice(["Resource not found with #{mod}(#{host}) RestClient.post(#{uri})"])
            when SocketError
              use_cache = true
              function_notice(["Socket error with #{mod}(#{host}) RestClient.post(#{uri})"])
          else
            raise e
          end
        rescue SystemCallError => e
          if e === Errno::ECONNRESET
            use_cache = true
            function_notice(["Unknown issue with #{mod}(#{host}) RestClient.get(#{uri})"])
          else
            raise Puppet::ParseError, e
          end
        end
      end
    end
  end
end
