module  Mws

  class Enum

    private :initialize

    private_class_method :new

    def initialize(entries)
      @reverse = {}
      @entries = []
      entries.each do | key, values |
        entry = EnumEntry.new(key, values)
        @entries << entry
        @reverse[key] = entry
        values = [ values ] unless values.respond_to? :each
        values.each do | value |
          @reverse[value] = entry
        end
      end
    end

    def syms
      @entries.map { |it| it.sym }
    end

    def vals
      @entries.map { |it| it.val }.flatten
    end

    def for(it)
      return it if it.instance_of? EnumEntry 
      @reverse[it]
    end

    def sym(str)
      entry = self.for(str)
      entry && entry.sym
    end

    def val(sym)
      entry = self.for(sym)
      entry && entry.val
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

    def self.sym_reader(target, *attributes)
      attributes.each do | attribute |
        target.send(:define_method, attribute) do
          entry = send(:instance_variable_get, "@#{attribute}")
          entry && entry.sym
        end
      end
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