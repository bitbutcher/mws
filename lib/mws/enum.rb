module  Mws

  class Enum

    private :initialize

    private_class_method :new

    def initialize(entries)
      @reverse = {}
      entries.each do | key, values |
        entry = EnumEntry.new(key, values)
        @reverse[key] = entry
        values = [ values ] unless values.respond_to? :each
        values.each do | value |
          @reverse[value] = entry
        end
      end
    end

    def for(it)
      @reverse[it]
    end

    def sym(str)
      entry_for(str).sym
    end

    def val(sym)
     entry_for(sym).val
    end

    def self.for(h)
      it = new(h)
      eigenclass = class << it
        self
      end
      h.each do | key, value |
        eigenclass.send(:define_method, key.to_s.upcase.to_sym) do
          it.for key
        end 
      end
      it
    end

  end

  class EnumEntry

    attr_reader :sym, :val

    def initialize(sym, val)
      @sym = sym
      @val = val
    end

  end

end