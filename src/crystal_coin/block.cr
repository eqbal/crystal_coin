require "openssl"

module CrystalCoin
  class Block

    property current_hash : String

    def initialize(index = 0, data = "data", previous_hash = "hash")
      @data = data
      @index = index
      @timestamp = Time.now
      @previous_hash = previous_hash
      @current_hash = hash_block
    end

    def self.first(data="Genesis Block")
      Block.new(data: data, previous_hash: "0")
    end

    private def hash_block
      hash = OpenSSL::Digest.new("SHA256")
      hash.update("#{@index}#{@timestamp}#{@data}#{@previous_hash}")
      hash.hexdigest
    end
  end
end

puts CrystalCoin::Block.first.inspect
