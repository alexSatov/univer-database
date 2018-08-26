-- [[1, 2], 3] -> [1, 2, 3]

data NestedList a = Elem a | List [NestedList a]

unGroup::NestedList a -> [a]
unGroup (Elem a) = [a]
unGroup (List a) = concatMap unGroup a
