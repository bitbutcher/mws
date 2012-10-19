class Mws::Apis::Feeds::Prices

  def initialize(feeds_api, merchant)
    @feeds_api = feeds_api
    @merchant = merchant
  end

  def add(*prices)
    feed = Mws::Apis::Feeds::Feed.new merchant: @merchant, message_type: :price do
      prices.each do | price |
        message :update do | builder |
          price.to_xml 'Price', builder
        end
      end
    end
    puts feed.xml_for
    @feeds_api.submit(feed.xml_for, feed_type: :product_pricing, purge_and_replace: false).id
  end

end