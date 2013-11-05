-----------------------------------------------------------------------------
-- |
-- Module    : Aether.WevService
-- Copyright : (c) Allen Guo 2013
-- License   : MIT
-- 
-- Maintainer : Allen Guo <guoguo12@gmail.com>
-- Stability  : alpha
--
-- This module contains the networking functions used to access Wikipedia via
-- the MediaWiki API. More information on the MediaWiki API can be found at 
-- <http://www.mediawiki.org/wiki/API>.
--
-- Note that arguments for API queries are represented as key-value pairs
-- of type '[(String, String)]'.
--
-----------------------------------------------------------------------------
module Aether.WebService ( donate
                         , stdQueries
                         , queriesToURI
                         , wikiRequest
                         ) where

import Control.Monad (void)                  
import Network.URI (URI(..), URIAuth(..))
import Network.HTTP (simpleHTTP)
import Network.HTTP.Base (rspBody, urlEncodeVars, Request(..), RequestMethod(..))
import Network.HTTP.Headers (mkHeader, Header, HeaderName(..))
import System.Cmd (system)

-- | Common query arguments that should be included in most API queries.
-- Defined as @stdQueries = [("format", "xml"), ("action", "query")]@.
-- Consult the MediaWiki API for query parameter details.
stdQueries :: [(String, String)]
stdQueries = [("format", "xml"), ("action", "query")]

-- | Returns an API query URI based on the given query arguments.
queriesToURI :: [(String, String)] -> URI
queriesToURI queries = URI { uriScheme = "http:"
                           , uriAuthority = Just $ URIAuth "" "en.wikipedia.org" ""
                           , uriPath = "/w/api.php?"
                           , uriQuery = urlEncodeVars queries
                           , uriFragment = ""
                           }

-- | Standard HTTP headers for use in networking. Currently contains Aether's
-- custom User-Agent: @Aether 0.1 (https://github.com/guoguo12/aether)@.
queryHeaders :: [Header]
queryHeaders = [mkHeader HdrUserAgent "Aether 0.1 (https://github.com/guoguo12/aether)"]

-- | Returns a API query 'Request' based on the given query arguments.
queriesToRequest :: [(String, String)] -> Request String
queriesToRequest queries = Request { rqURI = queriesToURI queries
                                   , rqMethod = GET
                                   , rqHeaders = queryHeaders
                                   , rqBody = ""
                                   }

-- | Sends an API query using the given query arguments and returns
-- the result as a string.
wikiRequest :: [(String, String)] -> IO String
wikiRequest queries = do
  let request = queriesToRequest queries
  result <- simpleHTTP $ request
  case result of
    Left _         -> return ""
    Right response -> return $ rspBody response
    
-- | Opens the Wikimedia donate page in an external web browser.
-- | Currently works on Windows only.
donate :: IO ()
donate = do
  void $ system "explorer.exe http://donate.wikimedia.org"