#!/bin/bash

default_diff_tool="code --diff"
diff_tool=$default_diff_tool

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


function main(){
    if [ "$received_text" == "" ];
    then
	cat - > "$received"
    else
	echo "$received_text" > "$received"
    fi

    touch "$approved"

    compare_and_approve
}

function pass(){ 
    echo "test passed" 
}


function fail(){
    echo "test failed" 
}

function fail_and_diff(){
    fail;
    if [ -e /dev/tty ]; then
	$diff_tool "$received" "$approved" </dev/tty
    else
	$diff_tool "$received" "$approved"
    fi;
    false
}


function compare_and_approve(){
    diff -q "$received" "$approved" > /dev/null \
	&& (pass; rm "$received") \
	|| (fail_and_diff)
}


main
