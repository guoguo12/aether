module WebService ( stdQueries
                  , queriesToURI
                  , wikiRequest
                  ) where

import Network.URI (URI(..), URIAuth(..))
import Network.HTTP (simpleHTTP)
import Network.HTTP.Base (rspBody, urlEncodeVars, Request(..), RequestMethod(..))
import Network.HTTP.Headers (mkHeader, Header, HeaderName(..))

stdQueries :: [(String, String)]
stdQueries = [("format", "xml"), ("action", "query")]

queriesToURI :: [(String, String)] -> URI
queriesToURI queries = URI { uriScheme = "http:"
                           , uriAuthority = Just $ URIAuth "" "en.wikipedia.org" ""
                           , uriPath = "/w/api.php?"
                           , uriQuery = urlEncodeVars queries
                           , uriFragment = ""
                           }

queryHeaders :: [Header]
queryHeaders = [mkHeader HdrUserAgent "Aether 0.1 (https://github.com/guoguo12/aether)"]

queriesToRequest :: [(String, String)] -> Request String
queriesToRequest queries = Request { rqURI = queriesToURI queries
                                   , rqMethod = GET
                                   , rqHeaders = queryHeaders
                                   , rqBody = ""
                                   }

wikiRequest :: [(String, String)] -> IO String
wikiRequest queries = do
  let request = queriesToRequest queries
  result <- simpleHTTP $ request
  case result of
    Left _         -> return ""
    Right response -> return $ rspBody response