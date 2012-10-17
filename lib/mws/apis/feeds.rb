require 'hashie'

module Mws::Apis::Feeds

  autoload :Api, 'mws/apis/feeds/api'
  autoload :Price, 'mws/apis/feeds/price'
  autoload :PriceListing, 'mws/apis/feeds/price_listing'
  autoload :Products, 'mws/apis/feeds/products'
  autoload :Feed, 'mws/apis/feeds/feed'
  autoload :SalePrice, 'mws/apis/feeds/sale_price'
  autoload :SubmissionInfo, 'mws/apis/feeds/submission_info'
  autoload :SubmissionResult, 'mws/apis/feeds/submission_result'

end