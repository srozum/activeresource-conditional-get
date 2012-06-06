require 'active_resource/base'

module ActiveResource
  class Base

    cattr_accessor :cache

    class << self
      
      def connection_with_cache(refresh = false)
        if defined?(@connection) || superclass == Object
          @connection = Connection.new(site, format) if refresh || @connection.nil?
          @connection.proxy = proxy if proxy
          @connection.user = user if user
          @connection.password = password if password
          @connection.auth_type = auth_type if auth_type
          @connection.timeout = timeout if timeout
          @connection.ssl_options = ssl_options if ssl_options
          @connection.cache = cache if cache
          @connection
        else
          superclass.connection
        end
      end

      alias_method :connection_without_cache, :connection
      alias_method :connection, :connection_with_cache
      
    end

  end
end
