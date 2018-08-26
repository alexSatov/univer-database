data Name = Name String
data Work = Work String

showInfo::Name->Work -> String
showInfo (Name name) (Work work) = "Name: " ++ name ++ " Work: " ++ work

name::Name
name = Name "Ron"
work::Work
work = Work "Coder"

displ = putStrLn $ showInfo name work

-- Нельзя поменять параметры местами, строгая проверка на типы!
