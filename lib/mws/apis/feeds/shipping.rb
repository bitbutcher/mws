require 'nokogiri'

class Mws::Apis::Feeds::Shipping

  Region = Mws::Enum.for(
    continental_us: 'Cont US',
    us_protectorates: 'US Prot',
    alaska_hawaii: 'Alaska Hawaii',
    apo_fpo: 'APO/FPO',
    canada: 'Canada',
    europe: 'Europe',
    asia: 'Asia',
    other: 'Outside US, EU, CA, Asia'
  )

  Variant = Mws::Enum.for(
    street: 'Street Addr', 
    po_box: 'PO Box'
  )

  Speed = Mws::Enum.for(
    standard: 'Std',
    expedited: 'Exp',
    two_day: 'Second',
    one_day: 'Next'
  )

  attr_reader :sku

  def initialize(sku, &block)
    raise Mws::Errors::ValidationError.new('SKU is required.') if sku.nil? or sku.to_s.strip.empty?
    @sku = sku
    @options = []
    Builder.new(self).instance_eval &block if block_given?
  end

  def options
    @options.dup
  end

  def <<(option)
    @options << option
  end

  def to_xml(name='Override', parent=nil)
    Mws::Serializer.tree name, parent do |xml|
      xml.SKU @sku
      @options.each { |option| option.to_xml 'ShippingOverride', xml }
    end
  end

  class Option

    attr_reader :region, :speed, :variant

    def initialize(region, speed=Speed.STANDARD, variant=nil)
      @region = Region.for(region)
      @speed = Speed.for(speed)
      @variant = nil
      if supports_variant?
        @variant = Variant.for(variant) || Variant.STREET
      end
    end

    def supports_variant?
      [ Region.CONTINENTAL_US, Region.US_PROTECTORATES, Region.ALASKA_HAWAII, Region.APO_FPO ].include? @region
    end

    def to_s
      return @speed.val if [ Speed.TWO_DAY, Speed.ONE_DAY ].include? @speed
      [ @speed, @region, @variant ].compact.map { |it| it.val }.join ' '
    end

  end

  class Restriction

    attr_reader :option, :restricted

    def initialize(option, restricted=true)
      @option = option
      @restricted = restricted
    end

    def to_xml(name='ShippingOverride', parent=nil)
      Mws::Serializer.tree name, parent do |xml|
        xml.ShipOption @option
        xml.IsShippingRestricted @restricted
      end
    end

  end

  class Override

    Type = Mws::Enum.for(
      adjust: 'Additive', 
      replace: 'Exclusive'
    )

    attr_reader :option, :type, :amount

    def initialize(option, type, amount)
      @option = option
      @type = Type.for(type)
      @amount = amount
    end

    def to_xml(name='ShippingOverride', parent=nil)
      Mws::Serializer.tree name, parent do |xml|
        xml.ShipOption @option
        xml.Type @type.val
        @amount.to_xml 'ShipAmount', xml
      end
    end

  end

  class Builder

    @target

    def initialize(target)
      @target = target
    end

    def restriction(restricted, region, speed, variant)
      @target << Restriction.new(Option.new(region, speed, variant), restricted)
    end

    def restricted(region, speed, variant=nil)
      restriction true, region, speed, variant
    end

    def unrestricted(region, speed, variant=nil)
      restriction false, region, speed, variant
    end

    def override(type, amount, currency, region, speed, variant)
      @target << Override.new(Option.new(region, speed, variant), type, 
        Mws::Apis::Feeds::Money.new(amount, currency))
    end

    def adjust(amount, currency, region, speed, variant=nil)
      override :adjust, amount, currency, region, speed, variant
    end

    def replace(amount, currency, region, speed, variant=nil)
      override :replace, amount, currency, region, speed, variant
    end

  end

end