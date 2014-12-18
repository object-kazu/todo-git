######### GLOBAL VARIABLE ###############
SUB_HEADER="<<< sub < "
 
######### functions ###############
#editor
function callEdit(){

#  emacs ${TODOFILE}
#    vim ${TODOFILE}
#    mg ${TODOFILE}
#    subl ${TODOFILE}

    if [ -x /Applications/Emacs24.app/Contents/MacOS/bin/emacsclient ]; then

        /Applications/Emacs24.app/Contents/MacOS/bin/emacsclient ${TODOFILE}

    else
        subl ${TODOFILE}
    fi

}

function branch_list(){
    git branch > ${BRANCH_LIST}
    nl ${BRANCH_LIST} #行番を付けて表示

}

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
function show_project_list_colored(){
    #temporary method
    todo.sh projectview > JUNKFILE

    count=0
    while read line; do
        # ---: red 
        # >>>: blue

        case ${line} in
            ---*) echo -e "${MAGENDA_U}""---${line}---- ""${DEFAULT}" ;;
            *">>>"*)echo -e "${CYAN}""${line}""${DEFAULT}";;
            *)echo "  ${line}";;
        esac

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
    
    echo ""
    echo "New order"
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
        #echo -e "${GREEN}" "back up file is Found""${DEFAULT}"
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


############## TODO_Arg_FLAG Check  #################################
function selectNumber(){
    echo ""
    show_list
    echo ""
    echo -n "Select item >>> "
    read number
}

function setNumber(){
    count_list
    echo ""
    get_title_list
}

function select_ListNumber(){

if [ ${TODO_Arg_FLAG} -eq ${FALSE} ]; then
    selectNumber
 fi

if [ ${TODO_Arg_FLAG} -eq ${TRUE} ]; then
    setNumber
fi
}



############## git flow feature branch  #################################
function flow_start(){

    check_current_git_dir
    select_ListNumber
    error_check
    [ $? -eq 110 ] && exit 55

    #Titleを得る
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

    select_ListNumber
    error_check
    [ $? -eq 110 ] && exit 66

    branchName=${titile[${number}]}
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
	    illegal_Operation
            ;;
        [a-z]*|[A-Z]*)
            echo "It is not git-flow branch"
            ;;
        "("[A-Z]")"* )
            echo "priority task for you. Fast Fast Fast"
            ;;
    esac
}

############## git flow release branch #################################
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

    selectNumber
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
	    illegal_Operation
            ;;
        [a-z]*|[A-Z]*)
            echo "It is not git-flow branch"
            ;;
        "("[A-Z]")"* )
            echo "priority task for you. Fast Fast Fast"
            ;;
    esac
}


function illegal_Operation(){
 if [ $? -ne 0 ]; then
     echo "xxxxx: may be git branch is not clear"
     exit 1
 fi

 sed -e "${number}d" ${TODOFILE} > temp.txt
 temp_treat
}

############## Feature sub-branch #################################
function feature_branch_start(){

    check_current_git_dir

if [ ${TODO_Arg_FLAG} -eq ${FALSE} ]; then 
    if [ -z ${subBranchName} ]; then
	#ex1) todo_git.sh -b >>>　引数なし
	subFeatureBranchWithOutArg
    else

	#ex3) todo_git.sh -b test　>>> 引数にSubBranch名
	subFeatureBranchWithBranchName
    fi

else #list numberが設定されている場合

    #ex2) todo_git.sh -b 5　>>> 引数にリスト番号
    subFeatureBranchWithListNumber
fi
}

function subFeatureBranchWithOutArg(){

    selectNumber
    count_list
     error_check
     [ $? -eq 110 ] && exit 55

    case ${titile[$number]} in
        "("[A-Z]")"* )
            titile[$number]=`echo ${titile[$number]}|cut -d " " -f2`
            ;;
    esac

    subBranchName=${titile[$number]}
    subFeatureBranchCore
}

function subFeatureBranchWithBranchName(){

    addTitle=${SUB_HEADER}${subBranchName}
    todo.sh add ${addTitle}
    git checkout -b ${subBranchName}

}

function subFeatureBranchWithListNumber(){
    setNumber
    case ${titile[$number]} in
        "("[A-Z]")"* )
            titile[$number]=`echo ${titile[$number]}|cut -d " " -f2`
            ;;
    esac

    subBranchName=${titile[$number]}
    subFeatureBranchCore
}

function subFeatureBranchCore(){

    git checkout -b ${subBranchName}
    
    sed -e "${number}s/^/${SUB_HEADER}/" ${TODOFILE} > temp.txt
    temp_treat

}

function get_current_Branch(){
    #current branchを保持
    currentBranch=`git rev-parse --abbrev-ref HEAD`

}

function select_Return_Branch(){

    # echo "------------ 1"
    # todo_git.sh -l
    # echo "------------ 1"
    
    #feature branchを探す
    git branch > temp.txt
    grep -m 1 -n "feature/" temp.txt > greppedResult    
    returnBranchNumber=`cut -f 1 -d ":" greppedResult`
        
    #不要なファイルを削除
    rm  greppedResult

    #戻るブランチを選択
    branch_list
    echo -n "Select feature branch  --> ${returnBranchNumber} (default)"
    read key
    if [[ $key = "" ]]; then
	#returnBranchNumberで処理を続ける
	#echo 'You pressed enter!'
	number=${returnBranchNumber}
    else
	#入力値で処理を続ける
	#echo "You pressed '$key'"
	number=${key}	
    fi
    
    echo "select: ${number}"
    count_list
    error_check
    [ $? -eq 110 ] && exit 88
    featureName=`cat ${BRANCH_LIST} |sed -n ${number}p`
}


function remove_Current_Branch(){
    #この関数を使う前にget_current_Branchを読んでおくこと！
    targetStrings=${SUB_HEADER}${currentBranch}
    sed "/${targetStrings}/d" ${TODOFILE} > temp.txt
    temp_treat
}

function feature_branch_merged_end(){

    get_current_Branch
    select_Return_Branch
    
    git checkout ${featureName}
    git merge ${currentBranch}
    git branch -d ${currentBranch}
    
    #todo.txt処理
    remove_Current_Branch
}

function feature_branch_unmerged_end(){

    get_current_Branch
    select_Return_Branch
    
    git checkout ${featureName}
    git branch -D ${currentBranch}

    #todo.txt処理
    remove_Current_Branch
}



############## help #################################
function display_help(){
    cat <<EOF
Usage: todo_git.sh -[sfbmulerodxph] [todo list number]

ex) 
   > todo_git.sh -s    ---> if you do not know list number
   > todo_git.sh -s 1  ---> you already know list number 

 OPTION
 --- feature branch ----
   s: git flow feature Start
   f: git flow feature Finish

 --- sub-Feature branch ----
   b: git checkout -b 
   m: marge sub-Feature branch
   u: un-marge sub-Feature branch

 --- release branch ----
   r: git flow Release start
   o: git flow Release finish

 --- todo list ----
   e: Edit todo.txt
   l: show todo List
   d: Delete item from todo list
   x: items order eXchange
   p: show list of Project
   h: show help

EOF
}
function errorMessage()
{
    cat <<EOF
 
 YOU NEED AN OPTION
 --- feature branch ----
   s: git flow feature Start
   f: git flow feature Finish

 --- sub-Feature branch ----
   b: make sub-branch (= git checkout -b)
   m: marge sub-Feature branch
   u: un-marge sub-Feature branch

 --- release branch ----
   r: git flow Release start
   o: git flow Release finish

 --- todo list ----
   e: Edit todo.txt
   l: show todo List
   d: Delete item from todo list
   x: items order eXchange
   p: show list of Project
   h: show help

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

export MAGENDA_U='\033[4;35m'

