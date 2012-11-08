module Mws::Apis::Feeds

  class Weight < Measurement

    Unit = Mws::Enum.for(
      grams: 'GR',
      kilograms: 'KG',
      ounces: 'OZ',
      pounds: 'LB',
      miligrams: 'MG'
    )

    def initialize(amount, unit=nil)
      super amount, unit || :pounds
    end

  end

end