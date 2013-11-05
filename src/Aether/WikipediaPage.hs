-----------------------------------------------------------------------------
-- |
-- Module    : Aether.WikipediaPage
-- Copyright : (c) Allen Guo 2013
-- License   : MIT
-- 
-- Maintainer : Allen Guo <guoguo12@gmail.com>
-- Stability  : alpha
--
-- This module exports the 'WikipediaPage' data type for representing
-- Wikipedia pages and functions related to it.
--
-----------------------------------------------------------------------------
module Aether.WikipediaPage ( isRedirect
                            , WikipediaPage(..)
                            ) where

import Data.List (isPrefixOf)

-- | Represents a single Wikipedia page.
data WikipediaPage = WikipediaPage { title :: String -- ^ Page title (with namespace prefix).
                                   , content :: String -- ^ Raw contents (wiki markup).
                                   , lastEdit :: String -- ^ Timestamp of last edit.
                                   , queryURI :: String -- ^ URI of the API query used.
                                   } deriving (Show)

-- | Returns if the given 'WikipediaPage' is a hard redirect.
isRedirect :: WikipediaPage -> Bool
isRedirect = isPrefixOf "#REDIRECT [[" . content