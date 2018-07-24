+++
title = "Test Driven Development in Haskell"
description = "Now with more trivial examples!"
draft = true
tags = ["technical", "rc", "haskell", "tdd"]
date = "2016-04-04"
+++

I have always been, conceptually, a fan of test driven development (TDD). Of course, I've also always been a lazy bastard, so I haven't done much of it.

For those who don't know, the idea with TDD is that you start by writing a test for the functionality you want to provide. You check and make sure this test fails. You then write the minimum viable code to make the test succeed and then write another test that fails. This is nice: you end up with tests for all your code, and you have to fully specify your code before you begin actually writing it.

One of the nice things about Haskell is that its functions (should) have no side-effects. This means you automatically get good isolation, and can pretty easily write good tests for them. [Stack](http://docs.haskellstack.org/en/stable/README/) has a built-in test runner which gives you some appropriately pretty output when you run `stack test`. I have some [nice test cases](https://github.com/mjec/cryptopals-haskell/blob/master/test/Spec.hs) set up, namely the actual challenge input and expected output from the problem specification. That's pretty nice, right?

The next bit of fun is that Haskell will compile if you have a proper type signature for a function and you set the function body to `undefined`. Obviously the system will error out if there is a call to that function. However, this makes it easy to set up your initial test case and have it fail: you have your test, your type signature and a nice no-op function.

So far that's all fairly standard. Now we fill out our function until the test passes.

Of course, sometimes you want something a little better than a single test case. Enter [QuickCheck](https://hackage.haskell.org/package/QuickCheck-2.8.2/docs/Test-QuickCheck.html). QuickCheck will automatically generate input data and ensure that a property you specify is true across that data. Because types are strict in Haskell, this can generate a wide range of data for which your function should work. Coming from a web background, I think of it as load testing. Of course, you don't have to generate those test cases yourself, and they are re-generated every time you test your application.

Who cares? Well, here are a few type signatures of library functions I've written:

```Haskell
base64_to_bytes :: String -> ByteString
bytes_to_base64 :: ByteString -> String
hex_to_bytes :: String -> ByteString
bytes_to_hex :: ByteString -> String
isHex :: String -> Bool
```

We can write a function showing the properties which (if they hold) prove that one function is an inverse of the other:

```Haskell
prop_funcInv :: (Eq a, Eq b) => (a -> b) -> (b -> a) -> a -> b -> Bool
prop_funcInv f g x y = (x == (g . f) x) and (y == (f . g))

prop_base64Inv :: String -> ByteString -> Bool
prop_base64Inv = prop_funcInv base64_to_bytes bytes_to_base64

prop_hexInv :: String -> ByteString -> Bool
prop_hexInv = prop_funcInv hex_to_bytes bytes_to_hex
```

Now we can invoke QuickCheck and make sure that for random inputs (by default, 100 per test) don't break this. While this does not *prove* that these functions are inverses, it gives us a lot of confidence. You can also configure QuickCheck to cover much larger test sets. For functions which take integers or chars, it is easy enough to test the entire domain of the function.

(You notice how I'm not even commenting on the awesome way we can use first class functions, function composition and partial application to create a general property for "these two functions are inverses". I also won't mention that you can omit the type signatures for `prop_base64Inv` and `prop_hexInv` and Haskell will figure them out automatically, meaning it doesn't matter the order in which you add those functions.)

This has some particular advantages. For example, going `ByteString -> String` involves assuming our `ByteString` contains valid UTF-8. That's probably not a legitimate assumption about `String`s, and that will be caught. We can at the very least see how we fail (and whether we care). If we do care, we can better define the property that holds, or the domain of input data that the function will accept. This makes us think about whether we really mean `Maybe String` instead of `String`. In this case, I have restricted the input data QuickCheck generates to only be valid UTF-8.

Again, we get the advantage that we have fully specified our functionality in advance.

The other thing that's nice about QuickCheck is that I can test `isHex`. This is related to a function I didn't write, `Numeric.showHex`. So, let's make that happen:

```Haskell
import Numeric (showHex)

prop_isHex :: (Integral a, Show a) => a -> Bool
prop_isHex n = True == isHex (showHex n "")
```

There are some limitations, of course. This only proves that `isHex` correctly returns `True` for hex. It says nothing about whether `isHex` returns false for non-hex. That's not a particularly good thing to test with QuickCheck, because we don't have a type which is both arbitrary and always non-hex. For example, an arbitrary string could accidentally be hex. An arbitrary number in another base would be hex. All this really does is show that we play nicely with `showHex`. If that function were ever to change its output (e.g. by prepending output with `0x`), this test would start to fail.

These examples are completely trivial, but
