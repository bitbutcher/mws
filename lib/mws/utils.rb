# This module contains a collection of generally useful methods that (currently) have no better place to live. They can 
# either be referenced directly as module methods or be mixed in. 
module Mws::Utils
  extend self

  # This method will derive a camelized name from the provided underscored name.
  # 
  # @param [#to_s] name The underscored name to be camelized.
  # @param [Boolean] uc_first True if and only if the first letter of the resulting camelized name should be 
  #  capitalized.
  #
  # @return [String] The camelized name corresponding to the provided underscored name.
  def camelize(name, uc_first=true)
    parts = name.to_s.split '_'
    assemble = ->(head, tail) { head + tail.capitalize }
    uc_first ? parts.inject('', &assemble) : parts.inject(&assemble)
  end

  def uri_escape(value)
    value.gsub /([^a-zA-Z0-9_.~-]+)/ do | it |
      '%' + it.unpack('H2' * it.bytesize).join('%').upcase
    end
  end

  def pipe(with_writer, with_reader)
    reader, writer = IO.pipe
    fork do
      reader.close
      with_writer.call writer
      writer.close
    end
    writer.close
    res = with_reader.call reader
    Process.wait
    reader.close
    res
  end

end
