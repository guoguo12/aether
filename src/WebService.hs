module WebService ( stdQueries
                  , wikiRequest
                  ) where

import Network.URI (URI(..), URIAuth(..))
import Network.HTTP (simpleHTTP)
import Network.HTTP.Base (Request(..), RequestMethod(..), rspBody, urlEncodeVars)
import Network.HTTP.Headers (mkHeader, Header, HeaderName(..))

type Query = String

stdQueries :: [(String, String)]
stdQueries = [("format", "xml"), ("action", "query")]

queryToURI :: Query -> URI
queryToURI query = URI { uriScheme = "http:"
                       , uriAuthority = Just $ URIAuth "" "en.wikipedia.org" ""
                       , uriPath = "/w/api.php?"
                       , uriQuery = query
                       , uriFragment = ""
                       }

queryHeaders :: [Header]
queryHeaders = [mkHeader HdrUserAgent "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.69 Safari/537.36"]

queryToRequest :: Query -> Request String
queryToRequest query = Request { rqURI = queryToURI query
                               , rqMethod = GET
                               , rqHeaders = queryHeaders
                               , rqBody = ""
                               }

wikiRequest :: [(String, String)] -> IO String
wikiRequest queries = do
  let request = queryToRequest $ urlEncodeVars queries
  result <- simpleHTTP $ request
  case result of
    Left _         -> return ""
    Right response -> return $ rspBody response