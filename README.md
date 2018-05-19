# Build a Blockchain from scratch using Crystal

### Intro

If you heard of Blockchain, Proof of work, hashing etc. and you know the theoretical part but you are still not convinced as you think the only way to understand the details is by digging deeper into the implementation, then this article is for you.

I'm not by any mean an expert blockchain engineer, but thought the easiest way to understand Blockchain is by implementing a new one from scratch.

In this article, I'll explore the internals of blockchain by building a coin called CrystalCoin from scratch. We will simplify most of the things like complexity, algorithm choices etc.

Focusing on the details of a concrete example will provide a deeper understanding of the strengths and limitations of blockchains.

>I will assume you have a basic understanding of Object Oriented Programming

For a better demonstration, I want to use a productive language like [ruby](https://www.ruby-lang.org/en/) without compromising the performance. Cryptocurrency has many time consuming computations (_mining_ and hashing) and that's why a compiled languages (like C++ and JAVA) are the languages of choice to build production-ready coins. That being said I want to use a language with a better syntax so I can keep the development fun and allow better demonstration for the ideas.

So, what I want to use? [Crystal](https://crystal-lang.org/) language. Crystal’s syntax is heavily inspired by Ruby’s, so it feels natural to read and easy to write, and has the added benefit of a lower learning curve for experienced Ruby devs. Their slogan is:

> Fast as C, slick as Ruby

Unlike [Ruby](https://www.ruby-lang.org/en/) or JavaScript, which are interpreted languages, Crystal is a compiled language, making it much faster and with a lower memory footprint. Under the hood, it uses [LLVM](https://llvm.org/) for compiling to native code.

Crystal is also statically typed, which means that the compiler will help you catch type errors in compile-time. But more on this later: let's now dive into installing Crystal.	

Not gonna talk more of why Crystal is a cool programming language to learn as it's out of the scoop of this article, but please feel free check out [this](https://medium.com/@DuroSoft/why-crystal-is-the-most-promising-programming-language-of-2018-aad669d8344f) article if you are still not convinced.	


### Blockchain?

So, what is a blockchain? It’s a list (chain) of blocks linked and secured by digital fingerprints (also known as crypto hashes).

Personally, I think the easiest way to think of it as a linked list. That being said, it's important to understand it's **not** a linked list. A linked list only required to have a reference to the previous element, a block must have an identifier depending on the previous block’s identifier, meaning that you cannot replace a block without recomputing every single block that comes after. But let's worry about this later on. 

For now think of blockchain as a series of blocks with some data, linked with a chain, the chain being the hash of the previous block.

The entire blockchain would exist on each one of the node that wants to interact with it, meaning it is copied on each one of the nodes in the network. So, no single server hosts it, which makes it decentralized.

Yes this is weird compared to the conventional centralized systems. Each of the nodes will have a copy of the entire blockchain (> 200 Gb in Bitcoin blockchain).

### Hash?

So, what is this hash? Think of the hash as a function, that when we give it an a text it would return a unique finger print. 

Even the smallest change in the input object would change the finger print.

There are different hashing algorithms, in this article we'll be using `SHA256` hash algorithm, which is the one used `Bitcoin`.

Using `SHA256` we'll always resulting a 64 hexadecimal chars (256-bit) in length even if the input is less than 256-bit or much bigger than 256-bit:



| Input                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Hashed Results                                                   |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------|
| VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEX VERY LONG TEXT VERY LONG  VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT | cf49bbb21c8b7c078165919d7e57c145ccb7f398e7b58d9a3729de368d86294a |
| Toptal                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | 2e4e500e20f1358224c08c7fb7d3e0e9a5e4ab7a013bfd6774dfa54d7684dd21 |
| Toptal.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | 12075307ce09a6859601ce9d451d385053be80238ea127c5df6e6611eed7c6f0 |

Note with the last example, that just adding a dot (.) resulted a dramatical changes in the hash.

Therefore, in a blockchain, the chain is built by passing the block data into a hashing algorithm that would generate a hash, which is linked to the next block, henceforth, forming a series of blocks linked with the hashes of the previous blocks.

Now let's start creating our Crystal project and build our `SHA256` encryption.

Assuming you have your Crystal language [installed](https://crystal-lang.org/docs/installation/), let's create the skeleton of the app using `crystal init app [name]` command:

```
% crystal init app crystal_coin
      create  crystal_coin/.gitignore
      create  crystal_coin/.editorconfig
      create  crystal_coin/LICENSE
      create  crystal_coin/README.md
      create  crystal_coin/.travis.yml
      create  crystal_coin/shard.yml
      create  crystal_coin/src/crystal_coin.cr
      create  crystal_coin/src/crystal_coin/version.cr
      create  crystal_coin/spec/spec_helper.cr
      create  crystal_coin/spec/crystal_coin_spec.cr
Initialized empty Git repository in /Users/eqbal/code/blockchain/ruby_coin/crystal_coin/.git/
```
As you can see, this command will create the basic structure for the project, with an already initialised git repository, license and readme files. It also comes with stubs for tests, and the `shard.yml` for describing the project and managing dependencies, also known as shards.

Let’s add the `openssl` shard, which is needed to build `SHA256` algorithm:

```
vim shard.yml
```

```
dependencies:
  openssl:
    github: datanoise/openssl.cr
```

Note that Crystal does not have a centralized repository, like [rubygems](https://rubygems.org/) or [npm](https://www.npmjs.com/). The way to specify a dependency is through its git repository, which in this case sits in Github.

We install the dependencies listed running: 

```
crystal deps
```

Now we have the required library installed in our code, let's start by defining the block class and then building the hash function.

```
vim src/crystal_coin/block.cr
```

```ruby
require "openssl"

module CrystalCoin
  class Block

    def initialize(data : String)
      @data = data
    end

    def hash
      hash = OpenSSL::Digest.new("SHA256")
      hash.update(@data)
      hash.hexdigest
    end
  end
end

puts CrystalCoin::Block.new("Hello, Cryptos!").hash
```

```
crystal_coin [master●] % crystal src/crystal_coin/block.cr
33eedea60b0662c66c289ceba71863a864cf84b00e10002ca1069bf58f9362d5
```


### Design our Blockchain

We’ll start by first defining what our blocks will look like. In Block, each block is stored with a `timestamp` and, optionally, an `index`. In CrystalCoin, we’re going to store both. And to help ensure integrity throughout the blockchain, each block will have a self-identifying hash. Like Bitcoin, each block’s hash will be a cryptographic hash of the block’s (`index`, `timestamp`, `data`, and the hash of the previous block’s hash `previous_hash`). The data can be anything you want.

```ruby
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

    private def hash_block
      hash = OpenSSL::Digest.new("SHA256")
      hash.update("#{@index}#{@timestamp}#{@data}#{@previous_hash}")
      hash.hexdigest
    end
  end
end


puts CrystalCoin::Block.new(data: "Same Data"). current_hash
```

Note that the same data will generate different hashes because of the different timestamps:

```
crystal_coin [master●] % crystal src/crystal_coin/block.cr
361d0df74e28d37b71f6c5f579ee182dd3d41f73f174dc88c9f2536172d3bb66
crystal_coin [master●] % crystal src/crystal_coin/block.cr
b1fafd81ba13fc21598fb083d9429d1b8a7e9a7120dbdacc7e461791b96b9bf3
```

Cool! We have our block structure, but we’re creating a blockchain. We need to start adding blocks to the actual chain. As I mentioned earlier, each block requires information from the previous block. But with that being said, a question arises: how does the first block in the blockchain get there? Well, the first block, or `genesis` block, is a special block (a block with no predecessors). In many cases, it’s added manually or has unique logic allowing it to be added.

We’ll create a function that simply returns a genesis block to make things easy. This block is of index=0, and it has an arbitrary data value and an arbitrary value in the “previous hash” parameter.

I'll create a class method `first` that generates the genesis block:

```ruby
def self.first(data="Genesis Block")
  Block.new(data: data, previous_hash: "0")
end
```

Now let's try it out:

```ruby
puts CrystalCoin::Block.first.inspect
```

```
#<CrystalCoin::Block:0x10b33ac80 @current_hash="acb701a9b70cff5a0617d654e6b8a7155a8c712910d34df692db92455964d54e", @data="Genesis Block", @index=0, @timestamp=2018-05-13 17:54:02 +03:00, @previous_hash="0">
```

Now that we’re able to create a genesis block, we need a function that will generate succeeding blocks in the blockchain.

This function will take the previous block in the chain as a parameter, create the data for the block to be generated, and return the new block with its appropriate data. When new blocks hash information from previous blocks, the integrity of the blockchain increases with each new block. 

If we didn’t do this, it would be easier for an outside party to “change the past” and replace our chain with an entirely new one of their own. This chain of hashes acts as cryptographic proof and helps ensure that once a block is added to the blockchain it cannot be replaced or removed. Let's create the class method `next`:

```ruby
def self.next(previous_node, data = "Transaction Data")
  Block.new(
    data: "Transaction data number (#{previous_node.index + 1})",
    index: previous_node.index + 1,
    previous_hash: previous_hash.hash
  )
end
```

Now let's try it out all together, we'll create a simple  blockchain. The first element of the list is the genesis block. And of course, we need to add the succeeding blocks. We'll create 10 new blocks to demonstrate `CrystalCoin`:

```ruby
blockchain = [ CrystalCoin::Block.first ]

previous_block = blockchain[0]

10.times do |i|
  new_block  = CrystalCoin::Block.next(previous_block: previous_block)
  blockchain << new_block
  previous_block = new_block
  puts new_block.inspect
end

```

```
#<CrystalCoin::Block:0x10e04abc0 @current_hash="a6d92e0787b005f25b7d4b132a71c16bdb2dbabad917d82bcdae6f2aac87b2a2", @index=1, @data="Transaction data number (1)", @timestamp=2018-05-13 23:22:17 +03:00, @previous_hash="c3b15c18b025cebaaa7302254910708d2ace1dd05b1a489034c25c87e579e889">
#<CrystalCoin::Block:0x10e04aa80 @current_hash="fc0566969686cd3e9cb70e6bae86019e89b41a601fab874364df4937254c71b9", @index=2, @data="Transaction data number (2)", @timestamp=2018-05-13 23:22:17 +03:00, @previous_hash="a6d92e0787b005f25b7d4b132a71c16bdb2dbabad917d82bcdae6f2aac87b2a2">
#<CrystalCoin::Block:0x10e04a980 @current_hash="cfec59ec174f7efccacd0de52a771116dae7084e38cd69cff4c6309b3da86bc5", @index=3, @data="Transaction data number (3)", @timestamp=2018-05-13 23:22:17 +03:00, @previous_hash="fc0566969686cd3e9cb70e6bae86019e89b41a601fab874364df4937254c71b9">
#<CrystalCoin::Block:0x10e04a880 @current_hash="1e50b43d893b832d210ab95777f81c413cc10b30a78b8f1a0ed895a7a8766ea0", @index=4, @data="Transaction data number (4)", @timestamp=2018-05-13 23:22:17 +03:00, @previous_hash="cfec59ec174f7efccacd0de52a771116dae7084e38cd69cff4c6309b3da86bc5">
#<CrystalCoin::Block:0x10e04a780 @current_hash="3ba86566e340209cfc8e59572dc76c1caa191752894d9e31da14db7e00902376", @index=5, @data="Transaction data number (5)", @timestamp=2018-05-13 23:22:17 +03:00, @previous_hash="1e50b43d893b832d210ab95777f81c413cc10b30a78b8f1a0ed895a7a8766ea0">
#<CrystalCoin::Block:0x10e04a680 @current_hash="4edc238c38efb37311129201f6938aaa6b170d95d51112745b738cd9cb738386", @index=6, @data="Transaction data number (6)", @timestamp=2018-05-13 23:22:17 +03:00, @previous_hash="3ba86566e340209cfc8e59572dc76c1caa191752894d9e31da14db7e00902376">
#<CrystalCoin::Block:0x10e04a580 @current_hash="e5974f5fef832fe6a3d81c7cf8342c05d198d114da5c333cbe85e84e30344567", @index=7, @data="Transaction data number (7)", @timestamp=2018-05-13 23:22:17 +03:00, @previous_hash="4edc238c38efb37311129201f6938aaa6b170d95d51112745b738cd9cb738386">
#<CrystalCoin::Block:0x10e04a480 @current_hash="ec308e41c8361fe6d11eb99c89a67f4173446fcf683d9e109511fcb20782c2ab", @index=8, @data="Transaction data number (8)", @timestamp=2018-05-13 23:22:17 +03:00, @previous_hash="e5974f5fef832fe6a3d81c7cf8342c05d198d114da5c333cbe85e84e30344567">
#<CrystalCoin::Block:0x10e04a380 @current_hash="035dd1a88f47f534b09a6d43b1ee2be365df6beb87b03edb4750489d82f3178b", @index=9, @data="Transaction data number (9)", @timestamp=2018-05-13 23:22:17 +03:00, @previous_hash="ec308e41c8361fe6d11eb99c89a67f4173446fcf683d9e109511fcb20782c2ab">
#<CrystalCoin::Block:0x10e04a280 @current_hash="47a43a7e9a980dc3e7d08c671a02d44f7293e41a7c2059c7f118c1e0a562b6e3", @index=10, @data="Transaction data number (10)", @timestamp=2018-05-13 23:22:17 +03:00, @previous_hash="035dd1a88f47f534b09a6d43b1ee2be365df6beb87b03edb4750489d82f3178b">
```


### Proof-of-Work

A Proof of Work algorithm (PoW) is how new Blocks are created or _mined_ on the blockchain. The goal of PoW is to discover a number which solves a problem. The number must be difficult to find but easy to verify computationally speaking—by anyone on the network. This is the core idea behind Proof of Work.

Let's explain by an example so things will get clearer.

Let’s decide that the hash of some integer x multiplied by another y must starts with `00`. So:

```
hash(x * y) = 00ac23dc...
```

And for this simplified example, let’s fix x = 5. Implementing this in Crystal:

```ruby
x = 5
y = 0

while hash((x*y).to_s)[0..1] != "00"
  y += 1
end

puts "The solution is y = #{y}"
puts "Hash(#{x}*#{y}) = #{hash((x*y).to_s)}"
```

Now let's run the code:

```
crystal_coin [master●●] % time crystal src/crystal_coin/pow.cr
The solution is y = 530
Hash(5*530) = 00150bc11aeeaa3cdbdc1e27085b0f6c584c27e05f255e303898dcd12426f110
crystal src/crystal_coin/pow.cr  1.53s user 0.23s system 160% cpu 1.092 total
```

As you can see this number (y=530) was hard to find (brute-force), but easy to verify using the hash function.

Why to bother with this PoW algorithm? We don't just create one hash per block and that's it. A hash must be _valid_. In our case, a hash will be valid if the first two characters of our hash are '00'. If our hash starts with '00......', it is considered valid. This is called the *difficulty*. The higher the difficulty, the longer it takes to get a valid hash.

But, if the hash is not valid the first time, something must change in the data we use. If we use the same data over and over, we will get the same hash over and over and our hash will never be valid. We use something called `nonce` in our hash (in our previous example it's the `y`). It is simply a number that we increment each time the hash is not valid. We get our data (date, message, previous hash, index) and a nonce of 1. If the hash we get with these is not valid, we try with a nonce of 2. And we increment the nonce until we get a valid hash.

In Bitcoin, the Proof of Work algorithm is called [Hashcash](https://en.wikipedia.org/wiki/Hashcash). Let's add a proof-of-work to our Block class. and let's start mining to find the nonce, let's start with the hard-coded difficulty of two leading zeros '00':

Now let's redesign our Block class to support that. Our `CrystalCoin` Block will contain only the follwoings attributes:

```
1) index: indicates the index of the block ex: 0,1
2) timestamp: timestamp in epoch, number of seconds since 1 Jan 1970
3) data: the actual data that needs to be stored on blockchain.
4) previous_hash: the hash of the previous block, this is the chain/link between the blocks
5) nonce: this is the number that is to be mined/found.
6) currnt_hash: The hash value of the current block, this is generated by combining all the above attributes and passing it to a hashing algorithm
```

![blockchain_list](./assets/blockchain-attributes.png).

I'll create a separate module to do the hashing and find the `nonce` so we keep our code clean and modular. I'll call it `proof_of_work.cr`:

```ruby
require "openssl"

module CrystalCoin
  module ProofOfWork

    private def proof_of_work(difficulty = "00")
      nonce = 0
      loop do
        hash = calc_hash_with_nonce(nonce)
        if hash[0..1] == difficulty
          return nonce
        else
          nonce += 1
        end
      end
    end

    private def calc_hash_with_nonce(nonce = 0)
      sha = OpenSSL::Digest.new("SHA256")
      sha.update("#{nonce}#{@index}#{@timestamp}#{@data}#{@previous_hash}")
      sha.hexdigest
    end
  end
end
```

Now our Block class would look something like:

```ruby
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

```

Few things to note about Crystal code. In Crystal methods are public by default, Crystal requires each private method to be prefixed with the private keyword which could be confusing coming from Ruby.

Another thing to note here, that the ruby `attr_accessor`, `attr_getter` and `attr_setter` methods are replaced with new keywords:

| Ruby Keyword  | Crystal Keyword |
|---------------|-----------------|
| attr_accessor | property        |
| attr_reader   | getter          |
| attr_writer   | setter          |


In Crystal you want to hint the compiler about specific types through your code. Crystal infers the types, but whenever you have ambiguity you can explicitly declare types as well. That's why we added the types for `current_hash`, `index` and `nonce`. 

You might noticed that for Crystal's Integer types there are `Int8`, `Int16`, `Int32`, `Int64`, `UInt8`, `UInt16`, `UInt32`, or `UInt64` compared to Ruby's `Fixnum`. `true` and `false` are values in the `Bool` class rather than values in classes `TrueClass` or `FalseClass` in Ruby.

Crystal has optional and named method arguments as core language features, and does not require writing special code for handling the arguments which is pretty cool. Check out `Block#initialize(index = 0, data = "data", previous_hash = "hash")` and then calling it with something like `Block.new(data: data, previous_hash: "0")`.

For a more detailed list of differences between Crystal and Ruby programming language check out [Crystal for Rubyists](https://github.com/crystal-lang/crystal/wiki/Crystal-for-Rubyists).

Now, let's try to create 5 transactions using:

```ruby
blockchain = [ CrystalCoin::Block.first ]
puts blockchain.inspect
previous_block = blockchain[0]

5.times do |i|
  new_block  = CrystalCoin::Block.next(previous_block: previous_block)
  blockchain << new_block
  previous_block = new_block
  puts new_block.inspect
end
```

```
[#<CrystalCoin::Block:0x108f8fea0 @current_hash="0088ca080a49334e1cb037ed4c42795d635515ef1742e6bcf439bf0f95711759", @index=0, @nonce=17, @timestamp=2018-05-14 17:20:46 +03:00, @data="Genesis Block", @previous_hash="0">]
#<CrystalCoin::Block:0x108f8f660 @current_hash="001bc2b04d7ad8ef25ada30e2bde19d7bbbbb3ad42348017036b0d4974d0ccb0", @index=1, @nonce=24, @timestamp=2018-05-14 17:20:46 +03:00, @data="Transaction data number (1)", @previous_hash="0088ca080a49334e1cb037ed4c42795d635515ef1742e6bcf439bf0f95711759">
#<CrystalCoin::Block:0x109fc5ba0 @current_hash="0019256c998028111838b872a437cd8adced53f5e0f8f43388a1dc4654844fe5", @index=2, @nonce=61, @timestamp=2018-05-14 17:20:46 +03:00, @data="Transaction data number (2)", @previous_hash="001bc2b04d7ad8ef25ada30e2bde19d7bbbbb3ad42348017036b0d4974d0ccb0">
#<CrystalCoin::Block:0x109fdc300 @current_hash="0080a30d0da33426a1d4f36d870d9eb709eaefb0fca62cc68e497169c5368b97", @index=3, @nonce=149, @timestamp=2018-05-14 17:20:46 +03:00, @data="Transaction data number (3)", @previous_hash="0019256c998028111838b872a437cd8adced53f5e0f8f43388a1dc4654844fe5">
#<CrystalCoin::Block:0x109ff58a0 @current_hash="00074399d51c700940e556673580a366a37dec16671430141f6013f04283a484", @index=4, @nonce=570, @timestamp=2018-05-14 17:20:46 +03:00, @data="Transaction data number (4)", @previous_hash="0080a30d0da33426a1d4f36d870d9eb709eaefb0fca62cc68e497169c5368b97">
#<CrystalCoin::Block:0x109fde120 @current_hash="00720bb6e562a25c19ecd2b277925057626edab8981ff08eb13773f9bb1cb842", @index=5, @nonce=475, @timestamp=2018-05-14 17:20:46 +03:00, @data="Transaction data number (5)", @previous_hash="00074399d51c700940e556673580a366a37dec16671430141f6013f04283a484">
```
See the difference? Now all hashes start with '00'. That's the magic of the proof-of-work. Using `ProofOfWork` we found the (nonce) and proof is the hash with the matching difficulty, that is, the two leading zeros `00`.

Note with the first block we created, we tried 17 nonces until finding the matching lucky number:

| Block | Loops / Number of Hash calculations |
|-------|-------------------------------------|
| #0    | 17                                  |
| #1    | 24                                  |
| #2    | 61                                  |
| #3    | 149                                 |
| #4    | 570                                 |
| #5    | 475                                 |

Let's try a difficulty of four leading zeros '0000' (let's use difficulty="0000" in `ProofOfWork#run`):

| Block | Loops / Number of Hash calculations |
|-------|-------------------------------------|
| #1    | 26 762                              |
| #2    | 68 419                              |
| #3    | 23 416                              |
| #4    | 15 353                              |

In the first block tried 26762 nonces (compare 17 nonces with difficulty '00') until finding the matching lucky number.

### Our Blockchain as an API

So far, so good. We created our simple blockchain and it was relatively easy to make. But the problem here is that `CrystalCoin` can only ran on one single machine (it's not distributed or decentralized).

From now on we'll start using JSON data for CrystalCoin, the data will be transactions, so each block’s data field will be a list of some transactions.

Each transaction will be a JSON object detailing the `sender` of the coin, the `receiver` of the coin, and the `amount` of SnakeCoin that is being transferred:

```
{
  "from": "71238uqirbfh894-random-public-key-a-alkjdflakjfewn204ij",
  "to": "93j4ivnqiopvh43-random-public-key-b-qjrgvnoeirbnferinfo",
  "amount": 3
}
```

A few modifications to our `Block` class to support the new `transaction` format (previously	we called it `data`). So, just to avoid confusion and maintain consistency, we'll be using the term `ransaction` to refer to `data` posted in our example application.

We'll introduce a new simple class `Transaction`:

```ruby
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
```

The transactions are packed into blocks. So a block can contain one or many transactions. The blocks containing the transactions are generated frequently and added to the blockchain. 

The blockchain is supposed to be a collection of blocks. We can store all of the blocks in the Crystal list, and that's why we introduce the new class `Blockchain`:

`Blockchain` will have `chain` and `uncommitted_transactions` arrays. The `chain` will include all the mined blocks in the blockchain, and `uncommitted_transactions` will have all the transactions that has not been added to the blockchain (still not mined). Once we initialize `Blockchain`, we create genesis block (using `Block.first`) and add it to `chain` array and we add an empty `uncommitted_transactions` array. 

We will create `Blockchain#add_transaction` method as well to add transactions to `uncommitted_transactions` array.

We will create the skeleton of a one more function `Blockchain#mine`. For now we'll keep it empty and we'll discuss the implementation once we work on `/mine` end-point. So for now our `Blockchain` class looks something like:

```ruby
require "./block"
require "./transaction"

module CrystalCoin
  class Blockchain
    getter chain
    getter uncommitted_transactions

    def initialize
      @chain = [ Block.first ]
      @uncommitted_transactions = [] of Block::Transaction
    end

    def add_transaction(transaction)
      @uncommitted_transactions << transaction
    end

    def mine
      # This function serves as an interface to add the pending
      # transactions to the blockchain by adding them to the block
      # and figuring out Proof of Work
    end
  end
end

```

And the changes for `Block`:

```diff
diff --git a/src/crystal_coin/block.cr b/src/crystal_coin/block.cr
index a7ef7d9..2c7f219 100644
--- a/src/crystal_coin/block.cr
+++ b/src/crystal_coin/block.cr
@@ -9,7 +9,7 @@ module CrystalCoin
     property index : Int32
     property nonce : Int32

-    def initialize(index = 0, transactions = [], previous_hash = "hash")
+    def initialize(index = 0, transactions = [] of Transaction, previous_hash = "hash")
       @transactions = transactions
       @index = index
       @timestamp = Time.now
@@ -22,7 +22,7 @@ module CrystalCoin
       Block.new(previous_hash: "0")
     end

-    def self.next(previous_block, transactions = [])
+    def self.next(previous_block, transactions = [] of Transaction)
       Block.new(
         transactions: transactions,
         index: previous_block.index + 1,
```

Now that we know what our transactions will look like, we need a way to add them to one of the computers in our blockchain network, called a `node`. To do that, we’ll create a simple HTTP server so that any user can let our nodes know that a new transaction has occurred. A node will be able to accept a POST request with a transaction (like above) as the request body. This is why transactions are JSON formatted; we need them to be transmitted to our server in a request body.

We'll create three end-points:

- `/transactions/new`: to create a new transaction to a block
- `/mine`: to tell our server to mine a new block.
- `/chain`: to return the full Blockchain.
- `/pending`: to return the pending transactions

We're going to use [Kermal](https://github.com/kemalcr/kemal) web framework. It’s a micro-framework and it makes it easy to map endpoints to Crystal functions. If you are coming from Ruby backgrounds, think of Kermal as an equivalent of [Sinatra](http://sinatrarb.com/) framework. If you are looking for a more advanced framework to create a database driven application (the equivalent of [Ruby on Rails](https://rubyonrails.org/)) then you have to try [Amber](https://github.com/amberframework/amber). In my case I didn't want to create a DB and use scaffolding so I decided to use Kermal to keep things simple.

Our server will form a single node in our blockchain network. Let's first add kemal to the `shard.yml` file as a dependency:

```
dependencies:
  kemal:
    github: kemalcr/kemal
```

And then let's install the dependencies using `shards install`:

Now let's build the skeleton of our HTTP server:

```ruby
# src/server.cr

require "kemal"
require "./crystal_coin"

# Generate a globally unique address for this node
node_identifier = UUID.random.to_s

# Create our Blockchain
blockchain = Blockchain.new

get "/chain" do
  "Send the blockchain as json objects"
end

get "/mine" do
  "We'll mine a new Block"
end

get "/pending" do
  "Send pending transactions as json objects"
end

post "/transactions/new" do
  "We'll add a new transaction"
end

Kemal.run
```

Let's run the server:

```
crystal_coin [master●●] % crystal run src/server.cr
[development] Kemal is ready to lead at http://0.0.0.0:3000
```

Let's make sure the server is working fine: 

```
% curl http://0.0.0.0:3000/chain
Send the blockchain as json objects%
```

Ok so far so good. Now we can proceed with implementing each of the endpoints. Let's start with implementing `/transactions/new` and `pending` end-points:

```ruby
get "/pending" do
  "#{blockchain.uncommitted_transactions}"
end

post "/transactions/new" do |env|

  transaction = CrystalCoin::Block::Transaction.new(
    from: env.params.json["from"].as(String),
    to:  env.params.json["to"].as(String),
    amount:  env.params.json["amount"].as(Int64)

  )

  blockchain.add_transaction(transaction)

  "Transaction #{transaction.inspect} has been added to the node"
end

```

Straight forward implementation. We just create a `CrystalCoin::Block::Transaction` object and add the transaction to the `uncommitted_transactions` array using `Blockchain#add_transaction`.

Now you must be asking yourself: where do people get `CrystalCoins` from? Nowhere, yet. There’s no such thing as a `CrystalCoin` yet, because not one coin has been created and issued yet. To create new coins, people have to _mine_ new blocks of `CrystalCoin`. 

At the moment, the transactions are initially stored in a pool of `uncommitted_transactions`. The process of putting the unconfirmed transactions in a block and computing Proof of Work (PoW) is known as the _mining_ of blocks. Once the nonce satisfying our constraints is figured out, we can say that a block has been mined, and the block is put into the blockchain.

In `CrystalCoin`, we’ll use the simple Proof-of-Work algorithm we created earlier. To create a new block, a miner’s computer will have to:

- Find the last block in the `chain`
- Find uncommitted transactions (`uncommitted_transactions`)
- Create a new block using `Block.next`
- Add the mined block to `chain` array
- Clean up `uncommitted_transactions` array

So to implement `/mine` end-point, let's first implement the above steps in `Blockchain#mine`:

```diff
 module CrystalCoin
   class Blockchain
+    BLOCK_SIZE = 25
+
     getter chain
     getter uncommitted_transactions

@@ -16,14 +18,15 @@ module CrystalCoin
     end

     def mine
+       raise "No transactions to be mined" if @uncommitted_transactions.empty?
+
+       new_block = Block.next(
+         previous_block: @chain.last,
+         transactions: @uncommitted_transactions.shift(BLOCK_SIZE)
+       )
+
+       @chain << new_block
     end

```

We make sure first we have some uncommitted transactions to mine. Then we get the last chain using `@chain.last`, and the first `25` transactions to be mined (we are using `@uncommited_transactions.shift(BLOCK_SIZE)` to return an array of the first 25 values, then remove the elements starting at index 0).

Now let's implement `/mine` end-point:

```
```

### What is next?
#### Consensus

This is very cool. We’ve got a basic Blockchain that accepts transactions and allows us to mine new Blocks. But the whole point of Blockchains is that they should be decentralized. And if they’re decentralized, how on earth do we ensure that they all reflect the same chain? This is called the problem of Consensus, and we’ll have to implement a Consensus Algorithm if we want more than one node in our network.


### References
- [Original paper](http://nakamotoinstitute.org/bitcoin/)

### Notes

