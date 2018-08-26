heron a b c = sqrt(p*(p-a)*(p-b)*(p-c))
    where p = (a+b+c)/2

heron1 a b c = do
    let p = (a+b+c)/2
        x = p-a
        y = p-b
        z = p-c
    sqrt(p*x*y*z)

-- или in без do

