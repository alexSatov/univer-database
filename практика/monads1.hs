main = do
    res <- calcsum
    print res


calcsum::IO String
calcsum = do
    putStr ">"
    n <- getLine
    if n == "" then return ("0")
    else do
        nextN <- getLine
        let n1 = read n :: Int
        let nextN1 = read nextN :: Int
        let res = n1 + nextN1
        return res