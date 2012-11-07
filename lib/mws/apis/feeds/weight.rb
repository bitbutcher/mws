module Mws::Apis::Feeds

  class Weight < Measurement

    Unit = Mws::Enum.for(
      grams: 'GR',
      kilograms: 'KG',
      ounces: 'OZ',
      pounds: 'LB',
      miligrams: 'MG'
    )

    def initialize(amount, unit=:pounds)
      super amount, unit
    end

  end

end