# Search High and Low

A workshop on finding things with computers.

## Setup

1. Download the zip of this repository, or `clone` it with `git`.
2. Open Terminal and `cd` into this directory.

## Regular Expressions

Regular expressions (regexes for short) find patterns in texts. They are powerful, flexible and are especially useful in unstructured documents. Many programming languages, text editors and command line tools support regexes.

A few examples of things regexes can help you do:

* Find all the hyphenated words in a text
* Find every word that comes after "I"
* Extract all of the comments from a javascript file
* Extract all the YouTube video IDs from a webpage
* Guess if a string is an email address

Let's work through the first use case, "find all hyphenated words in a text".

First we need to define the pattern that we're looking for. Ultimately we're looking for words with hyphens, so let's start just by looking for words. We have a lot of options to define what a word is, but let's start very simply and say that a word is anything consisting entirely of letters from the alphabet.

The regex for that looks like this:

    [A-Za-z]+

The square brackets `[]` denote a set of characters. `A-Z` means anything from uppercase A to uppercase Z. We could have written this out manually like `[ABCDEFGHIJKLMNOPQRSTUVWXYZ]` but the shorthand is obviously quicker. `a-z` means the same except for lowercase characters. `+` means "at least once".

Let's test this out with `grep`. `grep` is a command line program that searches text for a regex and prints out what it finds. And you probably (almost definitely) have it on your computer already. A grep command looks like:

    grep (options) "my regex" filename.txt

In terminal, type

    grep -E "[A-Za-z]+" texts/dracula.txt

When you run this command, you will get almost the entire book spit back out. This is because `grep`'s default behavior is not to print the match, but the line on which the match was found. And just about every line in Dracula has a letter on it.

By the way, the option `E` means "extended" which is closer to the kind of regex you will normally encounter in modern programming languages. You can see all the options by running `man grep` in terminal. Let's add another option that will print only the matches, not the whole line. This is option is `o`, which is short for "only matching".

    grep -Eo "[A-Za-z]+" texts/dracula.txt

Let's expand our definition of a word a bit. Words can sometimes include apostrophes, so let's add that to our set of characters:

    grep -Eo "[A-Za-z']+" texts/dracula.txt

It's hard to see with so many words, but now our result set includes words with apostrophes. To be exact, this will match words with an apostrophes anywhere in it. Generally we only care about apostrophes in the middle of a word, like `hasn't`. But this will also match apostrophes at the beginning or end of a word, so a word that is wrapped in single quotes like `'this'` would be matched as `'this'` and not `this`. This may not be how you want your regex to behave but it's good enough for us.

(And if you want to be _really_ pedantic you'll note that it's matching a typewriter apostrophe and not a proper typographic apostrophe, but since our text file is ASCII, that's not a problem.)

Now to start looking for hyphens. You can see we already used a hyphen in the regex to signify a range between two characters. This is because the hyphen is a character with special meaning in regex-land so if we want to refer to the actual hyphen character, we need to escape it. We escape characters with a backslash `\`. Try entering:

    grep -Eo "[A-Za-z']+\-" texts/dracula.txt

Which shows us the first half of all the hyphenated words. To find the other half of the hypenated word, we can duplicate our single-word regex on the other side of the hyphen:

    grep -Eo "[A-Za-z']+\-[A-Za-z']+" texts/dracula.txt

Without leaving the command line, we can also do some statistical analysis of these results. For example, we can use `sort` and `uniq` to find the most common hyphenated words.

    grep -Eo "[A-Za-z']+\-[A-Za-z']+" texts/dracula.txt | sort | uniq -c | sort -nr

Here, the pipe `|` character means "take the results from the thing on the left and send it to the thing on the right". We take our list of hyphenated words, sort them alphabetically, group them uniquely using the `c` flag to get counts, and finally sort them again with the options `n` for numeric and `r` for reverse.

### Exercizes

1. Our regex will only find two words separated by a hyphen. How can you modify it to accept three words separated by a hyphen? How about an unlimited number of hyphen-separated words? Hint: You can group regex rules with parentheses `()` and use a question mark `?` to make the preceding rule optional.
2. 

[Regex Quick Reference](http://www.regular-expressions.info/refquick.html)

## csvkit



## Elasticsearch
