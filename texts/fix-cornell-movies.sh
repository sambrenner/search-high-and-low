#!/bin/sh

# this script fixes the files from the cornell movie dialogs corpus to be in a format more easily understood by csvkit (and probably many other applications). you can download that from here: http://www.cs.cornell.edu/~cristian/Cornell_Movie-Dialogs_Corpus.html

# then copy this file into the unzipped directry and run it like:
# ./fix-cornell-movies.sh

if [ -f movie_lines.txt ];
then
    echo "fixing the cornell movie corpus."
else
    echo "can't find the corpus files... are you sure this script is in the right directory?"
    exit 1
fi

# the original delimiter from the source is " +++$+++ ". csvkit doesn't like multi-character delimiters so we
# will use sed to convert them all to the @ symbol. this is because @ isn't used anywhere in the data - if
# we used a comma, some columns would be lost because commas are used in movie lines and titles. by first
# converting the delimiter to an @ symbol, we can hand it off to csvkit later to convert to a csv and preserve
# non-delimiting commas by wrapping them in quotes.

# we will also convert the character encoding to utf-8 so we don't have to set the encoding flag in
# csvkit every time we use it.
echo "converting delimeters"
TEMP_LANG=$LANG
export LANG=C
for file in *.txt; do sed 's/ +++$+++ /@/g' $file | iconv -f iso-8859-1 -t UTF-8 > $file.asv; rm $file; done;
export LANG="$TEMP_LANG"

# the provided files also don't provide title rows. we'll add those in manually.
echo "adding header rows"
printf '0aid@title@year@rating@votes@genres.w' | ed movie_titles_metadata.txt.asv
printf '0aid@name@movie_id@movie_title@gender@credit_position.w' | ed movie_characters_metadata.txt.asv
printf '0aid@character_id@movie_id@character_name@line.w' | ed movie_lines.txt.asv
printf '0acharacter_id_1@character_id_2@movie_id@line_ids.w' | ed movie_conversations.txt.asv

# the movie_lines file contains weird unicode line break characters that we need to remove
echo "removing weird characters"
CHARS=$(python -c 'print u"\u0085".encode("utf8")'); sed 's/['"$CHARS"']//g' < movie_lines.txt.asv > movie_lines2.txt.asv
rm movie_lines.txt.asv
mv movie_lines2.txt.asv movie_lines.txt.asv 

# convert them to csvs
echo "converting to csv"
csvformat -d @ -D , movie_characters_metadata.txt.asv > movie_characters_metadata.csv
csvformat -d @ -D , movie_titles_metadata.txt.asv > movie_titles_metadata.csv
csvformat -d @ -D , movie_lines.txt.asv > movie_lines.csv
csvformat -d @ -D , movie_conversations.txt.asv > movie_conversations.csv

# remove asvs
echo "cleaning up"
rm movie_characters_metadata.txt.asv
rm movie_titles_metadata.txt.asv
rm movie_lines.txt.asv
rm movie_conversations.txt.asv

echo "done!"
exit
