#!../../bin/linux-x86_64/ez4axis

epicsEnvSet("ENGINEER",  "kgofron")
epicsEnvSet("LOCATION",  "740 10IDD RG-S")

epicsEnvSet("EPICS_CA_AUTO_ADDR_LIST", "NO")
epicsEnvSet("EPICS_CA_ADDR_LIST", "10.10.0.255")

< envPaths

## Register all support components
dbLoadDatabase("../../dbd/ez4axis.dbd",0,0)
ez4axis_registerRecordDeviceDriver(pdbbase) 

epicsEnvSet(EZ_IP   , "10.10.2.62")
epicsEnvSet(EZ_PORT , 4001)

epicsEnvSet(CtlSys  , "XF:10IDD-CT")
epicsEnvSet(Sys     , "XF:10IDD-ES")
epicsEnvSet(CntlDev , "Ez4:1")
#epicsEnvSet(CntlDev2 , "Ez4:2")
#epicsEnvSet(CntlDev3 , "Ez4:3")
#epicsEnvSet(CntlDev4 , "Ez4:4")
#epicsEnvSet(CntlDev5 , "Ez4:5")

#epicsEnvSet("IOCNAME", "ez4axis1") # set by softioc init.d script
epicsEnvSet("IOC_P", "$(CtlSys){IOC-$(IOCNAME)}")

## NOTE: RS485 address must match up with the address selected on the device with its address switch:
epicsEnvSet(ALM_ADDR, 1)
#epicsEnvSet(ALM_ADDR2, 2)
#epicsEnvSet(ALM_ADDR3, 3)
#epicsEnvSet(ALM_ADDR4, 4)
#epicsEnvSet(ALM_ADDR5, 5)

## Load record instances
dbLoadRecords("$(ALLMOTION)/db/ez4axis.db","Sys=$(Sys),Dev={$(CntlDev)},PORT=ALM1,ADDR=0")
#dbLoadRecords("$(ALLMOTION)/db/ez4axis.db","Sys=$(Sys),Dev={$(CntlDev2)},PORT=ALM2,ADDR=0")
#dbLoadRecords("$(ALLMOTION)/db/ez4axis.db","Sys=$(Sys),Dev={$(CntlDev3)},PORT=ALM3,ADDR=0")
#dbLoadRecords("$(ALLMOTION)/db/ez4axis.db","Sys=$(Sys),Dev={$(CntlDev4)},PORT=ALM4,ADDR=0")
#dbLoadRecords("$(ALLMOTION)/db/ez4axis.db","Sys=$(Sys),Dev={$(CntlDev5)},PORT=ALM5,ADDR=0")
dbLoadTemplate("motors.sub")

# drvAsynIPPortConfigure 'port name' 'host:port [protocol]' priority 'disable auto-connect' noProcessEos
drvAsynIPPortConfigure("IP1", "$(EZ_IP):$(EZ_PORT)", 0, 0, 0)

# almCreateController(AllMotion port name, asyn port name, RS485 address,
#                     Number of axes, Moving poll period (ms), Idle poll period (ms))
almCreateEZ4Controller("ALM1", "IP1", "$(ALM_ADDR)", 4, 100, 250)
#almCreateEZ4Controller("ALM2", "IP1", "$(ALM_ADDR2)", 4, 100, 250)
#almCreateEZ4Controller("ALM3", "IP1", "$(ALM_ADDR3)", 4, 100, 250)
#almCreateEZ4Controller("ALM4", "IP1", "$(ALM_ADDR4)", 4, 100, 250)
#almCreateEZ4Controller("ALM5", "IP1", "$(ALM_ADDR5)", 4, 100, 250)

asynSetTraceMask("ALM1", -1, 0x01)
#asynSetTraceMask("ALM2", -1, 0x01)
#asynSetTraceMask("ALM3", -1, 0x01)
#asynSetTraceMask("ALM4", -1, 0x01)
#asynSetTraceMask("ALM5", -1, 0x01)
asynSetTraceMask("IP1", -1, 0x01)
asynSetTraceMask("ALM1", -1, 0x1)
# asynSetTraceMask("IP1", -1, 0x0)
#asynSetTraceIOMask("ALM1", -1, 0x2)
#asynSetTraceIOMask("IP1", -1, 0x2)

cd ${TOP}/

dbLoadRecords("$(EPICS_BASE)/db/save_restoreStatus.db", "P=$(IOC_P)")
dbLoadRecords("$(EPICS_BASE)/db/iocAdminSoft.db","IOC=$(IOC_P)")
save_restoreSet_status_prefix("$(IOC_P)")

set_savefile_path("${TOP}/as/save","")
set_requestfile_path("$(EPICS_BASE)/as/req")
set_requestfile_path("${TOP}/as/req")

system("install -m 777 -d ${TOP}/as/save")
system("install -m 777 -d ${TOP}/as/req")

set_pass0_restoreFile("allmotion_pass0.sav")
#set_pass0_restoreFile("ioc_settings.sav")

set_pass1_restoreFile("allmotion_pass1.sav")
#set_pass1_restoreFile("ioc_pass1_settings.sav")

iocInit()

makeAutosaveFileFromDbInfo("$(TOP)/as/req/allmotion_pass0.req", "autosaveFields_pass0")
makeAutosaveFileFromDbInfo("$(TOP)/as/req/allmotion_pass1.req", "autosaveFields_pass1")

create_monitor_set("allmotion_pass0.req", 10, "")
create_monitor_set("allmotion_pass1.req", 10, "")

# caPutLogInit("ioclog.cs.nsls2.local:7004", 1)

# Enable limits
dbpf("$(Sys){$(CntlDev)}ModEnLimits","1")

# Move current value
dbpf("$(Sys){$(CntlDev)-Ax:2}MoveCur-SP","0.8")
dbpf("$(Sys){$(CntlDev)-Ax:4}MoveCur-SP","0.8")

# Adjust (reverse) limit polarity
#dbpf("XF:10IDD-ES{Ez4:1-Ax:1}LimitPolarity","1")
#dbpf("XF:10IDD-ES{Ez4:1-Ax:2}LimitPolarity","1")
#dbpf("XF:10IDD-ES{Ez4:1-Ax:3}LimitPolarity","1")
#dbpf("XF:10IDD-ES{Ez4:1-Ax:4}LimitPolarity","1")

#dbpf("$(Sys){$(CntlDev)-Ax:1}LimitPolarity","1")
#dbpf("$(Sys){$(CntlDev)-Ax:2}LimitPolarity","1")
#dbpf("$(Sys){$(CntlDev)-Ax:3}LimitPolarity","1")
#dbpf("$(Sys){$(CntlDev)-Ax:4}LimitPolarity","1")

cd ${TOP}
dbl > ./records.dbl
# system "cp ./records.dbl /cf-update/$HOSTNAME.$IOCNAME.dbl"
