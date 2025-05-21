source ../tool_version.sh

rm -f innovus.* logs/*
rm -rf reports/* dbs/* timingReports/*
rm -f PowerAnalysis/*
rm -rf FE2VSEarlyRA

innovus -overwrite -init scripts/innoFloorplan.tcl -log logs/innoFloorplan.log -cmd logs/innoFloorplan.cmdlog