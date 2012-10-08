require 'ostruct'

class Mws::Serializer

  def initialize(exceptions={})
    @exceptions = exceptions
  end

  def xml_for(data, builder, context=nil)
    data.each do | key, value |
      element = Mws::Utils.camelize(key)
      path = [ context, key ].compact.join '.'
      if @exceptions.include? path
        @exceptions[path].first.call(key, value, builder, path)
      elsif value.respond_to? :keys
        builder.send(element) { |b| xml_for(value, b, path) }
      elsif value.respond_to? :each
        value.each do | val |
          builder.send(element) { |b| xml_for(val, b, path)}
        end
      else
        builder.send element, value
      end
    end
  end

  def struct_for(doc)

  end

end
