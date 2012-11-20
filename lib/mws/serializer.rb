require 'nokogiri'

module Mws

  class Serializer

    def self.tree(name, parent, &block)
      if parent
        parent.send(name, &block)
        parent.doc.root.to_xml
      else
        Nokogiri::XML::Builder.new do | xml |
          xml.send(name, &block)
        end.doc.root.to_xml
      end
    end

    def self.leaf(name, parent, value, attributes)
      if parent
        parent.send(name, value, attributes)
        parent.doc.root.to_xml
      else
        Nokogiri::XML::Builder.new do | xml |
          xml.send(name, value, attributes)
        end.doc.root.to_xml
      end
    end

    def initialize(exceptions={})
      @xml_exceptions = exceptions
      @hash_exceptions = {}
      exceptions.each do | key, value |
        @hash_exceptions[value.to_sym] = key
      end
    end

    def xml_for(name, data, builder, context=nil)
      element = @xml_exceptions[name.to_sym] || Utils.camelize(name)
      path = path_for name, context
      if data.respond_to? :keys
        builder.send(element) do | b |
          data.each do | key, value |
            xml_for(key, value, builder, path)
          end
        end
      elsif data.respond_to? :each
        data.each { |value| xml_for(name, value, builder, path) }
      elsif data.respond_to? :to_xml
        data.to_xml element, builder
      else
        builder.send element, data
      end
    end

    def hash_for(node, context)
      elements = node.elements()
      return node.text unless elements.size > 0
      res = {}
      elements.each do | element |
        name = @hash_exceptions[element.name.to_sym] || Utils.underscore(element.name).to_sym
        path = path_for name, context 
        content = instance_exec element, path, &method(:hash_for)
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

end
