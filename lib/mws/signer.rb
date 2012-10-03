class Mws::Signer

    def initialize(options={})
      @verb = (options[:verb] || 'POST').to_s.upcase
      @host = (options[:verb] || 'https://mws.amazonservices.com').to_s.downcase
      @path = options[:path] || '/'
      @secret = options[:secret]
    end

    def signature(query, secret=@secret)
      digest = OpenSSL::Digest::Digest.new 'sha256'
      message = [ @verb, @host, @path, query ].join '\n'
      Base64::encode64(OpenSSL::HMAC.digest(digest, secret, message)).chomp
    end

    def sign(query, secret=@secret)
      "#{query}&Signature=#{signature query, secret}"
    end

  end
