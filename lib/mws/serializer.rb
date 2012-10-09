class Mws::Serializer

  def initialize(exceptions={})
    @exceptions = exceptions
  end

  def xml_for(name, data, builder, context=nil)
    element = Mws::Utils.camelize(name)
    path = path_for name, context
    exception = @exceptions[path]
    if exception
      exception.first.call(name, data, builder, path)
    else
      if data.respond_to? :keys
        builder.send(element) do | b |
          data.each do | key, value |
            xml_for(key, value, b, path)
          end
        end
      elsif data.respond_to? :each
        data.each { |value| xml_for(name, value, builder, path) }
      else
        builder.send element, data
      end
    end
  end

  def hash_for(node, context)
    elements = node.elements()
    return node.text unless elements.size > 0
    res = {}
    elements.each do | element |
      name = Mws::Utils.underscore(element.name).to_sym
      path = path_for name, context
      exception = @exceptions[path]
      delegate = exception ? exception.last : method(:hash_for)
      content = delegate.call element, path
      if res.include? name
        res[name] = [ res[name] ] unless res[name].instance_of? Array
        res[name] << content
      else
        res[name] = content
      end
    end
    res
  end

  private

  def path_for(name, context=nil)
    [ context, name ].compact.join '.'
  end

end
