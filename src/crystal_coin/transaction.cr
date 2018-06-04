require "json"

module CrystalCoin
  class Block
    class Transaction

      JSON.mapping(
        from: String,
        to: String,
        amount: Int64
      )

      property from : String
      property to : String
      property amount : Int64

      def initialize(@from, @to, @amount)
      end
    end
  end
end
