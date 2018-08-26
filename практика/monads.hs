{- IO() - монада, >> - комбинирование функций, >>= - передача результата вып. пред фун. следующей -}

myFunc::IO()
myFunc = putStrLn "Enter name" >> getLine >>= \x -> putStrLn ("Hello, " ++ x)

myFunc1 = do
    putStrLn "Enter name"
    name <- getLine
    putStrLn ("Hello, " ++ name)


comChar::IO Bool
comChar = do
    putStr ">"
    c <- getChar
    return (c == '!')
    return (c == 'q')


todoList::[IO()]
todoList = [putChar 'a',
    do
        putChar 'b'
        putChar 'c',
    do
        c <- getChar
        putChar c]

doList::[IO()] -> IO()
doList [] = return ()
doList (x::xs) = do
    x
    doList xs