occurensesCount::(Ord a) => [a]->[a] -> Int
occurensesCount sl l
    | length sl > length l = 0
    | sl == l = 1
    | take (length sl) l == sl = 1 + occurensesCount sl (tail l)
    | otherwise = occurensesCount sl (tail l)
