#!/bin/sh

# switch delimiter to @ and convert to utf-8
TEMP_LANG=$LANG
export LANG=C
for file in *.txt; do sed 's/ +++$+++ /@/g' $file | iconv -f iso-8859-1 -t UTF-8 > $file.asv; rm $file; done;
export LANG="$TEMP_LANG"

# add title rows
printf '0a\nid@title@year@rating@votes@genres\n.\nw\n' | ed movie_titles_metadata.txt.asv
printf '0a\nid@name@movie_id@movie_title@gender@credit_position\n.\nw\n' | ed movie_characters_metadata.txt.asv
printf '0a\nid@character_id@movie_id@character_name@line\n.\nw\n' | ed movie_lines.txt.asv
printf '0a\ncharacter_id_1@character_id_2@movie_id@line_ids\n.\nw\n' | ed movie_conversations.txt.asv

# remove weird unicode character from lines
CHARS=$(python -c 'print u"\u0085".encode("utf8")'); sed 's/['"$CHARS"']//g' < movie_lines.txt.asv > movie_lines2.txt.asv
rm movie_lines.txt.asv
mv movie_lines2.txt.asv movie_lines.txt.asv 

echo "done!"
exit
