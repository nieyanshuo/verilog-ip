#-------------------------------------------------------------------------------------------------------
vcs_syn   :
	vcs  \
              -f filelist.f  \
              -timescale=1ns/100ps \
              -fsdb  -full64  -R  +vc  +v2k  -sverilog  -debug_all  \
              -P ${LD_LIBRARY_PATH}/novas.tab  ${LD_LIBRARY_PATH}/pli.a  \
              |  tee  vcs.log  &
#-------------------------------------------------------------------------------------------------------
verdi_syn  :
	verdi -f filelist.f -nologo  -ssf tb_syn.fsdb
#-------------------------------------------------------------------------------------------------------
vcs_asyn   :
	vcs  \
              -f filelist_asyn.f  \
              -timescale=1ns/100ps \
              -fsdb  -full64  -R  +vc  +v2k  -sverilog  -debug_all  \
              -P ${LD_LIBRARY_PATH}/novas.tab  ${LD_LIBRARY_PATH}/pli.a  \
              |  tee  vcs.log  &
#-------------------------------------------------------------------------------------------------------
verdi_asyn  :
	verdi -f filelist_asyn.f -nologo  -ssf tb_asyn.fsdb
#-------------------------------------------------------------------------------------------------------
clean  :
	 rm  -rf  *~  core  csrc  simv*  vc_hdrs.h  ucli.key  urg* *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vpd
#-------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------
.PHONY  : clean vcs_syn verdi_syn vcs_asyn verdi_asyn 
