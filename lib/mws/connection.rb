class Mws::Connection

  def initialize(options)
    @scheme = options[:scheme] || 'https'
    @host = options[:host] || 'mws.amazonservices.com'
    @merchant = options[:merchant]
    @access = options[:access]
    @secret = options[:secret]
  end

  def get(endpoint, options)
    request(:get, endpoint, nil, options)
  end

  def post(endpoint, body, options)
    request(:post, endpoint, body, options)
  end

  private

  def request(method, endpoint, body, options)
    path = "/#{Mws::Utils.camelize endpoint}/#{options[:version]}"
    options[:merchant] ||= @merchant
    options[:access] ||= @access
    query = Mws::Query.new options
    signer = Mws::Signer.new method: method, host: @host, path: path, secret: @secret
    headers = {
      'User-Agent' => 'MWS Client/0.0.1 (Language=Ruby)',
      'Accept-Encoding' => 'text/xml'
    }
    unless body.nil?
      headers['Content-Type'] = 'text/xml'
    end
    HTTParty.send method, "#{@scheme}://#{@host}#{path}?#{signer.sign query}", headers: headers, body: body
  end

end
