#!/bin/bash
#================================================================
#           FILE            : books.sh
#
#           USAGE           : ./books.sh
#
#           DESCRIPTION     : Download webpage and get
#                                                               a list of all books from author
#
#           NOTES           : ---
#           AUTHOR          : Jop Bakker
#           CREATED         : 18/12/2022
#           REVISION        : 2.0
#================================================================
# docker build -t amazonbooks:latest .
# docker run -it --name amazonbooks --rm -v ~/docker-data/amazonbooks/:/books amazonbooks:latest

#init
MAIN_files='mainfiles/'
HTML_results='/books/results.html'
TEXT_results='/books/'
APP_TOKEN=""
USER_TOKEN=""
author=( $(cut -d ',' -f1 list.csv) )
url=( $(cut -d ',' -f2 list.csv) )
len=${#author[@]}

# downloading contect and parsing results
for (( i=0; i<$len; i++ ));
do
FILE=$TEXT_results$MAIN_files${author[$i]}'.main'
if [ ! -f "$FILE" ]; then
    touch $TEXT_results$MAIN_files${author[$i]}'.main'
fi

wget -O $HTML_results -U "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/54.0" --no-check-certificate ${url[$i]}  > /dev/null 2>&1

pcre2grep -o1 -e '([a-zA-Z\(\)\d\w\s:,]+)(?:"},"variationDimensionLength":)' $HTML_results | sort | sed -e 's/^[ \t]*//' >> $TEXT_results${author[$i]}'.txt'

# Looking for new books
touch newbooks.txt

while IFS="" read -r p || [ -n "$p" ]
do
  test=$(grep "${p}" $TEXT_results$MAIN_files${author[$i]}'.main' | wc -l)
  if [ $test -eq 0 ];then
    echo "$p" >> newbooks.txt
  fi
done < $TEXT_results${author[$i]}'.txt'

# sending new books with pushover
linecount=$(cat newbooks.txt | wc -l)
if (( $linecount > 0 ));then
	echo $linecount "new books found for" ${author[$i]}

	# updating .main file
	while read p;do
		echo "$p" >> $TEXT_results$MAIN_files${author[$i]}'.main'
	done <newbooks.txt

	# sending results
	result=$(cat newbooks.txt)
	wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$result&title=New books from ${author[$i]}" -qO- > /dev/null 2>&1 &
else
	echo "No new books found for" ${author[$i]}
fi

# cleanup
rm newbooks.txt
rm results.html
rm $TEXT_results${author[$i]}'.txt'

done