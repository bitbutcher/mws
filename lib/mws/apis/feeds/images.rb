class Mws::Apis::Feeds::Images

  def initialize(feeds_api, merchant)
    @feeds_api = feeds_api
    @merchant = merchant
  end

  def add(*images)
    feed = Mws::Apis::Feeds::Feed.new merchant: @merchant, message_type: :product_image do
      images.each do | image |
        message :update do | builder |
          image.to_xml 'ProductImage', builder
        end
      end
    end
    puts feed.xml_for
    @feeds_api.submit(feed.xml_for, feed_type: :product_image, purge_and_replace: true).id
  end

end