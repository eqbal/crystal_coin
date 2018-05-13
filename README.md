# Build a Blockchain from scratch using Crystal

### Intro

In this article, I'll explore the internals of blockchain by building a coin called Crystal Coin from scratch. We will simplify most of the things like complexity, algorithm choices etc.

Focusing on the details of a concrete example will provide a deeper understanding of the strengths and limitations of blockchains.

>I will assume you have a basic understanding of Object Oriented Programming

For a better demonstration, I want to use a productive language like [ruby](https://www.ruby-lang.org/en/) without compromising the performance. Cryptocurrency has many time consuming computations and that's why a compiled languages (like C++ and JAVA) are the languages to go. That being said I want to use a language with a better syntax so I can keep the development fun and allow better demonstration for the ideas.

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

Yes this is weird compared to the conventional centralized systems. Each of the nodes will have a copy of the entire blockchain (> 200 Gb).

### Hash?

So, what is this hash? Think of the hash as a function, that when we give it an a text it would return a unique finger print. 

Even the smallest change in the input object would change the finger print.

There are different hashing algorithms, in this article we'll be using `SHA256` hash algorithm, which is the one used `Bitcoin`.

Using `SHA256` we'll always resulting a 64 hexadecimal chars (256-bit) in length even if the input is less than 256-bit or much bigger than 256-bit:



| Input                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Hashed Results                                                   |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------|
| VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT VERY LONG TEXT | cf49bbb21c8b7c078165919d7e57c145ccb7f398e7b58d9a3729de368d86294a |
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


For simplicity, our `CrystalCoin` Block will contain only few attributes:

```
1) index: indicates the index of the block ex: 0,1
2) timestamp: timestamp in epoch, number of seconds since 1 Jan 1970
3) data: the actual data that needs to be stored on blockchain.
4) previous_hash: the hash of the previous block, this is the chain/link between the blocks
5) nonce: this is a magical number that is to be mined/found, we will explore about it in later posts
6) currnt_hash: The hash value of the current block, this is generated by combining all the above attributes and passing it to a hashing algorithm
```
``

Now, let's try to design our Block class and make it more generic.

-The Genesis block will contain these attributes. Some of the them are default values; for simplicity currHash is calculated by combining all the attributes.

### Proof-of-Work and Genesis



### Notes 

- I want to use Crystal [Amber](https://github.com/amberframework/amber) framework to handle transactions, the framework is heavily inspired by Rails framework so we can build an interface (RESTful API in our case to trigger some events like send a transaction ..etc)

### References
- [Original paper](http://nakamotoinstitute.org/bitcoin/)