+++
title = "Finding subsets with particular sums"
description = "Given a list L and a sum S, what's the best way to find x, y in L such that x + y = S? What about a set of n integers with that sum, instead of a pair? I don't have a good answer for the second question; suggestions welcome!"
tags = ["technical", "rc", "algorithms"]
date = "2016-04-11"
hasMath = true
+++

On Friday I came in on the tail end of a conversation explaining the solution to this problem. I think it's pretty interesting.

Given a list of integers `L` and a target sum `S`, what's the best way to find the pair `x, y` where `x` and `y` are both distinct elements of `L` such that `x + y = S`? We also want to be able to determine if there is no such pair.

The naive solution is to loop over `L` twice and see if you can find the sum:

```Python
def find_pair(L, S):
  for i in L:
    for j in L:
      if i + j = S:
        return (i, j)
  raise NoSuchPair
```

The complexity of this solution is $O(n^2)$, which is not ideal.

The solution that was being explained when I walked in has complexity $O(n \log n)$, which is much better (and I'm led to believe is the best general-case solution). That goes something like this:

```Python
def find_pair(L, S):
  d = {}
  i = 0
  for v in L:
    d[S - v] = i
    i = i + 1

  i = 0
  for v in L:
    if v in d.keys() and d[v] != i:
      return (v, l[d[v]])
    i = i + 1
  raise NoSuchPair
```

Let's step this through.

We start by initialising a dictionary `d` and an index `i`. Then we loop over the list once. We insert an element in the dictionary indexed by the difference between our target sum `S` and the value of the current element `v`. The value of this element is the index in the list `L` of the current element.

Note that we just overwrite the element if it exists.

We now have a dictionary the *keys* of which are numbers we need to get to our target `S`, and the *values* of which are the indices in `L` of the other half of the pair to get to `S`.

We then loop over the list `L` again, and this time check to see whether it is a key in the dictionary. If it is, that means we have found a match between the number in the list (`v` in the second loop) and a number we need to get to `S` (some key of `d`).

We also check to make sure that the index of the number in the dictionary (i.e. its value) is not the same as the index of the number we are looking at. If it were, that would be reusing a number in the dictionary, which is bad.

This is also what makes it okay (and indeed necessary!) to overwrite the value at that key if we already come across it in the first loop. Because each loop through `L` takes place in the same order, the first time the *second* loop finds an appropriate key of `d`, that will be for a different element of `L` if there is any such element.

Complexity-wise, we only step through the list twice, which is $O(n)$. We also build a dictionary (hash map) from the list, which is $O(n \log n)$. Dictionary lookups are $O(\log n)$ at worst. Overall, therefore, building the dictionary dominates and we end up with $O(n \log n)$. Yay!

We can look at a simple example:

```Python
L = [3, 7, 5, 9, 1]
S = 6
```

Our function `find_pair` will first loop through L and build the following dictionary:

```Python
{  3: 0,    #  3 (key) = 6 (S) - 3 (v in first loop)
  -1: 1,    # -1 (key) = 6 (S) - 7 (v in first loop)
   1: 2,    #  1 (key) = 6 (S) - 5 (v in first loop)
  -3: 3,    # -3 (key) = 6 (S) - 9 (v in first loop)
   5: 4 }   #  5 (key) = 6 (S) - 1 (v in first loop)
```

We then loop through `L` again, each step of which looks like this:

1. `i == 0`, `v == 3`. `3` is in `d.keys()` and `d[3] == 0`. But `i == 0 == d[3]` so this is not a solution: it's just doubling a single number in the array.
2. `i == 1`, `v == 7`. `7` is not in `d.keys()` so this is not a solution.
3. `i == 2`, `v == 5`. `5` is in `d.keys()` and `d[5] == 4`. Since `i == 2 != d[5]`, we now have a solution: `(5, L[d[5]]) == (5, L[4]) == (5, 1)`. Which we can check: `5 + 1 == 6`.

At that point, we bail out because we have found a solution.

It should be obvious that if we never hit `return` then we have found there is no such pair, and so we raise an appropriate exception.

This is pretty neat.

For clarity, if `L = [3, 3, 3, 4]` and `S = 6`, we would get the solution `(3, 3)`, because our dictionary would look like this:

```Python
{  3: 2,    # 3 (key) = 6 (S) - 3 (v)
   # L[2] is the last element for which this holds
   # and the last such element overwrites the previous values at key 3,
   # namely {3: 0} and {3: 1}
   2: 3 }   # 2 (key) = 6 (S) - 4 (v)
```

Now for the tough question:

Given a list of integers `L` and a target sum `S`, what's the best way to find the set of n integers `[x_1, x_2, ..., x_n]` where each `x_i` is a distinct element of `L` such that `x_1 + x_2 + ... + x_n = S`? We also want to be able to determine if there is no such set.

This question was raised at the whiteboard, but no definitive solution was worked out. The best solution I have is to recursively call the `find_pair` algorithm described above. This seems a little silly, but I can't find a better way that deals with the fact that you're not allowed to pull the same element twice. I think the complexity of this is $O((n \log n)^{a - 1})$ where `a` is the number of integers to find (which can I think be simplified, but this shows how the original algorithm is used). This seems... bad.

So, anyone have a better solution for the general case? Hit me up [on twitter](https://twitter.com/mjec) or something.
