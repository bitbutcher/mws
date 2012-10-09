require 'xml'

class Mws::Serializer

  def initialize(exceptions={})
    @exceptions = exceptions
  end

  def xml_for(data, parent, context=nil)
    data.each do | key, value |
      element = Mws::Utils.camelize(key)
      path = [ context, key ].compact.join '.'
      if @exceptions.include? path
        @exceptions[path].first.call(key, value, parent, path)
      elsif value.respond_to? :keys
        xml_for value, create_element(parent, element), path
      elsif value.respond_to? :each
        value.each do | val |
          if val.respond_to? :keys
            xml_for val, create_element(parent, element), path
          else
            create_text_element parent, element, val
          end
        end
      else
        create_text_element parent, element, value
      end
    end
  end

  def hash_for(node)
    xml_node_to_hash(node)
  end

  private
  
  def xml_node_to_hash(node, context=nil) 
    if node.element?
      if node.children? 
        result_hash = {} 
        node.each do | child | 
          key = Mws::Utils.underscore(child.name).to_sym
          path = [ context, key ].compact.join '.'
          unless @exceptions.include? path
            result = xml_node_to_hash child, path
          else
            result = @exceptions[path].last.call(key, child)
          end
          if key == :text
            if !child.next? and !child.prev?
              return result
            end
          elsif result_hash[key]
            if result_hash[key].is_a?(Object::Array)
              result_hash[key] << result
            else
              result_hash[key] = [result_hash[key]] << result
            end
          else 
            result_hash[key] = result
          end
        end
        return result_hash
      else
        return nil;  
      end
    else
      return node.content.to_s 
    end
  end  

  def create_element(parent, name)
    node = XML::Node.new name
    parent << node
    node
  end

  def create_text_element(parent, name, value)
    node = XML::Node.new name
    parent << node
    node << value
    node
  end        
  
end
