+++
title = "My Haskell was slow"
description = "This is how I fixed it, blogged live."
tags = ["technical", "rc", "haskell", "performance"]
date = "2016-04-12"
hasMath = true
+++

I have a Haskell function that builds frequency tables. It is very slow (and not very good). Originally this post was to look at why, and try to find a way to speed it up.

It turns out that GHC (the Haskell compiler) includes some nice profiling tools. You can set "cost centres" you want to look at using the `{-# SCC "cost-centre-name" #-}` pragma. So that's what I did, and I have ended up with this:

```Haskell
buidFreqTableRecursive :: Map.Map Word8 Float -> Float -> Float -> B.ByteString -> (Float, Map.Map Word8 Float)
buidFreqTableRecursive accumulatorMap inCount totalCount bytesToAdd
    | isNull    = {-# SCC "build-branch-null" #-} (0, accumulatorMap)
    | isEmpty   = {-# SCC "build-branch-empty" #-} ((totalCount - inCount) / totalCount, Map.map (/inCount) accumulatorMap)
    | isIn      = {-# SCC "build-branch-in" #-} let newmap = Map.adjust (+1) hd accumulatorMap
                  in  buidFreqTableRecursive newmap (inCount + 1) (totalCount + 1) tl
    | otherwise = buidFreqTableRecursive accumulatorMap inCount (totalCount + 1) tl
    where hd = {-# SCC "build-head" #-} B.head bytesToAdd
          tl = {-# SCC "build-tail" #-} B.tail bytesToAdd
          isIn = {-# SCC "build-isin?" #-} Map.member hd accumulatorMap
          isEmpty = {-# SCC "build-isempty?" #-} B.null bytesToAdd
          isNull = {-# SCC "build-isnull?" #-} isEmpty && (totalCount == 0)
```

This function takes a map of `Word8` to `Float` (the `accumulatorMap`), a `Float` called `inCount` being the total number of items which are counted, a second Float called `totalCount` being the total number of bytes processed so far, and a `ByteString` being the bytes to process.

The function recurses (in the `isIn` and `otherwise` branches). The `isIn` branch passes an `accumulatorMap` adjusted by adding one to the count for the relevant key, and increments both the counters. It then asks the recursing function to process the rest of the string (`B.tail bytesToAdd`). The `otherwise` branch passes an unmodified `accumulatorMap` and increments only the `totalCount`, but otherwise is similar.

(It's worth noting that I also looked at memory usage and the amount of time in garbage collection, neither of which was a concern.)

I spent a bit of time trying to figure out how to make this function faster, but it turns out that building tens of thousands of frequency tables (one for each of 256 possibilities for each of 326 strings = 83,456 frequency tables) takes a lot of work. Even so, I did end up with this much more succinct implementation:

```Haskell
buildFreqTable :: (Int, Int, Map.Map Word8 Double) -> B.ByteString -> (Double, Map.Map Word8 Double)
buildFreqTable startingValue haystack = (realToFrac (totalCount - inCount) / realToFrac totalCount, Map.map (/inCount) freqMap)
        where (inCount, totalCount, freqMap) = B.foldl' buidFreqTableFold startingValue haystack
```

That did run marginally slower (about 5%) in my tests. At this point, I was beginning to think there had to be a better way. So I looked at the *actual problem I was trying to solve*. I'm not so much interested in all the frequency tables as I am in which table is most different from the normal distribution of English text. So rather than looping over all this test, building a data structure with the frequencies, comparing them, getting a score and sorting on it, I can do most of this at the same time.

Here's a function which computes a single score of how close the input text is to a baseline frequency table:

```Haskell
buildDelta :: Int -> Map.Map Word8 Double -> B.ByteString -> Double
buildDelta totalCount startingMap haystack = Map.fold (\x y -> abs x + y) 0 $ B.foldl (flip (Map.adjust (\a -> a - (1/realToFrac totalCount)))) startingMap haystack
```

We do need the length of the input as a parameter to optimise this, but otherwise it's a pretty straightforward pair of folds. The key was to recognise that rather than getting each frequency separately and summing them up, I could just keep a running total in my fold. It took a (very) little bit of mathematics to figure out that subtracting $\frac{1}{totalCount}$ for each occurrance was equivalent to the difference between the expected value and the total proprtion.

This did require one other change: I no longer have the `inCount`, being the number of elements which are in the `startingMap` keys (as opposed to `totalCount`, being the total number of elements). This can be a problem for short strings with small `startingMap`s. In particular, when I first started on this stuff I used a standard case-insensitive frequency of English letters. This is a map which excludes a *lot* of characters. This means that a string of gibberish with a few English letters in it could conceivably score better than unusual English text.

There are a couple of fixes for this, but the key one is to put my expectations into the actual benchmark map (e.g. I expect that byte 0x07 will not occur for most plain text, so rather than not having a 0x07 needle I should have 0x07 -> 0). I built a map of expected ASCII based on the IMDb biographies dataset, and that seems to have been working pretty well so far.

I learned several lessons here. Many of these were how to make my Haskell more like Haskell (e.g. using folds rather than maps when I want to reduce). I also learned a lot about how the Haskell profiler works. It is pretty interesting and gives some excellent data. The only weakness I found was an inability to tell me how long was being spent in a particular fold/map, as opposed to in a function. So for example, I could tell how much time I was spending inside each of my `buildDelta` lambdas, but not how much time I was spending running down the folds. This would have been useful in particular when experimenting with different types of folds - lazy vs strict, left vs right - but ended up being not an issue. You can certainly do an estimate by subtracting time in lambdas from total time in the outer function.

The key lesson though was to spend more time thinking about the problem. When I first started with Haskell it was exciting to build these tiny composable functions, and where appropriate partially apply them to get functions that do what I want. (That's still exciting, by the way.) But this makes clear that I shouldn't just be building functions which follow my thought process. I need to be looking at what my *ultimate* inputs and outputs are. If I only want one number at the end, how much of this can I do in one fold? Well, all of it apparently. I went from about 30 lines down to two, including type declaration. It doesn't reflect what the way I think about the problem, but it does reflect the actual mathematical consequence of it (and it's certainly easy enough to read).
