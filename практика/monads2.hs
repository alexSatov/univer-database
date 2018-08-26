import System.Enviroment (getArgs)

head' n = mapM_ putStrLn . take n . lines

main::IO()
main = do
    args <- getArgs
    case args of
        [n] -> getContens >>= head' (read n)
        [n, filename] -> readFile fileName >>= head' (read n)
        _ -> error "number of args..."