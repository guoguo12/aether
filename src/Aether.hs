-----------------------------------------------------------------------------
-- |
-- Module    : Aether
-- Copyright : (c) Allen Guo 2013
-- License   : MIT
-- 
-- Maintainer : Allen Guo <guoguo12@gmail.com>
-- Stability  : alpha
--
-- The 'Aether' module provides an interface for fetching
-- information from Wikipedia, a free online encyclopedia.
-- Aether can be used to download articles, get search results,
-- generate random article titles, and more.
--
-- Aether wraps around the MediaWiki API. Learn more at
-- <http://www.mediawiki.org/wiki/API>.
--
-----------------------------------------------------------------------------
module Aether ( licenses
              , search
              , suggest
              , random
              , summary
              , page
              ) where

import Parser (extractBetween, extractAllAttrValues, trim)
import WebService (donate, stdQueries, queriesToURI, wikiRequest)
import WikipediaPage (isRedirect, WikipediaPage(..))

-- TODO: Add additional tests for title validity
-- | Tests if the given Wikipedia page title is invalid
isInvalidTitle :: String -> Bool
isInvalidTitle = null

-- | Returns a list of up to 10 Wikipedia search results
-- based on the given search terms.
search :: String -> IO [String]
search terms = do
  let queries = stdQueries ++ [ ("list", "search")
                              , ("srsearch", terms)
                              , ("srlimit", "10")
                              , ("srprop", "")
                              ]
  results <- wikiRequest queries
  return $ extractAllAttrValues results "title"

-- | Returns a suggestion based on the given search terms.
-- Returns an empty string if no suggestion is available.
suggest :: String -> IO String
suggest terms = do
  let queries = stdQueries ++ [ ("list", "search")
                              , ("srsearch", terms)
                              , ("srinfo", "suggestion")
                              , ("srprop", "")
                              , ("srlimit", "1")
                              ]
  results <- wikiRequest queries
  let suggestions = extractAllAttrValues results "suggestion"
  return $ if null suggestions then "" else head suggestions

-- | Returns a list of random Wikipedia article titles.
-- The given Int determines the length of the list; up to 10
-- titles can be fetched at once. The returned list is guaranteed
-- to contain no duplicate titles.
random :: Int -> IO [String]
random pages
  | pages <= 0 = return []
  | otherwise = do
    let queries = stdQueries ++ [ ("list", "random")
                                , ("rnnamespace", "0")
                                , ("rnlimit", show pages)
                                ]
    results <- wikiRequest queries
    return $ extractAllAttrValues results "title"
 
summary :: String -> IO String
summary title
  | isInvalidTitle title = return ""
  | otherwise = do
    let queries = stdQueries ++ [ ("prop", "extracts")
                                , ("explaintext", "")
                                , ("titles", title)
                                , ("exsentences", "1")
                                ]
    results <- wikiRequest queries
    return $ extractBetween results "xml:space=\"preserve\">" "</extract>"

page :: String -> IO (Maybe WikipediaPage)
page title
  | isInvalidTitle title = return Nothing
  | otherwise = do
    let queries = stdQueries ++ [ ("prop", "revisions")
                                , ("rvprop", "content|timestamp")
                                , ("rvlimit", "1")
                                , ("titles", title)
                                ]
    results <- wikiRequest queries
    case trim $ extractBetween results "xml:space=\"preserve\">" "</rev>" of
      ""      -> return Nothing
      content -> return . Just $ WikipediaPage title content timestamp queryURI
        where timestamp = head $ extractAllAttrValues results "timestamp"
              queryURI = show $ queriesToURI queries
              
licenses :: String
licenses = "The text of Wikipedia is available under the Creative Commons Attribution-ShareAlike 3.0 Unported License. \
           \Aether is an open source library available under the MIT License."