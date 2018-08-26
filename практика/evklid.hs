gcd1 0 0 = error "Not allow"
gcd1 m n = gcd0 (abs m) (abs n)
    where
        gcd0 m 0 = m
        gcd0 m n = gcd0 n (rem m n)

coprime a b = gcd1 a b == 1