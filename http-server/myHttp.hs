import Prelude hiding (catch)
import Network
import Control.Monad
import Control.Concurrent
import System.IO
import Text.Regex
import Control.Applicative
import Control.Arrow
import qualified Control.Exception as E
import qualified  Data.List as L
import qualified  Data.Map as M
import qualified Response as Resp
import qualified Request as Req


port :: Integer
port = 31337

composeAnswer :: Resp.Response -> String
composeAnswer (Resp.Response {Resp.code=code, Resp.headers=headers, Resp.body=body}) 
    = L.intercalate "\r\n" [statusString, "", body]
    where
        statusString =  unwords ["HTTP/1.0", show code, Resp.code2str code]


serve :: Handle -> String -> IO()
serve handle remote = do
    do
        reqStr <- hGetLine handle
        print reqStr
        let resp = Resp.fromCode 200 "Yes, it works"
        let res = composeAnswer resp
        print res
        hPutStr handle $ composeAnswer resp 
    hClose handle

main :: IO ()
main = withSocketsDo $ do
    sock <- listenOn $ PortNumber $ fromIntegral port
    putStrLn $ "Listen on: " ++ show port
    forever $ do
        (handle, host, _) <- accept sock
        forkIO $ serve handle host
