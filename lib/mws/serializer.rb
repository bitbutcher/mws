module Mws

  class Serializer

    def initialize(exceptions={}, &block)
      @exceptions = exceptions
      if block_given?
        builder = ExceptionBuilder.new(@exceptions)
        builder.instance_exec &block
      end
    end

    def proceed(data, builder, path)
      data.each do | key, value |
        xml_for(key, value, builder, path)
      end
    end

    def xml_for(name, data, builder, context=nil)
      element = Mws::Utils.camelize(name)
      path = path_for name, context
      exception = @exceptions[path]
      if exception and exception.include? :to
        instance_exec name, data, builder, path, &exception[:to]      
      else
        if data.respond_to? :keys
          builder.send(element) do | b |
            proceed(data, b, path)
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
        delegate = (exception and exception.include?(:from)) ? exception[:from] : method(:hash_for)
        content = instance_exec element, path, &delegate
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

  class ExceptionBuilder

    attr_reader :context

    def initialize(exceptions={}, context=nil, &block)
      @exceptions = exceptions
      @context = context
    end

    def to(&block)
      _exception[:to] = block
    end

    def from(&block)
      _exception[:from] = block
    end

    def method_missing(method, *args, &block)
      builder = self.class.new @exceptions, [ @context, method ].compact.join('.')
      return builder unless block_given?
      builder.instance_exec &block
    end

    private

    def _exception
      @exceptions[@context] ||= {}
    end

  end

end
