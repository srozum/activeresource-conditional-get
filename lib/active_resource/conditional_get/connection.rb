require 'active_resource/connection'

module ActiveResource
  class Connection
    extend ActiveSupport::Concern
    
    attr_accessor :cache

    def get_with_conditional_get(path, headers = {})
      return get_without_conditional_get(path, headers) unless cache
      begin
        cached_response = cache.read(cache_key(path))
        if cached_response
          headers.update('If-None-Match' => cached_response['eTag']) if cached_response['eTag']
          headers.update('If-Modified-Since' => cached_response['Cache-Control']) if cached_response['Cache-Control']
        end

        response = get_without_conditional_get(path, headers)
        
        return cached_response if (response.try(:code).to_i == 304) && cached_response
        
        if (response['Cache-Control'] =~ /public/) && (response['eTag'] || response['Last-Modified'])
          if response['Cache-Control'] =~ /max-age=(\d+)/ && $1.to_i > 0
            cache.write(cache_key(path), response, :expires_in => $1.to_i)
          end
        end
        return response
      rescue ActiveResource::TimeoutError => e
        cached_response || raise(e)
      end
    end

    alias_method_chain :get, :conditional_get

    private
    
    def cache_key(path)
      'conditional_get:' + Digest::MD5.hexdigest(path)
    end
    
  end
end
