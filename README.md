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


## Steps 

### Create the skeleton of the app:

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

### What’s Blockchain?

- It’s a list (chain) of blocks linked and secured by digital fingerprints (also known as crypto hashes).

- Create `src/crystal_coin/block.cr`

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

- Easiest way to think of it as a linked list. It's not really a linked list tho,  A linked list is only required to have a reference to the previous element, a block must have an identifier depending on the previous block’s identifier, meaning that you cannot replace a block without recomputing every single block that comes after.



### Notes 

- I want to use Crystal [Amber](https://github.com/amberframework/amber) framework to handle transactions, the framework is heavily inspired by Rails framework so we can build an interface (RESTful API in our case to trigger some events like send a transaction ..etc)
