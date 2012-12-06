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

#editor
function callEdit()
{
#  emacs ${TODOFILE}
#    vim ${TODOFILE}
    mg ${TODOFILE}
}


######  Default color map ########

export NONE=''
export BLACK='\033[0;30m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export BROWN='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT_GREY='\033[0;37m'
export DARK_GREY='\033[1;30m'
export LIGHT_RED='\033[1;31m'
export LIGHT_GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export LIGHT_BLUE='\033[1;34m'
export LIGHT_PURPLE='\033[1;35m'
export LIGHT_CYAN='\033[1;36m'
export WHITE='\033[1;37m'
export DEFAULT='\033[0;39m'

export GREEN_U='\033[4;32m'
export LIGHT_RED_U='\033[4;31m'
export YELLOW_U='\033[4;33m'
export BLUE_U='\033[4;34m'

######### variable init ###############

TODO_Arg_FLAG=0
TRUE=1
FALSE=0

######### functions ###############
function show_list_core(){
    count=1
    titile={}
    
    while read line
    do

        titile[${count}]=`echo ${line}|cut -d " " -f1`
        ch2=`echo ${line}|cut -d " " -f2-8`

        case ${titile[$count]} in
            ">>>""("[A-Z]")")
                titile[$count]="${titile[$count]}"" ${ch2}"
                ch2=`echo ${line}|cut -d " " -f3-7`
                ;;

            "("[A-Z]")")
                titile[$count]="${titile[$count]}"" ${ch2}"
                ch2=`echo ${line}|cut -d " " -f3-7`
                ;;

        esac

        if [ "${titile[$count]}" = "${ch2}" ]; then
            ch2="..."

        fi

        TEMP_LINE="${count}. ""${titile[$count]}"" : ""${ch2} "

        if echo "${TEMP_LINE}" | grep -sq ">>>"; then
            if echo "${TEMP_LINE}" | grep -sq "(release)"; then
                echo -e "${RED}""${TEMP_LINE}""${DEFAULT}"
            else
                echo -e "${CYAN}""${TEMP_LINE}""${DEFAULT}"
            fi
        else
            echo -e "${WHITE}""${TEMP_LINE}""${DEFAULT}"
        fi

        count=`expr $count + 1`

    done < JUNKFILE

    #不要な一時ファイルを削除
    [ -f JUNKFILE ] && rm JUNKFILE
    
}


function show_project_list(){

# non-project listed
    echo "0..non-project" >> temp-todo-git_list

#project listを得る
    todo.sh lsprj > temp-todo-git
    projects=`sed -e s/^+// temp-todo-git`
    count=1
 
    for project in ${projects}; do

        echo "${count}..""${project}" >> temp-todo-git_list
        ((count +=1))

    done

#todoを表示する

    cat temp-todo-git_list
    echo ""

    echo -n "Select project --> "
    read number

    error_check
        if [ $? -eq 110 ]; then
            rm temp-todo-git temp-todo-git_list
            exit 0
        elif [ $? -eq 119 ]; then
            number=0
            
        fi

    SELECT=${number}

    if [ ${SELECT} -eq 0 ]; then  #non-projectを選択した場合
        echo ""
        echo -e "${LIGHT_RED_U}""    Select non-project     ""${DEFAULT}"
        grep -v '\+.*' ${TODOFILE} > temp-todo-git_list
    
    else #projectを選択した場合
      
        TARGET=`grep ^${SELECT} temp-todo-git_list | sed -e s/^[0-9]..//`
        echo ""
        echo -e "${LIGHT_RED_U}""    project: ${TARGET}    ""${DEFAULT}"
        echo " "
        grep ${TARGET} ${TODOFILE} | sed -e s/.+${TARGET}// > temp-todo-git_list

    fi


    cat temp-todo-git_list > JUNKFILE
    show_list_core

    echo ""
    echo "--- feature/start (exit: q) ---"
    echo ""
    echo -n "Select Item  --> "
    read number

    error_check
    if [ $? -eq 110 ]; then
        rm temp-todo-git temp-todo-git_list
        exit 0
    fi


    SELECT_2=${number}

    branchName=${titile[${SELECT_2}]}
        
    number=`grep -n ^${branchName} ${TODOFILE}| cut -d ":" -f1`    

    #不要な一時ファイルを削除
    [ -f temp-todo-git ] && rm temp-todo-git
    [ -f temp-todo-git_list ] && rm temp-todo-git_list
    
    feature_core
}


function exchange_item(){
    show_list
    echo ""
    echo " exchange item "
    echo ""
    echo -n "Select item #1 >>>"
    read number
    
    error_check
    [ $? -eq 110 ] && exit 22

    firstItem=`cat ${TODOFILE} | sed -n ${number}p ${TODOFILE}`
    firstNum=${number}

    echo -n "Select item #2 >>>"
    read number

    error_check
    [ $? -eq 110 ] && exit 33

    secondItem=`cat ${TODOFILE} | sed -n ${number}p ${TODOFILE}`
    secondNum=${number}

    sed -e "${firstNum}s/.*/${secondItem}/" ${TODOFILE} > temp
    sed -e "${secondNum}s/.*/${firstItem}/" temp > ${TODOFILE}

    rm temp
    
    echo "${GREEN_U}""New order""${DEFAULT}"
    show_list

}


function delete_item() {

if [ ${TODO_Arg_FLAG} -eq ${FALSE} ]; then
    show_list
    echo ""
    echo -n "Select delete item >>> "
    read number
fi

if [ ${TODO_Arg_FLAG} -eq ${TRUE} ]; then
    count_list
    echo ""
#    echo -n "Select delete item >>> ${number}"
    echo  ""
fi

    error_check
    [ $? -eq 110 ] && exit 44

    todo.sh del ${number}
    echo ""

    show_list

}

function remove_empty_line() {
    sed '/^$/d' ${TODOFILE} > temp.txt
    temp_treat

}

function show_backup_file(){
            echo "@: ${BACKUPFILE}"
}

function dobuck4(){

    if  [ -e ${BACKUPFILE} ]  ;
    then
        echo -e "${GREEN}" "back up file is Found""${DEFAULT}"
        echo ""

    else
        touch ${BACKUPFILE}
        echo "${RED}""back up file not found""${DEFAULT}"
        echo "----> back up file is made"
        echo ""
    fi
    {
        date_now=`date`   #`date '+%Y-%m-%d'`
        echo ""
        echo ${date_now}
        echo ""
        }>>${BACKUPFILE} 

    cat ${TODOFILE}>>${BACKUPFILE}
}


function temp_treat(){

    cat < temp.txt > ${TODOFILE}
    rm -f temp.txt
}

#!!!error_checkする前に numberとcount変数を代入しておくこと!!
function error_check(){

    if expr ${number} : '[0-9]*' >/dev/null; then

        [ ${number} -eq 0 ] &&  return 119
    
        #error treatment: if it is out of range number.
        errorCheck=`expr $count - 1`
        if [ ${errorCheck} -lt ${number} ]; then
            echo "error:number is not exist"
            return 110
        fi
        
    else
        echo "数値以外です"
        return 110

    fi

}

function count_list(){

    remove_empty_line
    count=1

    while read line
    do
        count=`expr $count + 1`
    done < ${TODOFILE}
    
}

function get_title_list(){
    remove_empty_line

    count=1
    titile={}

    while read line
    do

        titile[${count}]=`echo ${line}|cut -d " " -f1`
        ch2=`echo ${line}|cut -d " " -f2-8`

        count=`expr $count + 1`

    done < ${TODOFILE}
}
function show_list(){

    remove_empty_line
    cat ${TODOFILE} > JUNKFILE
    show_list_core

}

function check_current_git_dir(){
    Cdir=`pwd`

    #dir 存在確認
    direc=.git
    if [ ! -e ${direc} ]; then
        echo -e "${RED}""---> .git is not exist""${DEFAULT}"
        exit 1
     
    fi

}

function flow_start(){

    check_current_git_dir

if [ ${TODO_Arg_FLAG} -eq ${FALSE} ]; then
    echo ""
    show_list
    echo ""
    echo -n "Select item >>> "
    read number
fi

if [ ${TODO_Arg_FLAG} -eq ${TRUE} ]; then
    count_list
    echo ""
#    echo -n "Select item >>> ${number}"
    echo  ""
    get_title_list

fi

    error_check
    [ $? -eq 110 ] && exit 55

#リストを変数に入力する

    case ${titile[$number]} in
        "("[A-Z]")"* )
            titile[$number]=`echo ${titile[$number]}|cut -d " " -f2`
            ;;
    esac

    branchName=${titile[$number]}
    feature_core
}

function feature_core(){

    git flow feature start ${branchName}
    
    sed -e "${number}s/^/>>>/" ${TODOFILE} > temp.txt
    temp_treat

}

function flow_finish(){

if [ ${TODO_Arg_FLAG} -eq ${FALSE} ]; then
    echo ""
    show_list
    echo ""
    echo -n "Select item >>> "
    read number
fi

if [ ${TODO_Arg_FLAG} -eq ${TRUE} ]; then
    count_list
    echo ""
    echo -n "Select item >>> ${number}"
    echo  ""
    get_title_list

fi

    error_check
    [ $? -eq 110 ] && exit 66

    branchName=${titile[${number}]}
    echo "${branchName}"

    case ${branchName} in
        ">>>"*)
            branchName=`echo "${branchName}" |sed -e "s/^>>>//"`
            branchName=`echo "${branchName}" |sed -e "s/^>>>([A-Z])//"`
            branchName=`echo "${branchName}" |sed -e "s/^ //"`

        #git branch name get
            gitbranch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
            echo "active branch is ${gitbranch}"

            if [ "feature/""${branchName}" != "${gitbranch}" ]; then
                echo "select branch is not active branch"
                exit 1
            fi

            git flow feature finish ${branchName}
            
        #不正終了する場合は終了
            if [ $? -ne 0 ]; then
                echo "xxxxx"
                exit 1
            fi

            sed -e "${number}d" ${TODOFILE} > temp.txt
            temp_treat

            ;;
        [a-z]*|[A-Z]*)
            echo "It is not git-flow branch"
            ;;
        "("[A-Z]")"* )
            echo "priority task for you. Fast Fast Fast"
            ;;
    esac
}

function flow_release_start(){

    check_current_git_dir

    echo "tag list"
    echo ""
    git tag #---> tag show
    echo ""
    echo -n "set the tag --->"
    read number

    case ${number} in
        q)
            echo "Exit todo-git"
            exit 1
            ;;
    esac

    git flow release start ${number}

    todo.sh add ">>>${number}:(release)"

}

function flow_release_finish(){

    show_list

    echo ""
    echo -n "Select number --> "
    read number

    error_check
    [ $? -eq 110 ] && exit 77

    releaseName=${titile[${number}]}

    case ${releaseName} in
        ">>>"*)
            releaseName=`echo "${releaseName}" |sed -e "s/^>>>//"`
            releaseName=`echo "${releaseName}" |sed -e "s/^>>>([A-Z])//"`
            releaseName=`echo "${releaseName}" |sed -e "s/^ //"`
            releaseName=`echo "${releaseName}" |sed -e "s/:(release)//"`

        #git branch name get
            gitbranch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

            if [ "release/""${releaseName}" != "${gitbranch}" ]; then
                echo "select branch is not active branch"
                exit 1
            fi

            git flow release finish ${releaseName}
            
        #不正終了する場合は終了
            if [ $? -ne 0 ]; then
                echo "xxxxx: may be git branch is not clear"
                exit 1
            fi

            sed -e "${number}d" ${TODOFILE} > temp.txt
            temp_treat

            ;;
        [a-z]*|[A-Z]*)
            echo "It is not git-flow branch"
            ;;
        "("[A-Z]")"* )
            echo "priority task for you. Fast Fast Fast"
            ;;
    esac
}

function display_help(){
    cat <<EOF
Usage: todo_git.sh -[sflerodxph] [todo list number]

ex) 
   > todo_git.sh -s    ---> if you do not know list number
   > todo_git.sh -s 1  ---> you already know list number 

 OPTION
   s: git flow feature Start
   f: git flow feature Finish
   e: Edit todo.txt
   l: show todo List
   r: git flow Release start
   o: git flow Release finish
   d: Delite item from todo list
   x: items order eXchange
   p: show list of Project
   h: show help

EOF
}
function errorMessage()
{
    cat <<EOF
 
 YOU NEED AN OPTION
   s: feature/start
   f: feature/finish
   e: edit todo.txt
   l: show todo list
   r: release/start
   o: release/finish
   d: delite item from todo list
   x: items order exchange
   p: show list of project

EOF

}

function arg_check(){

    if expr ${number} : '[0-9]*' >/dev/null; then
        echo "number is ${number}"
        TODO_Arg_FLAG=$TRUE
    else
        echo "not number"
        TODO_Arg_FLAG=$FALSE
    fi

}


######### #Script mains #################
echo "---------------------------------"
echo -e "${LIGHT_CYAN}""Git branch control from todo.txt""${DEFAULT}"
echo "---------------------------------"

# 変数 $# の値が 1~2 でなければエラー終了。

if [ $# -eq 0 ] || [ $# -gt 2 ] ; then
    errorMessage
    exit 1
fi

# second arg treatment
number=$2
if [ -z $2 ]; then
    TODO_Arg_FLAG=$FALSE
else
    arg_check
fi

#make buck up
dobuck4

#引数処理
#magic number come! warning!
while getopts "sflerodxph" opt
do 
    case ${opt} in
        s) FLAG=11
            ;;
        f) FLAG=111
            ;;
        l) FLAG=2
            ;;
        e) echo "----> Edit todo.txt";
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

        \?) errorMessage
            exit 1
            ;;
    esac
done

shift `expr $OPTIND - 1`

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
    echo -e "${GREEN_U}""show project list""${DEFAULT}";
    show_project_list
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
