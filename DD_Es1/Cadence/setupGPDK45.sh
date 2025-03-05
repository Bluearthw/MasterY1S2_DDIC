#!/bin/bash

#Run this in your cadence work directory, or whatever directory you are working in

#Updated 01.02.2022

cp ~micasusr/design/generic/045/gpdk045_v_4_0/pvtech.lib .
cp ~micasusr/design/generic/045/gpdk045_v_4_0/assura_tech.lib .
cp ~micasusr/design/generic/045/gpdk045_v_4_0/lib.defs ./cds.lib
ln -s ~micasusr/design/generic/045/gpdk045_v_4_0/assura assura
ln -s ~micasusr/design/generic/045/gpdk045_v_4_0/docs docs
ln -s ~micasusr/design/generic/045/gpdk045_v_4_0/gpdk045 gpdk045
ln -s ~micasusr/design/generic/045/gpdk045_v_4_0/models models
ln -s ~micasusr/design/generic/045/gpdk045_v_4_0/qrc qrc
ln -s ~micasusr/design/generic/045/gpdk045_v_4_0/soce soce
ln -s ~micasusr/design/generic/045/gpdk045_v_4_0/pvs pvs 


