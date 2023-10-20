#!/bin/bash

default_diff_tool="code --diff"
diff_tool=$default_diff_tool


function warn(){
    echo "$*" >&2
}


while getopts ":r:t:d:D" opt; do
    case $opt in
	d) diff_tool=$OPTARG;;
	r) received_text=$OPTARG;;
	t) test_name=$OPTARG;;
	D) debug_without_compare_and_approve="true";;
	\?) warn "Invalid option: -$OPTARG";;
    esac
done

if [[ "${test_name}" == '' ]]
then
    test_name="unspecified_test_name"
fi

received="$test_name.received"
approved="$test_name.approved"

function debug_arguments(){
    cat <<REPORT
$0 -d '$diff_tool' -r '$received_text' -t '$test_name'
REPORT
}


function main(){
    if [ "$received_text" == "" ];
    then
	cat - > "$received"
    else
	echo "$received_text" > "$received"
    fi

    touch "$approved"

    if [[ -n "$debug_without_compare_and_approve" ]]
    then
        debug_arguments;
    else
        compare_and_approve $test_name;
    fi
}


function pass(){ 
    echo "${1:unnamed-test} passed" 
}


function fail(){
    echo "${1:unnamed-test} failed" 
}


function fail_and_diff(){
    fail $1;
    if [ -e /dev/tty ]; then
	$diff_tool "$received" "$approved" </dev/tty
    else
	$diff_tool "$received" "$approved"
    fi;
    false
}


function pass_and_rm_received(){
    pass $1; 
    rm "$received"
}


function compare_and_approve(){
    diff -q "$received" "$approved" > /dev/null \
	&& (pass_and_rm_received $1) \
	|| (fail_and_diff $1)
}


main
