### Currently all code is "TDD as if you meant it"

This means that the implementation code is written in the same file as the tests.

The Database service is currently spoofed with a class that performs look ups equivalent to "LIKE" lookups.

### The current strategy is as follows:

- In order to narrow the search space as quickly as possible, we first find a subset of only those tokens which contain at least one of the words in the subject. 
- Find the maximum sensible number of words in a token - which is the minimum of the maximum number of words in any token stored in the database and the total number of words in the message to be compressed.
- Beginning with the maximum, attempt to match groups of words of this size to tokens.
- We slide a window of this group size along the subject - starting with the first word.
- When groups are matched they are removed from the search subject.
- We continue to look for smaller and smaller groups until we are searching for single words.
- Because this method does not guarantee the fewest tokens, we're using simulated annealing to decide whether to repeat the process, searching for a breakdown which produces fewer tokens.
- The annealing threshold is essentially a value between 0 and 1, which decreases with each cycle. We then generate a random value and if it's higher than the annealing threshold, we repeat the process.
- If we repeat, we do so by starting again using max-1 as the supposed maximum group size.

### The strategy in context

- Some subjects will first need to be subdivided using David A's search for links / twitter handles / numbers etc.
- In many cases we'll have multiple smaller subjects, rather than a single long subject.

### Possible improvements to the strategy and gaps in understanding:

If 'max' is large, instead of repeating the process with max-1, we could select a value between (2 and max-1) at random. Or we could do interval bisection - eg max, max/2, 3max/4, max/4... and so on.

It's not yet possible to tell whether this is a true hill climbing problem (in which there are smooth rises and falls in results over sets of values) or whether it's just a discontinuous set of results.

### The purpose of the annealing value

We could allow users to set the annealing value for themselves (a high value means lots of tries at finding a more efficient breakdown, a low value or 0 means that the first attempt is accepted).

Or... we could keep count of our tokens and alter the annealing value accordingly - ie, if this message is now shorter than the 140 (or less) tokens that means I can tweet it, we're done. 