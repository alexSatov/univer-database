module Response 
where

import qualified Data.Map as M

type Code = Int

data Response = Response {
    code :: Code,
    headers :: M.Map String String,
    body :: String
} deriving (Eq, Show)

fromBody :: String -> Response
fromBody = Response 200 M.empty

fromCode :: Int -> String-> Response
fromCode code' = Response code' M.empty

code2str :: Code -> String
code2str 200 = "OK"
code2str 404 = "Not found"
code2str 500 = "Server fault"
code2str _   = "Unknown"

addHeader :: Response -> (String, String) -> Response
addHeader resp@Response {headers=headers'} (key, val) = resp {headers=M.insert key val headers'}
