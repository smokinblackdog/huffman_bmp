module HuffmanBMP
  class HuffNode
    attr_accessor :byte, :freq, :left, :right

    def initialize(byte:, freq:, left: nil, right: nil)
      @byte = byte # = nil для внутренних узлов
      @freq = freq
      @left = left
      @right = right
    end

    def leaf?
      !@byte.nil?
    end
  end
end