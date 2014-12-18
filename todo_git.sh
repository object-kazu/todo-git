#!/bin/bash

#Copyright (C) 2012 momiji-mac.com  All Rights Reserved.
#our homepage is http://momiji-mac.com/wp/

####### configure file ###########

# You can set these file as you like.
# your todo.txt select

TODOFILE=~/Dropbox/todotxt/todo.txt

#your back up file set
BACKUPFILE=~/todo_git_backUp.bak

#junkfile
JUNKFILE=~/junkfile_todo_git

#branch file( display branch list)
BRANCH_LIST=~/branchlist.txt

#functions file load
. functions.sh

######### variable init ###############

TODO_Arg_FLAG=0
TRUE=1
FALSE=0

######### #Script mains #################
#echo "---------------------------------"
echo -e "${LIGHT_CYAN}""TODO_GIT: Git branch control from todo.txt""${DEFAULT}"
#echo "---------------------------------"

# 変数 $# の値が 1~2 でなければエラー終了。

if [ $# -eq 0 ] || [ $# -gt 2 ] ; then
    errorMessage
    exit 1
fi

# second arg treatment
number=$2
subBranchName=$2
if [ -z $2 ]; then
    TODO_Arg_FLAG=$FALSE
else
    arg_check
fi

#make buck up
dobuck4

#引数処理
while getopts "sfbumlerodxph" opt
do 
    case ${opt} in
        s) FLAG=11
            ;;
        f) FLAG=111
            ;;
        l) FLAG=2
            ;;
        e) echo "---->dev Edit todo.txt";
            callEdit
            exit 1
            ;;
        r) FLAG=3
            ;;
        o) FLAG=33
            ;;
        d) FLAG=4
            ;;
        x) FLAG=5
            ;;
        p) FLAG=22
            ;;
        h) FLAG=6
            ;;
	b) FLAG=7 #subFeature branch
	    ;;
	m) FLAG=77 # branch merge = subFeature branch sucsess
	    ;;
	u) FLAG=777 # brabch un-merge = subFeature branch fail
	    ;;
        \?) errorMessage
            exit 1
            ;;
    esac
done

shift `expr $OPTIND - 1` #option 以下の引数を＄１に代入

#エラー処理：FLAG=nullならFLAG=0を入れておく
[ -z ${FLAG} ] && FLAG=0

if [ ${FLAG} -eq 11 ]; then
    echo -e "${LIGHT_CYAN}""git flow feature start""${DEFAULT}";
    flow_start
fi

if [ ${FLAG} -eq 111 ]; then
    echo -e "${LIGHT_CYAN}""git flow feature finish""${DEFAULT}";
    flow_finish
fi

if [ ${FLAG} -eq 2 ]; then
    echo -e "${GREEN_U}""show list""${DEFAULT}";
    show_list
fi

if [ ${FLAG} -eq 22 ]; then
#    echo -e "${GREEN_U}""show project list""${DEFAULT}";
#    show_project_list
    show_project_list_colored
fi

if [ ${FLAG} -eq 3 ]; then
    echo -e "${LIGHT_RED}""git flow release start""${DEFAULT}";
    flow_release_start
fi

if [ ${FLAG} -eq 33 ]; then
    echo -e "${LIGHT_RED}""git flow release finish""${DEFAULT}";
    flow_release_finish
fi

if [ ${FLAG} -eq 4 ]; then
    echo -e "${YELLOW_U}""delite item from todo list""${DEFAULT}";
    delete_item
fi

if [ ${FLAG} -eq 5 ]; then
    echo -e "${BLUE_U}""exchange item from todo list""${DEFAULT}";
    exchange_item
fi
if [ ${FLAG} -eq 6 ]; then
    echo -e "${WHITE}""*** Help ***""${DEFAULT}";
    display_help
fi

if [ ${FLAG} -eq 7 ]; then
    echo -e "${LIGHT_RED}"" sub-feature branch""${DEFAULT}";
    feature_branch_start
fi
if [ ${FLAG} -eq 77 ]; then
    echo -e "${LIGHT_RED}""merge and delete branch""${DEFAULT}";
    feature_branch_merged_end
fi

if [ ${FLAG} -eq 777 ]; then
    echo -e "${LIGHT_RED}""un-merge and delete branch""${DEFAULT}";  
    feature_branch_unmerged_end
fi
