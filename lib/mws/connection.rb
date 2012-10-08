require 'uri'
require 'net/http'
require 'nokogiri'

class Mws::Connection

  attr_reader :orders, :feeds

  def initialize(options)
    @scheme = options[:scheme] || 'https'
    @host = options[:host] || 'mws.amazonservices.com'
    @merchant = options[:merchant]
    @access = options[:access]
    @secret = options[:secret]
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
    parse response_for(method, path, signer.sign(query), body), options[:action]
  end

  def response_for(method, path, query, body)
    uri = URI("#{@scheme}://#{@host}#{path}?#{query}")
    req = Net::HTTP.const_get(method.to_s.capitalize).new (uri.request_uri)
    req['User-Agent'] = 'MWS Connect/0.0.1 (Language=Ruby)'
    req['Accept-Encoding'] = 'text/xml'
    if req.request_body_permitted? and body
      req.content_type = 'text/xml'
      req.body = body
    end
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do | http |
      http.request req
    end
    raise "Code: #{res.code}, Message: #{res.msg}" if res.body.nil?
    res.body
  end

  def parse(body, action)
    doc = Nokogiri::XML(body)
    doc.xpath('/xmlns:ErrorResponse/xmlns:Error').each do | error |
      message = []
      error.element_children.each { |node| message << "#{node.name}: #{node.text}" }
      raise message.join ", "
    end
    doc.xpath("/xmlns:#{action}Response/xmlns:#{action}Result").first
  end

end
