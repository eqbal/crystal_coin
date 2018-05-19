module CrystalCoin
  class Block
    class Transaction

      property from : String
      property to : String
      property amount : Int64

      def initialize(@from, @to, @amount)
      end
    end
  end
end
