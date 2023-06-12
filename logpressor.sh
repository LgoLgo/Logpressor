#! /bin/bash

LOG_DIR=logs
[[ -d $LOG_DIR ]] || mkdir $LOG_DIR
cd $LOG_DIR

produce_log_files() {
  while true
  do
    let "host_count = $RANDOM % 7 + 2"

    now_time=$(date "+%H%M%S")
    declare -a host_arr
    for i in `seq 0 $host_count`
    do
      host_arr[$i]="192.0.0.`expr $i + 10`"
    done

    for host in "${host_arr[@]}"
    do
      echo "produce log file ${host}_${now_time}.access.log"
      touch ${host}_${now_time}.access.log
    done
    sleep 10
  done
}

compress_log_files() {
  while true
  do
    sleep 1
    compress_time=$(find . -name "*access.log" -exec basename {} \; | awk -F_ '{print $2}' | awk -F. '{print $1}' | sort -r | uniq | awk 'NR==1{print}')
    if [ -z "$compress_time" ]; then
      echo "no log file to compress"
      continue
    fi
    find . -name "*${compress_time}.access.log" | xargs tar -czpf log_compress_${compress_time}.tar.gz
    if [ $? -eq 0 ] && [ -e "log_compress_${compress_time}.tar.gz" ]; then
      find . -name "*${compress_time}.access.log" -exec rm -f {} \;
    fi
    echo "compress log file ${compress_time}.access.log"
  done
}

produce_log_files &
compress_log_files &