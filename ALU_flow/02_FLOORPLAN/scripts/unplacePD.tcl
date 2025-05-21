proc unplacePD {} {
    foreach pd_ptr [dbGet top.fplan.groups] {
        modifyPowerDomainAttr [dbGet $pd_ptr.name] -box  -100 -100  -110 -110
    }
deletePowerSwitch -column -powerDomain KERNEL_SW 

}
