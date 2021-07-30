#!/bin/bash

RAPIDS_MG_TOOLS_DIR=${RAPIDS_MG_TOOLS_DIR:=$(cd $(dirname $0); pwd)}
source ${RAPIDS_MG_TOOLS_DIR}/script-env.sh

module load cuda/11.0.3
activateCondaEnv

RUN_SCHEDULER=0

# Assumption is that this script is called from a multi-node sbatch
# run via srun, with one task per node.  Use SLURM_NODEID 1 for the
# scheduler instead of SLURM_NODEID 0, since the test/benchmark script
# is typically run on 0 and putting the scheduler on 1 helps
# distribute the load (I think, just based on getting OOM errors when
# everything ran on 0).
if [[ $SLURM_NODEID == 1 ]] || hasArg --scheduler-and-workers; then
    RUN_SCHEDULER=1
fi

# NOTE: if the LOGS_DIR env var is exported from the calling env, it
# will be used by run-dask-process.sh as the log location.
if [[ $RUN_SCHEDULER == 1 ]]; then
    ${SCRIPTS_DIR}/run-dask-process.sh scheduler workers
else
    ${SCRIPTS_DIR}/run-dask-process.sh workers
fi


