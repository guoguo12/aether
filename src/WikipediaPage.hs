module WikipediaPage ( isRedirect
                     , WikipediaPage(..)
                     ) where

import Data.List (isPrefixOf)

-- TODO: Add additional WikipediaPage fields and functions
data WikipediaPage = WikipediaPage { title :: String
                                   , content :: String
                                   , queryURI :: String
                                   } deriving (Show)

isRedirect :: WikipediaPage -> Bool
isRedirect = isPrefixOf "#REDIRECT [[" . content