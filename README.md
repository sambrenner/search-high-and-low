# Search High and Low

A workshop on finding things with computers.

## Setup

1. Download the zip of this repository, or `clone` it with `git`.
2. Open Terminal and `cd` into this directory.
3. Install `csvkit` with `sudo pip install csvkit`. If you don't have `pip`, install that with `sudo easy_install pip`.

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

### Possible Next Step...

Our regex will only find two words separated by a hyphen. How can you modify it to accept three words separated by a hyphen? How about an unlimited number of hyphen-separated words? Hint: You can group regex rules with parentheses `()` and use a question mark `?` to make the preceding rule optional.

### References

* [Regex Quick Reference](http://www.regular-expressions.info/refquick.html)
* [Shiffman's Regex Post](http://shiffman.net/teaching/a2z/regex/)

## csvkit

A CSV ("Comma Separated Values") is a type of file that represents tabular data (a series of rows and columns, much like an Excel spreadsheet) in plain text. CSVs are a common format for the dissemination of datasets, used by government agencies, research institutions, museums and more. [`csvkit`](https://csvkit.readthedocs.org/en/0.9.1/) is a collection of tools written in Python that make searching, displaying and analyzing CSV files very simple.

To install `csvkit`, use `pip`:

    `sudo pip install csvkit`

We'll also need some CSVs to work with. I came across [this dataset of movie scripts](http://www.cs.cornell.edu/~cristian/Cornell_Movie-Dialogs_Corpus.html), which provides [this zip file](http://www.mpi-sws.org/~cristian/data/cornell_movie_dialogs_corpus.zip) of data. It turns out that these CSVs aren't as clean as I'd like them to be so I've provided a cleaned-up version in the `texts/cornell-movies.zip` file. If you use the original data, I've provided a `fix-cornell-movies.sh` script that you should move in to the unzipped folder and run by calling `./fix-cornell-movies.sh` from your command line. That script has plenty of comments detailing everything it does if you're interested.

A great tool to start with in `csvkit` is `csvstat`. It gives you some basic statistics about a file.

    csvstat movie_characters_metadata.csv

From the command's output, we start to see some interesting information: The most common character name is "Man" and the movie with the most characters is _Casino_.

What are the names of all the speaking characters in _Casino_? We can use `csvgrep` to figure that out. Because `movie_characters_metadata` has columns for both the movie's title and ID, we know that _Casino_ has an ID of `m289`. Now we can search the column named `movie_id` for that ID.

    csvgrep -c "movie_id" -m "m289" movie_characters_metadata.csv | csvlook

The two important flags here are `c` for column and `m` for match. And sure enough, _Casino_ does have a lot of characters! One of the character's names is "Detective Johnson". What are some other detective names in these movies? Let's search the `name` column for the string `DETECTIVE`.

    csvgrep -c "name" -m "DETECTIVE" movie_characters_metadata.csv | csvlook

We can replace the `m` flag with an `r` flag which will let us use a regular expression. Let's copy the same one we used before to find hyphenated words.

    csvgrep -c "name" -r "(?i)[a-z]+\-[a-z]+" movie_characters_metadata.csv | csvlook

This regex contains something new: the parentheses at the beginning. This is called a matching mode and it's where you can configure options for how the regex will be interpreted. In this case, we use `?i` which means "case insensitive". You can read more about modes [here](http://www.regular-expressions.info/modifiers.html). 

Let's answer another question about this data: which movies most frequently use four letter words that begin with F? I'm not picky about the specific word. Just four letters long, begins with F.

    csvgrep -c "line" -r "(?i)\bf[a-z]{3}\b" movie_lines.txt | csvlook

This regex contains a few new things. `\b` is a ["word boundary"](http://www.regular-expressions.info/wordboundaries.html), so we put one at the beginning to signify the beginning of a word. Then we state that the first letter is `f`. Then we allow for any letter from a to z, repeated exactly 3 more times. Curly braces are used to signify repeats - more about that [here](http://www.regular-expressions.info/repeat.html). Finally, another word boundary signifies that after matching those three letters, the word should end. Sure enough, if you run this query, you get a lot of foul words (and some fine ones too).

Try piping it in to `csvstat` instead of `csvlook`. For some reason, we also have to remind `csvstat` to use commas as the delimeter with `-d ,`.

    csvgrep -c "line" -r "(?i)\bf[a-z]{3}\b" movie_lines.csv | csvstat -d ,

Now we can see the top five movies with these words. We can go look up the names of the movies ourselves because the `movie_id` column in this table maps to the `id` column in the `movie_titles_metadata` table. We could also get the computer to do it for us.

Sometimes you will find data with multiple CSVs that relate to each other. The reason for this is that linking the two tables together via ID saves space and makes updates easier. It's more efficient to link a movie line to `m0` than it is to copy the movie's title, year, genre and the rest of the metadata to every row in the `movie_lines` table, and if the author decided to add a "director" or "budget" column to the `movie_titles_metadata` column, they would only have to do it on one place instead of potentially thousands. This is especially common in relational databases such as MySQL. [Khan Academy](https://www.khanacademy.org/computing/computer-programming/sql/sql-basics/v/welcome-to-sql) has a more in-depth look at this if you're interested.

In order to see the movie titles and not just the IDs in the `movie_lines` table, we will have to duplicate (the technical term is "denormalize") the `movie_title` field in the `movie_characters_metadata` table. We can do this with `csvjoin`.

    csvjoin -c "movie_id,id" movie_lines.csv movie_titles_metadata.csv > movie_lines_titles.csv

Here the column flag takes two names, which map respectively to the file names to join together. Then we save the output to a file named `movie_lines_titles.csv`. Now we can run the same f-word command on this file instead of `movie_lines.csv`.

    csvgrep -c "line" -r "(?i)\bf[a-z]{3}\b" movie_lines_titles.csv | csvstat -d ,

And now we can see the titles of the top movie to feature these special words. If you have seen this movie, it should not surprise you.

### Possible Next Step

1. You've seen how we can chain `csvkit` commands with a pipe character. Using pipes, how can we write a command that finds specifically which four-letter F-words are used in the #1 movie from our frequency list?
2. Our query matched any four-letter word beginning with f. If we wanted to target that one particular word (we all know what it is) and its permutations, how would we write a regex to do it?

### References

* [`csvkit` documentation](https://csvkit.readthedocs.org/en/0.9.1/)
* [Relational Databases on Khan Academy](https://www.khanacademy.org/computing/computer-programming/sql/sql-basics/v/welcome-to-sql)

## Elasticsearch
