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
module Aether ( search
              , searchMaybe
              , suggest
              , suggestMaybe
              , random
              , randomMaybe
              , summary
              , summaryMaybe
              , page
              , pageMaybe
              ) where

import Data.Maybe (fromMaybe)
import Data.Text (empty, pack)
import Aether.Parser (extractBetween, extractAllAttrValues, extractAttrValue, trim)
import Aether.WebService (stdQueries, queriesToURI, wikiRequest)
import Aether.WikipediaPage

-- TODO: Add additional tests for title validity
-- | Tests if the given Wikipedia page title is invalid
isInvalidTitle :: String -> Bool
isInvalidTitle = null

-- | Returns a list of up to 10 Wikipedia search results
-- based on the given search terms. For error handling using 
-- 'Maybe', use 'searchMaybe'.
search :: String -> IO [String]
search terms = do
  maybeSearch <- searchMaybe terms
  case maybeSearch of
    Nothing -> return []
    Just xs -> return xs
  
-- | Same as 'search', except errors are handled using 'Maybe'. 
-- 'Nothing' is returned in the event of a network error.
searchMaybe :: String -> IO (Maybe [String])
searchMaybe terms = do
  let queries = stdQueries ++ [ ("list", "search")
                              , ("srsearch", terms)
                              , ("srlimit", "10")
                              , ("srprop", "")
                              ]
  maybeResults <- wikiRequest queries
  return $ fmap (extractAllAttrValues "title") maybeResults

-- | Returns a suggestion based on the given search terms.
-- Returns an empty string if no suggestion is available, or
-- if a network error occurs. For error handling using 'Maybe'
-- instead, use 'suggestMaybe'.
suggest :: String -> IO String
suggest terms = do
  maybeSuggest <- suggestMaybe terms
  return $ fromMaybe "" maybeSuggest
  
-- | Same as 'suggest', except errors are handled using 'Maybe'. 
-- 'Nothing' is returned in the event of a network error.
-- If no suggestion is available, then @Just \"\"@ is returned.
suggestMaybe :: String -> IO (Maybe String)
suggestMaybe terms = do
  let queries = stdQueries ++ [ ("list", "search")
                              , ("srsearch", terms)
                              , ("srinfo", "suggestion")
                              , ("srprop", "")
                              , ("srlimit", "1")
                              ]
  maybeResults <- wikiRequest queries
  return $ fmap (extractAttrValue "suggestion") maybeResults

-- | Returns a list of random Wikipedia article titles.
-- The given 'Int' determines the length of the list; up to 10
-- titles can be fetched at once. The returned list is guaranteed
-- to contain no duplicate titles. For error handling using 'Maybe',
-- use 'randomMaybe'.
random :: Int -> IO [String]
random pages = do
  maybeRandomPages <- randomMaybe pages
  return $ fromMaybe [] maybeRandomPages
    
-- | Same as 'random', except errors are handled using 'Maybe'. 
-- 'Nothing' is returned in the event of a network error.
randomMaybe :: Int -> IO (Maybe [String])
randomMaybe pages
  | pages <= 0 = return $ Just []
  | otherwise = do
    let queries = stdQueries ++ [ ("list", "random")
                                , ("rnnamespace", "0")
                                , ("rnlimit", show pages)
                                ]
    maybeResults <- wikiRequest queries
    return $ fmap (extractAllAttrValues "title") maybeResults
    
-- | Returns a summary of the Wikipedia article with the given title.
-- The summary will be about one line long. Returns an empty string
-- in the event of an error. For error handling using 'Maybe' instead,
-- use 'summaryMaybe'.
summary :: String -> IO String
summary title = do
  maybeSummary <- summaryMaybe 1 title
  return $ fromMaybe "" maybeSummary
    
-- | Returns a summary of the Wikipedia article with the given title.
-- The given 'Int' determines the maximum summary length, in lines.
-- Errors are handled using 'Maybe'. 'Nothing' is returned in the event
-- of a network error. However, if the given page does not exist,
-- @Just \"\"@ will be returned.
summaryMaybe :: Int -> String -> IO (Maybe String)
summaryMaybe lines title
  | isInvalidTitle title = return $ Just ""
  | otherwise = do
    let queries = stdQueries ++ [ ("prop", "extracts")
                                , ("explaintext", "")
                                , ("titles", title)
                                , ("exsentences", show lines)
                                ]
    maybeResults <- wikiRequest queries
    return $ fmap (extractBetween "xml:space=\"preserve\">" "</extract>") maybeResults
       
-- | Returns a 'WikipediaPage' for the article with the given title.
-- Returns a 'WikipediaPage' with all fields null in the event of an error.
-- For error handling using 'Maybe' instead, use 'pageMaybe'.
page :: String -> IO WikipediaPage
page title = do
  maybePg <- pageMaybe title
  case maybePg of
    Nothing -> return $ WikipediaPage "" empty "" "" ""
    Just pg -> return pg
    
-- | Returns a 'WikipediaPage' for the article with the given title.
-- Errors are handled using 'Maybe'. ('Nothing' is returned if the page
-- cannot be accessed or does not exist.)
pageMaybe :: String -> IO (Maybe WikipediaPage)
pageMaybe title
  | isInvalidTitle title = return Nothing
  | otherwise = do
    let queries = stdQueries ++ [ ("prop", "revisions")
                                , ("rvprop", "content|timestamp")
                                , ("rvlimit", "1")
                                , ("titles", title)
                                ]
    maybeResults <- wikiRequest queries
    let results = fromMaybe "" maybeResults
    case extractBetween "xml:space=\"preserve\">" "</rev>" results of
      ""      -> return Nothing
      content -> return . Just $ WikipediaPage title contentText pageID timestamp queryURI
        where contentText = pack content
              pageID = extractAttrValue "pageid" results
              timestamp = extractAttrValue "timestamp" results
              queryURI = show $ queriesToURI queries