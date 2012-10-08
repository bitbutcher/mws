require 'uri'
require 'net/http'
require 'xml'

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
    uri = URI("#{@scheme}://#{@host}#{path}?#{signer.sign query}")
    req = Net::HTTP.const_get(method.to_s.capitalize).new (uri.request_uri)
    req['User-Agent'] = 'MWS Client/0.0.1 (Language=Ruby)'
    req['Accept-Encoding'] = 'text/xml'
    if req.request_body_permitted? and body
      req.content_type = 'text/xml'
      req.body = body
    end
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do | http |
      http.request req do | res |
        case res
        when Net::HTTPSuccess, Net::HTTPBadRequest
          doc = Mws::Utils::pipe(
            ->(writer) {
              res.read_body { | chunk | writer.write chunk }
            }, 
            ->(reader) { XML::Parser.io(reader).parse }
          )
          doc.root.namespaces.default_prefix = 'mws'
          doc.find('/mws:ErrorResponse/mws:Error').each do | error |
          message = []
          error.each_element { |node| message << "#{node.name}: #{node.child}" }
            raise message.join ", "
          end
          return doc.find_first "mws:#{options[:action]}Result"
        else
          raise "Code: #{res.code}, Message :#{res.msg}"
        end
      end
    end
  end

end
