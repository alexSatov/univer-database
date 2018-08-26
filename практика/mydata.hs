data MyData = O | I | II | III | IV deriving (Eq, Ord, Show)

next::MyData -> MyData
next O = I
next I = II
next II = III
next III = IV
next IV = 0

prev::MyData -> MyData
prev O = IV
prev I = O
prev II = I
prev III = II
prev IV = III

(+++)::MyData->MyData -> MyData
O +++ x = x
n +++ x = next (prev n +++ x)
