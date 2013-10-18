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

    users = args[0]
    endpoint = args[1].to_s
    base_uri = "#{config.params[endpoint]['uri']}"

      username = config.params[endpoint]['username']
      password = config.params[endpoint]['password']
      payload = { 'jsonrpc' => '2.0', 'method' => 'user.login', 'params' => { 'user' => username, 'password' => password }, 'id' => 1 }.to_json
      begin
        response = RestClient.post base_uri, payload, :content_type => :json, :accept => :json
        parsed = JSON.parse(response.to_str)
        token = parsed['result']
      rescue => e
        case e
          when RestClient::ResourceNotFound
            use_cache = true
            function_notice(["Resource not found with #{mod}() RestClient.post(#{uri})"])
          when SocketError
            use_cache = true
            function_notice(["Socket error with #{mod}() RestClient.post(#{uri})"])
        else
          raise e
        end
      rescue SystemCallError => e
        if e === Errno::ECONNRESET
          use_cache = true
          function_notice(["Unknown issue with #{mod}() RestClient.get(#{uri})"])
        else
          raise Puppet::ParseError, e
        end
      end
    puts "Token: #{token}"
    if token
      users.each do |user|
        payload = { 'jsonrpc' => '2.0', 'method' => 'user.get', 'params' => { 'filter' => { 'alias' => [ user ]}, 'output' => 'extend' }, 'auth' => token, 'id' =>2 }.to_json
        begin
          response = RestClient.post base_uri, payload, :content_type => :json, :accept => :json
          parsed = JSON.parse(response.to_str)
          begin
            user_alias = parsed['result'][0]['alias']
          rescue => e
            user_alias = ''
          end
          if debug
            function_notice([": #{mod}(, #{user_alias})"])
          end
        rescue => e
          case e
            when RestClient::ResourceNotFound
              use_cache = true
              function_notice(["Resource not found with #{mod}() RestClient.post(#{uri})"])
            when SocketError
              use_cache = true
              function_notice(["Socket error with #{mod}() RestClient.post(#{uri})"])
          else
            raise e
          end
        rescue SystemCallError => e
          if e === Errno::ECONNRESET
            use_cache = true
            function_notice(["Unknown issue with #{mod}() RestClient.get(#{uri})"])
          else
            raise Puppet::ParseError, e
          end
        end
        if user == user_alias
          puts 'Already Exists'
        else
          payload = { 'jsonrpc'=>'2.0', 'method'=>'user.create', 'params'=>[{ 'usrgrps'=>[{ 'usrgrpid'=>'7', 'name'=>'Zabbix administrators' }], 'alias'=>user, 'name'=>'', 'surname'=>'', 'passwd'=>'zabbix',     'url'=>'', 'autologin'=>'0', 'autologout'=>'600', 'lang'=>'en_US', 'refresh'=>'90', 'type'=>'3', 'theme'=>'default', 'attempt_failed'=>'0', 'attempt_ip'=>'0', 'attempt_clock'=>'0', 'rows_per_page'=>'50' }], 'auth'=> token, 'id'=>3 }.to_json
          begin
            response = RestClient.post base_uri, payload, :content_type => :json, :accept => :json
            parsed = JSON.parse(response.to_str)
            result = parsed['result']
            puts result
            if debug
              function_notice([": #{mod}(, #{result})"])
            end
          rescue => e
            case e
              when RestClient::ResourceNotFound
                use_cache = true
                function_notice(["Resource not found with #{mod}() RestClient.post(#{uri})"])
              when SocketError
                use_cache = true
                function_notice(["Socket error with #{mod}() RestClient.post(#{uri})"])
            else
              raise e
            end
          rescue SystemCallError => e
            if e === Errno::ECONNRESET
              use_cache = true
              function_notice(["Unknown issue with #{mod}() RestClient.get(#{uri})"])
            else
              raise Puppet::ParseError, e
            end
          end
        end
      end
    end
  end
end
