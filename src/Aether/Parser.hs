module Aether.Parser ( extractBetween
                     , extractAllAttrValues
                     , trim
                     ) where

import Data.Text (pack, strip, unpack)
import Text.Regex (matchRegex, mkRegex, mkRegexWithOpts, splitRegex)

nonNull :: [String] -> [String]
nonNull = filter (/= [])

trim :: String -> String
trim = unpack . strip . pack

stdRegex :: String -> String -> String
stdRegex text regex =
  case matchRegex (mkRegexWithOpts regex False False) text of
    Nothing      -> ""
    Just matches -> head matches

extractBetween :: String -> String -> String -> String
extractBetween text start end = stdRegex text $ start ++ "(.*)" ++ end

extractAllAttrValues :: String -> String -> [String]
extractAllAttrValues text attr = nonNull $ map extract chunks where
  extract = flip stdRegex (attr ++ "=\"([^\"]*)\"")
  chunks = splitRegex (mkRegex "<") text