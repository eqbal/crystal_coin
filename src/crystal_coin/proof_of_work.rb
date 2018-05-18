require "openssl"

module CrystalCoin
  class ProofOfWork

    def initialize(block)
      @block = block
    end

    def run(difficulty = "00")
      nonce = 0
      loop do
        hash = calc_hash_with_nonce(nonce)
        if hash.start_with?(difficulty)
          return [nonce, hash]
        else
          nonce += 1
        end
      end
    end

    private

      getter :block

      def calc_hash_with_nonce(nonce = 0)
        sha = OpenSSL::Digest.new("SHA256")
        hash.update("#{nonce}#{block.index}#{block.timestamp}#{block.transactions}#{block.previous_hash}")
        sha.hexdigest
      end
  end
end
