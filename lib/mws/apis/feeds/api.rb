module Mws::Apis::Feeds

  class Api

    attr_accessor :products, :images, :prices, :inventory, :shipping

    def initialize(connection, defaults={})
      @connection = connection
      defaults[:version] ||= '2009-01-01'
      @defaults = defaults
      
      @products = TargetedApi.new self, defaults[:merchant], :product
      @images = TargetedApi.new self, defaults[:merchant], :image
      @prices = TargetedApi.new self, defaults[:merchant], :price
      @shipping = TargetedApi.new self, defaults[:merchant], :override
      @inventory = TargetedApi.new self, defaults[:merchant], :inventory
    end

    def get(id)
      node = @connection.get('/', { feed_submission_id: id }, @defaults.merge(
        action: 'GetFeedSubmissionResult',
        xpath: 'AmazonEnvelope/Message'
      ))
      SubmissionResult.from_xml node
    end

    def submit(body, params)
      params[:feed_type] = Mws::Apis::Feeds::Feed::Type.for(params[:feed_type]).val
      doc = @connection.post('/', params, body, @defaults.merge( action: 'SubmitFeed'))
      SubmissionInfo.from_xml doc.xpath('FeedSubmissionInfo').first
    end

    def cancel(options={})

    end

    def list(params={})
      params[:feed_submission_id] ||= params.delete(:ids) || [ params.delete(:id) ].flatten.compact
      doc = @connection.get('/', params, @defaults.merge(action: 'GetFeedSubmissionList'))
      doc.xpath('FeedSubmissionInfo').map do | node |
        SubmissionInfo.from_xml node
      end
    end

    def count()
      @connection.get('/', {}, @defaults.merge(action: 'GetFeedSubmissionCount')).xpath('Count').first.text.to_i
    end

  end

  class TargetedApi

    def initialize(feeds, merchant, type)
      @feeds = feeds
      @merchant = merchant
      @message_type = Feed::MessageType.for(type)
      @feed_type = Feed::Type.for(type)
    end

    def add(*resources)
      submit :update, true, *resources
    end

    def update(*resources)      submit :update, false, *resources
    end

    def patch(*resources)
      raise 'Operation Type not supported.' unless @feed_type == Feed::Type.PRODUCT
      submit :partial_update, false, *resources
    end

    def delete(*resources)
      submit :delete, false, *resources
    end

    def submit(operation_type, purge_and_replace, *resources)
      root = @message_type.val
      messages = []
      feed = Feed.new merchant: @merchant, message_type: @message_type do
        resources.each do | resource |
          messages << message(resource.sku, operation_type) do | builder |
            resource.to_xml root, builder
          end
        end
      end
      Transaction.new @feeds.submit(feed.xml_for, feed_type: @feed_type, purge_and_replace: purge_and_replace) do 
        messages.each_with_index do | message, index |
          resource = resources[index]
          item message.id, message.sku, message.operation_type, resource.respond_to?(:type) ? resource.type : nil
        end
      end
    end

  end

end