sublist::[a]->Int->Int -> [a]
sublist list ind len = take len (drop ind list)
