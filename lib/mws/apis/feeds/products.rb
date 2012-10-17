class Mws::Apis::Feeds::Products

  def initialize(feeds_api, merchant)
    @feeds_api = feeds_api
    @merchant = merchant

    @product_serializer = Mws::Serializer.new do
      product {
        sku {
          to { | key, value, doc, path | doc.send(key.upcase, value) }
        }
        description_data.msrp {
          to { | key, value, doc, path | doc.send(key.upcase, value[:amount], currency: value[:currency]) }
        }
        product_data {
          ce {
            to { | key, value, doc, path |
              doc.send(key.upcase) do | builder |
                proceed(value, builder, path)
              end
            }
            product_type.cable_or_adapter.cable_length {
              to { | key, value, doc, path |
                doc.send(Mws::Utils.camelize(key), value[:length], unitOfMeasure: value[:unit_of_measure])
              }
            }
          }
        }
      }
    end
  end

  def add(products)
    products = [ products ].flatten
    product_serializer = @product_serializer
    feed = Mws::Apis::Feeds::Feed.new merchant: @merchant, message_type: :product do
      products.each do | product |
        message :update do | builder |
          product_serializer.xml_for 'product', product, builder
        end
      end
    end
    @feeds_api.submit(feed.xml_for, feed_type: :product, purge_and_replace: false).id
  end

end