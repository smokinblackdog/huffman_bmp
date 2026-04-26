module HuffmanBMP
  module BMPHandler
    HEADER_SIZE = 54

    # Читает заголовок и пиксельные данные из 24-битного BMP
    def self.read(filename)
      File.open(filename, 'rb') do |f|
        header = f.read(HEADER_SIZE)
        offset = header[10, 4].unpack1('V')
        f.seek(offset)
        body = f.read

        bits_per_pixel = header[28, 2].unpack1('v')
        raise "Только 24-битные BMP поддерживаются (получено #{bits_per_pixel} бит)" unless bits_per_pixel == 24

        [header, body]
      end
    end

    # Записывает BMP-файл
    def self.write(filename, header, body)
      File.open(filename, 'wb') do |f|
        f.write(header)
        f.write(body)
      end
    end
  end
end