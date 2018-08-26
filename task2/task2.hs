import Control.Monad
import System.Directory

main::IO()
main = do
    dirName <- getLine
    absDirPath <- makeAbsolute dirName
    isDirExist <- doesDirectoryExist absDirPath
    if isDirExist then
        printExecutablesRecursive absDirPath
    else do 
        print ("Directory " ++ dirName ++ " doesn't exist.")


printExecutablesRecursive::FilePath -> IO()
printExecutablesRecursive dirName = do
    setCurrentDirectory dirName
    content <- listDirectory "."
    execFiles <- filterM (liftM executable . getPermissions) content
    let execAbsFiles = [dirName ++ "\\" ++ x | x <- execFiles]
    print execAbsFiles

    innerDirs <- filterM doesDirectoryExist content
    let innerAbsDirs = [dirName ++ "\\" ++ x | x <- innerDirs]
    forM_ innerAbsDirs printExecutablesRecursive 
