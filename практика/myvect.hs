type Myvect a = (a, a)

vectSum::(Num a) => Myvect a->Myvect a -> Myvect a
vectSum (a, b) (c, d) = (a+c, b+d)

type Name = String
type Work = String

showInfo::Name->Work -> String
showInfo name work = "Name: " ++ name ++ " Work: " ++ work

name::Name
name = "Robin"
work::Work
work = "Coder"

displ = putStrLn $ showInfo name work