require 'nokogiri'

module Mws::Apis::Feeds

  class ImageListing

    attr_reader :sku, :type, :url

    def initialize(sku, url, type='Main')
      @sku = sku
      @url = url
      @type = type
    end

    def ==(other)
      return true if equal? other
      return false unless other.class == self.class
      @sku == other.sku and @url == other.url and @type == other.type
    end

    def to_xml(name='ProductImage', parent=nil)
      Mws::Serializer.tree name, parent do  |xml| 
        xml.SKU @sku
        xml.ImageType @type
        xml.ImageLocation @url
      end
    end

  end

end