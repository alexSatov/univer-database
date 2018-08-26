data Complex a = Complex a a deriving (Show, Eq)

inv::(Num a) => Complex a -> Complex a
inv (Complex x y) = Complex x (-y)

myPrint::(Num a, Ord a, Show a) => Complex a -> String
myPrint (Complex x y) 
    | y < 0 = show x ++ " - " ++ show (-y) ++ "i"
    | otherwise = show x ++ " + " ++ show y ++ "i"

x::(Num a) => Complex a
x = Complex 1 2
displ = print $ myPrint $ inv x
