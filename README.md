# Mws

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'mws'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mws

## Usage

Create Mws connection:

    require 'mws'

    mws = Mws.connect(
      merchant: 'XXXXXXXXXXXXXX', 
      access: 'XXXXXXXXXXXXXXXXXXXXX', 
      secret: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    )

Access the Feeds Api:

    feeds_api = mws.feeds

Access the Feeds Api wrappers:

    products_api = mws.feeds.products
    prices_api = mws.feeds.prices
    images_api = mws.feeds.images
    inventory_api = mws.feeds.inventory

Example: Add product details:

    sku = '12345678'
    product = Mws::Apis::Feeds::Product.new sku {
      upc '123435566654'
      tax_code 'GEN_TAX_CODE'
      name 'Some Product'
      brand 'Some Brand'
      msrp 19.99, 'USD'
      manufacturer 'Some Manufacturer'
      category :ce
      details {
        cable_or_adapter {
          cable_length {
            length 5
            unit_of_measure :feet
          }
        }
      }
    }

    submission_id = mws.feeds.products.add(product)

Example: Adding product images:

    image_submission_id = mws.feeds.images.add(
      Mws::Apis::Feeds::ImageListing.new(sku, 'http://url.to.product.iamges/main.jpg', 'Main'),
      Mws::Apis::Feeds::ImageListing.new(sku, 'http://url.to.product.iamges/pt1.jpg', 'PT1')
    )

Example: Setting product pricing: 

    price_submission_id = mws.feeds.prices.add(
      Mws::Apis::Feeds::PriceListing.new(sku, 14.99).on_sale(12.99, Time.now, 3.months.from_now)
    )

Example: Overriding product shipping:

    sku = '12345678'
    shipping_submission_id = mws.feeds.shipping.add(
      Mws::Apis::Feeds::Shipping.new sku {
        replace 'UPS Ground', 4.99
        adjust '2nd-Day Air', 7.00
      }
    )

Example: Setting product inventory:

    inventory_submission_id = mws.feeds.inventory.add(
        Mws::Apis::Feeds::Inventory.new(sku, quantity: 10, fulfillment_type: :mfn)
    )

Example: Check the processing status of a feed:

    mws.feeds.list(id: submission_id).each do | info |
      puts "SubmissionId: #{info.id} Status: #{info.status}"
      puts "Complete!" if [:cancelled, :done].include? info.status
    end

Example: Get the results for a submission:

    result = mws.feeds.get(submission_id)
    puts "Submission: #{result.transaction_id} - #{result.status}"

_For an example of putting it all together check out the 'scripts/catalog-workflow'_

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
