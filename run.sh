#!/bin/sh
# 2013-10-13 by maniac@localhost.sk initial version with rrd
# 2019-03-15 by maniac@localhost.sk version with influx

POWERPLANT_IP=x.x.x.x
INFLUXDB_IP=y.y.y.y
URL="http://$INFLUXDB_IP:8086/write?db=opentsdb"
AUTH=""			# authenticate to influx format: -u login:pass  ; e.g. AUTH="-u mylogin:mypass"
DELAY=10		# seconds to sleep before next iteration

#######################################################################

while true ; do

X=$(curl -m 10 -s "http://$POWERPLANT_IP/diagnostics/measurements.xml" | sed 's|</.*||g')

  if [ $? -eq 0 ] ; then
    inputVoltage=$(echo "$X" | sed 's|</.*||g' | grep inputVoltage | sed s/.*\>// )
    inputThd=$(echo "$X" | sed 's|</.*||g' | grep inputThd | sed s/.*\>//)
    inputFrequency=$(echo "$X" | sed 's|</.*||g' | grep inputFrequency | sed s/.*\>//)
    outputVoltage=$(echo "$X" | sed 's|</.*||g' | grep outputVoltage | sed s/.*\>//)
    outputThd=$(echo "$X" | sed 's|</.*||g' | grep outputThd | sed s/.*\>//)
    outputCurrent=$(echo "$X" | sed 's|</.*||g' | grep outputCurrent | sed s/.*\>//)
    outputPower=$(echo "$X" | sed 's|</.*||g' | grep outputPower | sed s/.*\>//)
    outputDCOffset=$(echo "$X" | sed 's|</.*||g' | grep outputDCOffset | sed s/.*\>//)
    sensorTemp1=$(echo "$X" | sed 's|</.*||g' | grep sensorTemp1 | sed s/.*\>//)
    sensorTemp2=$(echo "$X" | sed 's|</.*||g' | grep sensorTemp2 | sed s/.*\>//)
    #  echo "inputVoltage: $inputVoltage"
    #  echo "inputThd: $inputThd"
    #  echo "inputFrequency: $inputFrequency"
    #  echo "outputVoltage: $outputVoltage"
    #  echo "outputThd: $outputThd"
    #  echo "outputCurrent: $outputCurrent"
    #  echo "outputPower: $outputPower"
    #  echo "outputDCOffset: $outputDCOffset"
    #  echo "sensorTemp1: $sensorTemp1"
    #  echo "sensorTemp2: $sensorTemp2"      
  fi

  DATA='metric=inputVoltage,host=P10 value='"$inputVoltage"
  DATA=$DATA$'\nmetric=inputThd,host=P10 value='"$inputThd"
  DATA=$DATA$'\nmetric=inputFrequency,host=P10 value='"$inputFrequency"
  DATA=$DATA$'\nmetric=outputVoltage,host=P10 value='"$outputVoltage"
  DATA=$DATA$'\nmetric=outputThd,host=P10 value='"$outputThd"
  DATA=$DATA$'\nmetric=outputCurrent,host=P10 value='"$outputCurrent"
  DATA=$DATA$'\nmetric=outputPower,host=P10 value='"$outputPower"
  DATA=$DATA$'\nmetric=outputDCOffset,host=P10 value='"$outputDCOffset"
  DATA=$DATA$'\nmetric=sensorTemp1,host=P10 value='"$sensorTemp1"
  DATA=$DATA$'\nmetric=sensorTemp2,host=P10 value='"$sensorTemp2"

  curl $AUTH -X POST --data "$DATA" "$URL"

  sleep $DELAY

done
