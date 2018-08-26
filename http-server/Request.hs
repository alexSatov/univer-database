module Request where
import qualified Data.Map as M
data Request = Request { 
        method :: String,
        url :: String,
        proto :: String,
        headers :: M.Map String String
    } deriving (Eq, Show)
