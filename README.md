Aether
======

**Aether** is simple Haskell API for finding and accessing data from Wikipedia.

Search Wikipedia, fetch search suggestions, get article summaries, and more!
Aether puts the power of the [MediaWiki API](http://www.mediawiki.org/wiki/API) at your fingertips.

Overview
--------

```Haskell
ghci> import Aether

ghci> summary "Blue"
"Blue is the colour of the clear sky and the deep sea. "

ghci> search "entropy law"
["Second law of thermodynamics","Entropy","Laws of thermodynamics","Thermodynami
cs","Non-equilibrium thermodynamics","Nicholas Georgescu-Roegen","Statistical me
chanics","Third law of thermodynamics","Ludwig Boltzmann","Fluctuation theorem"]

ghci> suggest "Pysics"
["Physics"]
```

Aether is designed to be simple and easy to use.
Developers in need of a complete Haskell binding to the MediaWiki API
should consult the [mediawiki](http://hackage.haskell.org/package/mediawiki) package.

Installation
------------

After downloading/cloning the source repository,
install Aether from the main directory using [cabal-install](http://www.haskell.org/haskellwiki/Cabal-Install):

    $ cabal install

Contributing
------------

Aether is a work-in-progress. Pull requests are most certainly welcome!

License and credits
-------------------

* Aether is licensed under the MIT License. See the `LICENSE` file for details.
* Aether is substantially based on the [goldsmith/Wikipedia](http://github.com/goldsmith/Wikipedia) Python library.
