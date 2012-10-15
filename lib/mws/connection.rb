require 'uri'
require 'net/http'
require 'nokogiri'
require 'digest/md5'

class Mws::Connection

  attr_reader :orders, :feeds

  def initialize(overrides)
    @scheme = overrides[:scheme] || 'https'
    @host = overrides[:host] || 'mws.amazonservices.com'
    @merchant = overrides[:merchant]
    @access = overrides[:access]
    @secret = overrides[:secret]
    @orders = Mws::Apis::Orders.new self
    @feeds = Mws::Apis::Feeds::Api.new self
  end

  def get(path, params, overrides)
    request(:get, path, params, nil, overrides)
  end

  def post(path, params, body, overrides)
    request(:post, path, params, body, overrides)
  end

  private

  def request(method, path, params, body, overrides)
    query = Mws::Query.new({
      action: overrides[:action],
      version: overrides[:version],
      merchant: @merchant,
      access: @access,
      list_pattern: overrides[:list_pattern]
    }.merge(params))
    signer = Mws::Signer.new method: method, host: @host, path: path, secret: @secret
    parse response_for(method, path, signer.sign(query), body), overrides
  end

  def response_for(method, path, query, body)
    uri = URI("#{@scheme}://#{@host}#{path}?#{query}")
    req = Net::HTTP.const_get(method.to_s.capitalize).new (uri.request_uri)
    req['User-Agent'] = 'MWS Connect/0.0.1 (Language=Ruby)'
    req['Accept-Encoding'] = 'text/xml'
    if req.request_body_permitted? and body
      req.content_type = 'text/xml'
      req['Content-MD5'] = Digest::MD5.base64digest(body).strip
      req.body = body
    end
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do | http |
      http.request req
    end
    raise "Code: #{res.code}, Message: #{res.msg}" if res.body.nil?
    res.body
  end

  def parse(body, overrides)
    doc = Nokogiri::XML(body)
    doc.remove_namespaces!
    puts doc.to_xml
    puts "------------------------======----------------------------"
    doc.xpath('/ErrorResponse/Error').each do | error |
      message = []
      error.element_children.each { |node| message << "#{node.name}: #{node.text}" }
      raise message.join ", "
    end
    result = doc.xpath((overrides[:xpath] || '/%{action}Response/%{action}Result') % overrides ).first
    puts result
    result
  end

end
