module Mws::Apis::Feeds

  class Measurement

    attr_reader :amount

    Mws::Enum.sym_reader self, :unit

    def initialize(amount, unit)
      @amount = amount
      @unit = self.class.const_get(:Unit).for(unit)
      raise Mws::Errors::ValidationError, "Invalid unit of measure '#{unit}'" if @unit.nil?
      
    end

    def ==(other)
      return true if equal? other
      return false unless other.class == self.class
      amount == other.amount and unit == other.unit
    end

    def to_xml(name=nil, parent=nil)
      name ||= self.class.name.split('::').last
      amount = @amount 
      amount = '%.2f' % amount if amount.to_s =~ /\d*\.\d\d+/
      Mws::Serializer.leaf name, parent, amount, unitOfMeasure: @unit.val
    end

  end

end

