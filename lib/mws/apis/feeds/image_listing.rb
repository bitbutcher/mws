require 'open-uri'

module Mws::Apis::Feeds

  class ImageListing

    Type = Mws::Enum.for(
      main: 'Main',
      alt1: 'PT1',
      alt2: 'PT2',
      alt3: 'PT3',
      alt4: 'PT4',
      alt5: 'PT5'
    )

    attr_reader :sku, :url

    Mws::Enum.sym_reader self, :type

    def initialize(sku, url, type=nil)
      raise Mws::Errors::ValidationError, 'SKU is required.' if sku.nil? or sku.strip.empty?
      @sku = sku
      raise Mws::Errors::ValidationError, 'URL must be an unsecured http address.' unless url =~ URI::regexp('http')
      @url = url
      @type = Type.for(type) || Type.MAIN
    end

    def ==(other)
      return true if equal? other
      return false unless other.class == self.class
      sku == other.sku and url == other.url and type == other.type
    end

    def to_xml(name='ProductImage', parent=nil)
      Mws::Serializer.tree name, parent do | xml | 
        xml.SKU @sku
        xml.ImageType @type.val
        xml.ImageLocation @url
      end
    end

  end

end