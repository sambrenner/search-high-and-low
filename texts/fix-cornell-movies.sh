#!/bin/sh

# the original delimiter from the source is " +++$+++ ". csvkit doesn't like multi-character delimiters so we
# will use sed to convert them all to the @ symbol. this is because @ isn't used anywhere in the data - if
# we used a comma, some columns would be lost because commas are used in movie lines and titles. by first
# converting the delimiter to an @ symbol, we can hand it off to csvkit later to convert to a csv and preserve
# non-delimiting commas by wrapping them in quotes.

# we will also convert the character encoding to utf-8 so we don't have to set the encoding flag in
# csvkit every time we use it.
TEMP_LANG=$LANG
export LANG=C
for file in *.txt; do sed 's/ +++$+++ /@/g' $file | iconv -f iso-8859-1 -t UTF-8 > $file.asv; rm $file; done;
export LANG="$TEMP_LANG"

# the provided files also don't provide title rows. we'll add those in manually.
printf '0a\nid@title@year@rating@votes@genres\n.\nw\n' | ed movie_titles_metadata.txt.asv
printf '0a\nid@name@movie_id@movie_title@gender@credit_position\n.\nw\n' | ed movie_characters_metadata.txt.asv
printf '0a\nid@character_id@movie_id@character_name@line\n.\nw\n' | ed movie_lines.txt.asv
printf '0a\ncharacter_id_1@character_id_2@movie_id@line_ids\n.\nw\n' | ed movie_conversations.txt.asv

# the movie_lines file contains weird unicode line break characters that we need to remove
CHARS=$(python -c 'print u"\u0085".encode("utf8")'); sed 's/['"$CHARS"']//g' < movie_lines.txt.asv > movie_lines2.txt.asv
rm movie_lines.txt.asv
mv movie_lines2.txt.asv movie_lines.txt.asv 

# convert them to csvs
csvformat -d @ -D , movie_characters_metadata.txt.asv > movie_characters_metadata.csv
csvformat -d @ -D , movie_titles_metadata.txt.asv > movie_titles_metadata.csv
csvformat -d @ -D , movie_lines.txt.asv > movie_lines.csv
csvformat -d @ -D , movie_conversations.txt.asv > movie_conversations.csv

# remove asvs
rm movie_characters_metadata.txt.asv
rm movie_titles_metadata.txt.asv
rm movie_lines.txt.asv
rm movie_conversations.txt.asv

echo "done!"
exit
