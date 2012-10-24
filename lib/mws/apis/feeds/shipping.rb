require 'nokogiri'

class Mws::Apis::Feeds::Shipping

  attr_reader :sku

  def initialize(sku, &block)
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
    block = lambda { |xml|
      xml.SKU @sku
      @options.each { |option| option.to_xml 'ShippingOverride', xml }
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

  class Option

    attr_reader :label

    def initialize(label)
      @label = label
    end

  end

  class Restriction < Option

    attr_reader :restricted

    def initialize(label, restricted=true)
      super(label)
      @restricted = restricted
    end

    def to_xml(name='ShippingOverride', parent=nil)
      block = lambda { |xml|
        xml.ShipOption @label
        xml.IsShippingRestricted @restricted
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

  class Override < Option

    Type = Mws::Enum.for adjust: 'Additive', replace: 'Exclusive'

    attr_reader :type, :amount

    def initialize(label, type, amount)
      super(label)
      @type = Type.for(type)
      @amount = amount
    end

    def to_xml(name='ShippingOverride', parent=nil)
      block = lambda { |xml|
        xml.ShipOption @label
        xml.Type @type.val
        @amount.to_xml 'ShipAmount', xml
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

  class Builder

    @target

    def initialize(target)
      @target = target
    end

    def restriction(label, restricted)
      @target << Restriction.new(label, restricted)
    end

    def restricted(label)
      restriction label, true
    end

    def unrestricted(label)
      restriction label, false
    end

    def override(label, type, amount, currency=nil)
      @target << Override.new(label, type, Mws::Apis::Feeds::Price.new(amount, currency))
    end

    def adjust(label, amount, currency=nil)
      override label, :adjust, amount, currency
    end

    def replace(label, amount, currency=nil)
      override label, :replace, amount, currency
    end

  end

end