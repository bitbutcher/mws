module Mws::Apis::Feeds

  class Measurement

    attr_reader :amount, :unit

    def initialize(amount, unit)
      @amount = amount
      @units = self.class.const_get(:Unit)
      raise ArgumentError.new("Invalid unit of measure '#{unit}'") if @units.for(unit).nil?
      @unit = unit
    end

    def ==(other)
      return true if equal? other
      return false unless other.class == self.class
      @amount == other.amount and @unit == other.unit
    end

    def to_xml(name=nil, parent=nil)
      name ||= self.class.name.split('::').last
      Mws::Serializer.leaf name, parent, @amount, unitOfMeasure: @units.for(@unit).val
    end

  end

end

