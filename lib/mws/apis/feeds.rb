require 'hashie'

module Mws::Apis::Feeds

  autoload :Api, 'mws/apis/feeds/api'
  autoload :Feed, 'mws/apis/feeds/feed'
  autoload :ImageListing, 'mws/apis/feeds/image_listing'
  autoload :Inventory, 'mws/apis/feeds/inventory'
  autoload :MonetaryAmount, 'mws/apis/feeds/monetary_amount'
  autoload :PriceListing, 'mws/apis/feeds/price_listing'
  autoload :Product, 'mws/apis/feeds/product'
  autoload :SalePrice, 'mws/apis/feeds/sale_price'
  autoload :Shipping, 'mws/apis/feeds/shipping'
  autoload :SubmissionInfo, 'mws/apis/feeds/submission_info'
  autoload :SubmissionResult, 'mws/apis/feeds/submission_result'
  autoload :TargetedApi, 'mws/apis/feeds/api'
  autoload :Transaction, 'mws/apis/feeds/transaction'

end