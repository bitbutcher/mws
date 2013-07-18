require 'uri'
require 'net/http'
require 'digest/md5'
require 'logging'
require 'nokogiri'

module Mws

  class Connection

    attr_reader :merchant, :orders, :feeds

    def initialize(overrides)
      @log = Logging.logger[self]
      @scheme = overrides[:scheme] || 'https'
      @host = overrides[:host] || 'mws.amazonservices.com'
      @merchant = overrides[:merchant]
      raise Mws::Errors::ValidationError, 'A merchant identifier must be specified.' if @merchant.nil?
      @access = overrides[:access]
      raise Mws::Errors::ValidationError, 'An access key must be specified.' if @access.nil?
      @secret = overrides[:secret]
      raise Mws::Errors::ValidationError, 'A secret key must be specified.' if @secret.nil?
      @orders = Apis::Orders.new self
      @feeds = Apis::Feeds::Api.new self
    end

    def get(path, params, overrides)
      request(:get, path, params, nil, overrides)
    end

    def post(path, params, body, overrides)
      request(:post, path, params, body, overrides)
    end

    private

    def request(method, path, params, body, overrides)
      query = Query.new({
        action: overrides[:action],
        version: overrides[:version],
        merchant: @merchant,
        access: @access,
        list_pattern: overrides.delete(:list_pattern)
      }.merge(params))
      signer = Signer.new method: method, host: @host, path: path, secret: @secret
      parse response_for(method, path, signer.sign(query), body), overrides
    end

    def response_for(method, path, query, body)
      uri = URI("#{@scheme}://#{@host}#{path}?#{query}")
      @log.debug "Request URI:\n#{uri}\n"
      req = Net::HTTP.const_get(method.to_s.capitalize).new (uri.request_uri)
      req['User-Agent'] = 'MWS Connect/0.0.1 (Language=Ruby)'
      req['Accept-Encoding'] = 'text/xml'
      if req.request_body_permitted? and body
        @log.debug "Body:\n#{body}"
        req.content_type = 'text/xml'
        req['Content-MD5'] = Digest::MD5.base64digest(body).strip
        @log.debug "Hash:\n#{req['Content-MD5']}\n"
        req.body = body
      end
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do | http |
        http.request req
      end
      raise Errors::ServerError.new(code: res.code, message: res.msg) if res.body.nil?
      @log.debug "Response Body:\n#{res.body}\n"
      res.body
    end

    def parse(body, overrides)
      doc = Nokogiri::XML(body)
      doc.remove_namespaces!
      doc.xpath('/ErrorResponse/Error').each do | error |
        options = {}
        error.element_children.each { |node| options[node.name.downcase.to_sym] = node.text }
        raise Errors::ServerError.new(options)
      end
      result = doc.xpath((overrides[:xpath] || '/%{action}Response/%{action}Result') % overrides ).first
      result
    end

  end

end