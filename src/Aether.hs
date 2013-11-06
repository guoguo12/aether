-----------------------------------------------------------------------------
-- |
-- Module    : Aether
-- Copyright : (c) Allen Guo 2013
-- License   : MIT
-- 
-- Maintainer : Allen Guo <guoguo12@gmail.com>
-- Stability  : alpha
--
-- Aether provides a high-level interface for fetching
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
              , summaryLines
              , page
              , pageMaybe
              ) where

import Aether.Parser (extractBetween, extractAllAttrValues, trim)
import Aether.WebService (donate, stdQueries, queriesToURI, wikiRequest)
import Aether.WikipediaPage (isRedirect, WikipediaPage(..))

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
-- The given 'Int' determines the length of the list; up to 10
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

-- | Returns a summary of the Wikipedia article with the given title.
-- The summary will be about one line long.    
summary :: String -> IO String
summary = summaryLines 1
    
-- | Returns a summary of the Wikipedia article with the given title.
-- The given 'Int' determines the maximum summary length, in lines.
summaryLines :: Int -> String -> IO String    
summaryLines lines title
  | isInvalidTitle title = return ""
  | otherwise = do
    let queries = stdQueries ++ [ ("prop", "extracts")
                                , ("explaintext", "")
                                , ("titles", title)
                                , ("exsentences", show lines)
                                ]
    results <- wikiRequest queries
    return $ extractBetween results "xml:space=\"preserve\">" "</extract>"
       
-- | Returns a 'WikipediaPage' for the article with the given title.
-- Returns a 'WikipediaPage' with all fields null in the event of an error.
-- For error handling using 'Maybe' instead, use 'pageMaybe'.
page :: String -> IO WikipediaPage
page title = do
  maybePg <- pageMaybe title
  case maybePg of
    Nothing -> return $ WikipediaPage "" "" "" "" ""
    Just pg -> return pg
    
-- | Returns a 'WikipediaPage' for the article with the given title.
-- Errors are handled using 'Maybe' ('Nothing' is returned on error).
pageMaybe :: String -> IO (Maybe WikipediaPage)
pageMaybe title
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
      content -> return . Just $ WikipediaPage title content pageID timestamp queryURI
        where pageID = head $ extractAllAttrValues results "pageid"
              timestamp = head $ extractAllAttrValues results "timestamp"
              queryURI = show $ queriesToURI queries    
    
-- | Returns information regarding Wikipedia's text license (CC BY-SA) and
-- the license used by Aether (MIT).
licenses :: String
licenses = "The text of Wikipedia is available under the \
           \Creative Commons Attribution-ShareAlike 3.0 Unported License. \
           \Aether is an open source library available under the MIT License."