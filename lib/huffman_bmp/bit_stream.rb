module HuffmanBMP
  module BitStream
    # Упаковка битовой строки в байты
    def self.pack(bitstring)
      padding = (8 - bitstring.length % 8) % 8
      bitstring += '0' * padding
      bytes = bitstring.scan(/.{1,8}/).map { |b| b.to_i(2).chr }
      [bytes.join, padding] # [упакованные_байты, количество_добитых_нулей]
    end

    # Распаковка байтов в битовую строку с удалением паддинга
    def self.unpack(data, bit_length)
      bitstring = data.unpack1('B*')
      bitstring[0...bit_length]
    end
  end
end