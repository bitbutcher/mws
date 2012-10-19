class Mws::Apis::Feeds::Product

  LengthUnit = Mws::Enum.for(
    inches: 'inches',
    feet: 'feet',
    meters: 'meters',
    decimeters: 'decimeters',
    centimeters:'centimeters',
    millimeters:'millimeters',
    micrometers: 'micrometers',
    nanometers: 'nanometers',
    picometers: 'picometers'
  )

  WeightUnit = Mws::Enum.for(
    grams: 'GR',
    kilograms: 'KG',
    ounces: 'OZ',
    pounds: 'LB',
    miligrams: 'MG'
  )

  attr_reader :sku, :description

  attr_accessor :upc, :tax_code, :msrp, :brand, :name, :description, :bullet_points
  attr_accessor :item_dimensions, :package_dimensions, :package_weight, :shipping_weight

  def initialize(sku, &block)
    @sku = sku
    @bullet_points = []
    ProductBuilder.new(self).instance_eval &block if block_given?
  end

  def to_xml(name='Product', parent=nil)
    block = lambda { |xml| 
      xml.SKU @sku
      xml.StandardProductID {
        xml.Type 'UPC'
        xml.Value @upc
      } 
      xml.ProductTaxCode @tax_code
      xml.DescriptionData {
        xml.Title @name
        xml.Brand @brand   
        xml.Description @description
        bullet_points.each do | bullet_point |
          xml.BulletPoint bullet_point
        end
        @item_dimensions.to_xml('ItemDimensions', xml) unless @item_dimensions.nil?
        @package_dimensions.to_xml('PackageDimensions', xml) unless @item_dimensions.nil?

        @package_weight.to_xml('PackageWeight', xml) unless @package_weight.nil?
        @shipping_weight.to_xml('ShippingWeight', xml) unless @shipping_weight.nil?

        xml.MSRP(@msrp.amount, currency: @msrp.currency) unless @msrp.nil?
      }
    }
    if parent
      parent.send(name, &block)
      parent.to_xml
    else
      Nokogiri::XML::Builder.new do | xml |
        xml.send(name, &block)
      end.to_xml
    end
  end

  class DelegatingBuilder

    def initialize(delegate)
      @delegate = delegate
    end

    def method_missing(method, *args, &block)
      @delegate.send("#{method}=", *args, &block) if @delegate.respond_to? "#{method}="
    end
  end

  class ProductBuilder < DelegatingBuilder

    def initialize(product)
      super product
      @product = product
    end

    def msrp(amount, currency)
      @product.msrp = Mws::Apis::Feeds::Price.new amount, currency
    end

    def item_dimensions(&block)
      @product.item_dimensions = Dimensions.new
      DimensionsBuilder.new(@product.item_dimensions).instance_eval &block if block_given?
    end

    def package_dimensions(&block)
      @product.package_dimensions = Dimensions.new
      DimensionsBuilder.new(@product.package_dimensions).instance_eval &block if block_given?
    end  

    def package_weight(value, unit)
      @product.package_weight = Dimension.new value, Dimension.require_valid_weight_unit(unit)
    end

    def shipping_weight(value, unit)
      @product.shipping_weight = Dimension.new value, Dimension.require_valid_weight_unit(unit)
    end

    def bullet_point(bullet_point)
      @product.bullet_points << bullet_point
    end  

  end

  class Dimensions
    
    attr_accessor :length, :width, :height, :weight

    def to_xml(name='Dimensions', parent=nil)
      block = lambda { |xml| 
        @length.to_xml 'Length', xml unless @length.nil?
        @width.to_xml 'Width', xml unless @width.nil?
        @height.to_xml 'Height', xml unless @height.nil?
        @weight.to_xml 'Weight', xml unless @weight.nil?
      }
      if parent
        parent.send(name, &block)
        parent.to_xml
      else
        Nokogiri::XML::Builder.new do | xml |
          xml.send(name, &block)
        end.to_xml
      end
    end

  end

  class Dimension

    attr_reader :value

    def initialize(value, unit)
      @unit = unit
      @value = value
    end

    def unit 
      @unit.sym
    end

    def to_xml(name='Dimension', parent=nil)
      if parent
        parent.send name, @value, unitOfMeasure: @unit.val
        parent.to_xml
      else
        Nokogiri::XML::Builder.new do | xml |
          xml.send name, @value, unitOfMeasure: @unit.val
        end.to_xml
      end
    end

    def self.require_valid_length_unit(unit)
      raise ArgumentError, "Not a valid unit of length - #{unit}" if LengthUnit.for(unit).nil?
      LengthUnit.for(unit)
    end
    
    def self.require_valid_weight_unit(unit)
      raise ArgumentError, "Not a valid unit of weight - #{unit}" if WeightUnit.for(unit).nil?
      WeightUnit.for(unit)
    end

  end

  class DimensionsBuilder 

    def initialize(dimensions)
      @dimensions = dimensions
    end

    def length(value, unit)
      @dimensions.length = Dimension.new value, Dimension.require_valid_length_unit(unit)
    end

    def width(value, unit)
      @dimensions.width = Dimension.new value, Dimension.require_valid_length_unit(unit)
    end

    def height(value, unit)
      @dimensions.height = Dimension.new value, Dimension.require_valid_length_unit(unit)
    end

    def weight(value, unit)
      @dimensions.weight = Dimension.new value, Dimension.require_valid_weight_unit(unit)
    end    
  end

end