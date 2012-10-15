module  Mws

  class Enum

    def self.for_hash(h)
      it = Enum.new(h)
      eigenclass = class << it
        self
      end
      h.each do | key, value |
        eigenclass.send(:define_method, key.to_s.upcase.to_sym) do
          it.entry_for key
        end 
      end
      it
    end

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

    def entry_for(it)
      @reverse[it]
    end

    def sym(str)
      entry_for(str).sym
    end

    def val(sym)
     entry_for(sym).val
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