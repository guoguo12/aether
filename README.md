Aether
======

**Aether** is simple Haskell API for finding and accessing data from Wikipedia.

Search Wikipedia, fetch search suggestions, get article summaries, and more!
Aether puts the power of the [MediaWiki API](http://www.mediawiki.org/wiki/API) at your fingertips.

Overview
--------

Let's play around with Aether in [GHCi](http://www.haskell.org/haskellwiki/GHC/GHCi). 
First, let's import Aether.

```Haskell
ghci> import Aether
```

Let's try out some basic Aether functions.

```Haskell
ghci> summary "Blue"
"Blue is the colour of the clear sky and the deep sea. "

ghci> search "entropy law"
["Second law of thermodynamics","Entropy","Laws of thermodynamics","Thermodynami
cs","Non-equilibrium thermodynamics","Nicholas Georgescu-Roegen","Statistical me
chanics","Third law of thermodynamics","Ludwig Boltzmann","Fluctuation theorem"]

ghci> suggest "Pysics"
["Physics"]
```

That was easy!

The `WikipediaPage` data type represents an individual Wikipedia page.
Let's use the `page` function to fetch a `WikipediaPage` value.

```Haskell
ghci> pg <- page "Computer science"
```

There are a variety of functions that operate on `WikipediaPage` values.

```Haskell
ghci> title pg
"Computer science"

ghci> lastEdit pg
"2013-11-04T04:33:42Z"

ghci> isRedirect pg
False

ghci> take 175 $ content pg
"'''Computer science''' (abbreviated '''CS''' or '''CompSci''') is the [[science
|scientific]] and practical approach to [[computation]] and its applications. It
 is the systemat"
```

Aether has many more features&mdash;and many more to come!
See below for installation and contribution information.

Installation
------------

After downloading/cloning the source repository,
install Aether from the main directory using [cabal-install](http://www.haskell.org/haskellwiki/Cabal-Install):

    $ cabal install

Contributions
-------------

Aether is a work-in-progress. Pull requests are most certainly welcome!

Notes and credits
-----------------

* Aether is designed to be simple and easy to use. Developers in need of a complete Haskell binding to the MediaWiki API should consult the [mediawiki](http://hackage.haskell.org/package/mediawiki) package.
* Aether is licensed under the MIT License. See the `LICENSE` file for details.
* Aether is substantially based on the [goldsmith/Wikipedia](http://github.com/goldsmith/Wikipedia) Python library.
