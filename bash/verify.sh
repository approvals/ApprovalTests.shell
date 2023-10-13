#!/bin/bash

default_diff_tool="code --diff"
diff_tool=$default_diff_tool

function main(){
while getopts ":r:t:d:" opt; do
  case $opt in
    d) diff_tool=$OPTARG;;
    r) received_text=$OPTARG;;
    t) test_name=$OPTARG;;
    \?) echo "Invalid option: -$OPTARG" >&2;;
  esac
done

received="$test_name.received"
approved="$test_name.approved"

if [ "$received_text" == "" ];
then
    cat - > "$received"
else
    echo "$received_text" > "$received"
fi

touch "$approved"

compare_and_approve

}

function compare_and_approve(){
    diff -q "$received" "$approved" > /dev/null \
	&& (echo "test passed"; rm "$received") \
	|| (echo "test failed";
	    if [ -e /dev/tty ]; then
		$diff_tool "$received" "$approved" </dev/tty
	    else
		$diff_tool "$received" "$approved"
	    fi;
	    false)
}

main
