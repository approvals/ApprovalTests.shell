#!/bin/bash
set -euo pipefail

true <<TODO
See:  
    - git config --get diff.tool
    - git difftool
    - git difftool --no-index
TODO

git_difftool="$(git config --get diff.tool)"
vs_code_path=$(command -v code)

if [[ -n "${git_difftool}" ]] && command -v "${git_difftool}"; then
   difftool="git difftool --tool ${git_difftool} --no-index"; 
elif [[ -n "${vs_code_path}" ]]; then
   difftool="${vs_code_path} --diff"
else
    difftool=""
fi

function warn(){
    echo "$*" >&2
}


while getopts ":r:t:d:D" opt; do
    case $opt in
	d) difftool=$OPTARG;;
	r) received_text=$OPTARG;;
	t) test_name=$OPTARG;;
	D) debug_without_compare_and_approve="true";;
	\?) warn "Invalid option: -$OPTARG";;
    esac
done

if [[ "${test_name=}" == '' ]]
then
    test_name="unspecified_test_name"
fi

received="$test_name.received"
approved="$test_name.approved"

function debug_arguments(){
    cat <<REPORT
$0 -d '$difftool' -r '$received_text' -t '$test_name'
REPORT
}


function main(){
    if [ "${received_text=}" == "" ];
    then
	cat - > "$received"
    else
	echo "$received_text" > "$received"
    fi

    touch "$approved"

    if [[ -n "${debug_without_compare_and_approve=}" ]]
    then
        debug_arguments;
    else
        compare_and_approve $test_name;
    fi
}


function pass(){ 
    echo "${1:=unnamed-test} passed" 
}


function fail(){
    echo "${1:unnamed-test} failed" 
}


function fail_and_diff(){

    if [ -e /dev/tty ]; then
	$difftool "$received" "$approved" </dev/tty
    else
	$difftool "$received" "$approved"
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
