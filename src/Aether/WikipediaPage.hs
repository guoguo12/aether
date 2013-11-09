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
module Aether.WikipediaPage ( images
                            , imageDescs
                            , isRedirect
                            , sections
                            , WikipediaPage(..)
                            ) where

import Data.List (isPrefixOf)
import Aether.Parser (extractAllAttrValues, extractBetween, trim)
import Aether.WebService (stdQueries, wikiRequest)

-- | Represents a single Wikipedia page.
data WikipediaPage = WikipediaPage { title :: String -- ^ Page title (with namespace prefix).
                                   , content :: String -- ^ Raw contents (wiki markup).
                                   , pageID :: String -- ^ Page ID.
                                   , lastEdit :: String -- ^ Timestamp of last edit.
                                   , queryURI :: String -- ^ URI of the API query used.
                                   } deriving (Show)

-- | Returns if the given page is a hard redirect.
isRedirect :: WikipediaPage -> Bool
isRedirect = isPrefixOf "#REDIRECT [[" . content

-- | Returns the URLs of the images on the given page.
-- Works for up to 500 images.
images :: WikipediaPage -> IO (Maybe [String])
images pg = do
  let queries = stdQueries ++ [ ("generator", "images")
                              , ("gimlimit", "max")
                              , ("prop", "imageinfo")
                              , ("iiprop", "url")
                              , ("titles", title pg)
                              ]
  maybeResults <- wikiRequest queries
  return $ fmap (extractAllAttrValues " url") maybeResults
  
-- | Returns the URLs of the description pages for the images
-- on the given page. Works for up to 500 images.
imageDescs :: WikipediaPage -> IO (Maybe [String])
imageDescs pg = do
  let queries = stdQueries ++ [ ("generator", "images")
                              , ("gimlimit", "max")
                              , ("prop", "imageinfo")
                              , ("iiprop", "url")
                              , ("titles", title pg)
                              ]
  maybeResults <- wikiRequest queries
  return $ fmap (extractAllAttrValues "descriptionurl") maybeResults

-- | Returns the section titles of the given page.
sections :: WikipediaPage -> IO (Maybe [String])
sections pg = do
  let queries = [ ("format", "xml")
                , ("action", "parse")
                , ("prop", "sections")
                , ("page", title pg)
                ]
  maybeResults <- wikiRequest queries
  return $ fmap (extractAllAttrValues "line") maybeResults

{-
-- | Returns the HTML markup of the given page.
contentHTML :: WikipediaPage -> IO String
contentHTML pg = do
  let queries = stdQueries ++ [ ("prop", "revisions")
                              , ("rvprop", "content")
                              , ("rvlimit", "1")
                              , ("rvparse", "")
                              , ("titles", title pg)
                              ]
  results <- wikiRequest queries
  return . trim $ extractBetween results "xml:space=\"preserve\">" "</rev>"
-}  