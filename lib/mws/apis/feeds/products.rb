class Mws::Apis::Feeds::Products

  def initialize(feeds_api, merchant)
    @feeds_api = feeds_api
    @merchant = merchant
  end

  def add(*products)
    feed = Mws::Apis::Feeds::Feed.new merchant: @merchant, message_type: :product do
      products.each do | product |
        message :update do | builder |
          product.to_xml('Product', builder)
        end
      end
    end
    @feeds_api.submit(feed.xml_for, feed_type: :product, purge_and_replace: false).id
  end

end