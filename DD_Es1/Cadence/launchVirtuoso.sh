#!/bin/bash
# Cadence source and startup script

# Updated 01.02.2022

##For generic PDK, assura is required
export CDS_LIC_FILE=27002@license-extern.esat.kuleuven.be

source /users/micas/micas/design/scripts/ic_6.1.8.170.rc
source /users/micas/micas/design/scripts/spectre_20.10.rc

source /users/micas/micas/design/scripts/assura_4.16.115.rc

virtuoso&
