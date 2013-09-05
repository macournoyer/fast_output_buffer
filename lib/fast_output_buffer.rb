require "fast_output_buffer/version"

class FastSafeBuffer
  class SafeConcatError < StandardError
    def initialize
      super 'Could not concatenate to the buffer because it is not html safe.'
    end
  end

  def initialize(buffer=nil)
    concat buffer if buffer
  end

  def to_s
    to_str
  end

  def to_param
    to_str
  end

  def clone_empty
    self.class.new
  end

  def encode_with(coder)
    coder.represent_scalar nil, to_str
  end

  def force_encoding(encoding)
    encoding = Encoding.find(encoding)
    raise EncodingError.new("buffer only supports UTF-8 encoding") unless encoding == Encoding::UTF_8
    self
  end

  def encoding
    Encoding::UTF_8
  end

  def encode!
    # noop
    self
  end
end

require "fast_output_buffer_ext"
require "fast_output_buffer/railtie"