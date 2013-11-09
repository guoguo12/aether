-----------------------------------------------------------------------------
-- |
-- Module    : Aether.Parser
-- Copyright : (c) Allen Guo 2013
-- License   : MIT
-- 
-- Maintainer : Allen Guo <guoguo12@gmail.com>
-- Stability  : alpha
--
-- This module contains several simple XML-parsing regex
-- functions, as well as other text utility functions.
--
-----------------------------------------------------------------------------
module Aether.Parser ( extractBetween
                     , extractAllAttrValues
                     , extractAttrValue
                     , trim
                     ) where

import Data.Text (pack, strip, unpack)
import Text.Regex (matchRegex, mkRegex, mkRegexWithOpts, splitRegex)

-- | Given a list of strings, returns those strings that are 
-- non-null as a list.
nonNull :: [String] -> [String]
nonNull = filter (/= [])

-- | Returns the given string with whitespace trimmed.
trim :: String -> String
trim = unpack . strip . pack

-- | A utility regex function that returns the first match found with
-- the given text and regex string. Returns an empty string if no matches
-- are found.
stdRegex :: String -> String -> String
stdRegex text regex =
  case matchRegex (mkRegexWithOpts regex False False) text of
    Nothing      -> ""
    Just matches -> head matches

-- | @extractBetween text start end@ will return the portion of @text@ between
-- @start@ and @end@ as a string.
extractBetween :: String -> String -> String -> String
extractBetween start end text = stdRegex text $ start ++ "(.*)" ++ end

-- | @extractAttrValue text attr@, where @text@ is a XML string, returns
-- the value of the first instance of the XML attribute @attr@. Returns 
-- an empty string If no instances of @attr@ exist in the given XML string.
extractAttrValue :: String -> String -> String
extractAttrValue attr text =
  case extractAllAttrValues attr text of
    [] -> ""
    xs -> head xs

-- | @extractAllAttrValues text attr@, where @text@ is a XML string, returns
-- the values of all instances of the XML attribute @attr@.
extractAllAttrValues :: String -> String -> [String]
extractAllAttrValues attr text = nonNull $ map extract chunks where
  extract = flip stdRegex (attr ++ "=\"([^\"]*)\"")
  chunks = splitRegex (mkRegex "<") text