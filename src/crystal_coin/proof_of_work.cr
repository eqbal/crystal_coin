require "openssl"

module CrystalCoin
  class ProofOfWork
    property block : CrystalCoin::Block

    def initialize(block)
      @block = block
    end

    def run(difficulty = "00")
      nonce = 0
      loop do
        hash = calc_hash_with_nonce(nonce)
        if hash[0..1] == difficulty
          return [nonce, hash]
        else
          nonce += 1
        end
      end
    end

      private def calc_hash_with_nonce(nonce = 0)
        sha = OpenSSL::Digest.new("SHA256")
        sha.update("#{nonce}#{block.index}#{block.timestamp}#{block.data}#{block.previous_hash}")
        sha.hexdigest
      end
  end
end
