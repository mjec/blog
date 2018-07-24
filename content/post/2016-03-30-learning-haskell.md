+++
title = "Learning Haskell"
description = "I have started to learn Haskell. It's amazing."
tags = ["technical", "rc", "haskell"]
date = "2016-03-30"
+++

I was surprised to hear that Haskell isn't really a functional language so much as it's a strongly typed one. I was of course aware that it had both these properties but it took really using it to see why the typing was so important.

I started on Monday afternoon with [Learn You A Haskell](http://learnyouahaskell.com/). It's pretty good. That, combined with a couple of group discussions sessions, has meant I'm feeling pretty confident. I'm no expert - I'm still working my way around the terminology in particular - but I've started to write actual code.

I decided to start with [the matasano crypto challenges](http://cryptopals.com/). I've actually done some of these before in Python (something like the first five challenges in set 1), so I thought it would be a nice introduction. I knew what I was looking for and how to solve the problems in the abstract. These actually made for a great intro lesson.

The thing about strongly typed languages is they are **strongly** typed. The very first challenge - and the one that took me the longest - is to read in a hex string and output those bytes encoded in base 64. Haskell has some convenient functions for this: there's [Data.ByteString](http://hackage.haskell.org/package/bytestring-0.10.6.0/docs/Data-ByteString.html) for a string of bytes, [Data.ByteString.Base16](http://hackage.haskell.org/package/base16-bytestring-0.1.1.6/docs/Data-ByteString-Base16.html) for hexadecimal and [Data.ByteString.Base64](http://hackage.haskell.org/package/base64-bytestring-1.0.0.1/docs/Data-ByteString-Base64.html) for base 64. Noting that `.` is the "function composition" operator, this makes the solution trivial:

```Haskell
hex_to_base64 :: ByteString -> ByteString
hex_to_base64 = base64_encode . base16_decode
```

(I'm still not used to camelCase and I keep using underscores. Sorry Haskellers.)

Of course, life is never quite that simple. Your input comes as a `String` and a `String` is not a `ByteString`. This is somewhat unlike Python. Okay, next try:

```Haskell
hex_to_base64 = byte_string_to_string . base64_encode . base16_decode . string_to_byte_string
```

Well, no. It turns out that the only `byte_string_to_string` function I could find (`Data.ByteString.Char8.unpack`) only works on `Data.ByteString.Char8.ByteString`s. Which are not the same as `Data.ByteString.ByteString`s. Which are also not the same as `Data.ByteString.Lazy.ByteString`s, which are what the base 16 and base 64 functions operate on.

It turns out the solution to this is [Data.Text](http://hackage.haskell.org/package/text-1.2.2.1/docs/Data-Text.html), but it took me the better part of a day (and a very helpful nudge from a fellow Recurser) to figure that out.

Now that I know that though, the solution is genuinely trivial. Here it is in full, written as a single function.

```Haskell
import qualified Data.ByteString.Base16.Lazy as B16
import qualified Data.ByteString.Base64.Lazy as B64
import qualified Data.Text.Lazy as Txt
import qualified Data.Text.Lazy.Encoding as TxtEnc

hex_to_base64 :: String -> String
hex_to_base64 = Txt.unpack . TxtEnc.decodeUtf8 . B64.encode . fst . B16.decode . TxtEnc.encodeUtf8 . Txt.pack
```

My actual code is a little different, because I've broken it down into functions like `hex_to_bytes` and `bytes_to_base64` which I expect (know) I'll use later.

(In case you don't know, `hex_to_base64 :: String -> String` is an optional type declaration, which says `hex_to_base64` takes a `String` paramater and outputs a `String` paramter. Everything in Haskell is a function, even static data.)

A few things that I find particularly impressive:

 * Genuinely, once it compiles, it works. I spend most of my time debugging type errors and only rarely do I find logic errors. It fails early and often, which turns out to be great.
 
 * I know exactly what is going in and exactly what is coming out.
 
 * It's all one line! Function composition using `.` means I don't declare my input parameter or what I'm returning. I just compose functions, which provably fit together.

A few other pieces of code which I think illustrate Haskell's strengths nicely. Here's one which returns true if and only if all characters in the string match the regex `[A-Fa-f0-9]+`:

```Haskell
isHex :: String -> Bool
isHex x = all (`elem` ['A'..'F'] ++ ['a'..'f'] ++ ['0'..'9']) x
```

So what, we can all do regex, right? Well, I get to use this to parse my input from the command line like so:

```Haskell
challenge1 :: [String] -> IO ()
challenge1 (x:[])
    | isHex x = do putStrLn $ hex_to_base64 x
    | otherwise = usage_failure $ unlines
        [ "That is not a valid way to run 1-1 (maybe ask for help?)"
        , "Your hex string must be actual hex i.e. [A-Za-z0-9]+"]
```

I implemented `usage_failure` (there's that underscore again) but everything else comes for free. In particular, note the guard syntax: we get to determine the return based on testing the input.

I quite like this one too:

```Haskell
bitwiseCombine :: (Word8 -> Word8 -> Word8) -> B.ByteString -> B.ByteString -> B.ByteString
bitwiseCombine f x y = B.pack $ B.zipWith (\x y -> (x `f` y)) x y
```

This combines two `ByteString`s by applying the `f` operator (as an infix) to each byte of the arguments, then returns a new `ByteString`. You can use this and [currying](https://en.wikipedia.org/wiki/Currying) to make a new function for whatever operator you want. For example, I have this:

```Haskell
bitwiseXor :: B.ByteString -> B.ByteString -> B.ByteString
bitwiseXor = bitwiseCombine `xor`
```

This now only takes two arguments, `ByteString`s, and returns the `xor` of them. Bam. One line.

Currying is also why we have that weird type signature: each function takes *one* argument and returns a new function which returns the next thing separated by a `->`. When you get to the end of the list, you have data. The `(Word8 -> Word8 -> Word8)` in parentheses is a function which has that signature.

Okay, last one. This function takes two "maps", each of which is essentially a key-value pair with keys composed of `Word8`s and values composed of `Float`s. As the name might suggest, these are frequency tables, where the `Word8` is a byte (e.g. 'A') and the `Float` is what proportion of the whole it makes up (in the range `0 .. 1`). `freqTableDifference` takes the absolute values of the differences between paired elements, discarding anything that is not in the intersection of the maps. `freqTableDelta` sums those differences into a basic score showing roughly how different the two are (think [Hamming distance](https://en.wikipedia.org/wiki/Hamming_distance), but not).


```Haskell
freqTableDelta :: Map.Map Word8 Float -> Map.Map Word8 Float -> Float
freqTableDelta x y = sum $ Map.elems $ freqTableDifference x y

freqTableDifference :: Map.Map Word8 Float -> Map.Map Word8 Float -> Map.Map Word8 Float
freqTableDifference x y = Map.differenceWith (\a b -> Just $ abs (a - b)) x y
```

That's right, the explanation took far, far longer than the code, *even with optional type signatures*. That's the beauty of functional programming. Combined with strong types, this experience is incredibly fluid. I hope it's clear how exciting this prospect is for me. Every function I write in Haskell is just as short. The longest section of code which is actually code (and not data) is six lines. That function takes a list of characters to look for (needles) and builds up those frequency tables. It also takes care of edge cases, ensures that there is a value of 0 for items in the needle but not in the string, returns a second paramter showing the proportion of elements in the string not in the needle and takes care of conversion to appropriate data types in both directions. **In six lines** and without becoming [Perl](https://en.wikipedia.org/wiki/Just_another_Perl_hacker).

This has been day three of RC. 87ish more days.
