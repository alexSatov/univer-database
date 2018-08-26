module RBTree(RBTree, insert, delete, height, contains, treeFromList) where

data Color = R | B deriving Show
data RBTree a = Empty | Node a Color (RBTree a) (RBTree a) deriving Show


insert::Ord a => RBTree a->a -> RBTree a
insert tree x = 
    Node root B l r
    where 
    Node root _ l r = ins tree
    ins Empty = Node x R Empty Empty

    ins tree@(Node a B l r)
        | x < a = balance a (ins l) r
        | x > a = balance a l (ins r)
        | otherwise = tree

    ins tree@(Node a R l r)
        | x < a = Node a R (ins l) r
        | x > a = Node a R l (ins r)
        | otherwise = tree

balance::a->RBTree a->RBTree a -> RBTree a
balance g (Node p R (Node n R c1 c2) c3) u@(Node _ B _ _) = Node p B (Node n R c1 c2) (Node g R c3 u)
balance g (Node p R (Node n R c1 c2) c3) Empty = Node p B (Node n R c1 c2) (Node g R c3 Empty)
balance g u@(Node _ B _ _) (Node p R c1 (Node n R c2 c3)) = Node p B (Node g R u c1) (Node n R c2 c3)
balance g Empty (Node p R c1 (Node n R c2 c3)) = Node p B (Node g R Empty c1) (Node n R c2 c3)

balance g (Node p R c1 (Node n R c2 c3)) u@(Node _ B _ _) = Node n B (Node p R c1 c2) (Node g R c3 u)
balance g (Node p R c1 (Node n R c2 c3)) Empty = Node n B (Node p R c1 c2) (Node g R c3 Empty)
balance g u@(Node _ B _ _) (Node p R (Node n R c1 c2) c3) = Node n B (Node g R u c1) (Node p R c2 c3)
balance g Empty (Node p R (Node n R c1 c2) c3) = Node n B (Node g R Empty c1) (Node p R c2 c3)

balance g (Node p R c1 c2) (Node u R c3 c4) = Node g R (Node p B c1 c2) (Node u B c3 c4)

balance p c1 c2 = Node p B c1 c2


delete::Ord a => RBTree a->a -> RBTree a
delete tree x
    | (contains tree x) = del tree
    | otherwise = error "Tree doesn't contain this element"
        where
        del (Node x _ Empty Empty) = Empty
        del (Node x _ (Node l _ ll lr) Empty) = Node l B ll lr 
        del (Node x _ Empty (Node r _ lr rr)) = Node r B lr rr
        del (Node a c l r)
            | x < a = balleft a c (del l) r
            | x > a = balright a c l (del r)
            | otherwise = Node lm c l (delete r lm) where lm = leftMost r

balleft::a->Color->RBTree a->RBTree a -> RBTree a
balleft a B x@(Node _ B _ _) (Node b R c d) = Node b B (Node a R x c) d
balleft a _ x@(Node _ B _ _) (Node b B (Node c B cl cr) (Node d B dl dr)) = Node a B x (Node b R (Node c B cl cr) (Node d B dl dr))
balleft a col x@(Node _ B _ _) (Node b B (Node c R cl cr) (Node d B dl dr)) = Node a col x (Node c B cl (Node b R cr (Node d B dl dr)))
balleft a col x@(Node _ B _ _) (Node b B c (Node d R dl dr)) = Node b col (Node a B x c) (Node d B dl dr)
balleft a col l r = Node a col l r

balright::a->Color->RBTree a->RBTree a -> RBTree a
balright a B (Node b R d c) x@(Node _ B _ _) = Node b B d (Node a R c x)
balright a _ (Node b B (Node d B dl dr) (Node c B cl cr)) x@(Node _ B _ _) = Node a B (Node b R (Node d B dl dr) (Node c B cl cr)) x
balright a col (Node b B (Node d B dl dr) (Node c R cl cr)) x@(Node _ B _ _) = Node a col (Node c B (Node b R (Node d B dl dr) cl) cr) x
balright a col (Node b B (Node d R dl dr) c) x@(Node _ B _ _) = Node b col (Node d B dl dr) (Node a B c x)
balright a col l r = Node a col l r

leftMost::RBTree a -> a
leftMost (Node a _ Empty r) = a
leftMost (Node _ _ l r) = leftMost l


contains::Ord a => RBTree a->a -> Bool
contains Empty x = False
contains (Node a _ l r) x
    | x < a = contains l x
    | x > a = contains r x
    | otherwise = True


height::RBTree a -> Integer
height Empty = 0
height (Node _ _ l r) = 1 + max (height l) (height r)


treeFromList::Ord a => [a] -> RBTree a
treeFromList list = foldl insert Empty list
