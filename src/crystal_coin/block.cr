require "./proof_of_work"

module CrystalCoin
  class Block

    property current_hash : (String | Int32)
    property index : Int32
    property nonce : (Int32 | String)
    property timestamp : Time
    property data : String
    property previous_hash : (String | Int32)

    def initialize(index = 0, data = "data", previous_hash = "hash")
      @data = data
      @index = index
      @timestamp = Time.now
      @previous_hash = previous_hash
      @nonce = 1
      @current_hash = "current"
      @nonce, @current_hash = ProofOfWork.new(self).run
    end

    def self.first(data = "Genesis Block")
      Block.new(data: data, previous_hash: "0")
    end

    def self.next(previous_block, data = "Transaction Data")
      Block.new(
        data: "Transaction data number (#{previous_block.index + 1})",
        index: previous_block.index + 1,
        previous_hash: previous_block.current_hash
      )
    end
  end
end

blockchain = [ CrystalCoin::Block.first ]
puts blockchain.inspect
previous_block = blockchain[0]

5.times do |i|
  new_block  = CrystalCoin::Block.next(previous_block: previous_block)
  blockchain << new_block
  previous_block = new_block
  puts new_block.inspect
end
