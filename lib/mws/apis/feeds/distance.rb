module Mws::Apis::Feeds

  class Distance < Measurement

    Unit = Mws::Enum.for(
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

    def initialize(amount, unit=:feet)
      super amount, unit
    end

  end

end