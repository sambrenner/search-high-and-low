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
[Shiffman's Regex Post](http://shiffman.net/teaching/a2z/regex/)

## csvkit

A CSV ("Comma Separated Values") is a type of file that represents tabular data (a series of rows and columns, much like an Excel spreadsheet) in plain text. CSVs are a common format for the dissemination of datasets, used by government agencies, research institutions, museums and more. [`csvkit`](https://csvkit.readthedocs.org/en/0.9.1/) is a collection of tools written in Python that make searching, displaying and analyzing CSV files very simple.

To install `csvkit`, use `pip`:

    `sudo pip install csvkit`

We'll also need some CSVs to work with. I came across [this dataset of movie scripts](http://www.cs.cornell.edu/~cristian/Cornell_Movie-Dialogs_Corpus.html), which provides [this zip file](http://www.mpi-sws.org/~cristian/data/cornell_movie_dialogs_corpus.zip) of data. Download and unzip the file to this repo's `texts` folder. As you'll see, this dataset will also be a good example of "data found in the wild" which might not always be as ready-for-analysis as we'd like it to be. If you want to read about making it usable, go on ahead. If you'd rather just get in to `csvkit`, you can unzip file provided in `texts/cornell-movies.zip` to get the cleaned-up data and skip ahead to [the next section](#actually-working-with-csvkit).

### Cleaning up the CSVs

Let's look at one of the original files. An easy way to get an idea of a file is with the `head` command, which by default prints out the first 10 lines of a file. From the directory you've unzipped the data to, let's run

    head movie_titles_metadata.txt

Interestingly, you'll notice there aren't too many commas. Checking the README, we see this is because the author of these files has chosen to use a different set of characters to separate columns. The string used to separate columns is called the "delimiter" and it is common to find tabular data delimited with characters other than a comma. In this case, the author has chosen to use the string ` +++$+++ `, which poses a problem. The `csvkit` documentation says that the delimiting character can only be a single character, so first let's replace the delimiting character in these files.

If we're going to delimit the text with a character, it needs to be something that isn't used anywhere in the contents of the table's cells. We can use `grep` to make sure a character we pick isn't anywhere else in the datasets. Let's start with the `#` character.

    grep -r '#' .

In this command, the `r` flag means recursive, which allows `grep` to work in a directory. The `.` at the end is how you say "my current directory" in Unix. You might be familiar with how `..` means "up on directory" - this is like that.

When we run the command we see that the `#` sign is used in some files, specifically in `movie_lines.txt` for character names such as "VOICE #2". Let's try another uncommon character, the `@` sign.

    grep -r '@' .

Much better! The only `@` appears in the README file and the PDF, which we will be ignoring. So let's replace all instances of ` +++$+++ ` with `@` so we can make `csvkit` happy. We'll do this by looping over all the `txt` files in the directory and using `sed` to find and replace text. `sed` is another useful tool, and it also supports regexes, but I won't get in to it today. The last thing we do is convert the character encoding to UTF-8. This isn't necessary for `csvkit` but it will stop us from having to set a flag for every command we run.

    export LANG=C; for file in *.txt; do sed 's/ +++$+++ /@/g' $file | iconv -f iso-8859-1 -t UTF-8 > $file.asv; rm $file; done; export LANG=en_US.UTF-8

(It's also worth noting here that datasets found online don't always require you to jump through so many hoops to use them. But this is a good real-world example of a dataset that takes a little extra love to be usable. I hope you leave today's workshop aware that the tools work with datasets, clean or not, are all easy to use!)

Anyway, now you have a bunch of "asv" files, which is a made-up extension that we'll pretend stands for "at separated values".

Finally, let's start to use `csvkit`. One of the tools it provides is `csvlook`, which "pretty prints" the file. We also pass it a `d` flag (for delimiter) telling it to use the `@` sign we chose earlier. (Commas are default so with a normal csv you could leave this out).

    csvlook -d @ movie_titles_metadata.txt.asv

You can now see the titles of the movies in this dataset. If it doesn't look pretty, increase your terminal window's size or make your font smaller until it does. By the looks of the column on the left, there appear to be 616 movies included. Not bad! If you scroll all the way up to where we began to run the script, you'll notice that the "title row", which would normally name all the columns, seems to be the first row of the data (rom-com classic [10 Things I Hate About You](https://en.wikipedia.org/wiki/10_Things_I_Hate_About_You)). Ugh! This problem is easy, albeit annoying, to fix. Fortunately the author of the dataset has given us column headers in the README file.

    printf '0a\nid@title@year@rating@votes@genres\n.\nw\n' | ed movie_titles_metadata.txt.asv; printf '0a\nid@name@movie_id@movie_title@gender@credit_position\n.\nw\n' | ed movie_characters_metadata.txt.asv; printf '0a\nid@character_id@movie_id@character_name@line\n.\nw\n' | ed movie_lines.txt.asv; printf '0a\ncharacter_id_1@character_id_2@movie_id@line_ids\n.\nw\n' | ed movie_conversations.txt.asv

This runs a bunch of commands that sticks the column headers at the top of the files. You could also do it manually by opening the files in a text editor.

### Actually Working With `csvkit`

Finally, we've made it! Let's perform a couple of basic operations with `csvkit`.

A great tool to start with in `csvkit` is `csvstat`. It gives you some basic statistics about a file.

    csvstat -d @ movie_characters_metadata.txt.asv

The flag `-d @` tells it to use `@` as the delimiter (since this will be the case for all files in this tutorial, I'm not going to mention it anymore). From the command's output, we start to see some interesting information: The most common character name is "Man" and the movie with the most characters is _Casino_.

What are the names of all the speaking characters in _Casino_? We can use `csvgrep` to figure that out. Because `movie_characters_metadata` has columns for both the movie's title and ID, we know that _Casino_ has an ID of `m289`. Now we can search the column named `movie_id` for that ID.

    csvgrep -d @ -c "movie_id" -m "m289" movie_characters_metadata.txt.asv | csvlook

The two important flags here are `c` for column and `m` for match. And sure enough, _Casino_ does have a lot of characters! One of the character's names is "Detective Johnson". What are some other detective names in these movies? Let's search the `name` column for the string `DETECTIVE`.

    csvgrep -d @ -c "name" -m "DETECTIVE" movie_characters_metadata.txt.asv | csvlook

We can replace the `m` flag with an `r` flag which will let us use a regular expression. Let's copy the same one we used before to find hyphenated words.

    csvgrep -d @ -c "name" -r "(?i)[a-z]+\-[a-z]+" movie_characters_metadata.txt.asv | csvlook

This regex contains something new: the parentheses at the beginning. This is called a matching mode and it's where you can configure options for how the regex will be interpreted. In this case, we use `?i` which means "case insensitive". You can read more about modes [here](http://www.regular-expressions.info/modifiers.html). 

Let's answer another question about this data: which movies most frequently use four letter words that begin with F? I'm not picky about the specific word. Just four letters long, begins with F.

    csvgrep -d @ -c "line" -r "(?i)\bf[a-z]{3}\b" movie_lines.txt | csvlook

This regex contains a few new things. `\b` is a ["word boundary"](http://www.regular-expressions.info/wordboundaries.html), so we put one at the beginning to signify the beginning of a word. Then we state that the first letter is `f`. Then we allow for any letter from a to z, repeated exactly 3 more times. Curly braces are used to signify repeats - more about that [here](http://www.regular-expressions.info/repeat.html). Finally, another word boundary signifies that after matching those three letters, the word should end. Sure enough, if you run this query, you get a lot of foul words (and some fine ones too).

Try piping it in to `csvstat` instead of `csvlook`. We'll also have to switch back to using commas as the delimeter.

    csvgrep -c "line" -r "(?i)f[a-z]{3}" -d @ movie_lines.txt.asv | csvstat -d ,

Now we can see the top five movies with these words. We can go look up the names of the movies ourselves because the `movie_id` column in this table maps to the `id` column in the `movie_titles_metadata` table. We could also get the computer to do it for us.

Sometimes you will find data with multiple CSVs that relate to each other. The reason for this is that linking the two tables together via ID saves space and makes updates easier. It's more efficient to link a movie line to `m0` than it is to copy the movie's title, year, genre and the rest of the metadata to every row in the `movie_lines` table, and if the author decided to add a "director" or "budget" column to the `movie_titles_metadata` column, they would only have to do it on one place instead of potentially thousands. This is especially common in relational databases such as MySQL. [Khan Academy](https://www.khanacademy.org/computing/computer-programming/sql/sql-basics/v/welcome-to-sql) has a more in-depth look at this if you're interested.

In order to see the movie titles and not just the IDs in the `movie_lines` table, we will have to duplicate (the technical term is "denormalize") the `movie_title` field in the `movie_characters_metadata` table. We can do this with `csvjoin`.


## Elasticsearch
