#! /bin/sh

db="/home/lzw/ceshi"
#db="/media/psf/lzw/ceshi"
key_size="16"
value_size="16"
compression_type="none" #"snappy,none"

#benchmarks="fillrandom,stats,readrandom,stats,seekrandom,stats" 
benchmarks="fillrandom,stats,readrandom,stats,seekrandom,stats,updaterandom,stats,deleterandom,stats"

num="100000000"
#num="100000000"
reads="10000000"
deletes="10000000"

use_direct_reads="true"
use_direct_io_for_flush_and_compaction="true"

cache_size="`expr $num \* \( $key_size + $value_size \) \* 1 / 10 / 512`"   #10% block cache

max_background_jobs="2"
max_bytes_for_level_base="`expr 32 \* 1024 \* 1024`" 

write_buffer_size="`expr 32 \* 1024 \* 1024`"
max_write_buffer_number="2"

target_file_size_base="`expr 4 \* 1024 \* 1024`"

seek_nexts="100"

#perf_level="1"

threads="4"

level0_file_num_compaction_trigger="4"   #
level0_slowdown_writes_trigger="8"       #
level0_stop_writes_trigger="12"          #


const_params=""

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

}

bench_file_path="$(dirname $PWD )/db_bench"

if [ ! -f "${bench_file_path}" ];then
bench_file_path="$PWD/db_bench"
fi

if [ ! -f "${bench_file_path}" ];then
echo "Error:${bench_file_path} or $(dirname $PWD )/db_bench not find!"
exit 1
fi

FILL_PATAMS 

cmd="$bench_file_path $const_params "

if [ -n "$1" ];then
cmd="nohup $bench_file_path $const_params >>out.out 2>&1 &"
echo $cmd >out.out
fi


echo $cmd
eval $cmd

