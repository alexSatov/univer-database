data MultiTree a = Leaf a | Node a [MultiTree a]

cntInNode::MultiTree a -> Int
cntInNode (Leaf _) = 0
cntInNode (Node _ tree) = foldr max (length tree) (map cntInNode tree)
