#!/bin/bash
# huggingface write token
#export HF_TOKEN=
#export HF_HUB_ENABLE_HF_TRANSFER=1

# usage: ./batch_quant_exllama.sh 2 Devstral-Small-2507,6.5 Devstral-Small-2507,5.0 Devstral-Small-2507,4.25"
# usage: ./batch_quant_exllama.sh 3 Devstral-Small-2507,3.5 Devstral-Small-2507,3.0 Devstral-Small-2507,2.5"

exl_version=$1

if [ "${exl_version}" != "2" ] && [ "${exl_version}" != "3" ]; then
	echo "USAGE: ./batch_quant_exllama.sh <exllama version> <model folder in models/>,<quant bpw> [...]"
	echo "USAGE: ./batch_quant_exllama.sh 2 Devstral-Small-2507,6.5 Devstral-Small-2507,5.0 Devstral-Small-2507,4.25"
	echo "USAGE: ./batch_quant_exllama.sh 3 Devstral-Small-2507,3.5 Devstral-Small-2507,3.0 Devstral-Small-2507,2.5"
fi

shift

real_models_root="./models"
real_exl2tmp="./exl2tmp" # make sure this is for exl2 only (ie. not /tmp), it will get rm -rf "${real_exl2tmp}"/*
models_root="/app/models"
ss=10240

if [ ! -d "${real_exl2tmp}" ]; then
    echo "The exl2tmp dir does not exist: '${real_exl2tmp}'"
    exit
fi

for mb in $@; do
    model=$(echo $mb | sed 's/,.*//')
    bits=$(echo $mb | sed 's/.*,//')
    model=$(basename $model)

    model_dir="${models_root}/${model}"

    # use 8bits for head over 6 bits.
    if awk "BEGIN { exit ($bits > 6.0 == 0) }"; then
        head_bits=8
        QUANT="${model}-${bits}bpw-h${head_bits}-exl${exl_version}"
    else
        head_bits=6
        QUANT="${model}-${bits}bpw-exl${exl_version}"
    fi

    if [ "${exl_version}" == "3" ]; then
        export CLI_ARGS="python3 exllamav3/convert.py -w /exl2tmp/ -i ${model_dir} -o ${models_root}/${QUANT} -hb ${head_bits} -b ${bits} -ss $ss"
    else
        if [ ! -f "${real_models_root}/${model}/measurement.json" ]; then
            export CLI_ARGS="python3 exllamav2/convert.py -o /exl2tmp/ -om ${model_dir}/measurement.json -i ${model_dir}/ -nr"
            echo "Starting MEASUREMENT of $model"
            rm -rf "${real_exl2tmp}"/*
            docker compose -f docker-compose.yml up
            # no error checking if measurement fails
            echo "Done MEASUREMENT of $model"
        fi

        export CLI_ARGS="python3 exllamav2/convert.py -o /exl2tmp/ -m ${model_dir}/measurement.json -i ${model_dir}/ -nr -cf ${models_root}/${QUANT} -hb ${head_bits} -b ${bits} -ss $ss"
    fi
   
    echo "Starting $model at $bits bits"
    rm -rf "${real_exl2tmp}"/*
    docker compose -f docker-compose.yml up
    echo "Model saved in ${QUANT}"

    echo huggingface-cli repo create -y "${QUANT}"
    echo huggingface-cli upload --repo-type model --commit-message 'initial' "<you>/${QUANT}" "${QUANT}"
done

rm -rf "${real_exl2tmp}"/*

