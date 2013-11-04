-- TODO: Add documentation.

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
isInvalidTitle :: String -> Bool
isInvalidTitle = null

search :: String -> IO [String]
search terms = do
  let queries = stdQueries ++ [ ("list", "search")
                              , ("srsearch", terms)
                              , ("srlimit", "10")
                              , ("srprop", "")
                              ]
  results <- wikiRequest queries
  return $ extractAllAttrValues results "title"

suggest :: String -> IO [String]
suggest terms = do
  let queries = stdQueries ++ [ ("list", "search")
                              , ("srsearch", terms)
                              , ("srinfo", "suggestion")
                              , ("srprop", "")
                              ]
  results <- wikiRequest queries
  return $ extractAllAttrValues results "suggestion"

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