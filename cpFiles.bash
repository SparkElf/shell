#!/bin/bash

function containElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}
src
dest
array=()
function cpFiles(){
    src=$1
    echo $src
    echo $dest
    for file in "$src"/*
    do
        if [[ -f $file ]]  
        then
            extension="${file##*.}"
            basename=`basename $file`
            echo $basename 是文件，后缀为$extension
            if ! containElement $extension ${array[@]}
            then
            array+=($extension)
            mkdir $dest/$extension #根据后缀创建文件夹
            touch $dest/analysis/$extension.txt #根据后缀生成临时子analysis文件
            echo " |$extension文件| ">> $dest/analysis/$extension.txt
            echo "------------src------------| |------------dest------------">> $dest/analysis/$extension.txt
            fi
            #处理重名问题
            if [[ -f $dest/$extension/$basename ]]
            then
                declare -i count=1
                echo $dest/$extension/"${basename%%.*}($count).$extension"
                while [[ -f $dest/$extension/"${basename%%.*}($count).$extension" ]]
                do
                     count+=1
                done
                cp $file $dest/$extension/"${basename%%.*}($count).$extension"
                echo "$file| |"$dest/$extension/"${basename%%.*}($count).$extension">> $dest/analysis/$extension.txt 
            else
                cp  $file $dest/$extension
                echo "$file| |"$dest/$extension/"$basename.$extension ">> $dest/analysis/$extension.txt
            fi
            
        fi

        if [[ -d $file ]] #前后要有空格 
        then
            echo $file 是目录
            cpFiles $file 
        fi
    done 
    
}

function initDest(){
    if [ -d "$dest" ] #创建目的目录
    then
        read md5 < <(echo -n  $(date "+%Y%m%d%H%M%S") | openssl md5)
        md5=${md5#*= }
        dest=$dest-$md5
    fi
    mkdir $dest
    mkdir $dest/analysis
}
function handleArgs(){
    while [ $1 ]
    do
        if [ "$1" == "-d" ] ||  [ "$1" == "-D" ]
        then 
            shift
            dest=$1
        elif [ "$1" == "-s" ] ||  [ "$1" == "-S" ]
        then 
            shift
            src="$1"
        fi
        shift
    done


    if [ ! $src ]
    then
        src="."
        echo 未指定src
    fi

    if [ ! $dest ]
    then 
        pwd=`pwd`
        dest=/tmp/`basename $pwd`-group_by_extensions
        echo 未指定dest
    fi
    echo src: $src
    echo dest: $dest
}
function organizeAnalysis(){
    touch $dest/analysis.txt

    for file in $dest/analysis/*
    do
        cat $file >> $dest/analysis.txt
        echo -e " | | \n | | \n" >> $dest/analysis.txt
    done
    rm -rf $dest/analysis
    (echo -e | column -t -s "|" $dest/analysis.txt) >> $dest/analysis-beautiful.txt
    rm -rf $dest/analysis.txt
    mv $dest/analysis-beautiful.txt $dest/analysis.txt
}

handleArgs $@
initDest
cpFiles $src $dest
organizeAnalysis
