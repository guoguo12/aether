-- TODO: Add documentation.

module Aether ( search
              , suggest
              , random
              , summary
              , page
              , WikipediaPage(..)
              ) where        

import Parser (extractBetween, extractAll, trim)
import WebService (stdQueries, wikiRequest)

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
  return $ extractAll results "title"

suggest :: String -> IO [String]
suggest terms = do
  let queries = stdQueries ++ [ ("list", "search")
                              , ("srsearch", terms)
                              , ("srinfo", "suggestion")
                              , ("srprop", "")
                              ]
  results <- wikiRequest queries
  return $ extractAll results "suggestion"

random :: Int -> IO [String]
random pages
  | pages <= 0 = return []
  | otherwise = do
    let queries = stdQueries ++ [ ("list", "random")
                                , ("rnnamespace", "0")
                                , ("rnlimit", show pages)
                                ]
    results <- wikiRequest queries
    return $ extractAll results "title"

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
                                , ("rvprop", "content")
                                , ("rvlimit", "1")
                                , ("titles", title)
                                ]
    results <- wikiRequest queries
    case trim $ extractBetween results "xml:space=\"preserve\">" "</rev" of
      ""      -> return Nothing
      content -> return . Just $ WikipediaPage title content
  
-- TODO: Add additional WikipediaPage fields and functions
data WikipediaPage = WikipediaPage { title :: String
                                   , content :: String
                                   } deriving (Show)