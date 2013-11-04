Aether
======

**Aether** is simple Haskell API for finding and accessing data from Wikipedia.

Search Wikipedia, fetch search suggestions, get article summaries, and more!
Aether puts the power of the [MediaWiki API](http://www.mediawiki.org/wiki/API) at your fingertips.

Overview
--------

```Haskell
ghci> import Aether

ghci> search "Git"
["Nashim","Git","GITS","Git (software)","GitHub","Guitar","Georgia Institute of
Technology","Digestion","Git (slang)","Human gastrointestinal tract"]

ghci> suggest "Pysics"
["Physics"]

ghci> summary "Hydrogen"
"Hydrogen is a chemical element with chemical symbol H and atomic number 1. With
 an atomic weight of 1.00794 u, hydrogen is the lightest element and its monatom
ic form (H) is the most abundant chemical substance, constituting roughly 75% of
 the Universe's baryonic mass. "

ghci> pg <- page "Haskell (programming language)"
ghci> :type pg
pg :: Maybe WikipediaPage
```

Aether is designed to be simple and easy to use.
Developers in need of a complete Haskell binding to MediaWiki API
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
