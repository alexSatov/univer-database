pr = print (pairs [1,2,3,4])

pairs a
    | length a == 0 = []
    | length a == 1 = [((head a), (head a))]
    | otherwise = [((head a), (last a))] ++ pairs (init $ tail a)
