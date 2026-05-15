module HuffmanBMP
  class FanoTree
    attr_reader :codes

    def initialize(freq_hash)
      @codes = {}
      sorted = freq_hash.sort_by { |byte, freq| [-freq, byte] }
      build_codes(sorted, '')
    end

    def encode(byte)
      @codes[byte]
    end

    private

    def build_codes(items, prefix)
      return if items.empty?

      if items.length == 1
        byte, = items.first
        @codes[byte] = prefix.empty? ? '0' : prefix
        return
      end

      split_index = best_split_index(items)
      left_items = items[0..split_index]
      right_items = items[(split_index + 1)..]

      build_codes(left_items, "#{prefix}0")
      build_codes(right_items, "#{prefix}1")
    end

    def best_split_index(items)
      total = items.sum { |_, freq| freq }
      left_sum = 0
      best_index = 0
      min_diff = nil

      (0...(items.length - 1)).each do |index|
        left_sum += items[index][1]
        right_sum = total - left_sum
        diff = (left_sum - right_sum).abs

        if min_diff.nil? || diff < min_diff
          min_diff = diff
          best_index = index
        end
      end

      best_index
    end
  end
end
