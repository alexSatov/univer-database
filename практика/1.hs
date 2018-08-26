-- inc1::Int->Int
{--
multi line comments
--}
inc1 = (+1)

abs1 x = if x >= 0 then x else (-x) 

abs2 x
    | x >= 0 = x
    | otherwise = (-x)

max1 x y
    | x >= y = x
    | otherwise = y 