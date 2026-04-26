module HuffmanBMP
  module RGBSplitter
    # Разделяет BGR-строку на R, G, B
    def self.split(data)
      r = String.new(capacity: data.bytesize / 3)
      g = String.new(capacity: data.bytesize / 3)
      b = String.new(capacity: data.bytesize / 3)

      data.bytes.each_slice(3) do |blue_byte, green_byte, red_byte|
        r << red_byte
        g << green_byte
        b << blue_byte
      end

      [r, g, b]
    end

    # Сливает R, G, B в BGR-строку
    def self.merge(r, g, b)
      res = String.new(capacity: r.bytesize * 3)
      r.bytes.zip(g.bytes, b.bytes).each do |red, green, blue|
        res << blue << green << red
      end
      res
    end
  end
end