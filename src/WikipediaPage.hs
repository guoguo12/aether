module WikipediaPage (WikipediaPage(..)) where

-- TODO: Add additional WikipediaPage fields and functions
data WikipediaPage = WikipediaPage { title :: String
                                   , content :: String
                                   } deriving (Show)