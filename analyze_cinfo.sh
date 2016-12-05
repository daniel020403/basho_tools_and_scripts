#!/bin/bash

if [ $# -lt 2 ]; then
  echo "analyse_cinfo <cluster-info file> <output dir>"
  exit 1
fi

CINFO=$1
WORK_DIR=$2
echo "Generating work directory: $WORK_DIR..."
DIR=`dirname $1`
REPORT_PREFIX=$WORK_DIR/report

mkdir -p $WORK_DIR
echo "Collecting pids having a large mailbox..."
fgrep 'Report: Non-zero mailbox sizes' $CINFO -A 30 | grep -v Non-zero | egrep '0\.[0-9]+\.[0-9]+'
fgrep 'Report: Non-zero mailbox sizes' $CINFO -A 30 | grep -v Non-zero | egrep -o '0\.[0-9]+\.[0-9]+' > $WORK_DIR/pids

echo "Generating the process report..."
for pid in `cat $WORK_DIR/pids`; do
  REPORT=${REPORT_PREFIX}_${pid}
  echo "== Process report: <$pid>" | tee $REPORT
  initial_call=`fgrep "=proc:&lt;$pid" $CINFO -A 10 | egrep -o "initial_call',{[a-z0-9_,]+}"`
  echo "initial_call: $initial_call" | tee -a $REPORT
  echo "Massage summary:" | tee -a $REPORT
  fgrep "=proc:&lt;$pid" $CINFO -A 10 | fgrep 'Message queue:' | egrep -o "[a-z0-9_]+_req_v[a-z0-9_]+" | sort | uniq -c | tee -a $REPORT
done

echo "Generating total message summary..."
cat $WORK_DIR/pids | xargs -n1 -I {} fgrep "=proc:&lt;{}" $CINFO -A 10 | fgrep 'Message queue:' | egrep -o "[a-z0-9_]+_req_v[a-z0-9_]+" | sort | uniq -c |tee $WORK_DIR/request_stats_total
