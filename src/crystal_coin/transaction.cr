module CrystalCoin
  class Block
    class Transaction

      property from : String
      property to : String
      property amount : Int32

      def initialize(@from, @to, @amount)
      end
    end
  end
end
