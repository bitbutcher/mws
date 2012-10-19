class Mws::Apis::Feeds::Products

  def initialize(feeds_api, merchant)
    @feeds_api = feeds_api
    @merchant = merchant

    @product_serializer = Mws::Serializer.new do
      product {
        standard_product_id {
          to { | key, value, doc, path | 
            doc.StandardProductID do | builder |
              proceed(value, builder, path)
            end
          }
        }
        sku {
          to { | key, value, doc, path | doc.SKU(value) }
        }
        description_data.msrp {
          to { | key, value, doc, path | doc.MSRP(value[:amount], currency: value[:currency]) }
        }
        product_data {
          ce {
            to { | key, value, doc, path |
              doc.CE do | builder |
                proceed(value, builder, path)
              end
            }
            product_type.cable_or_adapter.cable_length {
              to { | key, value, doc, path |
                doc.CableLength(value[:length], unitOfMeasure: value[:unit_of_measure])
              }
            }
          }
        }
      }
    end
  end

  def add(*products)
    product_serializer = @product_serializer
    feed = Mws::Apis::Feeds::Feed.new merchant: @merchant, message_type: :product do
      products.each do | product |
        message :update do | builder |
          product_serializer.xml_for 'product', product, builder
        end
      end
    end
    puts feed.xml_for
    @feeds_api.submit(feed.xml_for, feed_type: :product, purge_and_replace: false).id
  end

end