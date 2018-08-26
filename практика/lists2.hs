prm_list::[Integer]
prm_list = [x | x <- [3, 5..], 
    and[x `mod` y /= 0 | y <- [3,5.. ceiling $ sqrt $ fromIntegral x]]]

-- ceiling(sqrt(fromIntegral x)); fromIntegral x - cast int x to float

prm::Int -> Integer
prm n = prm_list!!n

bmi::(RealFloat a) => [(a, a)] -> [(a, a, a)]
bmi xs = [(w, h, i) | (w, h) <- xs, let i = w/((h/100)^2), i >= 25]

duplic::Int->[a]->[a]
duplic n xs = concatMap (replicate n) xs
replicate' n x = take n (repeat x)

someF y@(1:2:3:xs) = y
someF (x:xs) = xs

