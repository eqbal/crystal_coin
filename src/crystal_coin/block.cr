require "./proof_of_work"

module CrystalCoin
  class Block
    include ProofOfWork

    property current_hash : String
    property index : Int32
    property nonce : Int32

    def initialize(index = 0, data = "data", previous_hash = "hash")
      @data = data
      @index = index
      @timestamp = Time.now
      @previous_hash = previous_hash
      @nonce = proof_of_work
      @current_hash = calc_hash_with_nonce(@nonce)
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

