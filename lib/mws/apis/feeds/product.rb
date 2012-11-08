module Mws::Apis::Feeds

  class Product

    CategorySerializer = Mws::Serializer.new ce: 'CE', fba: 'FBA', eu_compliance: 'EUCompliance'

    attr_reader :sku, :description

    attr_accessor :upc, :tax_code, :msrp, :brand, :manufacturer, :name, :description, :bullet_points
    attr_accessor :item_dimensions, :package_dimensions, :package_weight, :shipping_weight
    attr_accessor :category, :details

    def initialize(sku, &block)
      @sku = sku
      @bullet_points = []
      ProductBuilder.new(self).instance_eval &block if block_given?
      raise ArgumentError, 'Product must have a category when details are specified.' if @details and @category.nil?
    end

    def to_xml(name='Product', parent=nil)
      Mws::Serializer.tree name, parent do |xml|
        xml.SKU @sku
        xml.StandardProductID {
          xml.Type 'UPC'
          xml.Value @upc
        } unless @upc.nil?
        xml.ProductTaxCode @tax_code unless @upc.nil?
        xml.DescriptionData {
          xml.Title @name unless @name.nil?
          xml.Brand @brand  unless @brand.nil?
          xml.Description @description  unless @description.nil?
          bullet_points.each do | bullet_point |
            xml.BulletPoint bullet_point
          end
          @item_dimensions.to_xml('ItemDimensions', xml) unless @item_dimensions.nil?
          @package_dimensions.to_xml('PackageDimensions', xml) unless @item_dimensions.nil?

          @package_weight.to_xml('PackageWeight', xml) unless @package_weight.nil?
          @shipping_weight.to_xml('ShippingWeight', xml) unless @shipping_weight.nil?

          @msrp.to_xml 'MSRP', xml unless @msrp.nil?

          xml.Manufacturer @manufacturer unless @manufacturer.nil?
        }

        unless @details.nil?
          xml.ProductData {
            CategorySerializer.xml_for @category, {product_type: @details}, xml
          }
        end
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
        @product.msrp = Mws::Apis::Feeds::Money.new amount, currency
      end

      def item_dimensions(&block)
        @product.item_dimensions = Dimensions.new
        DimensionsBuilder.new(@product.item_dimensions).instance_eval &block if block_given?
      end

      def package_dimensions(&block)
        @product.package_dimensions = Dimensions.new
        DimensionsBuilder.new(@product.package_dimensions).instance_eval &block if block_given?
      end

      def package_weight(value, unit=nil)
        @product.package_weight = Mws::Apis::Feeds::Weight.new(value, unit)
      end

      def shipping_weight(value, unit=nil)
        @product.shipping_weight = Mws::Apis::Feeds::Weight.new(value, unit)
      end

      def bullet_point(bullet_point)
        @product.bullet_points << bullet_point
      end

      def details(details=nil, &block)
        @product.details = details || {}
        DetailBuilder.new(@product.details).instance_eval &block if block_given?
      end

    end

    class Dimensions

      attr_accessor :length, :width, :height, :weight

      def to_xml(name='Dimensions', parent=nil)
        Mws::Serializer.tree name, parent do |xml|
          @length.to_xml 'Length', xml unless @length.nil?
          @width.to_xml 'Width', xml unless @width.nil?
          @height.to_xml 'Height', xml unless @height.nil?
          @weight.to_xml 'Weight', xml unless @weight.nil?
        end
      end

    end

    class DimensionsBuilder

      def initialize(dimensions)
        @dimensions = dimensions
      end

      def length(value, unit=nil)
        @dimensions.length = Mws::Apis::Feeds::Distance.new(value, unit)
      end

      def width(value, unit=nil)
        @dimensions.width = Mws::Apis::Feeds::Distance.new(value, unit)
      end

      def height(value, unit=nil)
        @dimensions.height = Mws::Apis::Feeds::Distance.new(value, unit)
      end

      def weight(value, unit=nil)
        @dimensions.weight = Mws::Apis::Feeds::Weight.new(value, unit)
      end
    end

    class DetailBuilder

      def initialize(details)
        @details = details
      end

      def as_distance(amount, unit=nil)
        Mws::Apis::Feeds::Distance.new amount, unit
      end

      def as_weight(amount, unit=nil)
        Mws::Apis::Feeds::Weight.new amount, unit
      end

      def as_money(amount, currency=nil)
        Mws::Apis::Feeds::Money.new amount, currency
      end            

      def method_missing(method, *args, &block)
        if block_given?
          @details[method] = {}
          DetailBuilder.new(@details[method]).instance_eval(&block)
        elsif args.length > 0
          @details[method] = args[0]
        end
      end

    end

  end
end
