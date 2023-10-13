#!/bin/bash

default_diff_tool="code --diff"
diff_tool=$default_diff_tool


function warn(){
    echo "$*" >&2
}


while getopts ":r:t:d:" opt; do
    case $opt in
	d) diff_tool=$OPTARG;;
	r) received_text=$OPTARG;;
	t) test_name=$OPTARG;;
	\?) warn "Invalid option: -$OPTARG";;
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


function pass_and_rm_received(){
    pass; 
    rm "$received"
}


function compare_and_approve(){
    diff -q "$received" "$approved" > /dev/null \
	&& (pass_and_rm_recieved) \
	|| (fail_and_diff)
}


main
