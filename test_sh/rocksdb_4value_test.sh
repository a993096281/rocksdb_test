#! /bin/sh

value_array=(1024 4096 16384 65536)
#value_array=(1024)
test_all_size=81920000000   #80G


db="/mnt/ssd/ceshi"


value_size="4096"
compression_type="none" #"snappy,none"



#benchmarks="fillrandom,stats"
benchmarks="fillseq,stats"
num="20000000"
reads="1000000"

max_background_jobs="2"
 
max_bytes_for_level_base="`expr 256 \* 1024 \* 1024`" 

#perf_level="1"


bench_file_path="$(dirname $PWD )/db_bench"

bench_file_dir="$(dirname $PWD )"

if [ ! -f "${bench_file_path}" ];then
bench_file_path="$PWD/db_bench"
bench_file_dir="$PWD"
fi

if [ ! -f "${bench_file_path}" ];then
echo "Error:${bench_file_path} or $(dirname $PWD )/db_bench not find!"
exit 1
fi

function FILL_PATAMS() {
    if [ -n "$db" ];then
        const_params=$const_params"--db=$db "
    fi

    if [ -n "$key_size" ];then
        const_params=$const_params"--key_size=$key_size "
    fi

    if [ -n "$value_size" ];then
        const_params=$const_params"--value_size=$value_size "
    fi

    if [ -n "$compression_type" ];then
        const_params=$const_params"--compression_type=$compression_type "
    fi

    if [ -n "$benchmarks" ];then
        const_params=$const_params"--benchmarks=$benchmarks "
    fi

    if [ -n "$num" ];then
        const_params=$const_params"--num=$num "
    fi

    if [ -n "$reads" ];then
        const_params=$const_params"--reads=$reads "
    fi

    if [ -n "$deletes" ];then
        const_params=$const_params"--deletes=$deletes "
    fi

    if [ -n "$max_background_jobs" ];then
        const_params=$const_params"--max_background_jobs=$max_background_jobs "
    fi

    if [ -n "$max_bytes_for_level_base" ];then
        const_params=$const_params"--max_bytes_for_level_base=$max_bytes_for_level_base "
    fi

    if [ -n "$perf_level" ];then
        const_params=$const_params"--perf_level=$perf_level "
    fi

    if [ -n "$threads" ];then
        const_params=$const_params"--threads=$threads "
    fi

    if [ -n "$histogram" ];then
        const_params=$const_params"--histogram=$histogram "
    fi

    if [ -n "$level0_file_num_compaction_trigger" ];then
        const_params=$const_params"--level0_file_num_compaction_trigger=$level0_file_num_compaction_trigger "
    fi

    if [ -n "$level0_slowdown_writes_trigger" ];then
        const_params=$const_params"--level0_slowdown_writes_trigger=$level0_slowdown_writes_trigger "
    fi

    if [ -n "$level0_stop_writes_trigger" ];then
        const_params=$const_params"--level0_stop_writes_trigger=$level0_stop_writes_trigger "
    fi

    if [ -n "$write_buffer_size" ];then
        const_params=$const_params"--write_buffer_size=$write_buffer_size "
    fi

    if [ -n "$max_write_buffer_number" ];then
        const_params=$const_params"--max_write_buffer_number=$max_write_buffer_number "
    fi

    if [ -n "$target_file_size_base" ];then
        const_params=$const_params"--target_file_size_base=$target_file_size_base "
    fi

    if [ -n "$seek_nexts" ];then
        const_params=$const_params"--seek_nexts=$seek_nexts "
    fi

    if [ -n "$use_direct_reads" ];then
        const_params=$const_params"--use_direct_reads=$use_direct_reads "
    fi

    if [ -n "$use_direct_io_for_flush_and_compaction" ];then
        const_params=$const_params"--use_direct_io_for_flush_and_compaction=$use_direct_io_for_flush_and_compaction "
    fi

    if [ -n "$cache_size" ];then
        const_params=$const_params"--cache_size=$cache_size "
    fi

    if [ -n "$statistics" ];then
        const_params=$const_params"--statistics=$statistics "
    fi

    if [ -n "$batch_size" ];then
        const_params=$const_params"--batch_size=$batch_size "
    fi

    if [ -n "$sync" ];then
        const_params=$const_params"--sync=$sync "
    fi

    if [ -n "$bloom_bits" ];then
        const_params=$const_params"--bloom_bits=$bloom_bits "
    fi

}

RUN_ONE_TEST() {
    const_params=""
    FILL_PATAMS
    cmd="$bench_file_path $const_params >>out.out 2>&1"
    echo $cmd >out.out
    echo $cmd
    eval $cmd
}

CLEAN_CACHE() {
    if [ -n "$db" ];then
        rm -f $db/*
    fi
    sleep 2
    sync
    echo 3 > /proc/sys/vm/drop_caches
    sleep 2
}

COPY_OUT_FILE(){
    mkdir $bench_file_dir/result > /dev/null 2>&1
    res_dir=$bench_file_dir/result/value-$value_size
    mkdir $res_dir > /dev/null 2>&1
    
    \cp -f $bench_file_dir/out.out $res_dir/
}
RUN_ALL_TEST() {
    for value in ${value_array[@]}; do
        CLEAN_CACHE
        value_size="$value"
        num="`expr $test_all_size / $value_size`"

        RUN_ONE_TEST
        if [ $? -ne 0 ];then
            exit 1
        fi
        COPY_OUT_FILE
        sleep 5
    done
}

RUN_ALL_TEST
