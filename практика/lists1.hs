minim::(Ord a) => [a] -> a
minim [] = error "Can not define"
minim [x] = x
minim (x:xs) = min x (minim xs)


addVectors::(Num a) => (a, a)->(a, a) -> (a, a)
addVectors a b = (fst a + fst b, snd a + snd b)

addVectors'::(Num a) => (a, a)->(a, a) -> (a, a)
addVectors' (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

head1::(Ord a) => [a] -> a
head1 [] = error "Empty list"
head1 (x:xs) = x

min1::(Ord a) => [a] -> a
min1 [] = error "Can not define"
min1 [x] = x
min1 (x:xs)
    | x <= (min1 xs) = x
    | otherwise = (min1 xs)