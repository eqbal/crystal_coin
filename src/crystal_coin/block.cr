require "openssl"

module CrystalCoin
  class Block

    def initialize(index = 1, data = "data", previous_hash = "hash")
      @data = data
      @index = index
      @timestamp = Time.now
      @previous_hash = previous_hash
    end

    def hash
      hash = OpenSSL::Digest.new("SHA256")
      hash.update("#{@index}#{@timestamp}#{@data}#{@previous_hash}")
      hash.hexdigest
    end
  end
end

puts CrystalCoin::Block.new(data: "Same Data").hash
