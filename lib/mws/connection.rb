require 'faraday'
require 'faraday_middleware'

class Mws::Connection

  attr_reader :orders, :feeds

  def initialize(options)
    @scheme = options[:scheme] || 'https'
    @host = options[:host] || 'mws.amazonservices.com'
    @merchant = options[:merchant]
    @access = options[:access]
    @secret = options[:secret]
    @conn = Faraday.new(url: "#{@scheme}://#{@host}") do | faraday |
      faraday.adapter Faraday.default_adapter
      faraday.headers = {
        'User-Agent' => 'MWS Client/0.0.1 (Language=Ruby)',
        'Accept-Encoding' => 'text/xml'
      }
      faraday.response :xml, content_type: /\bxml$/
    end
    @orders = Mws::Apis::Orders.new self
    @feeds = Mws::Apis::Feeds.new self
  end

  def get(endpoint, options, derive_list_ext=nil)
    request(:get, endpoint, nil, options, derive_list_ext)
  end

  def post(endpoint, body, options, derive_list_ext=nil)
    request(:post, endpoint, body, options, derive_list_ext)
  end

  private

  def request(method, endpoint, body, options, derive_list_ext)
    path = "/#{Mws::Utils.camelize endpoint}/#{options[:version]}"
    options[:merchant] ||= @merchant
    options[:access] ||= @access
    query = Mws::Query.new options, derive_list_ext
    signer = Mws::Signer.new method: method, host: @host, path: path, secret: @secret
    response = @conn.send(method, "#{path}?#{signer.sign query}") do | request |
      unless body.nil?
        request.headers['Content-Type'] = 'text/xml'
        req.body = body
      end
    end
    raise "#{response.code}:#{response.message}" if response.body.nil?
    error = response.body['ErrorResponse']
    raise "Type: #{error['Error']['Type']}, Message: #{error['Error']['Message']}" unless error.nil?
    response.body["#{options[:action]}Response"]["#{options[:action]}Result"]
  end

end
