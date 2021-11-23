// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: monitor.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
//
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
//
// The above named program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
//
// ========== Copyright Header End ============================================
`include "cross_module.tmp.h"
`include "iop.h"
`include "ifu.tmp.h"
//define and will move all the define to cross.h later
`define PLI_QUIT  1    /* None */

// /home/ruaro/nooman-openpiton/piton/verif/env/manycore/devices_ariane.xml


module monitor(/*AUTOARG*/
   // Inputs
   clk, cmp_gclk, rst_l
   );

   input clk;
   input cmp_gclk;
   input rst_l;

   wire  reset = ~rst_l;
   integer number, num, f_time, max_cycle, cycle;
   reg [1023:0] err;
   reg 		err_f;
   reg 		bad;
   reg          dum;

   initial
     begin
	number = 2;
	num    = 0;
	err_f  = 1;
	bad    = 0;
`ifndef VERILATOR
	max_cycle = 30000;
`else // ifndef VERILATOR
	max_cycle = 1500000;
`endif // ifndef VERILATOR
	cycle  = 0;
	if($value$plusargs("wait_cycle_to_kill=%d", number))$display("wait cycles = %d", number);
	if($value$plusargs("max_cycle=%d", max_cycle))$display("max cycles = %d", max_cycle);
     end // initial begin
   always @(posedge clk)begin
     if(`TOP_MOD.diag_done == 0)cycle = cycle + 1;
      if(cycle == max_cycle)begin
	 $display("%0d : Simulation -> (terminated by reaching max cycles = %0d)", $time, max_cycle);
	 $finish;
      end
   end

// central fail task. all the monitor should call this task to finish simulation.
   task fail;
      input [1023:0] comment;
      begin
	 if(bad)begin
	    $display("%0d : Simulation -> FAIL(%0s)", $time, comment);
	    $finish;
	 end
	 if(err_f)begin
	    err = comment;
	    f_time = $time;
	 end // if (err_f)
	 err_f = 0;
	 `TOP_MOD.fail_flag = 1'b1;
      end
   endtask // fail
   always @(posedge clk)begin
      if(`TOP_MOD.fail_flag)begin
	 num = num+1;
	 if(num == number)begin
	    $display("%0d : Simulation -> FAIL(%0s)", f_time, err);
	    $finish;
	 end
      end // if (`TOP_MOD.fail_flag)
   end

   /* l_cache_mon AUTO_TEMPLATE(

     //ICT
     .wrtag_f         (`IFUPATH@.ifq_ict_wrtag_f[`IC_TAG_SZ:0]),
     .wrway_f         (`IFUPATH@.icd.wrway_f[1:0]),
     .index_f         (`ICTPATH@.index_y[`IC_SET_IDX_HI:0]),
     .wrreq_f         (`ICTPATH@.wrreq_y),

    //ICV
     .wrreq_bf        (`ICVPATH@.wr_en),
     .wrindex_bf      (`ICVPATH@.wr_adr[`IC_SET_IDX_HI:2]),
     .wr_data         (`ICVPATH@.din_d1),
     .wren_f          (`ICVPATH@.bit_wen_d1[15:0]),

     .cpx_spc_data_cx (`PCXPATH@.cpx_spc_data_cx2),
     .cpx_spc_data_rdy_cx (`PCXPATH@.cpx_spc_data_rdy_cx2),
     .spc_pcx_data_pa (`TOP_DESIGN.sparc@.spc_pcx_data_pa),
     .spc_pcx_req_pq (`TOP_DESIGN.sparc@.spc_pcx_req_pq),
     .w0              (128'b0),
     .w1              (128'b0),
     .w2              (128'b0),
     .w3              (128'b0),
     .spc(@),
     );
    */
    /*thrfsm_mon AUTO_TEMPLATE(
`ifndef RTL_SPU
     .wm_imiss        (`TOP_DESIGN.sparc@.ifu.ifu.swl.wm_imiss[3:0]),
     .wm_other        (`TOP_DESIGN.sparc@.ifu.ifu.swl.wm_other[3:0]),
     .wm_stbwait      (`TOP_DESIGN.sparc@.ifu.ifu.swl.wm_stbwait[3:0]),
     .thr_state0      (`TOP_DESIGN.sparc@.ifu.ifu.swl.thr0_state[4:0]),
     .thr_state1      (`TOP_DESIGN.sparc@.ifu.ifu.swl.thr1_state[4:0]),
     .thr_state2      (`TOP_DESIGN.sparc@.ifu.ifu.swl.thr2_state[4:0]),
     .thr_state3      (`TOP_DESIGN.sparc@.ifu.ifu.swl.thr3_state[4:0]),
     .rst_stallreq    (`TOP_DESIGN.sparc@.ifu.ifu.fcl.rst_stallreq),
     .ifq_fcl_stallreq (`TOP_DESIGN.sparc@.ifu.ifu.fcl.ifq_fcl_stallreq),
     .lsu_ifu_stallreq (`TOP_DESIGN.sparc@.ifu.ifu.fcl.lsu_ifu_stallreq),
     .ffu_ifu_stallreq (`TOP_DESIGN.sparc@.ifu.ifu.fcl.ffu_ifu_stallreq),
     .completion      (`TOP_DESIGN.sparc@.ifu.ifu.swl.completion),
     .mul_wait        (`TOP_DESIGN.sparc@.ifu.ifu.swl.mul_wait),
     .div_wait        (`TOP_DESIGN.sparc@.ifu.ifu.swl.div_wait),
     .fp_wait         (`TOP_DESIGN.sparc@.ifu.ifu.swl.fp_wait),
     .mul_wait_nxt    (`TOP_DESIGN.sparc@.ifu.ifu.swl.mul_wait_nxt),
     .div_wait_nxt    (`TOP_DESIGN.sparc@.ifu.ifu.swl.div_wait_nxt),
     .fp_wait_nxt     (`TOP_DESIGN.sparc@.ifu.ifu.swl.fp_wait_nxt),
     .mul_busy_d      (`TOP_DESIGN.sparc@.ifu.ifu.swl.mul_busy_d),
     .div_busy_d      (`TOP_DESIGN.sparc@.ifu.ifu.swl.div_busy_d),
     .fp_busy_d       (`TOP_DESIGN.sparc@.ifu.ifu.swl.fp_busy_d),
     .ifet_ue_vec_d1  (`TOP_DESIGN.sparc@.ifu.ifu.fcl.ifet_ue_vec_d1),
`else
     .wm_imiss        (`TOP_DESIGN.sparc@.ifu.swl.wm_imiss[3:0]),
     .wm_other        (`TOP_DESIGN.sparc@.ifu.swl.wm_other[3:0]),
     .wm_stbwait      (`TOP_DESIGN.sparc@.ifu.swl.wm_stbwait[3:0]),
     .thr_state0      (`TOP_DESIGN.sparc@.ifu.swl.thr0_state[4:0]),
     .thr_state1      (`TOP_DESIGN.sparc@.ifu.swl.thr1_state[4:0]),
     .thr_state2      (`TOP_DESIGN.sparc@.ifu.swl.thr2_state[4:0]),
     .thr_state3      (`TOP_DESIGN.sparc@.ifu.swl.thr3_state[4:0]),
     .rst_stallreq    (`TOP_DESIGN.sparc@.ifu.fcl.rst_stallreq),
     .ifq_fcl_stallreq (`TOP_DESIGN.sparc@.ifu.fcl.ifq_fcl_stallreq),
     .lsu_ifu_stallreq (`TOP_DESIGN.sparc@.ifu.fcl.lsu_ifu_stallreq),
     .ffu_ifu_stallreq (`TOP_DESIGN.sparc@.ifu.fcl.ffu_ifu_stallreq),
     .completion      (`TOP_DESIGN.sparc@.ifu.swl.completion),
     .mul_wait        (`TOP_DESIGN.sparc@.ifu.swl.mul_wait),
     .div_wait        (`TOP_DESIGN.sparc@.ifu.swl.div_wait),
     .fp_wait         (`TOP_DESIGN.sparc@.ifu.swl.fp_wait),
     .mul_wait_nxt    (`TOP_DESIGN.sparc@.ifu.swl.mul_wait_nxt),
     .div_wait_nxt    (`TOP_DESIGN.sparc@.ifu.swl.div_wait_nxt),
     .fp_wait_nxt     (`TOP_DESIGN.sparc@.ifu.swl.fp_wait_nxt),
     .mul_busy_d      (`TOP_DESIGN.sparc@.ifu.swl.mul_busy_d),
     .div_busy_d      (`TOP_DESIGN.sparc@.ifu.swl.div_busy_d),
     .fp_busy_d       (`TOP_DESIGN.sparc@.ifu.swl.fp_busy_d),
     .ifet_ue_vec_d1  (`TOP_DESIGN.sparc@.ifu.fcl.ifet_ue_vec_d1),
`endif
     .cpu_id(3'h@));
    */
   /* spu_ma_mon AUTO_TEMPLATE(
    .wrmi_mamul_1sthalf   (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    .wrmi_mamul_2ndhalf   (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    .wrmi_maaeqb_1sthalf  (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    .wrmi_maaeqb_2ndhalf  (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    .iptr             (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    .iminus_lenminus1 (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    .mul_data         (`TOP_DESIGN.sparc@.spu.spu_madp.spu_madp_evedata[63:0]));
    */
    /* cmp_pcxandcpx  AUTO_TEMPLATE(
     .spc_pcx_data_pa(`PCXPATH@.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
     .cpx_spc_data_cx(`PCXPATH@.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
     .cpu(@),
     );

    */

   /*
    mask_mon AUTO_TEMPLATE(
`ifndef RTL_SPU
    .wm_imiss (`TOP_DESIGN.sparc@.ifu.ifu.swl.wm_imiss),
    .wm_other (`TOP_DESIGN.sparc@.ifu.ifu.swl.wm_other),
    .wm_stbwait (`TOP_DESIGN.sparc@.ifu.ifu.swl.wm_stbwait),
    .mul_wait (`TOP_DESIGN.sparc@.ifu.ifu.swl.mul_wait),
    .div_wait (`TOP_DESIGN.sparc@.ifu.ifu.swl.div_wait),
    .fp_wait (`TOP_DESIGN.sparc@.ifu.ifu.swl.fp_wait),
    .mul_busy_e (`TOP_DESIGN.sparc@.ifu.ifu.swl.mul_busy_e),
    .div_busy_e (`TOP_DESIGN.sparc@.ifu.ifu.swl.div_busy_e),
    .fp_busy_e (`TOP_DESIGN.sparc@.ifu.ifu.swl.fp_busy_e),
    .ldmiss (`TOP_DESIGN.sparc@.ifu.ifu.swl.ldmiss),
`else
    .wm_imiss (`TOP_DESIGN.sparc@.ifu.swl.wm_imiss),
    .wm_other (`TOP_DESIGN.sparc@.ifu.swl.wm_other),
    .wm_stbwait (`TOP_DESIGN.sparc@.ifu.swl.wm_stbwait),
    .mul_wait (`TOP_DESIGN.sparc@.ifu.swl.mul_wait),
    .div_wait (`TOP_DESIGN.sparc@.ifu.swl.div_wait),
    .fp_wait (`TOP_DESIGN.sparc@.ifu.swl.fp_wait),
    .mul_busy_e (`TOP_DESIGN.sparc@.ifu.swl.mul_busy_e),
    .div_busy_e (`TOP_DESIGN.sparc@.ifu.swl.div_busy_e),
    .fp_busy_e (`TOP_DESIGN.sparc@.ifu.swl.fp_busy_e),
    .ldmiss (`TOP_DESIGN.sparc@.ifu.swl.ldmiss),
`endif
    .coreid (3'h@),
    );
    */

   /*
    nc_inv_chk AUTO_TEMPLATE(
`ifndef RTL_SPU
    .cpxpkt_vld (`TOP_DESIGN.sparc@.ifu.ifu.lsu_ifu_cpxpkt_i1[144]),
    .cpxpkt_rtntype (`TOP_DESIGN.sparc@.ifu.ifu.lsu_ifu_cpxpkt_i1[143:140]),
    .nc (`TOP_DESIGN.sparc@.ifu.ifu.lsu_ifu_cpxpkt_i1[136]),
    .wv (`TOP_DESIGN.sparc@.ifu.ifu.lsu_ifu_cpxpkt_i1[133]),
`else
    .cpxpkt_vld (`TOP_DESIGN.sparc@.ifu.lsu_ifu_cpxpkt_i1[144]),
    .cpxpkt_rtntype (`TOP_DESIGN.sparc@.ifu.lsu_ifu_cpxpkt_i1[143:140]),
    .nc (`TOP_DESIGN.sparc@.ifu.lsu_ifu_cpxpkt_i1[136]),
    .wv (`TOP_DESIGN.sparc@.ifu.lsu_ifu_cpxpkt_i1[133]),
`endif
    .coreid (3'h@),
    );
    */

   /*
    pc_muxsel_mon AUTO_TEMPLATE(
`ifndef RTL_SPU
    .pc_f  (`TOP_DESIGN.sparc@.ifu.ifu.fdp.pc_f[47:0]),
    .thr_f (`TOP_DESIGN.sparc@.ifu.ifu.fcl.thr_f[3:0]),
    .t0pc_f (`TOP_DESIGN.sparc@.ifu.ifu.fdp.t0pc_f[47:0]),
    .t1pc_f (`TOP_DESIGN.sparc@.ifu.ifu.fdp.t1pc_f[47:0]),
    .t2pc_f (`TOP_DESIGN.sparc@.ifu.ifu.fdp.t2pc_f[47:0]),
    .t3pc_f (`TOP_DESIGN.sparc@.ifu.ifu.fdp.t3pc_f[47:0]),
    .inst_vld_f (`TOP_DESIGN.sparc@.ifu.ifu.fcl.inst_vld_f),
    .dtu_fcl_running_s (`TOP_DESIGN.sparc@.ifu.ifu.dtu_fcl_running_s),
`else
    .pc_f  (`TOP_DESIGN.sparc@.ifu.fdp.pc_f[47:0]),
    .thr_f (`TOP_DESIGN.sparc@.ifu.fcl.thr_f[3:0]),
    .t0pc_f (`TOP_DESIGN.sparc@.ifu.fdp.t0pc_f[47:0]),
    .t1pc_f (`TOP_DESIGN.sparc@.ifu.fdp.t1pc_f[47:0]),
    .t2pc_f (`TOP_DESIGN.sparc@.ifu.fdp.t2pc_f[47:0]),
    .t3pc_f (`TOP_DESIGN.sparc@.ifu.fdp.t3pc_f[47:0]),
    .inst_vld_f (`TOP_DESIGN.sparc@.ifu.fcl.inst_vld_f),
    .dtu_fcl_running_s (`TOP_DESIGN.sparc@.ifu.dtu_fcl_running_s),
`endif
    .coreid(3'h@),
    );
    */

   /*
    nukeint_mon AUTO_TEMPLATE(
    `ifndef RTL_SPU
    .nukeint (`TOP_DESIGN.sparc@.ifu.ifu.tlu_ifu_nukeint_i2),
    .resumint (`TOP_DESIGN.sparc@.ifu.ifu.tlu_ifu_resumint_i2),
    .rstint (`TOP_DESIGN.sparc@.ifu.ifu.tlu_ifu_rstint_i2),
    .rstthr (`TOP_DESIGN.sparc@.ifu.ifu.tlu_ifu_rstthr_i2[3:0]),
    .thr_state0 (`TOP_DESIGN.sparc@.ifu.ifu.swl.thr0_state[4:0]),
    .thr_state1 (`TOP_DESIGN.sparc@.ifu.ifu.swl.thr1_state[4:0]),
    .thr_state2 (`TOP_DESIGN.sparc@.ifu.ifu.swl.thr2_state[4:0]),
    .thr_state3 (`TOP_DESIGN.sparc@.ifu.ifu.swl.thr3_state[4:0]),
    `else
    .nukeint (`TOP_DESIGN.sparc@.ifu.tlu_ifu_nukeint_i2),
    .resumint (`TOP_DESIGN.sparc@.ifu.tlu_ifu_resumint_i2),
    .rstint (`TOP_DESIGN.sparc@.ifu.tlu_ifu_rstint_i2),
    .rstthr (`TOP_DESIGN.sparc@.ifu.tlu_ifu_rstthr_i2[3:0]),
    .thr_state0 (`TOP_DESIGN.sparc@.ifu.swl.thr0_state[4:0]),
    .thr_state1 (`TOP_DESIGN.sparc@.ifu.swl.thr1_state[4:0]),
    .thr_state2 (`TOP_DESIGN.sparc@.ifu.swl.thr2_state[4:0]),
    .thr_state3 (`TOP_DESIGN.sparc@.ifu.swl.thr3_state[4:0]),
    `endif
    .coreid(3'h@),
    );
    */

   /*
    stb_ovfl_mon AUTO_TEMPLATE(
`ifndef RTL_SPU
    .lsu_ifu_stbcnt3 (`TOP_DESIGN.sparc@.ifu.ifu.lsu_ifu_stbcnt3),
    .lsu_ifu_stbcnt2 (`TOP_DESIGN.sparc@.ifu.ifu.lsu_ifu_stbcnt2),
    .lsu_ifu_stbcnt1 (`TOP_DESIGN.sparc@.ifu.ifu.lsu_ifu_stbcnt1),
    .lsu_ifu_stbcnt0 (`TOP_DESIGN.sparc@.ifu.ifu.lsu_ifu_stbcnt0),
`else
    .lsu_ifu_stbcnt3 (`TOP_DESIGN.sparc@.ifu.lsu_ifu_stbcnt3),
    .lsu_ifu_stbcnt2 (`TOP_DESIGN.sparc@.ifu.lsu_ifu_stbcnt2),
    .lsu_ifu_stbcnt1 (`TOP_DESIGN.sparc@.ifu.lsu_ifu_stbcnt1),
    .lsu_ifu_stbcnt0 (`TOP_DESIGN.sparc@.ifu.lsu_ifu_stbcnt0),
`endif
    .stb_ctl_reset3 (`TOP_DESIGN.sparc@.lsu.stb_ctl3.reset),
    .stb_ctl_reset2 (`TOP_DESIGN.sparc@.lsu.stb_ctl2.reset),
    .stb_ctl_reset1 (`TOP_DESIGN.sparc@.lsu.stb_ctl1.reset),
    .stb_ctl_reset0 (`TOP_DESIGN.sparc@.lsu.stb_ctl0.reset),
    .coreid(3'h@),
    );
   */

   /*
    icache_mutex_mon AUTO_TEMPLATE(
`ifndef RTL_SPU
    .waysel_buf_s1 (`TOP_DESIGN.sparc@.ifu.ifu.wseldp.waysel_buf_s1),
    .alltag_err_s1 (`TOP_DESIGN.sparc@.ifu.ifu.errctl.alltag_err_s1),
    .tlb_cam_miss_s1 (`TOP_DESIGN.sparc@.ifu.ifu.fcl.tlb_cam_miss_s1),
    .cam_vld_s1 (`TOP_DESIGN.sparc@.ifu.ifu.fcl.cam_vld_s1),
`else
    .waysel_buf_s1 (`TOP_DESIGN.sparc@.ifu.wseldp.waysel_buf_s1),
    .alltag_err_s1 (`TOP_DESIGN.sparc@.ifu.errctl.alltag_err_s1),
    .tlb_cam_miss_s1 (`TOP_DESIGN.sparc@.ifu.fcl.tlb_cam_miss_s1),
    .cam_vld_s1 (`TOP_DESIGN.sparc@.ifu.fcl.cam_vld_s1),
`endif
    .coreid(3'h@),
    );
   */

   /*
   exu_mon AUTO_TEMPLATE(
    .exu_irf_wen    (`EXUPATH@.ecl_irf_wen_w),
    .exu_irf_wen2   (`EXUPATH@.ecl_irf_wen_w2),
    .exu_irf_data   (`EXUPATH@.byp_irf_rd_data_w),
    .exu_irf_data2  (`EXUPATH@.byp_irf_rd_data_w2),
    .exu_rd	    (`EXUPATH@.irf.irf.ecl_irf_rd_w ),
    .restore_request(`EXUPATH@.ecl.writeback.restore_request),
    .divcntl_wb_req_g	    (`EXUPATH@.ecl.writeback.divcntl_wb_req_g),
    );
    */

   /*
    tlu_mon AUTO_TEMPLATE(
`ifndef RTL_SPU
    .clk            (`TOP_DESIGN.sparc@.tlu.tlu.rclk),
    .grst_l         (`TOP_DESIGN.sparc@.tlu.tlu.grst_l),
    .rst_l          (`TOP_DESIGN.sparc@.tlu.tlu.tcl.tlu_rst_l),
`else
    .clk			(`TOP_DESIGN.sparc@.tlu.rclk),
    .grst_l			(`TOP_DESIGN.sparc@.tlu.grst_l),
    .rst_l			(`TOP_DESIGN.sparc@.tlu.tcl.tlu_rst_l),
`endif
	.lsu_ifu_flush_pipe_w		(`TOP_DESIGN.sparc@.lsu_ifu_flush_pipe_w),
`ifndef RTL_SPU
    .tlu_lsu_int_ldxa_vld_w2    (`TOP_DESIGN.sparc@.tlu.tlu_lsu_int_ldxa_vld_w2),
    .tlu_lsu_int_ld_ill_va_w2   (`TOP_DESIGN.sparc@.tlu.tlu_lsu_int_ld_ill_va_w2),
    .tlu_scpd_wr_vld_g          (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
    .cpu_mondo_head_wr_g        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
    .cpu_mondo_tail_wr_g        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
    .dev_mondo_head_wr_g        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.dev_mondo_head_wr_g),
    .dev_mondo_tail_wr_g        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
    .resum_err_head_wr_g        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.resum_err_head_wr_g),
    .resum_err_tail_wr_g        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.resum_err_tail_wr_g),
    .nresum_err_head_wr_g       (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.nresum_err_head_wr_g),
    .nresum_err_tail_wr_g       (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.nresum_err_tail_wr_g),
    .ifu_lsu_ld_inst_e      (`TOP_DESIGN.sparc@.tlu.tlu.ifu_lsu_ld_inst_e),
    .ifu_lsu_st_inst_e      (`TOP_DESIGN.sparc@.tlu.tlu.ifu_lsu_st_inst_e),
    .ifu_lsu_alt_space_e    (`TOP_DESIGN.sparc@.tlu.tlu.ifu_lsu_alt_space_e),
    .tlu_early_flush_pipe_w (`TOP_DESIGN.sparc@.tlu.tlu.tlu_early_flush_pipe_w),
    .tlu_asi_state_e        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_asi_state_e),
    .exu_lsu_ldst_va_e      (`TOP_DESIGN.sparc@.tlu.tlu.exu_lsu_ldst_va_e),
    .por_rstint0_w2 (`TOP_DESIGN.sparc@.tlu.tlu.tcl.por_rstint0_w2),
    .por_rstint1_w2 (`TOP_DESIGN.sparc@.tlu.tlu.tcl.por_rstint1_w2),
    .por_rstint2_w2 (`TOP_DESIGN.sparc@.tlu.tlu.tcl.por_rstint2_w2),
    .por_rstint3_w2 (`TOP_DESIGN.sparc@.tlu.tlu.tcl.por_rstint3_w2),
    .tlu_gl_lvl0    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.gl_lvl0),
    .tlu_gl_lvl1    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.gl_lvl1),
    .tlu_gl_lvl2    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.gl_lvl2),
    .tlu_gl_lvl3    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hyperv.gl_lvl3),
`else
	.tlu_lsu_int_ldxa_vld_w2	(`TOP_DESIGN.sparc@.tlu_lsu_int_ldxa_vld_w2),
	.tlu_lsu_int_ld_ill_va_w2	(`TOP_DESIGN.sparc@.tlu_lsu_int_ld_ill_va_w2),
	.tlu_scpd_wr_vld_g			(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
	.cpu_mondo_head_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
	.cpu_mondo_tail_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
	.dev_mondo_head_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.dev_mondo_head_wr_g),
	.dev_mondo_tail_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
	.resum_err_head_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.resum_err_head_wr_g),
	.resum_err_tail_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.resum_err_tail_wr_g),
	.nresum_err_head_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.nresum_err_head_wr_g),
	.nresum_err_tail_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.nresum_err_tail_wr_g),
	.ifu_lsu_ld_inst_e		(`TOP_DESIGN.sparc@.tlu.ifu_lsu_ld_inst_e),
	.ifu_lsu_st_inst_e		(`TOP_DESIGN.sparc@.tlu.ifu_lsu_st_inst_e),
	.ifu_lsu_alt_space_e	(`TOP_DESIGN.sparc@.tlu.ifu_lsu_alt_space_e),
	.tlu_early_flush_pipe_w	(`TOP_DESIGN.sparc@.tlu.tlu_early_flush_pipe_w),
	.tlu_asi_state_e		(`TOP_DESIGN.sparc@.tlu.tlu_asi_state_e),
	.exu_lsu_ldst_va_e		(`TOP_DESIGN.sparc@.tlu.exu_lsu_ldst_va_e),
	.por_rstint0_w2	(`TOP_DESIGN.sparc@.tlu.tcl.por_rstint0_w2),
	.por_rstint1_w2	(`TOP_DESIGN.sparc@.tlu.tcl.por_rstint1_w2),
	.por_rstint2_w2	(`TOP_DESIGN.sparc@.tlu.tcl.por_rstint2_w2),
	.por_rstint3_w2	(`TOP_DESIGN.sparc@.tlu.tcl.por_rstint3_w2),
	.tlu_gl_lvl0	(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.gl_lvl0),
	.tlu_gl_lvl1	(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.gl_lvl1),
	.tlu_gl_lvl2	(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.gl_lvl2),
	.tlu_gl_lvl3	(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.gl_lvl3),
`endif
	.exu_gl_lvl0	(`TOP_DESIGN.sparc@.exu.rml.agp_thr0_next),
	.exu_gl_lvl1	(`TOP_DESIGN.sparc@.exu.rml.agp_thr1_next),
	.exu_gl_lvl2	(`TOP_DESIGN.sparc@.exu.rml.agp_thr2_next),
	.exu_gl_lvl3	(`TOP_DESIGN.sparc@.exu.rml.agp_thr3_next),
`ifndef RTL_SPU
    .ifu_tlu_thrid_d        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ifu_tlu_thrid_d),
    .ifu_tlu_inst_vld_m     (`TOP_DESIGN.sparc@.tlu.tlu.ifu_tlu_inst_vld_m),
    .ifu_tlu_imiss_e        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ifu_tlu_imiss_e),
    .ifu_tlu_immu_miss_m    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ifu_tlu_immu_miss_m),
    .ifu_tlu_flush_fd_w     (`TOP_DESIGN.sparc@.tlu.tlu.ifu_tlu_flush_fd_w),
    .tlu_thread_inst_vld_g  (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.tlu_thread_inst_vld_g),
    .tlu_thread_wsel_g      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.tlu_thread_wsel_g),
    .ifu_tlu_l2imiss        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ifu_tlu_l2imiss),
    .ifu_tlu_sraddr_d       (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ifu_tlu_sraddr_d),
    .ifu_tlu_rsr_inst_d     (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ifu_tlu_rsr_inst_d),
    .lsu_tlu_wsr_inst_e     (`TOP_DESIGN.sparc@.tlu.tlu.lsu_tlu_wsr_inst_e),
    .tlu_wsr_inst_nq_g      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.tlu_wsr_inst_nq_g),
    .tlu_wsr_data_w     (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.tlu_wsr_data_w),
    .lsu_tlu_dcache_miss_w2 (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2),
    .lsu_tlu_l2_dmiss       (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss),
    .lsu_tlu_stb_full_w2    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2),
    .lsu_tlu_dmmu_miss_g    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g),
    .ffu_tlu_fpu_tid        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid),
    .ffu_tlu_fpu_cmplt      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt),
    .tlu_pstate_priv        (`TOP_DESIGN.sparc@.tlu.tlu.local_pstate_priv),
    .tlu_hpstate_priv       (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hpstate_priv),
    .tlu_hpstate_enb        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hpstate_enb),
    .tlu_pstate_ie      (`TOP_DESIGN.sparc@.tlu.tlu.local_pstate_ie),
    .wsr_thread_inst_g      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.wsr_thread_inst_g),
    .lsu_tlu_defr_trp_taken_g   (`TOP_DESIGN.sparc@.tlu.tlu.lsu_tlu_defr_trp_taken_g),
    .lsu_tlu_async_ttype_vld_w1 (`TOP_DESIGN.sparc@.tlu.tlu.lsu_tlu_async_ttype_vld_g),
    .lsu_tlu_ttype_vld_m2   (`TOP_DESIGN.sparc@.tlu.tlu.lsu_tlu_ttype_vld_m2),
    .tlu_ifu_flush_pipe_w   (`TOP_DESIGN.sparc@.tlu.tlu.tcl.tlu_ifu_flush_pipe_w),
    .tlu_pib_rsr_data_e     (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e),
    .tlu_pib_priv_act_trap_m    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pib_priv_act_trap_m),
    .tlu_pib_picl_wrap      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pib_picl_wrap),
    .tlu_pib_pich_wrap      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pich_onebelow_flg),
    .tlu_ifu_trappc_vld_w1  (`TOP_DESIGN.sparc@.tlu.tlu.tlu_ifu_trappc_vld_w1),
    .tlu_ifu_trappc_w2      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_ifu_trappc_w2),
    .tlu_final_ttype_w2     (`TOP_DESIGN.sparc@.tlu.tlu.tlu_final_ttype_w2),
    .tlu_ifu_trap_tid_w1    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_ifu_trap_tid_w1),
    .tlu_full_flush_pipe_w2 (`TOP_DESIGN.sparc@.tlu.tlu.tlu_full_flush_pipe_w2),
    .rtl_pcr0           (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pcr0),
    .rtl_pcr1           (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pcr1),
    .rtl_pcr2           (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pcr2),
    .rtl_pcr3           (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pcr3),
    .rtl_lsu_tlu_stb_full_w2    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2),
    .rtl_fpu_cmplt_thread   (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.fpu_cmplt_thread),
    .rtl_imiss_thread_g     (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.imiss_thread_g),
    .rtl_lsu_tlu_dcache_miss_w2 (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2),
    .lsu_tlu_l2_dmiss       (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss),
    .lsu_tlu_stb_full_w2    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2),
    .lsu_tlu_dmmu_miss_g    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g),
    .ffu_tlu_fpu_tid        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid),
    .ffu_tlu_fpu_cmplt      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt),
    .tlu_pstate_priv        (`TOP_DESIGN.sparc@.tlu.tlu.local_pstate_priv),
    .tlu_hpstate_priv       (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hpstate_priv),
    .tlu_hpstate_enb        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_hpstate_enb),
    .tlu_pstate_ie      (`TOP_DESIGN.sparc@.tlu.tlu.local_pstate_ie),
    .wsr_thread_inst_g      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.wsr_thread_inst_g),
    .lsu_tlu_defr_trp_taken_g   (`TOP_DESIGN.sparc@.tlu.tlu.lsu_tlu_defr_trp_taken_g),
    .lsu_tlu_async_ttype_vld_w1 (`TOP_DESIGN.sparc@.tlu.tlu.lsu_tlu_async_ttype_vld_g),
    .lsu_tlu_ttype_vld_m2   (`TOP_DESIGN.sparc@.tlu.tlu.lsu_tlu_ttype_vld_m2),
    .tlu_ifu_flush_pipe_w   (`TOP_DESIGN.sparc@.tlu.tlu.tcl.tlu_ifu_flush_pipe_w),
    .tlu_pib_rsr_data_e     (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e),
    .tlu_pib_priv_act_trap_m    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pib_priv_act_trap_m),
    .tlu_pib_picl_wrap      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pib_picl_wrap),
    .tlu_pib_pich_wrap      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pich_onebelow_flg),
    .tlu_ifu_trappc_vld_w1  (`TOP_DESIGN.sparc@.tlu.tlu.tlu_ifu_trappc_vld_w1),
    .tlu_ifu_trappc_w2      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_ifu_trappc_w2),
    .tlu_final_ttype_w2     (`TOP_DESIGN.sparc@.tlu.tlu.tlu_final_ttype_w2),
    .tlu_ifu_trap_tid_w1    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_ifu_trap_tid_w1),
    .tlu_full_flush_pipe_w2 (`TOP_DESIGN.sparc@.tlu.tlu.tlu_full_flush_pipe_w2),
    .rtl_pcr0           (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pcr0),
    .rtl_pcr1           (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pcr1),
    .rtl_pcr2           (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pcr2),
    .rtl_pcr3           (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pcr3),
    .rtl_lsu_tlu_stb_full_w2    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2),
    .rtl_fpu_cmplt_thread   (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.fpu_cmplt_thread),
    .rtl_imiss_thread_g     (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.imiss_thread_g),
    .rtl_lsu_tlu_dcache_miss_w2 (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2),
    .rtl_immu_miss_thread_g (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.immu_miss_thread_g),
    .rtl_dmmu_miss_thread_g (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.dmmu_miss_thread_g),
    .rtl_ifu_tlu_l2imiss    (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.ifu_tlu_l2imiss),
    .rtl_lsu_tlu_l2_dmiss   (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss),
    .true_pil0          (`TOP_DESIGN.sparc@.tlu.tlu.tcl.true_pil0),
    .true_pil1          (`TOP_DESIGN.sparc@.tlu.tlu.tcl.true_pil1),
    .true_pil2          (`TOP_DESIGN.sparc@.tlu.tlu.tcl.true_pil2),
    .true_pil3          (`TOP_DESIGN.sparc@.tlu.tlu.tcl.true_pil3),
    .rtl_trp_lvl0       (`TOP_DESIGN.sparc@.tlu.tlu.tcl.trp_lvl0),
    .rtl_trp_lvl1       (`TOP_DESIGN.sparc@.tlu.tlu.tcl.trp_lvl1),
    .rtl_trp_lvl2       (`TOP_DESIGN.sparc@.tlu.tlu.tcl.trp_lvl2),
    .rtl_trp_lvl3       (`TOP_DESIGN.sparc@.tlu.tlu.tcl.trp_lvl3),
    .tcc_inst_w2        (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.tcc_inst_w2),
    .rtl_pich_cnt0      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pich_cnt0),
    .rtl_pich_cnt1      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pich_cnt1),
    .rtl_pich_cnt2      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pich_cnt2),
    .rtl_pich_cnt3      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.pich_cnt3),
    .rtl_picl_cnt0      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.picl_cnt0),
    .rtl_picl_cnt1      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.picl_cnt1),
    .rtl_picl_cnt2      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.picl_cnt2),
    .rtl_picl_cnt3      (`TOP_DESIGN.sparc@.tlu.tlu.tlu_pib.picl_cnt3),
    .tlz_thread         (`TOP_DESIGN.sparc@.tlu.tlu.tcl.tlz_thread),
    .th0_sftint_15      (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint0[15]),
    .th1_sftint_15      (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint1[15]),
    .th2_sftint_15      (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint2[15]),
    .th3_sftint_15      (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint3[15]),
    .ifu_swint_g        (`TOP_DESIGN.sparc@.tlu.tlu.tcl.swint_g),
`else
    .ifu_tlu_thrid_d		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_thrid_d),
    .ifu_tlu_inst_vld_m		(`TOP_DESIGN.sparc@.tlu.ifu_tlu_inst_vld_m),
    .ifu_tlu_imiss_e		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_imiss_e),
    .ifu_tlu_immu_miss_m	(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_immu_miss_m),
    .ifu_tlu_flush_fd_w		(`TOP_DESIGN.sparc@.tlu.ifu_tlu_flush_fd_w),
    .tlu_thread_inst_vld_g	(`TOP_DESIGN.sparc@.tlu.tlu_pib.tlu_thread_inst_vld_g),
    .tlu_thread_wsel_g		(`TOP_DESIGN.sparc@.tlu.tlu_pib.tlu_thread_wsel_g),
    .ifu_tlu_l2imiss		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_l2imiss),
    .ifu_tlu_sraddr_d		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_sraddr_d),
    .ifu_tlu_rsr_inst_d		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_rsr_inst_d),
    .lsu_tlu_wsr_inst_e		(`TOP_DESIGN.sparc@.tlu.lsu_tlu_wsr_inst_e),
    .tlu_wsr_inst_nq_g		(`TOP_DESIGN.sparc@.tlu.tlu_pib.tlu_wsr_inst_nq_g),
    .tlu_wsr_data_w		(`TOP_DESIGN.sparc@.tlu.tlu_pib.tlu_wsr_data_w),
    .lsu_tlu_dcache_miss_w2	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_dcache_miss_w2),
    .lsu_tlu_l2_dmiss		(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_l2_dmiss),
    .lsu_tlu_stb_full_w2	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_stb_full_w2),
    .lsu_tlu_dmmu_miss_g	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_dmmu_miss_g),
    .ffu_tlu_fpu_tid		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ffu_tlu_fpu_tid),
    .ffu_tlu_fpu_cmplt		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ffu_tlu_fpu_cmplt),
    .tlu_pstate_priv		(`TOP_DESIGN.sparc@.tlu.local_pstate_priv),
    .tlu_hpstate_priv		(`TOP_DESIGN.sparc@.tlu.tlu_hpstate_priv),
    .tlu_hpstate_enb		(`TOP_DESIGN.sparc@.tlu.tlu_hpstate_enb),
    .tlu_pstate_ie		(`TOP_DESIGN.sparc@.tlu.local_pstate_ie),
    .wsr_thread_inst_g		(`TOP_DESIGN.sparc@.tlu.tlu_pib.wsr_thread_inst_g),
    .lsu_tlu_defr_trp_taken_g	(`TOP_DESIGN.sparc@.tlu.lsu_tlu_defr_trp_taken_g),
    .lsu_tlu_async_ttype_vld_w1	(`TOP_DESIGN.sparc@.tlu.lsu_tlu_async_ttype_vld_g),
    .lsu_tlu_ttype_vld_m2	(`TOP_DESIGN.sparc@.tlu.lsu_tlu_ttype_vld_m2),
    .tlu_ifu_flush_pipe_w	(`TOP_DESIGN.sparc@.tlu.tcl.tlu_ifu_flush_pipe_w),
    .tlu_pib_rsr_data_e		(`TOP_DESIGN.sparc@.tlu.tlu_pib.tlu_pib_rsr_data_e),
    .tlu_pib_priv_act_trap_m	(`TOP_DESIGN.sparc@.tlu.tlu_pib.pib_priv_act_trap_m),
    .tlu_pib_picl_wrap		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pib_picl_wrap),
    .tlu_pib_pich_wrap		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pich_onebelow_flg),
    .tlu_ifu_trappc_vld_w1	(`TOP_DESIGN.sparc@.tlu.tlu_ifu_trappc_vld_w1),
    .tlu_ifu_trappc_w2		(`TOP_DESIGN.sparc@.tlu.tlu_ifu_trappc_w2),
    .tlu_final_ttype_w2		(`TOP_DESIGN.sparc@.tlu.tlu_final_ttype_w2),
    .tlu_ifu_trap_tid_w1	(`TOP_DESIGN.sparc@.tlu.tlu_ifu_trap_tid_w1),
    .tlu_full_flush_pipe_w2	(`TOP_DESIGN.sparc@.tlu.tlu_full_flush_pipe_w2),
    .rtl_pcr0			(`TOP_DESIGN.sparc@.tlu.tlu_pib.pcr0),
    .rtl_pcr1			(`TOP_DESIGN.sparc@.tlu.tlu_pib.pcr1),
    .rtl_pcr2			(`TOP_DESIGN.sparc@.tlu.tlu_pib.pcr2),
    .rtl_pcr3			(`TOP_DESIGN.sparc@.tlu.tlu_pib.pcr3),
    .rtl_lsu_tlu_stb_full_w2	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_stb_full_w2),
    .rtl_fpu_cmplt_thread	(`TOP_DESIGN.sparc@.tlu.tlu_pib.fpu_cmplt_thread),
    .rtl_imiss_thread_g		(`TOP_DESIGN.sparc@.tlu.tlu_pib.imiss_thread_g),
    .rtl_lsu_tlu_dcache_miss_w2	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_dcache_miss_w2),
    .rtl_immu_miss_thread_g	(`TOP_DESIGN.sparc@.tlu.tlu_pib.immu_miss_thread_g),
    .rtl_dmmu_miss_thread_g	(`TOP_DESIGN.sparc@.tlu.tlu_pib.dmmu_miss_thread_g),
    .rtl_ifu_tlu_l2imiss	(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_l2imiss),
    .rtl_lsu_tlu_l2_dmiss	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_l2_dmiss),
    .true_pil0			(`TOP_DESIGN.sparc@.tlu.tcl.true_pil0),
    .true_pil1			(`TOP_DESIGN.sparc@.tlu.tcl.true_pil1),
    .true_pil2			(`TOP_DESIGN.sparc@.tlu.tcl.true_pil2),
    .true_pil3			(`TOP_DESIGN.sparc@.tlu.tcl.true_pil3),
    .rtl_trp_lvl0		(`TOP_DESIGN.sparc@.tlu.tcl.trp_lvl0),
    .rtl_trp_lvl1		(`TOP_DESIGN.sparc@.tlu.tcl.trp_lvl1),
    .rtl_trp_lvl2		(`TOP_DESIGN.sparc@.tlu.tcl.trp_lvl2),
    .rtl_trp_lvl3		(`TOP_DESIGN.sparc@.tlu.tcl.trp_lvl3),
    .tcc_inst_w2		(`TOP_DESIGN.sparc@.tlu.tlu_pib.tcc_inst_w2),
    .rtl_pich_cnt0		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pich_cnt0),
    .rtl_pich_cnt1		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pich_cnt1),
    .rtl_pich_cnt2		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pich_cnt2),
    .rtl_pich_cnt3		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pich_cnt3),
    .rtl_picl_cnt0		(`TOP_DESIGN.sparc@.tlu.tlu_pib.picl_cnt0),
    .rtl_picl_cnt1		(`TOP_DESIGN.sparc@.tlu.tlu_pib.picl_cnt1),
    .rtl_picl_cnt2		(`TOP_DESIGN.sparc@.tlu.tlu_pib.picl_cnt2),
    .rtl_picl_cnt3		(`TOP_DESIGN.sparc@.tlu.tlu_pib.picl_cnt3),
    .tlz_thread			(`TOP_DESIGN.sparc@.tlu.tcl.tlz_thread),
    .th0_sftint_15		(`TOP_DESIGN.sparc@.tlu.tdp.sftint0[15]),
    .th1_sftint_15		(`TOP_DESIGN.sparc@.tlu.tdp.sftint1[15]),
    .th2_sftint_15		(`TOP_DESIGN.sparc@.tlu.tdp.sftint2[15]),
    .th3_sftint_15		(`TOP_DESIGN.sparc@.tlu.tdp.sftint3[15]),
    .ifu_swint_g		(`TOP_DESIGN.sparc@.tlu.tcl.swint_g),
`endif
    .core_id			(3'h@),
`ifndef RTL_SPU
    .tlu_itlb_wr_vld_g          (`TOP_DESIGN.sparc@.tlu.tlu_itlb_wr_vld_g),
    .tlu_itlb_dmp_vld_g         (`TOP_DESIGN.sparc@.tlu.tlu_itlb_dmp_vld_g),
    .tlu_itlb_tte_tag_w2        (`TOP_DESIGN.sparc@.tlu.tlu_itlb_tte_tag_w2),
    .tlu_itlb_tte_data_w2       (`TOP_DESIGN.sparc@.tlu.tlu_itlb_tte_data_w2),
    .itlb_wr_vld                (`TOP_DESIGN.sparc@.ifu.ifu.itlb.tlb_wr_vld),
`else
    .tlu_itlb_wr_vld_g          (`TOP_DESIGN.sparc@.tlu_itlb_wr_vld_g),
    .tlu_itlb_dmp_vld_g         (`TOP_DESIGN.sparc@.tlu_itlb_dmp_vld_g),
    .tlu_itlb_tte_tag_w2        (`TOP_DESIGN.sparc@.tlu_itlb_tte_tag_w2),
    .tlu_itlb_tte_data_w2       (`TOP_DESIGN.sparc@.tlu_itlb_tte_data_w2),
    .itlb_wr_vld                (`TOP_DESIGN.sparc@.ifu.itlb.tlb_wr_vld),
`endif
    .dtlb_wr_vld                (`TOP_DESIGN.sparc@.lsu.dtlb.tlb_wr_vld),
`ifndef RTL_SPU
    .tlu_tlb_access_en_l_d1     (`TOP_DESIGN.sparc@.tlu.tlu.mmu_dp.tlu_tlb_access_en_l_d1),
    .tlu_lng_ltncy_en_l         (`TOP_DESIGN.sparc@.tlu.tlu.mmu_dp.tlu_lng_ltncy_en_l),
`else
    .tlu_tlb_access_en_l_d1     (`TOP_DESIGN.sparc@.tlu.mmu_dp.tlu_tlb_access_en_l_d1),
    .tlu_lng_ltncy_en_l         (`TOP_DESIGN.sparc@.tlu.mmu_dp.tlu_lng_ltncy_en_l),
`endif
    );
   */

   /*
    softint_mon AUTO_TEMPLATE(
`ifndef RTL_SPU
    .rtl_softint0       (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint0),
    .rtl_softint1       (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint1),
    .rtl_softint2       (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint2),
    .rtl_softint3       (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint3),
    .rtl_wsr_data_w     (`TOP_DESIGN.sparc@.tlu.tlu.tdp.wsr_data_w),
    .rtl_sftint_en_l_g  (`TOP_DESIGN.sparc@.tlu.tlu.tdp.tlu_sftint_en_l_g),
    .rtl_sftint_b0_en   (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint_b0_en),
    .rtl_tickcmp_int    (`TOP_DESIGN.sparc@.tlu.tlu.tdp.tickcmp_int),
    .rtl_sftint_b16_en  (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint_b16_en),
    .rtl_stickcmp_int   (`TOP_DESIGN.sparc@.tlu.tlu.tdp.stickcmp_int),
    .rtl_sftint_b15_en  (`TOP_DESIGN.sparc@.tlu.tlu.tdp.sftint_b15_en),
    .rtl_pib_picl_wrap  (`TOP_DESIGN.sparc@.tlu.tlu.tdp.pib_picl_wrap),
    .rtl_pib_pich_wrap  (`TOP_DESIGN.sparc@.tlu.tlu.tdp.pib_pich_wrap),
    .rtl_wr_sftint_l_g  (`TOP_DESIGN.sparc@.tlu.tlu.tdp.tlu_wr_sftint_l_g),
    .rtl_set_sftint_l_g (`TOP_DESIGN.sparc@.tlu.tlu.tdp.tlu_set_sftint_l_g),
    .rtl_clr_sftint_l_g (`TOP_DESIGN.sparc@.tlu.tlu.tdp.tlu_clr_sftint_l_g),
    .rtl_clk        (`TOP_DESIGN.sparc@.tlu.tlu.tdp.rclk),
    .rtl_reset      (`TOP_DESIGN.sparc@.tlu.tlu.tdp.tlu_rst),
`else
    .rtl_softint0       (`TOP_DESIGN.sparc@.tlu.tdp.sftint0),
    .rtl_softint1       (`TOP_DESIGN.sparc@.tlu.tdp.sftint1),
    .rtl_softint2       (`TOP_DESIGN.sparc@.tlu.tdp.sftint2),
    .rtl_softint3       (`TOP_DESIGN.sparc@.tlu.tdp.sftint3),
    .rtl_wsr_data_w     (`TOP_DESIGN.sparc@.tlu.tdp.wsr_data_w),
    .rtl_sftint_en_l_g  (`TOP_DESIGN.sparc@.tlu.tdp.tlu_sftint_en_l_g),
    .rtl_sftint_b0_en   (`TOP_DESIGN.sparc@.tlu.tdp.sftint_b0_en),
    .rtl_tickcmp_int    (`TOP_DESIGN.sparc@.tlu.tdp.tickcmp_int),
    .rtl_sftint_b16_en  (`TOP_DESIGN.sparc@.tlu.tdp.sftint_b16_en),
    .rtl_stickcmp_int   (`TOP_DESIGN.sparc@.tlu.tdp.stickcmp_int),
    .rtl_sftint_b15_en  (`TOP_DESIGN.sparc@.tlu.tdp.sftint_b15_en),
    .rtl_pib_picl_wrap  (`TOP_DESIGN.sparc@.tlu.tdp.pib_picl_wrap),
    .rtl_pib_pich_wrap  (`TOP_DESIGN.sparc@.tlu.tdp.pib_pich_wrap),
    .rtl_wr_sftint_l_g  (`TOP_DESIGN.sparc@.tlu.tdp.tlu_wr_sftint_l_g),
    .rtl_set_sftint_l_g (`TOP_DESIGN.sparc@.tlu.tdp.tlu_set_sftint_l_g),
    .rtl_clr_sftint_l_g (`TOP_DESIGN.sparc@.tlu.tdp.tlu_clr_sftint_l_g),
    .rtl_clk		(`TOP_DESIGN.sparc@.tlu.tdp.rclk),
    .rtl_reset		(`TOP_DESIGN.sparc@.tlu.tdp.tlu_rst),
`endif
    .core_id		(3'h@),
    );
   */

`ifdef GATE_SIM
`else


   `ifdef RTL_SPARC0
   l_cache_mon l_cache_mon0(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(0),			 // Templated
			    .index_f	(`ICTPATH0.index_y[`IC_SET_IDX_HI:0]), // Templated
			    .wrreq_f	(`ICTPATH0.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH0.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH0.ifq_ict_wrtag_f[`IC_TAG_SZ:0]), // Templated
			    .wr_data	(`ICVPATH0.write_bit_y),	 // Templated
                // .wr_data    (`ICVPATH0.din_d1),  // Templated
			    .wren_f	(`ICVPATH0.write_mask_y[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH0.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH0.wr_adr[`IC_SET_IDX_HI:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH0.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH0.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`SPARC_CORE0.sparc0.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`SPARC_CORE0.sparc0.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon0(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .wm_imiss (`SPARC_CORE0.sparc0.ifu.ifu.swl.wm_imiss[3:0]), // Templated
              .wm_other (`SPARC_CORE0.sparc0.ifu.ifu.swl.wm_other[3:0]), // Templated
              .wm_stbwait   (`SPARC_CORE0.sparc0.ifu.ifu.swl.wm_stbwait[3:0]), // Templated
              .thr_state0   (`SPARC_CORE0.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
              .thr_state1   (`SPARC_CORE0.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
              .thr_state2   (`SPARC_CORE0.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
              .thr_state3   (`SPARC_CORE0.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
              .rst_stallreq (`SPARC_CORE0.sparc0.ifu.ifu.fcl.rst_stallreq), // Templated
              .ifq_fcl_stallreq(`SPARC_CORE0.sparc0.ifu.ifu.fcl.ifq_fcl_stallreq), // Templated
              .lsu_ifu_stallreq(`SPARC_CORE0.sparc0.ifu.ifu.fcl.lsu_ifu_stallreq), // Templated
              .ffu_ifu_stallreq(`SPARC_CORE0.sparc0.ifu.ifu.fcl.ffu_ifu_stallreq), // Templated
              .completion   (`SPARC_CORE0.sparc0.ifu.ifu.swl.completion), // Templated
              .mul_wait (`SPARC_CORE0.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait (`SPARC_CORE0.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait  (`SPARC_CORE0.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_wait_nxt (`SPARC_CORE0.sparc0.ifu.ifu.swl.mul_wait_nxt), // Templated
              .div_wait_nxt (`SPARC_CORE0.sparc0.ifu.ifu.swl.div_wait_nxt), // Templated
              .fp_wait_nxt  (`SPARC_CORE0.sparc0.ifu.ifu.swl.fp_wait_nxt), // Templated
              .mul_busy_d   (`SPARC_CORE0.sparc0.ifu.ifu.swl.mul_busy_d), // Templated
              .div_busy_d   (`SPARC_CORE0.sparc0.ifu.ifu.swl.div_busy_d), // Templated
              .fp_busy_d    (`SPARC_CORE0.sparc0.ifu.ifu.swl.fp_busy_d), // Templated
              .ifet_ue_vec_d1(`SPARC_CORE0.sparc0.ifu.ifu.fcl.ifet_ue_vec_d1), // Templated
`else
			  .wm_imiss	(`SPARC_CORE0.sparc0.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`SPARC_CORE0.sparc0.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`SPARC_CORE0.sparc0.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`SPARC_CORE0.sparc0.ifu.swl.thr0_state[4:0]), // Templated
			  .thr_state1	(`SPARC_CORE0.sparc0.ifu.swl.thr1_state[4:0]), // Templated
			  .thr_state2	(`SPARC_CORE0.sparc0.ifu.swl.thr2_state[4:0]), // Templated
			  .thr_state3	(`SPARC_CORE0.sparc0.ifu.swl.thr3_state[4:0]), // Templated
			  .rst_stallreq	(`SPARC_CORE0.sparc0.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`SPARC_CORE0.sparc0.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`SPARC_CORE0.sparc0.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`SPARC_CORE0.sparc0.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`SPARC_CORE0.sparc0.ifu.swl.completion), // Templated
			  .mul_wait	(`SPARC_CORE0.sparc0.ifu.swl.mul_wait), // Templated
			  .div_wait	(`SPARC_CORE0.sparc0.ifu.swl.div_wait), // Templated
			  .fp_wait	(`SPARC_CORE0.sparc0.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`SPARC_CORE0.sparc0.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`SPARC_CORE0.sparc0.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`SPARC_CORE0.sparc0.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`SPARC_CORE0.sparc0.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`SPARC_CORE0.sparc0.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`SPARC_CORE0.sparc0.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`SPARC_CORE0.sparc0.ifu.fcl.ifet_ue_vec_d1), // Templated
`endif
			  .cpu_id	(10'd0));			 // Templated
   exu_mon exu_mon0(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH0.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH0.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH0.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH0.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH0.irf.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH0.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH0.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon0(/*AUTOINST*/
		    // Inputs
    `ifndef RTL_SPU
            .clk        (`SPARC_CORE0.sparc0.tlu.tlu.rclk), // Templated
            .grst_l     (`SPARC_CORE0.sparc0.tlu.tlu.grst_l), // Templated
            .rst_l      (`SPARC_CORE0.sparc0.tlu.tlu.tcl.tlu_rst_l), // Templated
    `else
		    .clk		(`SPARC_CORE0.sparc0.tlu.rclk), // Templated
		    .grst_l		(`SPARC_CORE0.sparc0.tlu.grst_l), // Templated
		    .rst_l		(`SPARC_CORE0.sparc0.tlu.tcl.tlu_rst_l), // Templated
    `endif
			.lsu_ifu_flush_pipe_w	(`SPARC_CORE0.sparc0.lsu_ifu_flush_pipe_w),
    `ifndef RTL_SPU
            .tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE0.sparc0.tlu.tlu_lsu_int_ldxa_vld_w2),
            .tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE0.sparc0.tlu.tlu_lsu_int_ld_ill_va_w2),
            .tlu_scpd_wr_vld_g      (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
            .cpu_mondo_head_wr_g    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
            .cpu_mondo_tail_wr_g    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
            .dev_mondo_head_wr_g    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_head_wr_g),
            .dev_mondo_tail_wr_g    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
            .resum_err_head_wr_g    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.resum_err_head_wr_g),
            .resum_err_tail_wr_g    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.resum_err_tail_wr_g),
            .nresum_err_head_wr_g   (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.nresum_err_head_wr_g),
            .nresum_err_tail_wr_g   (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.nresum_err_tail_wr_g),
            .ifu_lsu_ld_inst_e      (`SPARC_CORE0.sparc0.tlu.tlu.ifu_lsu_ld_inst_e),
            .ifu_lsu_st_inst_e      (`SPARC_CORE0.sparc0.tlu.tlu.ifu_lsu_st_inst_e),
            .ifu_lsu_alt_space_e    (`SPARC_CORE0.sparc0.tlu.tlu.ifu_lsu_alt_space_e),
            .tlu_early_flush_pipe_w (`SPARC_CORE0.sparc0.tlu.tlu.tlu_early_flush_pipe_w),
            .tlu_asi_state_e        (`SPARC_CORE0.sparc0.tlu.tlu.tlu_asi_state_e),
            .exu_lsu_ldst_va_e      (`SPARC_CORE0.sparc0.tlu.tlu.exu_lsu_ldst_va_e),
            .por_rstint0_w2 (`SPARC_CORE0.sparc0.tlu.tlu.tcl.por_rstint0_w2),
            .por_rstint1_w2 (`SPARC_CORE0.sparc0.tlu.tlu.tcl.por_rstint1_w2),
            .por_rstint2_w2 (`SPARC_CORE0.sparc0.tlu.tlu.tcl.por_rstint2_w2),
            .por_rstint3_w2 (`SPARC_CORE0.sparc0.tlu.tlu.tcl.por_rstint3_w2),
            .tlu_gl_lvl0    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.gl_lvl0),
            .tlu_gl_lvl1    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.gl_lvl1),
            .tlu_gl_lvl2    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.gl_lvl2),
            .tlu_gl_lvl3    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hyperv.gl_lvl3),
    `else
			.tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE0.sparc0.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE0.sparc0.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`SPARC_CORE0.sparc0.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`SPARC_CORE0.sparc0.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`SPARC_CORE0.sparc0.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`SPARC_CORE0.sparc0.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`SPARC_CORE0.sparc0.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`SPARC_CORE0.sparc0.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`SPARC_CORE0.sparc0.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`SPARC_CORE0.sparc0.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`SPARC_CORE0.sparc0.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`SPARC_CORE0.sparc0.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`SPARC_CORE0.sparc0.tlu.tlu_hyperv.gl_lvl3),
    `endif
            .exu_gl_lvl0	(`SPARC_CORE0.sparc0.exu.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`SPARC_CORE0.sparc0.exu.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`SPARC_CORE0.sparc0.exu.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`SPARC_CORE0.sparc0.exu.exu.rml.agp_thr3_next),
    `ifndef RTL_SPU
            .ifu_tlu_thrid_d    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
            .ifu_tlu_inst_vld_m (`SPARC_CORE0.sparc0.tlu.tlu.ifu_tlu_inst_vld_m), // Templated
            .ifu_tlu_imiss_e    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
            .ifu_tlu_immu_miss_m(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
            .tlu_thread_inst_vld_g(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
            .tlu_thread_wsel_g  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
            .ifu_tlu_l2imiss    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .ifu_tlu_flush_fd_w (`SPARC_CORE0.sparc0.tlu.tlu.ifu_tlu_flush_fd_w), // Templated
            .ifu_tlu_sraddr_d   (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
            .ifu_tlu_rsr_inst_d (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
            .lsu_tlu_wsr_inst_e (`SPARC_CORE0.sparc0.tlu.tlu.lsu_tlu_wsr_inst_e), // Templated
            .tlu_wsr_inst_nq_g  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
            .tlu_wsr_data_w (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.tlu_wsr_data_w), // Templated
            .lsu_tlu_dcache_miss_w2(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .lsu_tlu_l2_dmiss   (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .lsu_tlu_stb_full_w2(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .lsu_tlu_dmmu_miss_g(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
            .ffu_tlu_fpu_tid    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
            .ffu_tlu_fpu_cmplt  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
            .tlu_pstate_priv    (`SPARC_CORE0.sparc0.tlu.tlu.local_pstate_priv), // Templated
            .tlu_hpstate_priv   (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hpstate_priv), // Templated
            .tlu_hpstate_enb    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_hpstate_enb), // Templated
            .tlu_pstate_ie  (`SPARC_CORE0.sparc0.tlu.tlu.local_pstate_ie), // Templated
            .wsr_thread_inst_g  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.wsr_thread_inst_g), // Templated
            .lsu_tlu_defr_trp_taken_g(`SPARC_CORE0.sparc0.tlu.tlu.lsu_tlu_defr_trp_taken_g), // Templated
            .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE0.sparc0.tlu.tlu.lsu_tlu_async_ttype_vld_g), // Templated
            .lsu_tlu_ttype_vld_m2(`SPARC_CORE0.sparc0.tlu.tlu.lsu_tlu_ttype_vld_m2), // Templated
            .tlu_ifu_flush_pipe_w(`SPARC_CORE0.sparc0.tlu.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
            .tcc_inst_w2    (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.tcc_inst_w2), // Templated
            .tlu_pib_rsr_data_e (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
            .tlu_pib_priv_act_trap_m(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
            .tlu_pib_picl_wrap  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pib_picl_wrap), // Templated
            .tlu_pib_pich_wrap  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pich_onebelow_flg), // Templated
            .tlu_ifu_trappc_vld_w1(`SPARC_CORE0.sparc0.tlu.tlu.tlu_ifu_trappc_vld_w1), // Templated
            .tlu_ifu_trappc_w2  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_ifu_trappc_w2), // Templated
            .tlu_final_ttype_w2 (`SPARC_CORE0.sparc0.tlu.tlu.tlu_final_ttype_w2), // Templated
            .tlu_ifu_trap_tid_w1(`SPARC_CORE0.sparc0.tlu.tlu.tlu_ifu_trap_tid_w1), // Templated
            .tlu_full_flush_pipe_w2(`SPARC_CORE0.sparc0.tlu.tlu.tlu_full_flush_pipe_w2), // Templated
            .rtl_pcr0       (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pcr0), // Templated
            .rtl_pcr1       (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pcr1), // Templated
            .rtl_pcr2       (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pcr2), // Templated
            .rtl_pcr3       (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pcr3), // Templated
            .rtl_pich_cnt0  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pich_cnt0), // Templated
            .rtl_pich_cnt1  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pich_cnt1), // Templated
            .rtl_pich_cnt2  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pich_cnt2), // Templated
            .rtl_pich_cnt3  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.pich_cnt3), // Templated
            .rtl_picl_cnt0  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.picl_cnt0), // Templated
            .rtl_picl_cnt1  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.picl_cnt1), // Templated
            .rtl_picl_cnt2  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.picl_cnt2), // Templated
            .rtl_picl_cnt3  (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.picl_cnt3), // Templated
            .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .rtl_fpu_cmplt_thread(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.fpu_cmplt_thread), // Templated
            .rtl_imiss_thread_g (`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.imiss_thread_g), // Templated
            .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .rtl_immu_miss_thread_g(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.immu_miss_thread_g), // Templated
            .rtl_dmmu_miss_thread_g(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
            .rtl_ifu_tlu_l2imiss(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE0.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .true_pil0      (`SPARC_CORE0.sparc0.tlu.tlu.tcl.true_pil0), // Templated
            .true_pil1      (`SPARC_CORE0.sparc0.tlu.tlu.tcl.true_pil1), // Templated
            .true_pil2      (`SPARC_CORE0.sparc0.tlu.tlu.tcl.true_pil2), // Templated
            .true_pil3      (`SPARC_CORE0.sparc0.tlu.tlu.tcl.true_pil3), // Templated
            .rtl_trp_lvl0   (`SPARC_CORE0.sparc0.tlu.tlu.tcl.trp_lvl0), // Templated
            .rtl_trp_lvl1   (`SPARC_CORE0.sparc0.tlu.tlu.tcl.trp_lvl1), // Templated
            .rtl_trp_lvl2   (`SPARC_CORE0.sparc0.tlu.tlu.tcl.trp_lvl2), // Templated
            .rtl_trp_lvl3   (`SPARC_CORE0.sparc0.tlu.tlu.tcl.trp_lvl3), // Templated
            .tlz_thread     (`SPARC_CORE0.sparc0.tlu.tlu.tcl.tlz_thread), // Templated
            .th0_sftint_15  (`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint0[15]), // Templated
            .th1_sftint_15  (`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint1[15]), // Templated
            .th2_sftint_15  (`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint2[15]), // Templated
            .th3_sftint_15  (`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint3[15]), // Templated
            .ifu_swint_g    (`SPARC_CORE0.sparc0.tlu.tlu.tcl.swint_g), // Templated
    `else
		    .ifu_tlu_thrid_d	(`SPARC_CORE0.sparc0.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`SPARC_CORE0.sparc0.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`SPARC_CORE0.sparc0.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`SPARC_CORE0.sparc0.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`SPARC_CORE0.sparc0.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`SPARC_CORE0.sparc0.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`SPARC_CORE0.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`SPARC_CORE0.sparc0.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`SPARC_CORE0.sparc0.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`SPARC_CORE0.sparc0.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`SPARC_CORE0.sparc0.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`SPARC_CORE0.sparc0.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`SPARC_CORE0.sparc0.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`SPARC_CORE0.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`SPARC_CORE0.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`SPARC_CORE0.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`SPARC_CORE0.sparc0.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`SPARC_CORE0.sparc0.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`SPARC_CORE0.sparc0.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`SPARC_CORE0.sparc0.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`SPARC_CORE0.sparc0.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`SPARC_CORE0.sparc0.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`SPARC_CORE0.sparc0.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`SPARC_CORE0.sparc0.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`SPARC_CORE0.sparc0.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE0.sparc0.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`SPARC_CORE0.sparc0.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`SPARC_CORE0.sparc0.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`SPARC_CORE0.sparc0.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`SPARC_CORE0.sparc0.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`SPARC_CORE0.sparc0.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`SPARC_CORE0.sparc0.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`SPARC_CORE0.sparc0.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`SPARC_CORE0.sparc0.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`SPARC_CORE0.sparc0.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`SPARC_CORE0.sparc0.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`SPARC_CORE0.sparc0.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`SPARC_CORE0.sparc0.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`SPARC_CORE0.sparc0.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`SPARC_CORE0.sparc0.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`SPARC_CORE0.sparc0.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`SPARC_CORE0.sparc0.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`SPARC_CORE0.sparc0.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`SPARC_CORE0.sparc0.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`SPARC_CORE0.sparc0.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`SPARC_CORE0.sparc0.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`SPARC_CORE0.sparc0.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`SPARC_CORE0.sparc0.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`SPARC_CORE0.sparc0.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`SPARC_CORE0.sparc0.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE0.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`SPARC_CORE0.sparc0.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`SPARC_CORE0.sparc0.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE0.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`SPARC_CORE0.sparc0.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`SPARC_CORE0.sparc0.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`SPARC_CORE0.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE0.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`SPARC_CORE0.sparc0.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`SPARC_CORE0.sparc0.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`SPARC_CORE0.sparc0.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`SPARC_CORE0.sparc0.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`SPARC_CORE0.sparc0.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`SPARC_CORE0.sparc0.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`SPARC_CORE0.sparc0.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`SPARC_CORE0.sparc0.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`SPARC_CORE0.sparc0.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`SPARC_CORE0.sparc0.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`SPARC_CORE0.sparc0.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`SPARC_CORE0.sparc0.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`SPARC_CORE0.sparc0.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`SPARC_CORE0.sparc0.tlu.tcl.swint_g), // Templated
    `endif
		    .core_id		(10'd0),			 // Templated
    `ifndef RTL_SPU
            .tlu_itlb_wr_vld_g  (`SPARC_CORE0.sparc0.tlu.tlu_itlb_wr_vld_g), // Templated
            .tlu_itlb_dmp_vld_g (`SPARC_CORE0.sparc0.tlu.tlu_itlb_dmp_vld_g), // Templated
            .tlu_itlb_tte_tag_w2(`SPARC_CORE0.sparc0.tlu.tlu_itlb_tte_tag_w2), // Templated
            .tlu_itlb_tte_data_w2(`SPARC_CORE0.sparc0.tlu.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE0.sparc0.ifu.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE0.sparc0.lsu.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE0.sparc0.tlu.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE0.sparc0.tlu.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `else
		    .tlu_itlb_wr_vld_g	(`SPARC_CORE0.sparc0.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`SPARC_CORE0.sparc0.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`SPARC_CORE0.sparc0.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`SPARC_CORE0.sparc0.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE0.sparc0.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE0.sparc0.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `endif
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon0 (/*AUTOINST*/
			      // Inputs
    `ifndef RTL_SPU
                  .rtl_softint0(`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint0), // Templated
                  .rtl_softint1(`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint1), // Templated
                  .rtl_softint2(`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint2), // Templated
                  .rtl_softint3(`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint3), // Templated
                  .rtl_wsr_data_w(`SPARC_CORE0.sparc0.tlu.tlu.tdp.wsr_data_w), // Templated
                  .rtl_sftint_en_l_g(`SPARC_CORE0.sparc0.tlu.tlu.tdp.tlu_sftint_en_l_g), // Templated
                  .rtl_sftint_b0_en(`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint_b0_en), // Templated
                  .rtl_tickcmp_int(`SPARC_CORE0.sparc0.tlu.tlu.tdp.tickcmp_int), // Templated
                  .rtl_sftint_b16_en(`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint_b16_en), // Templated
                  .rtl_stickcmp_int(`SPARC_CORE0.sparc0.tlu.tlu.tdp.stickcmp_int), // Templated
                  .rtl_sftint_b15_en(`SPARC_CORE0.sparc0.tlu.tlu.tdp.sftint_b15_en), // Templated
                  .rtl_pib_picl_wrap(`SPARC_CORE0.sparc0.tlu.tlu.tdp.pib_picl_wrap), // Templated
                  .rtl_pib_pich_wrap(`SPARC_CORE0.sparc0.tlu.tlu.tdp.pib_pich_wrap), // Templated
                  .rtl_wr_sftint_l_g(`SPARC_CORE0.sparc0.tlu.tlu.tdp.tlu_wr_sftint_l_g), // Templated
                  .rtl_set_sftint_l_g(`SPARC_CORE0.sparc0.tlu.tlu.tdp.tlu_set_sftint_l_g), // Templated
                  .rtl_clr_sftint_l_g(`SPARC_CORE0.sparc0.tlu.tlu.tdp.tlu_clr_sftint_l_g), // Templated
                  .rtl_clk  (`SPARC_CORE0.sparc0.tlu.tlu.tdp.rclk), // Templated
                  .rtl_reset(`SPARC_CORE0.sparc0.tlu.tlu.tdp.tlu_rst), // Templated
    `else
			      .rtl_softint0(`SPARC_CORE0.sparc0.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`SPARC_CORE0.sparc0.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`SPARC_CORE0.sparc0.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`SPARC_CORE0.sparc0.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`SPARC_CORE0.sparc0.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`SPARC_CORE0.sparc0.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`SPARC_CORE0.sparc0.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`SPARC_CORE0.sparc0.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`SPARC_CORE0.sparc0.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`SPARC_CORE0.sparc0.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`SPARC_CORE0.sparc0.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`SPARC_CORE0.sparc0.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`SPARC_CORE0.sparc0.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`SPARC_CORE0.sparc0.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`SPARC_CORE0.sparc0.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`SPARC_CORE0.sparc0.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`SPARC_CORE0.sparc0.tlu.tdp.rclk), // Templated
			      .rtl_reset(`SPARC_CORE0.sparc0.tlu.tdp.tlu_rst), // Templated
    `endif
			      .core_id	(10'd0));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon0(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
`ifndef RTL_SPU
                .thr_state0 (`SPARC_CORE0.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
                .thr_state1 (`SPARC_CORE0.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
                .thr_state2 (`SPARC_CORE0.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
                .thr_state3 (`SPARC_CORE0.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
                .rstthr (`SPARC_CORE0.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
                .nukeint    (`SPARC_CORE0.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
                .resumint   (`SPARC_CORE0.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
                .rstint (`SPARC_CORE0.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`else
			    .thr_state0	(`SPARC_CORE0.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
			    .thr_state1	(`SPARC_CORE0.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
			    .thr_state2	(`SPARC_CORE0.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
			    .thr_state3	(`SPARC_CORE0.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
			    .rstthr	(`SPARC_CORE0.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			    .nukeint	(`SPARC_CORE0.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
			    .resumint	(`SPARC_CORE0.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
			    .rstint	(`SPARC_CORE0.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`endif
			    .coreid	(10'd0));			 // Templated
   mask_mon mask_mon0(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
`ifndef RTL_SPU
              .wm_imiss     (`SPARC_CORE0.sparc0.ifu.ifu.swl.wm_imiss), // Templated
              .wm_other     (`SPARC_CORE0.sparc0.ifu.ifu.swl.wm_other), // Templated
              .wm_stbwait   (`SPARC_CORE0.sparc0.ifu.ifu.swl.wm_stbwait), // Templated
              .mul_wait     (`SPARC_CORE0.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait     (`SPARC_CORE0.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait      (`SPARC_CORE0.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_busy_e   (`SPARC_CORE0.sparc0.ifu.ifu.swl.mul_busy_e), // Templated
              .div_busy_e   (`SPARC_CORE0.sparc0.ifu.ifu.swl.div_busy_e), // Templated
              .fp_busy_e    (`SPARC_CORE0.sparc0.ifu.ifu.swl.fp_busy_e), // Templated
              .ldmiss       (`SPARC_CORE0.sparc0.ifu.ifu.swl.ldmiss), // Templated
`else
		      .wm_imiss		(`SPARC_CORE0.sparc0.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`SPARC_CORE0.sparc0.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`SPARC_CORE0.sparc0.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`SPARC_CORE0.sparc0.ifu.swl.mul_wait), // Templated
		      .div_wait		(`SPARC_CORE0.sparc0.ifu.swl.div_wait), // Templated
		      .fp_wait		(`SPARC_CORE0.sparc0.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`SPARC_CORE0.sparc0.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`SPARC_CORE0.sparc0.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`SPARC_CORE0.sparc0.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`SPARC_CORE0.sparc0.ifu.swl.ldmiss), // Templated
`endif
		      .coreid		(10'd0));			 // Templated
   pc_muxsel_mon pc_muxsel_mon0(/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
`ifndef RTL_SPU
                .t0pc_f (`SPARC_CORE0.sparc0.ifu.ifu.fdp.t0pc_f[47:0]), // Templated
                .t1pc_f (`SPARC_CORE0.sparc0.ifu.ifu.fdp.t1pc_f[47:0]), // Templated
                .t2pc_f (`SPARC_CORE0.sparc0.ifu.ifu.fdp.t2pc_f[47:0]), // Templated
                .t3pc_f (`SPARC_CORE0.sparc0.ifu.ifu.fdp.t3pc_f[47:0]), // Templated
                .pc_f   (`SPARC_CORE0.sparc0.ifu.ifu.fdp.pc_f[47:0]), // Templated
                .inst_vld_f(`SPARC_CORE0.sparc0.ifu.ifu.fcl.inst_vld_f), // Templated
                .dtu_fcl_running_s(`SPARC_CORE0.sparc0.ifu.ifu.dtu_fcl_running_s), // Templated
                .thr_f  (`SPARC_CORE0.sparc0.ifu.ifu.fcl.thr_f[3:0]), // Templated
`else
				.t0pc_f	(`SPARC_CORE0.sparc0.ifu.fdp.t0pc_f[47:0]), // Templated
				.t1pc_f	(`SPARC_CORE0.sparc0.ifu.fdp.t1pc_f[47:0]), // Templated
				.t2pc_f	(`SPARC_CORE0.sparc0.ifu.fdp.t2pc_f[47:0]), // Templated
				.t3pc_f	(`SPARC_CORE0.sparc0.ifu.fdp.t3pc_f[47:0]), // Templated
				.pc_f	(`SPARC_CORE0.sparc0.ifu.fdp.pc_f[47:0]), // Templated
				.inst_vld_f(`SPARC_CORE0.sparc0.ifu.fcl.inst_vld_f), // Templated
				.dtu_fcl_running_s(`SPARC_CORE0.sparc0.ifu.dtu_fcl_running_s), // Templated
				.thr_f	(`SPARC_CORE0.sparc0.ifu.fcl.thr_f[3:0]), // Templated
`endif
				.coreid	(10'd0));			 // Templated
   stb_ovfl_mon stb_ovfl_mon0(/*AUTOINST*/
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
`ifndef RTL_SPU
                  .lsu_ifu_stbcnt3(`SPARC_CORE0.sparc0.ifu.ifu.lsu_ifu_stbcnt3), // Templated
                  .lsu_ifu_stbcnt2(`SPARC_CORE0.sparc0.ifu.ifu.lsu_ifu_stbcnt2), // Templated
                  .lsu_ifu_stbcnt1(`SPARC_CORE0.sparc0.ifu.ifu.lsu_ifu_stbcnt1), // Templated
                  .lsu_ifu_stbcnt0(`SPARC_CORE0.sparc0.ifu.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.reset), // Templated
`else
			      .lsu_ifu_stbcnt3(`SPARC_CORE0.sparc0.ifu.lsu_ifu_stbcnt3), // Templated
			      .lsu_ifu_stbcnt2(`SPARC_CORE0.sparc0.ifu.lsu_ifu_stbcnt2), // Templated
			      .lsu_ifu_stbcnt1(`SPARC_CORE0.sparc0.ifu.lsu_ifu_stbcnt1), // Templated
			      .lsu_ifu_stbcnt0(`SPARC_CORE0.sparc0.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE0.sparc0.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE0.sparc0.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE0.sparc0.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE0.sparc0.lsu.stb_ctl0.reset), // Templated
`endif
			      .coreid	(10'd0));			 // Templated
   icache_mutex_mon icache_mutex_mon0(/*AUTOINST*/
				      // Inputs
				      .clk(clk),
				      .rst_l(rst_l),
`ifndef RTL_SPU
                      .waysel_buf_s1(`SPARC_CORE0.sparc0.ifu.ifu.wseldp.waysel_buf_s1), // Templated
                      .alltag_err_s1(`SPARC_CORE0.sparc0.ifu.ifu.errctl.alltag_err_s1), // Templated
                      .tlb_cam_miss_s1(`SPARC_CORE0.sparc0.ifu.ifu.fcl.tlb_cam_miss_s1), // Templated
                      .cam_vld_s1(`SPARC_CORE0.sparc0.ifu.ifu.fcl.cam_vld_s1), // Templated
`else
				      .waysel_buf_s1(`SPARC_CORE0.sparc0.ifu.wseldp.waysel_buf_s1), // Templated
				      .alltag_err_s1(`SPARC_CORE0.sparc0.ifu.errctl.alltag_err_s1), // Templated
				      .tlb_cam_miss_s1(`SPARC_CORE0.sparc0.ifu.fcl.tlb_cam_miss_s1), // Templated
				      .cam_vld_s1(`SPARC_CORE0.sparc0.ifu.fcl.cam_vld_s1), // Templated
`endif
				      .coreid(10'd0));		 // Templated
   nc_inv_chk nc_inv_chk0(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .cpxpkt_vld   (`SPARC_CORE0.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
              .cpxpkt_rtntype(`SPARC_CORE0.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
              .nc       (`SPARC_CORE0.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
              .wv       (`SPARC_CORE0.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`else
			  .cpxpkt_vld	(`SPARC_CORE0.sparc0.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`SPARC_CORE0.sparc0.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`SPARC_CORE0.sparc0.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`SPARC_CORE0.sparc0.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`endif
			  .coreid	(10'd0));			 // Templated

       // trin: we don't have spu
       // spu_ma_mon spu_ma_mon0(/* AUTOINST*/
    			//   // Inputs
    			//   .clk		(clk),
    			//   .wrmi_mamul_1sthalf(`SPARC_CORE0.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    			//   .wrmi_mamul_2ndhalf(`SPARC_CORE0.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    			//   .wrmi_maaeqb_1sthalf(`SPARC_CORE0.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    			//   .wrmi_maaeqb_2ndhalf(`SPARC_CORE0.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    			//   .iptr		(`SPARC_CORE0.sparc0.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    			//   .iminus_lenminus1(`SPARC_CORE0.sparc0.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    			//   .mul_data	(`SPARC_CORE0.sparc0.spu.spu_madp.spu_madp_evedata[63:0]));


always @ (negedge clk)
begin
    // if (`SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_inv_data_val === 1'bx))
    if (`SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val === 1'bx))
    begin
        $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received X invalidation");
        `ifndef VERILATOR
        repeat(5)@(posedge clk);
        `endif
        `MONITOR_PATH.fail("TILE0 lsu received X invalidation");
    end

    // if (`SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_inv_data_val)
    if (`SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val)
    begin
        if (|`SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_way === 1'bx)
        begin
            $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received invalid way invalidation");
            `ifndef VERILATOR
            repeat(5)@(posedge clk);
            `endif
            `MONITOR_PATH.fail("TILE0 lsu received invalid way invalidation");
        end
    end
end



    //   cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
    //				// Inputs
    //				.clk	(clk),
    //				.rst_l	(rst_l),
    //				.spc_pcx_data_pa(`PCXPATH0.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
    //				.cpx_spc_data_cx(`PCXPATH0.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
    //				.cpu	(0));
   `endif


   `ifdef RTL_SPARC1
   l_cache_mon l_cache_mon1(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(0),			 // Templated
			    .index_f	(`ICTPATH1.index_y[`IC_SET_IDX_HI:0]), // Templated
			    .wrreq_f	(`ICTPATH1.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH1.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH1.ifq_ict_wrtag_f[`IC_TAG_SZ:0]), // Templated
			    .wr_data	(`ICVPATH1.write_bit_y),	 // Templated
                // .wr_data    (`ICVPATH1.din_d1),  // Templated
			    .wren_f	(`ICVPATH1.write_mask_y[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH1.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH1.wr_adr[`IC_SET_IDX_HI:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH1.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH1.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`SPARC_CORE1.sparc0.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`SPARC_CORE1.sparc0.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon1(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .wm_imiss (`SPARC_CORE1.sparc0.ifu.ifu.swl.wm_imiss[3:0]), // Templated
              .wm_other (`SPARC_CORE1.sparc0.ifu.ifu.swl.wm_other[3:0]), // Templated
              .wm_stbwait   (`SPARC_CORE1.sparc0.ifu.ifu.swl.wm_stbwait[3:0]), // Templated
              .thr_state0   (`SPARC_CORE1.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
              .thr_state1   (`SPARC_CORE1.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
              .thr_state2   (`SPARC_CORE1.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
              .thr_state3   (`SPARC_CORE1.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
              .rst_stallreq (`SPARC_CORE1.sparc0.ifu.ifu.fcl.rst_stallreq), // Templated
              .ifq_fcl_stallreq(`SPARC_CORE1.sparc0.ifu.ifu.fcl.ifq_fcl_stallreq), // Templated
              .lsu_ifu_stallreq(`SPARC_CORE1.sparc0.ifu.ifu.fcl.lsu_ifu_stallreq), // Templated
              .ffu_ifu_stallreq(`SPARC_CORE1.sparc0.ifu.ifu.fcl.ffu_ifu_stallreq), // Templated
              .completion   (`SPARC_CORE1.sparc0.ifu.ifu.swl.completion), // Templated
              .mul_wait (`SPARC_CORE1.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait (`SPARC_CORE1.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait  (`SPARC_CORE1.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_wait_nxt (`SPARC_CORE1.sparc0.ifu.ifu.swl.mul_wait_nxt), // Templated
              .div_wait_nxt (`SPARC_CORE1.sparc0.ifu.ifu.swl.div_wait_nxt), // Templated
              .fp_wait_nxt  (`SPARC_CORE1.sparc0.ifu.ifu.swl.fp_wait_nxt), // Templated
              .mul_busy_d   (`SPARC_CORE1.sparc0.ifu.ifu.swl.mul_busy_d), // Templated
              .div_busy_d   (`SPARC_CORE1.sparc0.ifu.ifu.swl.div_busy_d), // Templated
              .fp_busy_d    (`SPARC_CORE1.sparc0.ifu.ifu.swl.fp_busy_d), // Templated
              .ifet_ue_vec_d1(`SPARC_CORE1.sparc0.ifu.ifu.fcl.ifet_ue_vec_d1), // Templated
`else
			  .wm_imiss	(`SPARC_CORE1.sparc0.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`SPARC_CORE1.sparc0.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`SPARC_CORE1.sparc0.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`SPARC_CORE1.sparc0.ifu.swl.thr0_state[4:0]), // Templated
			  .thr_state1	(`SPARC_CORE1.sparc0.ifu.swl.thr1_state[4:0]), // Templated
			  .thr_state2	(`SPARC_CORE1.sparc0.ifu.swl.thr2_state[4:0]), // Templated
			  .thr_state3	(`SPARC_CORE1.sparc0.ifu.swl.thr3_state[4:0]), // Templated
			  .rst_stallreq	(`SPARC_CORE1.sparc0.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`SPARC_CORE1.sparc0.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`SPARC_CORE1.sparc0.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`SPARC_CORE1.sparc0.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`SPARC_CORE1.sparc0.ifu.swl.completion), // Templated
			  .mul_wait	(`SPARC_CORE1.sparc0.ifu.swl.mul_wait), // Templated
			  .div_wait	(`SPARC_CORE1.sparc0.ifu.swl.div_wait), // Templated
			  .fp_wait	(`SPARC_CORE1.sparc0.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`SPARC_CORE1.sparc0.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`SPARC_CORE1.sparc0.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`SPARC_CORE1.sparc0.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`SPARC_CORE1.sparc0.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`SPARC_CORE1.sparc0.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`SPARC_CORE1.sparc0.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`SPARC_CORE1.sparc0.ifu.fcl.ifet_ue_vec_d1), // Templated
`endif
			  .cpu_id	(10'd1));			 // Templated
   exu_mon exu_mon1(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH1.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH1.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH1.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH1.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH1.irf.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH1.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH1.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon1(/*AUTOINST*/
		    // Inputs
    `ifndef RTL_SPU
            .clk        (`SPARC_CORE1.sparc0.tlu.tlu.rclk), // Templated
            .grst_l     (`SPARC_CORE1.sparc0.tlu.tlu.grst_l), // Templated
            .rst_l      (`SPARC_CORE1.sparc0.tlu.tlu.tcl.tlu_rst_l), // Templated
    `else
		    .clk		(`SPARC_CORE1.sparc0.tlu.rclk), // Templated
		    .grst_l		(`SPARC_CORE1.sparc0.tlu.grst_l), // Templated
		    .rst_l		(`SPARC_CORE1.sparc0.tlu.tcl.tlu_rst_l), // Templated
    `endif
			.lsu_ifu_flush_pipe_w	(`SPARC_CORE1.sparc0.lsu_ifu_flush_pipe_w),
    `ifndef RTL_SPU
            .tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE1.sparc0.tlu.tlu_lsu_int_ldxa_vld_w2),
            .tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE1.sparc0.tlu.tlu_lsu_int_ld_ill_va_w2),
            .tlu_scpd_wr_vld_g      (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
            .cpu_mondo_head_wr_g    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
            .cpu_mondo_tail_wr_g    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
            .dev_mondo_head_wr_g    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_head_wr_g),
            .dev_mondo_tail_wr_g    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
            .resum_err_head_wr_g    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.resum_err_head_wr_g),
            .resum_err_tail_wr_g    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.resum_err_tail_wr_g),
            .nresum_err_head_wr_g   (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.nresum_err_head_wr_g),
            .nresum_err_tail_wr_g   (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.nresum_err_tail_wr_g),
            .ifu_lsu_ld_inst_e      (`SPARC_CORE1.sparc0.tlu.tlu.ifu_lsu_ld_inst_e),
            .ifu_lsu_st_inst_e      (`SPARC_CORE1.sparc0.tlu.tlu.ifu_lsu_st_inst_e),
            .ifu_lsu_alt_space_e    (`SPARC_CORE1.sparc0.tlu.tlu.ifu_lsu_alt_space_e),
            .tlu_early_flush_pipe_w (`SPARC_CORE1.sparc0.tlu.tlu.tlu_early_flush_pipe_w),
            .tlu_asi_state_e        (`SPARC_CORE1.sparc0.tlu.tlu.tlu_asi_state_e),
            .exu_lsu_ldst_va_e      (`SPARC_CORE1.sparc0.tlu.tlu.exu_lsu_ldst_va_e),
            .por_rstint0_w2 (`SPARC_CORE1.sparc0.tlu.tlu.tcl.por_rstint0_w2),
            .por_rstint1_w2 (`SPARC_CORE1.sparc0.tlu.tlu.tcl.por_rstint1_w2),
            .por_rstint2_w2 (`SPARC_CORE1.sparc0.tlu.tlu.tcl.por_rstint2_w2),
            .por_rstint3_w2 (`SPARC_CORE1.sparc0.tlu.tlu.tcl.por_rstint3_w2),
            .tlu_gl_lvl0    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.gl_lvl0),
            .tlu_gl_lvl1    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.gl_lvl1),
            .tlu_gl_lvl2    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.gl_lvl2),
            .tlu_gl_lvl3    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hyperv.gl_lvl3),
    `else
			.tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE1.sparc0.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE1.sparc0.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`SPARC_CORE1.sparc0.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`SPARC_CORE1.sparc0.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`SPARC_CORE1.sparc0.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`SPARC_CORE1.sparc0.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`SPARC_CORE1.sparc0.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`SPARC_CORE1.sparc0.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`SPARC_CORE1.sparc0.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`SPARC_CORE1.sparc0.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`SPARC_CORE1.sparc0.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`SPARC_CORE1.sparc0.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`SPARC_CORE1.sparc0.tlu.tlu_hyperv.gl_lvl3),
    `endif
            .exu_gl_lvl0	(`SPARC_CORE1.sparc0.exu.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`SPARC_CORE1.sparc0.exu.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`SPARC_CORE1.sparc0.exu.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`SPARC_CORE1.sparc0.exu.exu.rml.agp_thr3_next),
    `ifndef RTL_SPU
            .ifu_tlu_thrid_d    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
            .ifu_tlu_inst_vld_m (`SPARC_CORE1.sparc0.tlu.tlu.ifu_tlu_inst_vld_m), // Templated
            .ifu_tlu_imiss_e    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
            .ifu_tlu_immu_miss_m(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
            .tlu_thread_inst_vld_g(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
            .tlu_thread_wsel_g  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
            .ifu_tlu_l2imiss    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .ifu_tlu_flush_fd_w (`SPARC_CORE1.sparc0.tlu.tlu.ifu_tlu_flush_fd_w), // Templated
            .ifu_tlu_sraddr_d   (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
            .ifu_tlu_rsr_inst_d (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
            .lsu_tlu_wsr_inst_e (`SPARC_CORE1.sparc0.tlu.tlu.lsu_tlu_wsr_inst_e), // Templated
            .tlu_wsr_inst_nq_g  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
            .tlu_wsr_data_w (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.tlu_wsr_data_w), // Templated
            .lsu_tlu_dcache_miss_w2(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .lsu_tlu_l2_dmiss   (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .lsu_tlu_stb_full_w2(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .lsu_tlu_dmmu_miss_g(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
            .ffu_tlu_fpu_tid    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
            .ffu_tlu_fpu_cmplt  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
            .tlu_pstate_priv    (`SPARC_CORE1.sparc0.tlu.tlu.local_pstate_priv), // Templated
            .tlu_hpstate_priv   (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hpstate_priv), // Templated
            .tlu_hpstate_enb    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_hpstate_enb), // Templated
            .tlu_pstate_ie  (`SPARC_CORE1.sparc0.tlu.tlu.local_pstate_ie), // Templated
            .wsr_thread_inst_g  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.wsr_thread_inst_g), // Templated
            .lsu_tlu_defr_trp_taken_g(`SPARC_CORE1.sparc0.tlu.tlu.lsu_tlu_defr_trp_taken_g), // Templated
            .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE1.sparc0.tlu.tlu.lsu_tlu_async_ttype_vld_g), // Templated
            .lsu_tlu_ttype_vld_m2(`SPARC_CORE1.sparc0.tlu.tlu.lsu_tlu_ttype_vld_m2), // Templated
            .tlu_ifu_flush_pipe_w(`SPARC_CORE1.sparc0.tlu.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
            .tcc_inst_w2    (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.tcc_inst_w2), // Templated
            .tlu_pib_rsr_data_e (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
            .tlu_pib_priv_act_trap_m(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
            .tlu_pib_picl_wrap  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pib_picl_wrap), // Templated
            .tlu_pib_pich_wrap  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pich_onebelow_flg), // Templated
            .tlu_ifu_trappc_vld_w1(`SPARC_CORE1.sparc0.tlu.tlu.tlu_ifu_trappc_vld_w1), // Templated
            .tlu_ifu_trappc_w2  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_ifu_trappc_w2), // Templated
            .tlu_final_ttype_w2 (`SPARC_CORE1.sparc0.tlu.tlu.tlu_final_ttype_w2), // Templated
            .tlu_ifu_trap_tid_w1(`SPARC_CORE1.sparc0.tlu.tlu.tlu_ifu_trap_tid_w1), // Templated
            .tlu_full_flush_pipe_w2(`SPARC_CORE1.sparc0.tlu.tlu.tlu_full_flush_pipe_w2), // Templated
            .rtl_pcr0       (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pcr0), // Templated
            .rtl_pcr1       (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pcr1), // Templated
            .rtl_pcr2       (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pcr2), // Templated
            .rtl_pcr3       (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pcr3), // Templated
            .rtl_pich_cnt0  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pich_cnt0), // Templated
            .rtl_pich_cnt1  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pich_cnt1), // Templated
            .rtl_pich_cnt2  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pich_cnt2), // Templated
            .rtl_pich_cnt3  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.pich_cnt3), // Templated
            .rtl_picl_cnt0  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.picl_cnt0), // Templated
            .rtl_picl_cnt1  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.picl_cnt1), // Templated
            .rtl_picl_cnt2  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.picl_cnt2), // Templated
            .rtl_picl_cnt3  (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.picl_cnt3), // Templated
            .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .rtl_fpu_cmplt_thread(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.fpu_cmplt_thread), // Templated
            .rtl_imiss_thread_g (`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.imiss_thread_g), // Templated
            .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .rtl_immu_miss_thread_g(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.immu_miss_thread_g), // Templated
            .rtl_dmmu_miss_thread_g(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
            .rtl_ifu_tlu_l2imiss(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE1.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .true_pil0      (`SPARC_CORE1.sparc0.tlu.tlu.tcl.true_pil0), // Templated
            .true_pil1      (`SPARC_CORE1.sparc0.tlu.tlu.tcl.true_pil1), // Templated
            .true_pil2      (`SPARC_CORE1.sparc0.tlu.tlu.tcl.true_pil2), // Templated
            .true_pil3      (`SPARC_CORE1.sparc0.tlu.tlu.tcl.true_pil3), // Templated
            .rtl_trp_lvl0   (`SPARC_CORE1.sparc0.tlu.tlu.tcl.trp_lvl0), // Templated
            .rtl_trp_lvl1   (`SPARC_CORE1.sparc0.tlu.tlu.tcl.trp_lvl1), // Templated
            .rtl_trp_lvl2   (`SPARC_CORE1.sparc0.tlu.tlu.tcl.trp_lvl2), // Templated
            .rtl_trp_lvl3   (`SPARC_CORE1.sparc0.tlu.tlu.tcl.trp_lvl3), // Templated
            .tlz_thread     (`SPARC_CORE1.sparc0.tlu.tlu.tcl.tlz_thread), // Templated
            .th0_sftint_15  (`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint0[15]), // Templated
            .th1_sftint_15  (`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint1[15]), // Templated
            .th2_sftint_15  (`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint2[15]), // Templated
            .th3_sftint_15  (`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint3[15]), // Templated
            .ifu_swint_g    (`SPARC_CORE1.sparc0.tlu.tlu.tcl.swint_g), // Templated
    `else
		    .ifu_tlu_thrid_d	(`SPARC_CORE1.sparc0.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`SPARC_CORE1.sparc0.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`SPARC_CORE1.sparc0.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`SPARC_CORE1.sparc0.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`SPARC_CORE1.sparc0.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`SPARC_CORE1.sparc0.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`SPARC_CORE1.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`SPARC_CORE1.sparc0.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`SPARC_CORE1.sparc0.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`SPARC_CORE1.sparc0.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`SPARC_CORE1.sparc0.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`SPARC_CORE1.sparc0.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`SPARC_CORE1.sparc0.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`SPARC_CORE1.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`SPARC_CORE1.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`SPARC_CORE1.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`SPARC_CORE1.sparc0.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`SPARC_CORE1.sparc0.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`SPARC_CORE1.sparc0.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`SPARC_CORE1.sparc0.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`SPARC_CORE1.sparc0.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`SPARC_CORE1.sparc0.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`SPARC_CORE1.sparc0.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`SPARC_CORE1.sparc0.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`SPARC_CORE1.sparc0.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE1.sparc0.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`SPARC_CORE1.sparc0.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`SPARC_CORE1.sparc0.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`SPARC_CORE1.sparc0.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`SPARC_CORE1.sparc0.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`SPARC_CORE1.sparc0.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`SPARC_CORE1.sparc0.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`SPARC_CORE1.sparc0.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`SPARC_CORE1.sparc0.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`SPARC_CORE1.sparc0.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`SPARC_CORE1.sparc0.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`SPARC_CORE1.sparc0.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`SPARC_CORE1.sparc0.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`SPARC_CORE1.sparc0.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`SPARC_CORE1.sparc0.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`SPARC_CORE1.sparc0.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`SPARC_CORE1.sparc0.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`SPARC_CORE1.sparc0.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`SPARC_CORE1.sparc0.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`SPARC_CORE1.sparc0.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`SPARC_CORE1.sparc0.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`SPARC_CORE1.sparc0.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`SPARC_CORE1.sparc0.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`SPARC_CORE1.sparc0.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`SPARC_CORE1.sparc0.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE1.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`SPARC_CORE1.sparc0.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`SPARC_CORE1.sparc0.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE1.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`SPARC_CORE1.sparc0.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`SPARC_CORE1.sparc0.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`SPARC_CORE1.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE1.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`SPARC_CORE1.sparc0.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`SPARC_CORE1.sparc0.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`SPARC_CORE1.sparc0.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`SPARC_CORE1.sparc0.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`SPARC_CORE1.sparc0.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`SPARC_CORE1.sparc0.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`SPARC_CORE1.sparc0.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`SPARC_CORE1.sparc0.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`SPARC_CORE1.sparc0.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`SPARC_CORE1.sparc0.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`SPARC_CORE1.sparc0.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`SPARC_CORE1.sparc0.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`SPARC_CORE1.sparc0.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`SPARC_CORE1.sparc0.tlu.tcl.swint_g), // Templated
    `endif
		    .core_id		(10'd1),			 // Templated
    `ifndef RTL_SPU
            .tlu_itlb_wr_vld_g  (`SPARC_CORE1.sparc0.tlu.tlu_itlb_wr_vld_g), // Templated
            .tlu_itlb_dmp_vld_g (`SPARC_CORE1.sparc0.tlu.tlu_itlb_dmp_vld_g), // Templated
            .tlu_itlb_tte_tag_w2(`SPARC_CORE1.sparc0.tlu.tlu_itlb_tte_tag_w2), // Templated
            .tlu_itlb_tte_data_w2(`SPARC_CORE1.sparc0.tlu.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE1.sparc0.ifu.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE1.sparc0.lsu.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE1.sparc0.tlu.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE1.sparc0.tlu.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `else
		    .tlu_itlb_wr_vld_g	(`SPARC_CORE1.sparc0.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`SPARC_CORE1.sparc0.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`SPARC_CORE1.sparc0.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`SPARC_CORE1.sparc0.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE1.sparc0.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE1.sparc0.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE1.sparc0.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE1.sparc0.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `endif
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon1 (/*AUTOINST*/
			      // Inputs
    `ifndef RTL_SPU
                  .rtl_softint0(`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint0), // Templated
                  .rtl_softint1(`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint1), // Templated
                  .rtl_softint2(`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint2), // Templated
                  .rtl_softint3(`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint3), // Templated
                  .rtl_wsr_data_w(`SPARC_CORE1.sparc0.tlu.tlu.tdp.wsr_data_w), // Templated
                  .rtl_sftint_en_l_g(`SPARC_CORE1.sparc0.tlu.tlu.tdp.tlu_sftint_en_l_g), // Templated
                  .rtl_sftint_b0_en(`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint_b0_en), // Templated
                  .rtl_tickcmp_int(`SPARC_CORE1.sparc0.tlu.tlu.tdp.tickcmp_int), // Templated
                  .rtl_sftint_b16_en(`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint_b16_en), // Templated
                  .rtl_stickcmp_int(`SPARC_CORE1.sparc0.tlu.tlu.tdp.stickcmp_int), // Templated
                  .rtl_sftint_b15_en(`SPARC_CORE1.sparc0.tlu.tlu.tdp.sftint_b15_en), // Templated
                  .rtl_pib_picl_wrap(`SPARC_CORE1.sparc0.tlu.tlu.tdp.pib_picl_wrap), // Templated
                  .rtl_pib_pich_wrap(`SPARC_CORE1.sparc0.tlu.tlu.tdp.pib_pich_wrap), // Templated
                  .rtl_wr_sftint_l_g(`SPARC_CORE1.sparc0.tlu.tlu.tdp.tlu_wr_sftint_l_g), // Templated
                  .rtl_set_sftint_l_g(`SPARC_CORE1.sparc0.tlu.tlu.tdp.tlu_set_sftint_l_g), // Templated
                  .rtl_clr_sftint_l_g(`SPARC_CORE1.sparc0.tlu.tlu.tdp.tlu_clr_sftint_l_g), // Templated
                  .rtl_clk  (`SPARC_CORE1.sparc0.tlu.tlu.tdp.rclk), // Templated
                  .rtl_reset(`SPARC_CORE1.sparc0.tlu.tlu.tdp.tlu_rst), // Templated
    `else
			      .rtl_softint0(`SPARC_CORE1.sparc0.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`SPARC_CORE1.sparc0.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`SPARC_CORE1.sparc0.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`SPARC_CORE1.sparc0.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`SPARC_CORE1.sparc0.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`SPARC_CORE1.sparc0.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`SPARC_CORE1.sparc0.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`SPARC_CORE1.sparc0.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`SPARC_CORE1.sparc0.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`SPARC_CORE1.sparc0.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`SPARC_CORE1.sparc0.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`SPARC_CORE1.sparc0.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`SPARC_CORE1.sparc0.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`SPARC_CORE1.sparc0.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`SPARC_CORE1.sparc0.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`SPARC_CORE1.sparc0.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`SPARC_CORE1.sparc0.tlu.tdp.rclk), // Templated
			      .rtl_reset(`SPARC_CORE1.sparc0.tlu.tdp.tlu_rst), // Templated
    `endif
			      .core_id	(10'd1));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon1(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
`ifndef RTL_SPU
                .thr_state0 (`SPARC_CORE1.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
                .thr_state1 (`SPARC_CORE1.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
                .thr_state2 (`SPARC_CORE1.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
                .thr_state3 (`SPARC_CORE1.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
                .rstthr (`SPARC_CORE1.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
                .nukeint    (`SPARC_CORE1.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
                .resumint   (`SPARC_CORE1.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
                .rstint (`SPARC_CORE1.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`else
			    .thr_state0	(`SPARC_CORE1.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
			    .thr_state1	(`SPARC_CORE1.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
			    .thr_state2	(`SPARC_CORE1.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
			    .thr_state3	(`SPARC_CORE1.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
			    .rstthr	(`SPARC_CORE1.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			    .nukeint	(`SPARC_CORE1.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
			    .resumint	(`SPARC_CORE1.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
			    .rstint	(`SPARC_CORE1.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`endif
			    .coreid	(10'd1));			 // Templated
   mask_mon mask_mon1(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
`ifndef RTL_SPU
              .wm_imiss     (`SPARC_CORE1.sparc0.ifu.ifu.swl.wm_imiss), // Templated
              .wm_other     (`SPARC_CORE1.sparc0.ifu.ifu.swl.wm_other), // Templated
              .wm_stbwait   (`SPARC_CORE1.sparc0.ifu.ifu.swl.wm_stbwait), // Templated
              .mul_wait     (`SPARC_CORE1.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait     (`SPARC_CORE1.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait      (`SPARC_CORE1.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_busy_e   (`SPARC_CORE1.sparc0.ifu.ifu.swl.mul_busy_e), // Templated
              .div_busy_e   (`SPARC_CORE1.sparc0.ifu.ifu.swl.div_busy_e), // Templated
              .fp_busy_e    (`SPARC_CORE1.sparc0.ifu.ifu.swl.fp_busy_e), // Templated
              .ldmiss       (`SPARC_CORE1.sparc0.ifu.ifu.swl.ldmiss), // Templated
`else
		      .wm_imiss		(`SPARC_CORE1.sparc0.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`SPARC_CORE1.sparc0.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`SPARC_CORE1.sparc0.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`SPARC_CORE1.sparc0.ifu.swl.mul_wait), // Templated
		      .div_wait		(`SPARC_CORE1.sparc0.ifu.swl.div_wait), // Templated
		      .fp_wait		(`SPARC_CORE1.sparc0.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`SPARC_CORE1.sparc0.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`SPARC_CORE1.sparc0.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`SPARC_CORE1.sparc0.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`SPARC_CORE1.sparc0.ifu.swl.ldmiss), // Templated
`endif
		      .coreid		(10'd1));			 // Templated
   pc_muxsel_mon pc_muxsel_mon1(/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
`ifndef RTL_SPU
                .t0pc_f (`SPARC_CORE1.sparc0.ifu.ifu.fdp.t0pc_f[47:0]), // Templated
                .t1pc_f (`SPARC_CORE1.sparc0.ifu.ifu.fdp.t1pc_f[47:0]), // Templated
                .t2pc_f (`SPARC_CORE1.sparc0.ifu.ifu.fdp.t2pc_f[47:0]), // Templated
                .t3pc_f (`SPARC_CORE1.sparc0.ifu.ifu.fdp.t3pc_f[47:0]), // Templated
                .pc_f   (`SPARC_CORE1.sparc0.ifu.ifu.fdp.pc_f[47:0]), // Templated
                .inst_vld_f(`SPARC_CORE1.sparc0.ifu.ifu.fcl.inst_vld_f), // Templated
                .dtu_fcl_running_s(`SPARC_CORE1.sparc0.ifu.ifu.dtu_fcl_running_s), // Templated
                .thr_f  (`SPARC_CORE1.sparc0.ifu.ifu.fcl.thr_f[3:0]), // Templated
`else
				.t0pc_f	(`SPARC_CORE1.sparc0.ifu.fdp.t0pc_f[47:0]), // Templated
				.t1pc_f	(`SPARC_CORE1.sparc0.ifu.fdp.t1pc_f[47:0]), // Templated
				.t2pc_f	(`SPARC_CORE1.sparc0.ifu.fdp.t2pc_f[47:0]), // Templated
				.t3pc_f	(`SPARC_CORE1.sparc0.ifu.fdp.t3pc_f[47:0]), // Templated
				.pc_f	(`SPARC_CORE1.sparc0.ifu.fdp.pc_f[47:0]), // Templated
				.inst_vld_f(`SPARC_CORE1.sparc0.ifu.fcl.inst_vld_f), // Templated
				.dtu_fcl_running_s(`SPARC_CORE1.sparc0.ifu.dtu_fcl_running_s), // Templated
				.thr_f	(`SPARC_CORE1.sparc0.ifu.fcl.thr_f[3:0]), // Templated
`endif
				.coreid	(10'd1));			 // Templated
   stb_ovfl_mon stb_ovfl_mon1(/*AUTOINST*/
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
`ifndef RTL_SPU
                  .lsu_ifu_stbcnt3(`SPARC_CORE1.sparc0.ifu.ifu.lsu_ifu_stbcnt3), // Templated
                  .lsu_ifu_stbcnt2(`SPARC_CORE1.sparc0.ifu.ifu.lsu_ifu_stbcnt2), // Templated
                  .lsu_ifu_stbcnt1(`SPARC_CORE1.sparc0.ifu.ifu.lsu_ifu_stbcnt1), // Templated
                  .lsu_ifu_stbcnt0(`SPARC_CORE1.sparc0.ifu.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE1.sparc0.lsu.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE1.sparc0.lsu.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE1.sparc0.lsu.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE1.sparc0.lsu.lsu.stb_ctl0.reset), // Templated
`else
			      .lsu_ifu_stbcnt3(`SPARC_CORE1.sparc0.ifu.lsu_ifu_stbcnt3), // Templated
			      .lsu_ifu_stbcnt2(`SPARC_CORE1.sparc0.ifu.lsu_ifu_stbcnt2), // Templated
			      .lsu_ifu_stbcnt1(`SPARC_CORE1.sparc0.ifu.lsu_ifu_stbcnt1), // Templated
			      .lsu_ifu_stbcnt0(`SPARC_CORE1.sparc0.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE1.sparc0.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE1.sparc0.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE1.sparc0.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE1.sparc0.lsu.stb_ctl0.reset), // Templated
`endif
			      .coreid	(10'd1));			 // Templated
   icache_mutex_mon icache_mutex_mon1(/*AUTOINST*/
				      // Inputs
				      .clk(clk),
				      .rst_l(rst_l),
`ifndef RTL_SPU
                      .waysel_buf_s1(`SPARC_CORE1.sparc0.ifu.ifu.wseldp.waysel_buf_s1), // Templated
                      .alltag_err_s1(`SPARC_CORE1.sparc0.ifu.ifu.errctl.alltag_err_s1), // Templated
                      .tlb_cam_miss_s1(`SPARC_CORE1.sparc0.ifu.ifu.fcl.tlb_cam_miss_s1), // Templated
                      .cam_vld_s1(`SPARC_CORE1.sparc0.ifu.ifu.fcl.cam_vld_s1), // Templated
`else
				      .waysel_buf_s1(`SPARC_CORE1.sparc0.ifu.wseldp.waysel_buf_s1), // Templated
				      .alltag_err_s1(`SPARC_CORE1.sparc0.ifu.errctl.alltag_err_s1), // Templated
				      .tlb_cam_miss_s1(`SPARC_CORE1.sparc0.ifu.fcl.tlb_cam_miss_s1), // Templated
				      .cam_vld_s1(`SPARC_CORE1.sparc0.ifu.fcl.cam_vld_s1), // Templated
`endif
				      .coreid(10'd1));		 // Templated
   nc_inv_chk nc_inv_chk1(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .cpxpkt_vld   (`SPARC_CORE1.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
              .cpxpkt_rtntype(`SPARC_CORE1.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
              .nc       (`SPARC_CORE1.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
              .wv       (`SPARC_CORE1.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`else
			  .cpxpkt_vld	(`SPARC_CORE1.sparc0.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`SPARC_CORE1.sparc0.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`SPARC_CORE1.sparc0.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`SPARC_CORE1.sparc0.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`endif
			  .coreid	(10'd1));			 // Templated

       // trin: we don't have spu
       // spu_ma_mon spu_ma_mon1(/* AUTOINST*/
    			//   // Inputs
    			//   .clk		(clk),
    			//   .wrmi_mamul_1sthalf(`SPARC_CORE1.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    			//   .wrmi_mamul_2ndhalf(`SPARC_CORE1.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    			//   .wrmi_maaeqb_1sthalf(`SPARC_CORE1.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    			//   .wrmi_maaeqb_2ndhalf(`SPARC_CORE1.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    			//   .iptr		(`SPARC_CORE1.sparc0.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    			//   .iminus_lenminus1(`SPARC_CORE1.sparc0.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    			//   .mul_data	(`SPARC_CORE1.sparc0.spu.spu_madp.spu_madp_evedata[63:0]));


always @ (negedge clk)
begin
    // if (`SPARC_CORE1.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE1.sparc0.lsu.lsu.qctl2.dfq_inv_data_val === 1'bx))
    if (`SPARC_CORE1.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE1.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val === 1'bx))
    begin
        $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received X invalidation");
        `ifndef VERILATOR
        repeat(5)@(posedge clk);
        `endif
        `MONITOR_PATH.fail("TILE0 lsu received X invalidation");
    end

    // if (`SPARC_CORE1.sparc0.lsu.lsu.qctl2.dfq_inv_data_val)
    if (`SPARC_CORE1.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val)
    begin
        if (|`SPARC_CORE1.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_way === 1'bx)
        begin
            $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received invalid way invalidation");
            `ifndef VERILATOR
            repeat(5)@(posedge clk);
            `endif
            `MONITOR_PATH.fail("TILE0 lsu received invalid way invalidation");
        end
    end
end



    //   cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
    //				// Inputs
    //				.clk	(clk),
    //				.rst_l	(rst_l),
    //				.spc_pcx_data_pa(`PCXPATH1.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
    //				.cpx_spc_data_cx(`PCXPATH1.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
    //				.cpu	(0));
   `endif


   `ifdef RTL_SPARC2
   l_cache_mon l_cache_mon2(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(0),			 // Templated
			    .index_f	(`ICTPATH2.index_y[`IC_SET_IDX_HI:0]), // Templated
			    .wrreq_f	(`ICTPATH2.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH2.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH2.ifq_ict_wrtag_f[`IC_TAG_SZ:0]), // Templated
			    .wr_data	(`ICVPATH2.write_bit_y),	 // Templated
                // .wr_data    (`ICVPATH2.din_d1),  // Templated
			    .wren_f	(`ICVPATH2.write_mask_y[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH2.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH2.wr_adr[`IC_SET_IDX_HI:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH2.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH2.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`SPARC_CORE2.sparc0.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`SPARC_CORE2.sparc0.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon2(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .wm_imiss (`SPARC_CORE2.sparc0.ifu.ifu.swl.wm_imiss[3:0]), // Templated
              .wm_other (`SPARC_CORE2.sparc0.ifu.ifu.swl.wm_other[3:0]), // Templated
              .wm_stbwait   (`SPARC_CORE2.sparc0.ifu.ifu.swl.wm_stbwait[3:0]), // Templated
              .thr_state0   (`SPARC_CORE2.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
              .thr_state1   (`SPARC_CORE2.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
              .thr_state2   (`SPARC_CORE2.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
              .thr_state3   (`SPARC_CORE2.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
              .rst_stallreq (`SPARC_CORE2.sparc0.ifu.ifu.fcl.rst_stallreq), // Templated
              .ifq_fcl_stallreq(`SPARC_CORE2.sparc0.ifu.ifu.fcl.ifq_fcl_stallreq), // Templated
              .lsu_ifu_stallreq(`SPARC_CORE2.sparc0.ifu.ifu.fcl.lsu_ifu_stallreq), // Templated
              .ffu_ifu_stallreq(`SPARC_CORE2.sparc0.ifu.ifu.fcl.ffu_ifu_stallreq), // Templated
              .completion   (`SPARC_CORE2.sparc0.ifu.ifu.swl.completion), // Templated
              .mul_wait (`SPARC_CORE2.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait (`SPARC_CORE2.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait  (`SPARC_CORE2.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_wait_nxt (`SPARC_CORE2.sparc0.ifu.ifu.swl.mul_wait_nxt), // Templated
              .div_wait_nxt (`SPARC_CORE2.sparc0.ifu.ifu.swl.div_wait_nxt), // Templated
              .fp_wait_nxt  (`SPARC_CORE2.sparc0.ifu.ifu.swl.fp_wait_nxt), // Templated
              .mul_busy_d   (`SPARC_CORE2.sparc0.ifu.ifu.swl.mul_busy_d), // Templated
              .div_busy_d   (`SPARC_CORE2.sparc0.ifu.ifu.swl.div_busy_d), // Templated
              .fp_busy_d    (`SPARC_CORE2.sparc0.ifu.ifu.swl.fp_busy_d), // Templated
              .ifet_ue_vec_d1(`SPARC_CORE2.sparc0.ifu.ifu.fcl.ifet_ue_vec_d1), // Templated
`else
			  .wm_imiss	(`SPARC_CORE2.sparc0.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`SPARC_CORE2.sparc0.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`SPARC_CORE2.sparc0.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`SPARC_CORE2.sparc0.ifu.swl.thr0_state[4:0]), // Templated
			  .thr_state1	(`SPARC_CORE2.sparc0.ifu.swl.thr1_state[4:0]), // Templated
			  .thr_state2	(`SPARC_CORE2.sparc0.ifu.swl.thr2_state[4:0]), // Templated
			  .thr_state3	(`SPARC_CORE2.sparc0.ifu.swl.thr3_state[4:0]), // Templated
			  .rst_stallreq	(`SPARC_CORE2.sparc0.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`SPARC_CORE2.sparc0.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`SPARC_CORE2.sparc0.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`SPARC_CORE2.sparc0.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`SPARC_CORE2.sparc0.ifu.swl.completion), // Templated
			  .mul_wait	(`SPARC_CORE2.sparc0.ifu.swl.mul_wait), // Templated
			  .div_wait	(`SPARC_CORE2.sparc0.ifu.swl.div_wait), // Templated
			  .fp_wait	(`SPARC_CORE2.sparc0.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`SPARC_CORE2.sparc0.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`SPARC_CORE2.sparc0.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`SPARC_CORE2.sparc0.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`SPARC_CORE2.sparc0.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`SPARC_CORE2.sparc0.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`SPARC_CORE2.sparc0.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`SPARC_CORE2.sparc0.ifu.fcl.ifet_ue_vec_d1), // Templated
`endif
			  .cpu_id	(10'd2));			 // Templated
   exu_mon exu_mon2(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH2.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH2.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH2.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH2.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH2.irf.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH2.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH2.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon2(/*AUTOINST*/
		    // Inputs
    `ifndef RTL_SPU
            .clk        (`SPARC_CORE2.sparc0.tlu.tlu.rclk), // Templated
            .grst_l     (`SPARC_CORE2.sparc0.tlu.tlu.grst_l), // Templated
            .rst_l      (`SPARC_CORE2.sparc0.tlu.tlu.tcl.tlu_rst_l), // Templated
    `else
		    .clk		(`SPARC_CORE2.sparc0.tlu.rclk), // Templated
		    .grst_l		(`SPARC_CORE2.sparc0.tlu.grst_l), // Templated
		    .rst_l		(`SPARC_CORE2.sparc0.tlu.tcl.tlu_rst_l), // Templated
    `endif
			.lsu_ifu_flush_pipe_w	(`SPARC_CORE2.sparc0.lsu_ifu_flush_pipe_w),
    `ifndef RTL_SPU
            .tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE2.sparc0.tlu.tlu_lsu_int_ldxa_vld_w2),
            .tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE2.sparc0.tlu.tlu_lsu_int_ld_ill_va_w2),
            .tlu_scpd_wr_vld_g      (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
            .cpu_mondo_head_wr_g    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
            .cpu_mondo_tail_wr_g    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
            .dev_mondo_head_wr_g    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_head_wr_g),
            .dev_mondo_tail_wr_g    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
            .resum_err_head_wr_g    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.resum_err_head_wr_g),
            .resum_err_tail_wr_g    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.resum_err_tail_wr_g),
            .nresum_err_head_wr_g   (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.nresum_err_head_wr_g),
            .nresum_err_tail_wr_g   (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.nresum_err_tail_wr_g),
            .ifu_lsu_ld_inst_e      (`SPARC_CORE2.sparc0.tlu.tlu.ifu_lsu_ld_inst_e),
            .ifu_lsu_st_inst_e      (`SPARC_CORE2.sparc0.tlu.tlu.ifu_lsu_st_inst_e),
            .ifu_lsu_alt_space_e    (`SPARC_CORE2.sparc0.tlu.tlu.ifu_lsu_alt_space_e),
            .tlu_early_flush_pipe_w (`SPARC_CORE2.sparc0.tlu.tlu.tlu_early_flush_pipe_w),
            .tlu_asi_state_e        (`SPARC_CORE2.sparc0.tlu.tlu.tlu_asi_state_e),
            .exu_lsu_ldst_va_e      (`SPARC_CORE2.sparc0.tlu.tlu.exu_lsu_ldst_va_e),
            .por_rstint0_w2 (`SPARC_CORE2.sparc0.tlu.tlu.tcl.por_rstint0_w2),
            .por_rstint1_w2 (`SPARC_CORE2.sparc0.tlu.tlu.tcl.por_rstint1_w2),
            .por_rstint2_w2 (`SPARC_CORE2.sparc0.tlu.tlu.tcl.por_rstint2_w2),
            .por_rstint3_w2 (`SPARC_CORE2.sparc0.tlu.tlu.tcl.por_rstint3_w2),
            .tlu_gl_lvl0    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.gl_lvl0),
            .tlu_gl_lvl1    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.gl_lvl1),
            .tlu_gl_lvl2    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.gl_lvl2),
            .tlu_gl_lvl3    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hyperv.gl_lvl3),
    `else
			.tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE2.sparc0.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE2.sparc0.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`SPARC_CORE2.sparc0.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`SPARC_CORE2.sparc0.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`SPARC_CORE2.sparc0.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`SPARC_CORE2.sparc0.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`SPARC_CORE2.sparc0.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`SPARC_CORE2.sparc0.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`SPARC_CORE2.sparc0.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`SPARC_CORE2.sparc0.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`SPARC_CORE2.sparc0.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`SPARC_CORE2.sparc0.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`SPARC_CORE2.sparc0.tlu.tlu_hyperv.gl_lvl3),
    `endif
            .exu_gl_lvl0	(`SPARC_CORE2.sparc0.exu.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`SPARC_CORE2.sparc0.exu.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`SPARC_CORE2.sparc0.exu.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`SPARC_CORE2.sparc0.exu.exu.rml.agp_thr3_next),
    `ifndef RTL_SPU
            .ifu_tlu_thrid_d    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
            .ifu_tlu_inst_vld_m (`SPARC_CORE2.sparc0.tlu.tlu.ifu_tlu_inst_vld_m), // Templated
            .ifu_tlu_imiss_e    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
            .ifu_tlu_immu_miss_m(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
            .tlu_thread_inst_vld_g(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
            .tlu_thread_wsel_g  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
            .ifu_tlu_l2imiss    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .ifu_tlu_flush_fd_w (`SPARC_CORE2.sparc0.tlu.tlu.ifu_tlu_flush_fd_w), // Templated
            .ifu_tlu_sraddr_d   (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
            .ifu_tlu_rsr_inst_d (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
            .lsu_tlu_wsr_inst_e (`SPARC_CORE2.sparc0.tlu.tlu.lsu_tlu_wsr_inst_e), // Templated
            .tlu_wsr_inst_nq_g  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
            .tlu_wsr_data_w (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.tlu_wsr_data_w), // Templated
            .lsu_tlu_dcache_miss_w2(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .lsu_tlu_l2_dmiss   (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .lsu_tlu_stb_full_w2(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .lsu_tlu_dmmu_miss_g(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
            .ffu_tlu_fpu_tid    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
            .ffu_tlu_fpu_cmplt  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
            .tlu_pstate_priv    (`SPARC_CORE2.sparc0.tlu.tlu.local_pstate_priv), // Templated
            .tlu_hpstate_priv   (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hpstate_priv), // Templated
            .tlu_hpstate_enb    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_hpstate_enb), // Templated
            .tlu_pstate_ie  (`SPARC_CORE2.sparc0.tlu.tlu.local_pstate_ie), // Templated
            .wsr_thread_inst_g  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.wsr_thread_inst_g), // Templated
            .lsu_tlu_defr_trp_taken_g(`SPARC_CORE2.sparc0.tlu.tlu.lsu_tlu_defr_trp_taken_g), // Templated
            .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE2.sparc0.tlu.tlu.lsu_tlu_async_ttype_vld_g), // Templated
            .lsu_tlu_ttype_vld_m2(`SPARC_CORE2.sparc0.tlu.tlu.lsu_tlu_ttype_vld_m2), // Templated
            .tlu_ifu_flush_pipe_w(`SPARC_CORE2.sparc0.tlu.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
            .tcc_inst_w2    (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.tcc_inst_w2), // Templated
            .tlu_pib_rsr_data_e (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
            .tlu_pib_priv_act_trap_m(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
            .tlu_pib_picl_wrap  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pib_picl_wrap), // Templated
            .tlu_pib_pich_wrap  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pich_onebelow_flg), // Templated
            .tlu_ifu_trappc_vld_w1(`SPARC_CORE2.sparc0.tlu.tlu.tlu_ifu_trappc_vld_w1), // Templated
            .tlu_ifu_trappc_w2  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_ifu_trappc_w2), // Templated
            .tlu_final_ttype_w2 (`SPARC_CORE2.sparc0.tlu.tlu.tlu_final_ttype_w2), // Templated
            .tlu_ifu_trap_tid_w1(`SPARC_CORE2.sparc0.tlu.tlu.tlu_ifu_trap_tid_w1), // Templated
            .tlu_full_flush_pipe_w2(`SPARC_CORE2.sparc0.tlu.tlu.tlu_full_flush_pipe_w2), // Templated
            .rtl_pcr0       (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pcr0), // Templated
            .rtl_pcr1       (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pcr1), // Templated
            .rtl_pcr2       (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pcr2), // Templated
            .rtl_pcr3       (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pcr3), // Templated
            .rtl_pich_cnt0  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pich_cnt0), // Templated
            .rtl_pich_cnt1  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pich_cnt1), // Templated
            .rtl_pich_cnt2  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pich_cnt2), // Templated
            .rtl_pich_cnt3  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.pich_cnt3), // Templated
            .rtl_picl_cnt0  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.picl_cnt0), // Templated
            .rtl_picl_cnt1  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.picl_cnt1), // Templated
            .rtl_picl_cnt2  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.picl_cnt2), // Templated
            .rtl_picl_cnt3  (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.picl_cnt3), // Templated
            .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .rtl_fpu_cmplt_thread(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.fpu_cmplt_thread), // Templated
            .rtl_imiss_thread_g (`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.imiss_thread_g), // Templated
            .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .rtl_immu_miss_thread_g(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.immu_miss_thread_g), // Templated
            .rtl_dmmu_miss_thread_g(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
            .rtl_ifu_tlu_l2imiss(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE2.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .true_pil0      (`SPARC_CORE2.sparc0.tlu.tlu.tcl.true_pil0), // Templated
            .true_pil1      (`SPARC_CORE2.sparc0.tlu.tlu.tcl.true_pil1), // Templated
            .true_pil2      (`SPARC_CORE2.sparc0.tlu.tlu.tcl.true_pil2), // Templated
            .true_pil3      (`SPARC_CORE2.sparc0.tlu.tlu.tcl.true_pil3), // Templated
            .rtl_trp_lvl0   (`SPARC_CORE2.sparc0.tlu.tlu.tcl.trp_lvl0), // Templated
            .rtl_trp_lvl1   (`SPARC_CORE2.sparc0.tlu.tlu.tcl.trp_lvl1), // Templated
            .rtl_trp_lvl2   (`SPARC_CORE2.sparc0.tlu.tlu.tcl.trp_lvl2), // Templated
            .rtl_trp_lvl3   (`SPARC_CORE2.sparc0.tlu.tlu.tcl.trp_lvl3), // Templated
            .tlz_thread     (`SPARC_CORE2.sparc0.tlu.tlu.tcl.tlz_thread), // Templated
            .th0_sftint_15  (`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint0[15]), // Templated
            .th1_sftint_15  (`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint1[15]), // Templated
            .th2_sftint_15  (`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint2[15]), // Templated
            .th3_sftint_15  (`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint3[15]), // Templated
            .ifu_swint_g    (`SPARC_CORE2.sparc0.tlu.tlu.tcl.swint_g), // Templated
    `else
		    .ifu_tlu_thrid_d	(`SPARC_CORE2.sparc0.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`SPARC_CORE2.sparc0.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`SPARC_CORE2.sparc0.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`SPARC_CORE2.sparc0.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`SPARC_CORE2.sparc0.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`SPARC_CORE2.sparc0.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`SPARC_CORE2.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`SPARC_CORE2.sparc0.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`SPARC_CORE2.sparc0.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`SPARC_CORE2.sparc0.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`SPARC_CORE2.sparc0.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`SPARC_CORE2.sparc0.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`SPARC_CORE2.sparc0.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`SPARC_CORE2.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`SPARC_CORE2.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`SPARC_CORE2.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`SPARC_CORE2.sparc0.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`SPARC_CORE2.sparc0.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`SPARC_CORE2.sparc0.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`SPARC_CORE2.sparc0.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`SPARC_CORE2.sparc0.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`SPARC_CORE2.sparc0.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`SPARC_CORE2.sparc0.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`SPARC_CORE2.sparc0.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`SPARC_CORE2.sparc0.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE2.sparc0.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`SPARC_CORE2.sparc0.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`SPARC_CORE2.sparc0.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`SPARC_CORE2.sparc0.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`SPARC_CORE2.sparc0.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`SPARC_CORE2.sparc0.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`SPARC_CORE2.sparc0.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`SPARC_CORE2.sparc0.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`SPARC_CORE2.sparc0.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`SPARC_CORE2.sparc0.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`SPARC_CORE2.sparc0.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`SPARC_CORE2.sparc0.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`SPARC_CORE2.sparc0.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`SPARC_CORE2.sparc0.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`SPARC_CORE2.sparc0.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`SPARC_CORE2.sparc0.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`SPARC_CORE2.sparc0.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`SPARC_CORE2.sparc0.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`SPARC_CORE2.sparc0.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`SPARC_CORE2.sparc0.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`SPARC_CORE2.sparc0.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`SPARC_CORE2.sparc0.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`SPARC_CORE2.sparc0.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`SPARC_CORE2.sparc0.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`SPARC_CORE2.sparc0.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE2.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`SPARC_CORE2.sparc0.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`SPARC_CORE2.sparc0.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE2.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`SPARC_CORE2.sparc0.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`SPARC_CORE2.sparc0.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`SPARC_CORE2.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE2.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`SPARC_CORE2.sparc0.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`SPARC_CORE2.sparc0.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`SPARC_CORE2.sparc0.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`SPARC_CORE2.sparc0.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`SPARC_CORE2.sparc0.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`SPARC_CORE2.sparc0.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`SPARC_CORE2.sparc0.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`SPARC_CORE2.sparc0.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`SPARC_CORE2.sparc0.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`SPARC_CORE2.sparc0.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`SPARC_CORE2.sparc0.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`SPARC_CORE2.sparc0.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`SPARC_CORE2.sparc0.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`SPARC_CORE2.sparc0.tlu.tcl.swint_g), // Templated
    `endif
		    .core_id		(10'd2),			 // Templated
    `ifndef RTL_SPU
            .tlu_itlb_wr_vld_g  (`SPARC_CORE2.sparc0.tlu.tlu_itlb_wr_vld_g), // Templated
            .tlu_itlb_dmp_vld_g (`SPARC_CORE2.sparc0.tlu.tlu_itlb_dmp_vld_g), // Templated
            .tlu_itlb_tte_tag_w2(`SPARC_CORE2.sparc0.tlu.tlu_itlb_tte_tag_w2), // Templated
            .tlu_itlb_tte_data_w2(`SPARC_CORE2.sparc0.tlu.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE2.sparc0.ifu.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE2.sparc0.lsu.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE2.sparc0.tlu.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE2.sparc0.tlu.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `else
		    .tlu_itlb_wr_vld_g	(`SPARC_CORE2.sparc0.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`SPARC_CORE2.sparc0.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`SPARC_CORE2.sparc0.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`SPARC_CORE2.sparc0.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE2.sparc0.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE2.sparc0.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE2.sparc0.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE2.sparc0.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `endif
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon2 (/*AUTOINST*/
			      // Inputs
    `ifndef RTL_SPU
                  .rtl_softint0(`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint0), // Templated
                  .rtl_softint1(`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint1), // Templated
                  .rtl_softint2(`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint2), // Templated
                  .rtl_softint3(`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint3), // Templated
                  .rtl_wsr_data_w(`SPARC_CORE2.sparc0.tlu.tlu.tdp.wsr_data_w), // Templated
                  .rtl_sftint_en_l_g(`SPARC_CORE2.sparc0.tlu.tlu.tdp.tlu_sftint_en_l_g), // Templated
                  .rtl_sftint_b0_en(`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint_b0_en), // Templated
                  .rtl_tickcmp_int(`SPARC_CORE2.sparc0.tlu.tlu.tdp.tickcmp_int), // Templated
                  .rtl_sftint_b16_en(`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint_b16_en), // Templated
                  .rtl_stickcmp_int(`SPARC_CORE2.sparc0.tlu.tlu.tdp.stickcmp_int), // Templated
                  .rtl_sftint_b15_en(`SPARC_CORE2.sparc0.tlu.tlu.tdp.sftint_b15_en), // Templated
                  .rtl_pib_picl_wrap(`SPARC_CORE2.sparc0.tlu.tlu.tdp.pib_picl_wrap), // Templated
                  .rtl_pib_pich_wrap(`SPARC_CORE2.sparc0.tlu.tlu.tdp.pib_pich_wrap), // Templated
                  .rtl_wr_sftint_l_g(`SPARC_CORE2.sparc0.tlu.tlu.tdp.tlu_wr_sftint_l_g), // Templated
                  .rtl_set_sftint_l_g(`SPARC_CORE2.sparc0.tlu.tlu.tdp.tlu_set_sftint_l_g), // Templated
                  .rtl_clr_sftint_l_g(`SPARC_CORE2.sparc0.tlu.tlu.tdp.tlu_clr_sftint_l_g), // Templated
                  .rtl_clk  (`SPARC_CORE2.sparc0.tlu.tlu.tdp.rclk), // Templated
                  .rtl_reset(`SPARC_CORE2.sparc0.tlu.tlu.tdp.tlu_rst), // Templated
    `else
			      .rtl_softint0(`SPARC_CORE2.sparc0.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`SPARC_CORE2.sparc0.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`SPARC_CORE2.sparc0.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`SPARC_CORE2.sparc0.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`SPARC_CORE2.sparc0.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`SPARC_CORE2.sparc0.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`SPARC_CORE2.sparc0.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`SPARC_CORE2.sparc0.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`SPARC_CORE2.sparc0.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`SPARC_CORE2.sparc0.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`SPARC_CORE2.sparc0.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`SPARC_CORE2.sparc0.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`SPARC_CORE2.sparc0.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`SPARC_CORE2.sparc0.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`SPARC_CORE2.sparc0.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`SPARC_CORE2.sparc0.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`SPARC_CORE2.sparc0.tlu.tdp.rclk), // Templated
			      .rtl_reset(`SPARC_CORE2.sparc0.tlu.tdp.tlu_rst), // Templated
    `endif
			      .core_id	(10'd2));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon2(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
`ifndef RTL_SPU
                .thr_state0 (`SPARC_CORE2.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
                .thr_state1 (`SPARC_CORE2.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
                .thr_state2 (`SPARC_CORE2.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
                .thr_state3 (`SPARC_CORE2.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
                .rstthr (`SPARC_CORE2.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
                .nukeint    (`SPARC_CORE2.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
                .resumint   (`SPARC_CORE2.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
                .rstint (`SPARC_CORE2.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`else
			    .thr_state0	(`SPARC_CORE2.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
			    .thr_state1	(`SPARC_CORE2.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
			    .thr_state2	(`SPARC_CORE2.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
			    .thr_state3	(`SPARC_CORE2.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
			    .rstthr	(`SPARC_CORE2.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			    .nukeint	(`SPARC_CORE2.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
			    .resumint	(`SPARC_CORE2.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
			    .rstint	(`SPARC_CORE2.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`endif
			    .coreid	(10'd2));			 // Templated
   mask_mon mask_mon2(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
`ifndef RTL_SPU
              .wm_imiss     (`SPARC_CORE2.sparc0.ifu.ifu.swl.wm_imiss), // Templated
              .wm_other     (`SPARC_CORE2.sparc0.ifu.ifu.swl.wm_other), // Templated
              .wm_stbwait   (`SPARC_CORE2.sparc0.ifu.ifu.swl.wm_stbwait), // Templated
              .mul_wait     (`SPARC_CORE2.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait     (`SPARC_CORE2.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait      (`SPARC_CORE2.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_busy_e   (`SPARC_CORE2.sparc0.ifu.ifu.swl.mul_busy_e), // Templated
              .div_busy_e   (`SPARC_CORE2.sparc0.ifu.ifu.swl.div_busy_e), // Templated
              .fp_busy_e    (`SPARC_CORE2.sparc0.ifu.ifu.swl.fp_busy_e), // Templated
              .ldmiss       (`SPARC_CORE2.sparc0.ifu.ifu.swl.ldmiss), // Templated
`else
		      .wm_imiss		(`SPARC_CORE2.sparc0.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`SPARC_CORE2.sparc0.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`SPARC_CORE2.sparc0.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`SPARC_CORE2.sparc0.ifu.swl.mul_wait), // Templated
		      .div_wait		(`SPARC_CORE2.sparc0.ifu.swl.div_wait), // Templated
		      .fp_wait		(`SPARC_CORE2.sparc0.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`SPARC_CORE2.sparc0.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`SPARC_CORE2.sparc0.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`SPARC_CORE2.sparc0.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`SPARC_CORE2.sparc0.ifu.swl.ldmiss), // Templated
`endif
		      .coreid		(10'd2));			 // Templated
   pc_muxsel_mon pc_muxsel_mon2(/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
`ifndef RTL_SPU
                .t0pc_f (`SPARC_CORE2.sparc0.ifu.ifu.fdp.t0pc_f[47:0]), // Templated
                .t1pc_f (`SPARC_CORE2.sparc0.ifu.ifu.fdp.t1pc_f[47:0]), // Templated
                .t2pc_f (`SPARC_CORE2.sparc0.ifu.ifu.fdp.t2pc_f[47:0]), // Templated
                .t3pc_f (`SPARC_CORE2.sparc0.ifu.ifu.fdp.t3pc_f[47:0]), // Templated
                .pc_f   (`SPARC_CORE2.sparc0.ifu.ifu.fdp.pc_f[47:0]), // Templated
                .inst_vld_f(`SPARC_CORE2.sparc0.ifu.ifu.fcl.inst_vld_f), // Templated
                .dtu_fcl_running_s(`SPARC_CORE2.sparc0.ifu.ifu.dtu_fcl_running_s), // Templated
                .thr_f  (`SPARC_CORE2.sparc0.ifu.ifu.fcl.thr_f[3:0]), // Templated
`else
				.t0pc_f	(`SPARC_CORE2.sparc0.ifu.fdp.t0pc_f[47:0]), // Templated
				.t1pc_f	(`SPARC_CORE2.sparc0.ifu.fdp.t1pc_f[47:0]), // Templated
				.t2pc_f	(`SPARC_CORE2.sparc0.ifu.fdp.t2pc_f[47:0]), // Templated
				.t3pc_f	(`SPARC_CORE2.sparc0.ifu.fdp.t3pc_f[47:0]), // Templated
				.pc_f	(`SPARC_CORE2.sparc0.ifu.fdp.pc_f[47:0]), // Templated
				.inst_vld_f(`SPARC_CORE2.sparc0.ifu.fcl.inst_vld_f), // Templated
				.dtu_fcl_running_s(`SPARC_CORE2.sparc0.ifu.dtu_fcl_running_s), // Templated
				.thr_f	(`SPARC_CORE2.sparc0.ifu.fcl.thr_f[3:0]), // Templated
`endif
				.coreid	(10'd2));			 // Templated
   stb_ovfl_mon stb_ovfl_mon2(/*AUTOINST*/
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
`ifndef RTL_SPU
                  .lsu_ifu_stbcnt3(`SPARC_CORE2.sparc0.ifu.ifu.lsu_ifu_stbcnt3), // Templated
                  .lsu_ifu_stbcnt2(`SPARC_CORE2.sparc0.ifu.ifu.lsu_ifu_stbcnt2), // Templated
                  .lsu_ifu_stbcnt1(`SPARC_CORE2.sparc0.ifu.ifu.lsu_ifu_stbcnt1), // Templated
                  .lsu_ifu_stbcnt0(`SPARC_CORE2.sparc0.ifu.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE2.sparc0.lsu.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE2.sparc0.lsu.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE2.sparc0.lsu.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE2.sparc0.lsu.lsu.stb_ctl0.reset), // Templated
`else
			      .lsu_ifu_stbcnt3(`SPARC_CORE2.sparc0.ifu.lsu_ifu_stbcnt3), // Templated
			      .lsu_ifu_stbcnt2(`SPARC_CORE2.sparc0.ifu.lsu_ifu_stbcnt2), // Templated
			      .lsu_ifu_stbcnt1(`SPARC_CORE2.sparc0.ifu.lsu_ifu_stbcnt1), // Templated
			      .lsu_ifu_stbcnt0(`SPARC_CORE2.sparc0.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE2.sparc0.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE2.sparc0.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE2.sparc0.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE2.sparc0.lsu.stb_ctl0.reset), // Templated
`endif
			      .coreid	(10'd2));			 // Templated
   icache_mutex_mon icache_mutex_mon2(/*AUTOINST*/
				      // Inputs
				      .clk(clk),
				      .rst_l(rst_l),
`ifndef RTL_SPU
                      .waysel_buf_s1(`SPARC_CORE2.sparc0.ifu.ifu.wseldp.waysel_buf_s1), // Templated
                      .alltag_err_s1(`SPARC_CORE2.sparc0.ifu.ifu.errctl.alltag_err_s1), // Templated
                      .tlb_cam_miss_s1(`SPARC_CORE2.sparc0.ifu.ifu.fcl.tlb_cam_miss_s1), // Templated
                      .cam_vld_s1(`SPARC_CORE2.sparc0.ifu.ifu.fcl.cam_vld_s1), // Templated
`else
				      .waysel_buf_s1(`SPARC_CORE2.sparc0.ifu.wseldp.waysel_buf_s1), // Templated
				      .alltag_err_s1(`SPARC_CORE2.sparc0.ifu.errctl.alltag_err_s1), // Templated
				      .tlb_cam_miss_s1(`SPARC_CORE2.sparc0.ifu.fcl.tlb_cam_miss_s1), // Templated
				      .cam_vld_s1(`SPARC_CORE2.sparc0.ifu.fcl.cam_vld_s1), // Templated
`endif
				      .coreid(10'd2));		 // Templated
   nc_inv_chk nc_inv_chk2(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .cpxpkt_vld   (`SPARC_CORE2.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
              .cpxpkt_rtntype(`SPARC_CORE2.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
              .nc       (`SPARC_CORE2.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
              .wv       (`SPARC_CORE2.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`else
			  .cpxpkt_vld	(`SPARC_CORE2.sparc0.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`SPARC_CORE2.sparc0.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`SPARC_CORE2.sparc0.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`SPARC_CORE2.sparc0.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`endif
			  .coreid	(10'd2));			 // Templated

       // trin: we don't have spu
       // spu_ma_mon spu_ma_mon2(/* AUTOINST*/
    			//   // Inputs
    			//   .clk		(clk),
    			//   .wrmi_mamul_1sthalf(`SPARC_CORE2.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    			//   .wrmi_mamul_2ndhalf(`SPARC_CORE2.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    			//   .wrmi_maaeqb_1sthalf(`SPARC_CORE2.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    			//   .wrmi_maaeqb_2ndhalf(`SPARC_CORE2.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    			//   .iptr		(`SPARC_CORE2.sparc0.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    			//   .iminus_lenminus1(`SPARC_CORE2.sparc0.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    			//   .mul_data	(`SPARC_CORE2.sparc0.spu.spu_madp.spu_madp_evedata[63:0]));


always @ (negedge clk)
begin
    // if (`SPARC_CORE2.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE2.sparc0.lsu.lsu.qctl2.dfq_inv_data_val === 1'bx))
    if (`SPARC_CORE2.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE2.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val === 1'bx))
    begin
        $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received X invalidation");
        `ifndef VERILATOR
        repeat(5)@(posedge clk);
        `endif
        `MONITOR_PATH.fail("TILE0 lsu received X invalidation");
    end

    // if (`SPARC_CORE2.sparc0.lsu.lsu.qctl2.dfq_inv_data_val)
    if (`SPARC_CORE2.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val)
    begin
        if (|`SPARC_CORE2.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_way === 1'bx)
        begin
            $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received invalid way invalidation");
            `ifndef VERILATOR
            repeat(5)@(posedge clk);
            `endif
            `MONITOR_PATH.fail("TILE0 lsu received invalid way invalidation");
        end
    end
end



    //   cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
    //				// Inputs
    //				.clk	(clk),
    //				.rst_l	(rst_l),
    //				.spc_pcx_data_pa(`PCXPATH2.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
    //				.cpx_spc_data_cx(`PCXPATH2.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
    //				.cpu	(0));
   `endif


   `ifdef RTL_SPARC3
   l_cache_mon l_cache_mon3(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(0),			 // Templated
			    .index_f	(`ICTPATH3.index_y[`IC_SET_IDX_HI:0]), // Templated
			    .wrreq_f	(`ICTPATH3.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH3.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH3.ifq_ict_wrtag_f[`IC_TAG_SZ:0]), // Templated
			    .wr_data	(`ICVPATH3.write_bit_y),	 // Templated
                // .wr_data    (`ICVPATH3.din_d1),  // Templated
			    .wren_f	(`ICVPATH3.write_mask_y[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH3.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH3.wr_adr[`IC_SET_IDX_HI:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH3.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH3.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`SPARC_CORE3.sparc0.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`SPARC_CORE3.sparc0.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon3(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .wm_imiss (`SPARC_CORE3.sparc0.ifu.ifu.swl.wm_imiss[3:0]), // Templated
              .wm_other (`SPARC_CORE3.sparc0.ifu.ifu.swl.wm_other[3:0]), // Templated
              .wm_stbwait   (`SPARC_CORE3.sparc0.ifu.ifu.swl.wm_stbwait[3:0]), // Templated
              .thr_state0   (`SPARC_CORE3.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
              .thr_state1   (`SPARC_CORE3.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
              .thr_state2   (`SPARC_CORE3.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
              .thr_state3   (`SPARC_CORE3.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
              .rst_stallreq (`SPARC_CORE3.sparc0.ifu.ifu.fcl.rst_stallreq), // Templated
              .ifq_fcl_stallreq(`SPARC_CORE3.sparc0.ifu.ifu.fcl.ifq_fcl_stallreq), // Templated
              .lsu_ifu_stallreq(`SPARC_CORE3.sparc0.ifu.ifu.fcl.lsu_ifu_stallreq), // Templated
              .ffu_ifu_stallreq(`SPARC_CORE3.sparc0.ifu.ifu.fcl.ffu_ifu_stallreq), // Templated
              .completion   (`SPARC_CORE3.sparc0.ifu.ifu.swl.completion), // Templated
              .mul_wait (`SPARC_CORE3.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait (`SPARC_CORE3.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait  (`SPARC_CORE3.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_wait_nxt (`SPARC_CORE3.sparc0.ifu.ifu.swl.mul_wait_nxt), // Templated
              .div_wait_nxt (`SPARC_CORE3.sparc0.ifu.ifu.swl.div_wait_nxt), // Templated
              .fp_wait_nxt  (`SPARC_CORE3.sparc0.ifu.ifu.swl.fp_wait_nxt), // Templated
              .mul_busy_d   (`SPARC_CORE3.sparc0.ifu.ifu.swl.mul_busy_d), // Templated
              .div_busy_d   (`SPARC_CORE3.sparc0.ifu.ifu.swl.div_busy_d), // Templated
              .fp_busy_d    (`SPARC_CORE3.sparc0.ifu.ifu.swl.fp_busy_d), // Templated
              .ifet_ue_vec_d1(`SPARC_CORE3.sparc0.ifu.ifu.fcl.ifet_ue_vec_d1), // Templated
`else
			  .wm_imiss	(`SPARC_CORE3.sparc0.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`SPARC_CORE3.sparc0.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`SPARC_CORE3.sparc0.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`SPARC_CORE3.sparc0.ifu.swl.thr0_state[4:0]), // Templated
			  .thr_state1	(`SPARC_CORE3.sparc0.ifu.swl.thr1_state[4:0]), // Templated
			  .thr_state2	(`SPARC_CORE3.sparc0.ifu.swl.thr2_state[4:0]), // Templated
			  .thr_state3	(`SPARC_CORE3.sparc0.ifu.swl.thr3_state[4:0]), // Templated
			  .rst_stallreq	(`SPARC_CORE3.sparc0.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`SPARC_CORE3.sparc0.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`SPARC_CORE3.sparc0.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`SPARC_CORE3.sparc0.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`SPARC_CORE3.sparc0.ifu.swl.completion), // Templated
			  .mul_wait	(`SPARC_CORE3.sparc0.ifu.swl.mul_wait), // Templated
			  .div_wait	(`SPARC_CORE3.sparc0.ifu.swl.div_wait), // Templated
			  .fp_wait	(`SPARC_CORE3.sparc0.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`SPARC_CORE3.sparc0.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`SPARC_CORE3.sparc0.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`SPARC_CORE3.sparc0.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`SPARC_CORE3.sparc0.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`SPARC_CORE3.sparc0.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`SPARC_CORE3.sparc0.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`SPARC_CORE3.sparc0.ifu.fcl.ifet_ue_vec_d1), // Templated
`endif
			  .cpu_id	(10'd3));			 // Templated
   exu_mon exu_mon3(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH3.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH3.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH3.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH3.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH3.irf.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH3.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH3.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon3(/*AUTOINST*/
		    // Inputs
    `ifndef RTL_SPU
            .clk        (`SPARC_CORE3.sparc0.tlu.tlu.rclk), // Templated
            .grst_l     (`SPARC_CORE3.sparc0.tlu.tlu.grst_l), // Templated
            .rst_l      (`SPARC_CORE3.sparc0.tlu.tlu.tcl.tlu_rst_l), // Templated
    `else
		    .clk		(`SPARC_CORE3.sparc0.tlu.rclk), // Templated
		    .grst_l		(`SPARC_CORE3.sparc0.tlu.grst_l), // Templated
		    .rst_l		(`SPARC_CORE3.sparc0.tlu.tcl.tlu_rst_l), // Templated
    `endif
			.lsu_ifu_flush_pipe_w	(`SPARC_CORE3.sparc0.lsu_ifu_flush_pipe_w),
    `ifndef RTL_SPU
            .tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE3.sparc0.tlu.tlu_lsu_int_ldxa_vld_w2),
            .tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE3.sparc0.tlu.tlu_lsu_int_ld_ill_va_w2),
            .tlu_scpd_wr_vld_g      (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
            .cpu_mondo_head_wr_g    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
            .cpu_mondo_tail_wr_g    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
            .dev_mondo_head_wr_g    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_head_wr_g),
            .dev_mondo_tail_wr_g    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
            .resum_err_head_wr_g    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.resum_err_head_wr_g),
            .resum_err_tail_wr_g    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.resum_err_tail_wr_g),
            .nresum_err_head_wr_g   (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.nresum_err_head_wr_g),
            .nresum_err_tail_wr_g   (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.nresum_err_tail_wr_g),
            .ifu_lsu_ld_inst_e      (`SPARC_CORE3.sparc0.tlu.tlu.ifu_lsu_ld_inst_e),
            .ifu_lsu_st_inst_e      (`SPARC_CORE3.sparc0.tlu.tlu.ifu_lsu_st_inst_e),
            .ifu_lsu_alt_space_e    (`SPARC_CORE3.sparc0.tlu.tlu.ifu_lsu_alt_space_e),
            .tlu_early_flush_pipe_w (`SPARC_CORE3.sparc0.tlu.tlu.tlu_early_flush_pipe_w),
            .tlu_asi_state_e        (`SPARC_CORE3.sparc0.tlu.tlu.tlu_asi_state_e),
            .exu_lsu_ldst_va_e      (`SPARC_CORE3.sparc0.tlu.tlu.exu_lsu_ldst_va_e),
            .por_rstint0_w2 (`SPARC_CORE3.sparc0.tlu.tlu.tcl.por_rstint0_w2),
            .por_rstint1_w2 (`SPARC_CORE3.sparc0.tlu.tlu.tcl.por_rstint1_w2),
            .por_rstint2_w2 (`SPARC_CORE3.sparc0.tlu.tlu.tcl.por_rstint2_w2),
            .por_rstint3_w2 (`SPARC_CORE3.sparc0.tlu.tlu.tcl.por_rstint3_w2),
            .tlu_gl_lvl0    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.gl_lvl0),
            .tlu_gl_lvl1    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.gl_lvl1),
            .tlu_gl_lvl2    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.gl_lvl2),
            .tlu_gl_lvl3    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hyperv.gl_lvl3),
    `else
			.tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE3.sparc0.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE3.sparc0.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`SPARC_CORE3.sparc0.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`SPARC_CORE3.sparc0.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`SPARC_CORE3.sparc0.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`SPARC_CORE3.sparc0.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`SPARC_CORE3.sparc0.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`SPARC_CORE3.sparc0.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`SPARC_CORE3.sparc0.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`SPARC_CORE3.sparc0.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`SPARC_CORE3.sparc0.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`SPARC_CORE3.sparc0.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`SPARC_CORE3.sparc0.tlu.tlu_hyperv.gl_lvl3),
    `endif
            .exu_gl_lvl0	(`SPARC_CORE3.sparc0.exu.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`SPARC_CORE3.sparc0.exu.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`SPARC_CORE3.sparc0.exu.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`SPARC_CORE3.sparc0.exu.exu.rml.agp_thr3_next),
    `ifndef RTL_SPU
            .ifu_tlu_thrid_d    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
            .ifu_tlu_inst_vld_m (`SPARC_CORE3.sparc0.tlu.tlu.ifu_tlu_inst_vld_m), // Templated
            .ifu_tlu_imiss_e    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
            .ifu_tlu_immu_miss_m(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
            .tlu_thread_inst_vld_g(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
            .tlu_thread_wsel_g  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
            .ifu_tlu_l2imiss    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .ifu_tlu_flush_fd_w (`SPARC_CORE3.sparc0.tlu.tlu.ifu_tlu_flush_fd_w), // Templated
            .ifu_tlu_sraddr_d   (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
            .ifu_tlu_rsr_inst_d (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
            .lsu_tlu_wsr_inst_e (`SPARC_CORE3.sparc0.tlu.tlu.lsu_tlu_wsr_inst_e), // Templated
            .tlu_wsr_inst_nq_g  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
            .tlu_wsr_data_w (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.tlu_wsr_data_w), // Templated
            .lsu_tlu_dcache_miss_w2(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .lsu_tlu_l2_dmiss   (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .lsu_tlu_stb_full_w2(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .lsu_tlu_dmmu_miss_g(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
            .ffu_tlu_fpu_tid    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
            .ffu_tlu_fpu_cmplt  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
            .tlu_pstate_priv    (`SPARC_CORE3.sparc0.tlu.tlu.local_pstate_priv), // Templated
            .tlu_hpstate_priv   (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hpstate_priv), // Templated
            .tlu_hpstate_enb    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_hpstate_enb), // Templated
            .tlu_pstate_ie  (`SPARC_CORE3.sparc0.tlu.tlu.local_pstate_ie), // Templated
            .wsr_thread_inst_g  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.wsr_thread_inst_g), // Templated
            .lsu_tlu_defr_trp_taken_g(`SPARC_CORE3.sparc0.tlu.tlu.lsu_tlu_defr_trp_taken_g), // Templated
            .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE3.sparc0.tlu.tlu.lsu_tlu_async_ttype_vld_g), // Templated
            .lsu_tlu_ttype_vld_m2(`SPARC_CORE3.sparc0.tlu.tlu.lsu_tlu_ttype_vld_m2), // Templated
            .tlu_ifu_flush_pipe_w(`SPARC_CORE3.sparc0.tlu.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
            .tcc_inst_w2    (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.tcc_inst_w2), // Templated
            .tlu_pib_rsr_data_e (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
            .tlu_pib_priv_act_trap_m(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
            .tlu_pib_picl_wrap  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pib_picl_wrap), // Templated
            .tlu_pib_pich_wrap  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pich_onebelow_flg), // Templated
            .tlu_ifu_trappc_vld_w1(`SPARC_CORE3.sparc0.tlu.tlu.tlu_ifu_trappc_vld_w1), // Templated
            .tlu_ifu_trappc_w2  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_ifu_trappc_w2), // Templated
            .tlu_final_ttype_w2 (`SPARC_CORE3.sparc0.tlu.tlu.tlu_final_ttype_w2), // Templated
            .tlu_ifu_trap_tid_w1(`SPARC_CORE3.sparc0.tlu.tlu.tlu_ifu_trap_tid_w1), // Templated
            .tlu_full_flush_pipe_w2(`SPARC_CORE3.sparc0.tlu.tlu.tlu_full_flush_pipe_w2), // Templated
            .rtl_pcr0       (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pcr0), // Templated
            .rtl_pcr1       (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pcr1), // Templated
            .rtl_pcr2       (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pcr2), // Templated
            .rtl_pcr3       (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pcr3), // Templated
            .rtl_pich_cnt0  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pich_cnt0), // Templated
            .rtl_pich_cnt1  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pich_cnt1), // Templated
            .rtl_pich_cnt2  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pich_cnt2), // Templated
            .rtl_pich_cnt3  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.pich_cnt3), // Templated
            .rtl_picl_cnt0  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.picl_cnt0), // Templated
            .rtl_picl_cnt1  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.picl_cnt1), // Templated
            .rtl_picl_cnt2  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.picl_cnt2), // Templated
            .rtl_picl_cnt3  (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.picl_cnt3), // Templated
            .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .rtl_fpu_cmplt_thread(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.fpu_cmplt_thread), // Templated
            .rtl_imiss_thread_g (`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.imiss_thread_g), // Templated
            .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .rtl_immu_miss_thread_g(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.immu_miss_thread_g), // Templated
            .rtl_dmmu_miss_thread_g(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
            .rtl_ifu_tlu_l2imiss(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE3.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .true_pil0      (`SPARC_CORE3.sparc0.tlu.tlu.tcl.true_pil0), // Templated
            .true_pil1      (`SPARC_CORE3.sparc0.tlu.tlu.tcl.true_pil1), // Templated
            .true_pil2      (`SPARC_CORE3.sparc0.tlu.tlu.tcl.true_pil2), // Templated
            .true_pil3      (`SPARC_CORE3.sparc0.tlu.tlu.tcl.true_pil3), // Templated
            .rtl_trp_lvl0   (`SPARC_CORE3.sparc0.tlu.tlu.tcl.trp_lvl0), // Templated
            .rtl_trp_lvl1   (`SPARC_CORE3.sparc0.tlu.tlu.tcl.trp_lvl1), // Templated
            .rtl_trp_lvl2   (`SPARC_CORE3.sparc0.tlu.tlu.tcl.trp_lvl2), // Templated
            .rtl_trp_lvl3   (`SPARC_CORE3.sparc0.tlu.tlu.tcl.trp_lvl3), // Templated
            .tlz_thread     (`SPARC_CORE3.sparc0.tlu.tlu.tcl.tlz_thread), // Templated
            .th0_sftint_15  (`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint0[15]), // Templated
            .th1_sftint_15  (`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint1[15]), // Templated
            .th2_sftint_15  (`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint2[15]), // Templated
            .th3_sftint_15  (`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint3[15]), // Templated
            .ifu_swint_g    (`SPARC_CORE3.sparc0.tlu.tlu.tcl.swint_g), // Templated
    `else
		    .ifu_tlu_thrid_d	(`SPARC_CORE3.sparc0.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`SPARC_CORE3.sparc0.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`SPARC_CORE3.sparc0.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`SPARC_CORE3.sparc0.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`SPARC_CORE3.sparc0.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`SPARC_CORE3.sparc0.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`SPARC_CORE3.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`SPARC_CORE3.sparc0.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`SPARC_CORE3.sparc0.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`SPARC_CORE3.sparc0.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`SPARC_CORE3.sparc0.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`SPARC_CORE3.sparc0.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`SPARC_CORE3.sparc0.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`SPARC_CORE3.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`SPARC_CORE3.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`SPARC_CORE3.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`SPARC_CORE3.sparc0.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`SPARC_CORE3.sparc0.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`SPARC_CORE3.sparc0.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`SPARC_CORE3.sparc0.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`SPARC_CORE3.sparc0.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`SPARC_CORE3.sparc0.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`SPARC_CORE3.sparc0.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`SPARC_CORE3.sparc0.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`SPARC_CORE3.sparc0.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE3.sparc0.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`SPARC_CORE3.sparc0.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`SPARC_CORE3.sparc0.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`SPARC_CORE3.sparc0.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`SPARC_CORE3.sparc0.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`SPARC_CORE3.sparc0.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`SPARC_CORE3.sparc0.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`SPARC_CORE3.sparc0.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`SPARC_CORE3.sparc0.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`SPARC_CORE3.sparc0.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`SPARC_CORE3.sparc0.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`SPARC_CORE3.sparc0.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`SPARC_CORE3.sparc0.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`SPARC_CORE3.sparc0.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`SPARC_CORE3.sparc0.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`SPARC_CORE3.sparc0.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`SPARC_CORE3.sparc0.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`SPARC_CORE3.sparc0.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`SPARC_CORE3.sparc0.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`SPARC_CORE3.sparc0.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`SPARC_CORE3.sparc0.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`SPARC_CORE3.sparc0.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`SPARC_CORE3.sparc0.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`SPARC_CORE3.sparc0.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`SPARC_CORE3.sparc0.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE3.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`SPARC_CORE3.sparc0.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`SPARC_CORE3.sparc0.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE3.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`SPARC_CORE3.sparc0.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`SPARC_CORE3.sparc0.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`SPARC_CORE3.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE3.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`SPARC_CORE3.sparc0.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`SPARC_CORE3.sparc0.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`SPARC_CORE3.sparc0.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`SPARC_CORE3.sparc0.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`SPARC_CORE3.sparc0.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`SPARC_CORE3.sparc0.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`SPARC_CORE3.sparc0.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`SPARC_CORE3.sparc0.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`SPARC_CORE3.sparc0.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`SPARC_CORE3.sparc0.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`SPARC_CORE3.sparc0.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`SPARC_CORE3.sparc0.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`SPARC_CORE3.sparc0.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`SPARC_CORE3.sparc0.tlu.tcl.swint_g), // Templated
    `endif
		    .core_id		(10'd3),			 // Templated
    `ifndef RTL_SPU
            .tlu_itlb_wr_vld_g  (`SPARC_CORE3.sparc0.tlu.tlu_itlb_wr_vld_g), // Templated
            .tlu_itlb_dmp_vld_g (`SPARC_CORE3.sparc0.tlu.tlu_itlb_dmp_vld_g), // Templated
            .tlu_itlb_tte_tag_w2(`SPARC_CORE3.sparc0.tlu.tlu_itlb_tte_tag_w2), // Templated
            .tlu_itlb_tte_data_w2(`SPARC_CORE3.sparc0.tlu.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE3.sparc0.ifu.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE3.sparc0.lsu.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE3.sparc0.tlu.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE3.sparc0.tlu.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `else
		    .tlu_itlb_wr_vld_g	(`SPARC_CORE3.sparc0.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`SPARC_CORE3.sparc0.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`SPARC_CORE3.sparc0.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`SPARC_CORE3.sparc0.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE3.sparc0.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE3.sparc0.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE3.sparc0.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE3.sparc0.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `endif
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon3 (/*AUTOINST*/
			      // Inputs
    `ifndef RTL_SPU
                  .rtl_softint0(`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint0), // Templated
                  .rtl_softint1(`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint1), // Templated
                  .rtl_softint2(`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint2), // Templated
                  .rtl_softint3(`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint3), // Templated
                  .rtl_wsr_data_w(`SPARC_CORE3.sparc0.tlu.tlu.tdp.wsr_data_w), // Templated
                  .rtl_sftint_en_l_g(`SPARC_CORE3.sparc0.tlu.tlu.tdp.tlu_sftint_en_l_g), // Templated
                  .rtl_sftint_b0_en(`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint_b0_en), // Templated
                  .rtl_tickcmp_int(`SPARC_CORE3.sparc0.tlu.tlu.tdp.tickcmp_int), // Templated
                  .rtl_sftint_b16_en(`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint_b16_en), // Templated
                  .rtl_stickcmp_int(`SPARC_CORE3.sparc0.tlu.tlu.tdp.stickcmp_int), // Templated
                  .rtl_sftint_b15_en(`SPARC_CORE3.sparc0.tlu.tlu.tdp.sftint_b15_en), // Templated
                  .rtl_pib_picl_wrap(`SPARC_CORE3.sparc0.tlu.tlu.tdp.pib_picl_wrap), // Templated
                  .rtl_pib_pich_wrap(`SPARC_CORE3.sparc0.tlu.tlu.tdp.pib_pich_wrap), // Templated
                  .rtl_wr_sftint_l_g(`SPARC_CORE3.sparc0.tlu.tlu.tdp.tlu_wr_sftint_l_g), // Templated
                  .rtl_set_sftint_l_g(`SPARC_CORE3.sparc0.tlu.tlu.tdp.tlu_set_sftint_l_g), // Templated
                  .rtl_clr_sftint_l_g(`SPARC_CORE3.sparc0.tlu.tlu.tdp.tlu_clr_sftint_l_g), // Templated
                  .rtl_clk  (`SPARC_CORE3.sparc0.tlu.tlu.tdp.rclk), // Templated
                  .rtl_reset(`SPARC_CORE3.sparc0.tlu.tlu.tdp.tlu_rst), // Templated
    `else
			      .rtl_softint0(`SPARC_CORE3.sparc0.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`SPARC_CORE3.sparc0.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`SPARC_CORE3.sparc0.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`SPARC_CORE3.sparc0.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`SPARC_CORE3.sparc0.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`SPARC_CORE3.sparc0.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`SPARC_CORE3.sparc0.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`SPARC_CORE3.sparc0.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`SPARC_CORE3.sparc0.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`SPARC_CORE3.sparc0.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`SPARC_CORE3.sparc0.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`SPARC_CORE3.sparc0.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`SPARC_CORE3.sparc0.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`SPARC_CORE3.sparc0.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`SPARC_CORE3.sparc0.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`SPARC_CORE3.sparc0.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`SPARC_CORE3.sparc0.tlu.tdp.rclk), // Templated
			      .rtl_reset(`SPARC_CORE3.sparc0.tlu.tdp.tlu_rst), // Templated
    `endif
			      .core_id	(10'd3));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon3(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
`ifndef RTL_SPU
                .thr_state0 (`SPARC_CORE3.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
                .thr_state1 (`SPARC_CORE3.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
                .thr_state2 (`SPARC_CORE3.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
                .thr_state3 (`SPARC_CORE3.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
                .rstthr (`SPARC_CORE3.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
                .nukeint    (`SPARC_CORE3.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
                .resumint   (`SPARC_CORE3.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
                .rstint (`SPARC_CORE3.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`else
			    .thr_state0	(`SPARC_CORE3.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
			    .thr_state1	(`SPARC_CORE3.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
			    .thr_state2	(`SPARC_CORE3.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
			    .thr_state3	(`SPARC_CORE3.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
			    .rstthr	(`SPARC_CORE3.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			    .nukeint	(`SPARC_CORE3.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
			    .resumint	(`SPARC_CORE3.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
			    .rstint	(`SPARC_CORE3.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`endif
			    .coreid	(10'd3));			 // Templated
   mask_mon mask_mon3(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
`ifndef RTL_SPU
              .wm_imiss     (`SPARC_CORE3.sparc0.ifu.ifu.swl.wm_imiss), // Templated
              .wm_other     (`SPARC_CORE3.sparc0.ifu.ifu.swl.wm_other), // Templated
              .wm_stbwait   (`SPARC_CORE3.sparc0.ifu.ifu.swl.wm_stbwait), // Templated
              .mul_wait     (`SPARC_CORE3.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait     (`SPARC_CORE3.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait      (`SPARC_CORE3.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_busy_e   (`SPARC_CORE3.sparc0.ifu.ifu.swl.mul_busy_e), // Templated
              .div_busy_e   (`SPARC_CORE3.sparc0.ifu.ifu.swl.div_busy_e), // Templated
              .fp_busy_e    (`SPARC_CORE3.sparc0.ifu.ifu.swl.fp_busy_e), // Templated
              .ldmiss       (`SPARC_CORE3.sparc0.ifu.ifu.swl.ldmiss), // Templated
`else
		      .wm_imiss		(`SPARC_CORE3.sparc0.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`SPARC_CORE3.sparc0.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`SPARC_CORE3.sparc0.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`SPARC_CORE3.sparc0.ifu.swl.mul_wait), // Templated
		      .div_wait		(`SPARC_CORE3.sparc0.ifu.swl.div_wait), // Templated
		      .fp_wait		(`SPARC_CORE3.sparc0.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`SPARC_CORE3.sparc0.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`SPARC_CORE3.sparc0.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`SPARC_CORE3.sparc0.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`SPARC_CORE3.sparc0.ifu.swl.ldmiss), // Templated
`endif
		      .coreid		(10'd3));			 // Templated
   pc_muxsel_mon pc_muxsel_mon3(/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
`ifndef RTL_SPU
                .t0pc_f (`SPARC_CORE3.sparc0.ifu.ifu.fdp.t0pc_f[47:0]), // Templated
                .t1pc_f (`SPARC_CORE3.sparc0.ifu.ifu.fdp.t1pc_f[47:0]), // Templated
                .t2pc_f (`SPARC_CORE3.sparc0.ifu.ifu.fdp.t2pc_f[47:0]), // Templated
                .t3pc_f (`SPARC_CORE3.sparc0.ifu.ifu.fdp.t3pc_f[47:0]), // Templated
                .pc_f   (`SPARC_CORE3.sparc0.ifu.ifu.fdp.pc_f[47:0]), // Templated
                .inst_vld_f(`SPARC_CORE3.sparc0.ifu.ifu.fcl.inst_vld_f), // Templated
                .dtu_fcl_running_s(`SPARC_CORE3.sparc0.ifu.ifu.dtu_fcl_running_s), // Templated
                .thr_f  (`SPARC_CORE3.sparc0.ifu.ifu.fcl.thr_f[3:0]), // Templated
`else
				.t0pc_f	(`SPARC_CORE3.sparc0.ifu.fdp.t0pc_f[47:0]), // Templated
				.t1pc_f	(`SPARC_CORE3.sparc0.ifu.fdp.t1pc_f[47:0]), // Templated
				.t2pc_f	(`SPARC_CORE3.sparc0.ifu.fdp.t2pc_f[47:0]), // Templated
				.t3pc_f	(`SPARC_CORE3.sparc0.ifu.fdp.t3pc_f[47:0]), // Templated
				.pc_f	(`SPARC_CORE3.sparc0.ifu.fdp.pc_f[47:0]), // Templated
				.inst_vld_f(`SPARC_CORE3.sparc0.ifu.fcl.inst_vld_f), // Templated
				.dtu_fcl_running_s(`SPARC_CORE3.sparc0.ifu.dtu_fcl_running_s), // Templated
				.thr_f	(`SPARC_CORE3.sparc0.ifu.fcl.thr_f[3:0]), // Templated
`endif
				.coreid	(10'd3));			 // Templated
   stb_ovfl_mon stb_ovfl_mon3(/*AUTOINST*/
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
`ifndef RTL_SPU
                  .lsu_ifu_stbcnt3(`SPARC_CORE3.sparc0.ifu.ifu.lsu_ifu_stbcnt3), // Templated
                  .lsu_ifu_stbcnt2(`SPARC_CORE3.sparc0.ifu.ifu.lsu_ifu_stbcnt2), // Templated
                  .lsu_ifu_stbcnt1(`SPARC_CORE3.sparc0.ifu.ifu.lsu_ifu_stbcnt1), // Templated
                  .lsu_ifu_stbcnt0(`SPARC_CORE3.sparc0.ifu.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE3.sparc0.lsu.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE3.sparc0.lsu.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE3.sparc0.lsu.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE3.sparc0.lsu.lsu.stb_ctl0.reset), // Templated
`else
			      .lsu_ifu_stbcnt3(`SPARC_CORE3.sparc0.ifu.lsu_ifu_stbcnt3), // Templated
			      .lsu_ifu_stbcnt2(`SPARC_CORE3.sparc0.ifu.lsu_ifu_stbcnt2), // Templated
			      .lsu_ifu_stbcnt1(`SPARC_CORE3.sparc0.ifu.lsu_ifu_stbcnt1), // Templated
			      .lsu_ifu_stbcnt0(`SPARC_CORE3.sparc0.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE3.sparc0.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE3.sparc0.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE3.sparc0.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE3.sparc0.lsu.stb_ctl0.reset), // Templated
`endif
			      .coreid	(10'd3));			 // Templated
   icache_mutex_mon icache_mutex_mon3(/*AUTOINST*/
				      // Inputs
				      .clk(clk),
				      .rst_l(rst_l),
`ifndef RTL_SPU
                      .waysel_buf_s1(`SPARC_CORE3.sparc0.ifu.ifu.wseldp.waysel_buf_s1), // Templated
                      .alltag_err_s1(`SPARC_CORE3.sparc0.ifu.ifu.errctl.alltag_err_s1), // Templated
                      .tlb_cam_miss_s1(`SPARC_CORE3.sparc0.ifu.ifu.fcl.tlb_cam_miss_s1), // Templated
                      .cam_vld_s1(`SPARC_CORE3.sparc0.ifu.ifu.fcl.cam_vld_s1), // Templated
`else
				      .waysel_buf_s1(`SPARC_CORE3.sparc0.ifu.wseldp.waysel_buf_s1), // Templated
				      .alltag_err_s1(`SPARC_CORE3.sparc0.ifu.errctl.alltag_err_s1), // Templated
				      .tlb_cam_miss_s1(`SPARC_CORE3.sparc0.ifu.fcl.tlb_cam_miss_s1), // Templated
				      .cam_vld_s1(`SPARC_CORE3.sparc0.ifu.fcl.cam_vld_s1), // Templated
`endif
				      .coreid(10'd3));		 // Templated
   nc_inv_chk nc_inv_chk3(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .cpxpkt_vld   (`SPARC_CORE3.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
              .cpxpkt_rtntype(`SPARC_CORE3.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
              .nc       (`SPARC_CORE3.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
              .wv       (`SPARC_CORE3.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`else
			  .cpxpkt_vld	(`SPARC_CORE3.sparc0.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`SPARC_CORE3.sparc0.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`SPARC_CORE3.sparc0.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`SPARC_CORE3.sparc0.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`endif
			  .coreid	(10'd3));			 // Templated

       // trin: we don't have spu
       // spu_ma_mon spu_ma_mon3(/* AUTOINST*/
    			//   // Inputs
    			//   .clk		(clk),
    			//   .wrmi_mamul_1sthalf(`SPARC_CORE3.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    			//   .wrmi_mamul_2ndhalf(`SPARC_CORE3.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    			//   .wrmi_maaeqb_1sthalf(`SPARC_CORE3.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    			//   .wrmi_maaeqb_2ndhalf(`SPARC_CORE3.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    			//   .iptr		(`SPARC_CORE3.sparc0.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    			//   .iminus_lenminus1(`SPARC_CORE3.sparc0.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    			//   .mul_data	(`SPARC_CORE3.sparc0.spu.spu_madp.spu_madp_evedata[63:0]));


always @ (negedge clk)
begin
    // if (`SPARC_CORE3.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE3.sparc0.lsu.lsu.qctl2.dfq_inv_data_val === 1'bx))
    if (`SPARC_CORE3.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE3.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val === 1'bx))
    begin
        $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received X invalidation");
        `ifndef VERILATOR
        repeat(5)@(posedge clk);
        `endif
        `MONITOR_PATH.fail("TILE0 lsu received X invalidation");
    end

    // if (`SPARC_CORE3.sparc0.lsu.lsu.qctl2.dfq_inv_data_val)
    if (`SPARC_CORE3.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val)
    begin
        if (|`SPARC_CORE3.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_way === 1'bx)
        begin
            $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received invalid way invalidation");
            `ifndef VERILATOR
            repeat(5)@(posedge clk);
            `endif
            `MONITOR_PATH.fail("TILE0 lsu received invalid way invalidation");
        end
    end
end



    //   cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
    //				// Inputs
    //				.clk	(clk),
    //				.rst_l	(rst_l),
    //				.spc_pcx_data_pa(`PCXPATH3.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
    //				.cpx_spc_data_cx(`PCXPATH3.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
    //				.cpu	(0));
   `endif


   `ifdef RTL_SPARC4
   l_cache_mon l_cache_mon4(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(0),			 // Templated
			    .index_f	(`ICTPATH4.index_y[`IC_SET_IDX_HI:0]), // Templated
			    .wrreq_f	(`ICTPATH4.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH4.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH4.ifq_ict_wrtag_f[`IC_TAG_SZ:0]), // Templated
			    .wr_data	(`ICVPATH4.write_bit_y),	 // Templated
                // .wr_data    (`ICVPATH4.din_d1),  // Templated
			    .wren_f	(`ICVPATH4.write_mask_y[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH4.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH4.wr_adr[`IC_SET_IDX_HI:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH4.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH4.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`SPARC_CORE4.sparc0.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`SPARC_CORE4.sparc0.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon4(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .wm_imiss (`SPARC_CORE4.sparc0.ifu.ifu.swl.wm_imiss[3:0]), // Templated
              .wm_other (`SPARC_CORE4.sparc0.ifu.ifu.swl.wm_other[3:0]), // Templated
              .wm_stbwait   (`SPARC_CORE4.sparc0.ifu.ifu.swl.wm_stbwait[3:0]), // Templated
              .thr_state0   (`SPARC_CORE4.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
              .thr_state1   (`SPARC_CORE4.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
              .thr_state2   (`SPARC_CORE4.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
              .thr_state3   (`SPARC_CORE4.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
              .rst_stallreq (`SPARC_CORE4.sparc0.ifu.ifu.fcl.rst_stallreq), // Templated
              .ifq_fcl_stallreq(`SPARC_CORE4.sparc0.ifu.ifu.fcl.ifq_fcl_stallreq), // Templated
              .lsu_ifu_stallreq(`SPARC_CORE4.sparc0.ifu.ifu.fcl.lsu_ifu_stallreq), // Templated
              .ffu_ifu_stallreq(`SPARC_CORE4.sparc0.ifu.ifu.fcl.ffu_ifu_stallreq), // Templated
              .completion   (`SPARC_CORE4.sparc0.ifu.ifu.swl.completion), // Templated
              .mul_wait (`SPARC_CORE4.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait (`SPARC_CORE4.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait  (`SPARC_CORE4.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_wait_nxt (`SPARC_CORE4.sparc0.ifu.ifu.swl.mul_wait_nxt), // Templated
              .div_wait_nxt (`SPARC_CORE4.sparc0.ifu.ifu.swl.div_wait_nxt), // Templated
              .fp_wait_nxt  (`SPARC_CORE4.sparc0.ifu.ifu.swl.fp_wait_nxt), // Templated
              .mul_busy_d   (`SPARC_CORE4.sparc0.ifu.ifu.swl.mul_busy_d), // Templated
              .div_busy_d   (`SPARC_CORE4.sparc0.ifu.ifu.swl.div_busy_d), // Templated
              .fp_busy_d    (`SPARC_CORE4.sparc0.ifu.ifu.swl.fp_busy_d), // Templated
              .ifet_ue_vec_d1(`SPARC_CORE4.sparc0.ifu.ifu.fcl.ifet_ue_vec_d1), // Templated
`else
			  .wm_imiss	(`SPARC_CORE4.sparc0.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`SPARC_CORE4.sparc0.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`SPARC_CORE4.sparc0.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`SPARC_CORE4.sparc0.ifu.swl.thr0_state[4:0]), // Templated
			  .thr_state1	(`SPARC_CORE4.sparc0.ifu.swl.thr1_state[4:0]), // Templated
			  .thr_state2	(`SPARC_CORE4.sparc0.ifu.swl.thr2_state[4:0]), // Templated
			  .thr_state3	(`SPARC_CORE4.sparc0.ifu.swl.thr3_state[4:0]), // Templated
			  .rst_stallreq	(`SPARC_CORE4.sparc0.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`SPARC_CORE4.sparc0.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`SPARC_CORE4.sparc0.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`SPARC_CORE4.sparc0.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`SPARC_CORE4.sparc0.ifu.swl.completion), // Templated
			  .mul_wait	(`SPARC_CORE4.sparc0.ifu.swl.mul_wait), // Templated
			  .div_wait	(`SPARC_CORE4.sparc0.ifu.swl.div_wait), // Templated
			  .fp_wait	(`SPARC_CORE4.sparc0.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`SPARC_CORE4.sparc0.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`SPARC_CORE4.sparc0.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`SPARC_CORE4.sparc0.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`SPARC_CORE4.sparc0.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`SPARC_CORE4.sparc0.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`SPARC_CORE4.sparc0.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`SPARC_CORE4.sparc0.ifu.fcl.ifet_ue_vec_d1), // Templated
`endif
			  .cpu_id	(10'd4));			 // Templated
   exu_mon exu_mon4(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH4.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH4.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH4.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH4.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH4.irf.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH4.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH4.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon4(/*AUTOINST*/
		    // Inputs
    `ifndef RTL_SPU
            .clk        (`SPARC_CORE4.sparc0.tlu.tlu.rclk), // Templated
            .grst_l     (`SPARC_CORE4.sparc0.tlu.tlu.grst_l), // Templated
            .rst_l      (`SPARC_CORE4.sparc0.tlu.tlu.tcl.tlu_rst_l), // Templated
    `else
		    .clk		(`SPARC_CORE4.sparc0.tlu.rclk), // Templated
		    .grst_l		(`SPARC_CORE4.sparc0.tlu.grst_l), // Templated
		    .rst_l		(`SPARC_CORE4.sparc0.tlu.tcl.tlu_rst_l), // Templated
    `endif
			.lsu_ifu_flush_pipe_w	(`SPARC_CORE4.sparc0.lsu_ifu_flush_pipe_w),
    `ifndef RTL_SPU
            .tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE4.sparc0.tlu.tlu_lsu_int_ldxa_vld_w2),
            .tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE4.sparc0.tlu.tlu_lsu_int_ld_ill_va_w2),
            .tlu_scpd_wr_vld_g      (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
            .cpu_mondo_head_wr_g    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
            .cpu_mondo_tail_wr_g    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
            .dev_mondo_head_wr_g    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_head_wr_g),
            .dev_mondo_tail_wr_g    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
            .resum_err_head_wr_g    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.resum_err_head_wr_g),
            .resum_err_tail_wr_g    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.resum_err_tail_wr_g),
            .nresum_err_head_wr_g   (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.nresum_err_head_wr_g),
            .nresum_err_tail_wr_g   (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.nresum_err_tail_wr_g),
            .ifu_lsu_ld_inst_e      (`SPARC_CORE4.sparc0.tlu.tlu.ifu_lsu_ld_inst_e),
            .ifu_lsu_st_inst_e      (`SPARC_CORE4.sparc0.tlu.tlu.ifu_lsu_st_inst_e),
            .ifu_lsu_alt_space_e    (`SPARC_CORE4.sparc0.tlu.tlu.ifu_lsu_alt_space_e),
            .tlu_early_flush_pipe_w (`SPARC_CORE4.sparc0.tlu.tlu.tlu_early_flush_pipe_w),
            .tlu_asi_state_e        (`SPARC_CORE4.sparc0.tlu.tlu.tlu_asi_state_e),
            .exu_lsu_ldst_va_e      (`SPARC_CORE4.sparc0.tlu.tlu.exu_lsu_ldst_va_e),
            .por_rstint0_w2 (`SPARC_CORE4.sparc0.tlu.tlu.tcl.por_rstint0_w2),
            .por_rstint1_w2 (`SPARC_CORE4.sparc0.tlu.tlu.tcl.por_rstint1_w2),
            .por_rstint2_w2 (`SPARC_CORE4.sparc0.tlu.tlu.tcl.por_rstint2_w2),
            .por_rstint3_w2 (`SPARC_CORE4.sparc0.tlu.tlu.tcl.por_rstint3_w2),
            .tlu_gl_lvl0    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.gl_lvl0),
            .tlu_gl_lvl1    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.gl_lvl1),
            .tlu_gl_lvl2    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.gl_lvl2),
            .tlu_gl_lvl3    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hyperv.gl_lvl3),
    `else
			.tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE4.sparc0.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE4.sparc0.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`SPARC_CORE4.sparc0.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`SPARC_CORE4.sparc0.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`SPARC_CORE4.sparc0.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`SPARC_CORE4.sparc0.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`SPARC_CORE4.sparc0.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`SPARC_CORE4.sparc0.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`SPARC_CORE4.sparc0.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`SPARC_CORE4.sparc0.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`SPARC_CORE4.sparc0.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`SPARC_CORE4.sparc0.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`SPARC_CORE4.sparc0.tlu.tlu_hyperv.gl_lvl3),
    `endif
            .exu_gl_lvl0	(`SPARC_CORE4.sparc0.exu.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`SPARC_CORE4.sparc0.exu.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`SPARC_CORE4.sparc0.exu.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`SPARC_CORE4.sparc0.exu.exu.rml.agp_thr3_next),
    `ifndef RTL_SPU
            .ifu_tlu_thrid_d    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
            .ifu_tlu_inst_vld_m (`SPARC_CORE4.sparc0.tlu.tlu.ifu_tlu_inst_vld_m), // Templated
            .ifu_tlu_imiss_e    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
            .ifu_tlu_immu_miss_m(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
            .tlu_thread_inst_vld_g(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
            .tlu_thread_wsel_g  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
            .ifu_tlu_l2imiss    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .ifu_tlu_flush_fd_w (`SPARC_CORE4.sparc0.tlu.tlu.ifu_tlu_flush_fd_w), // Templated
            .ifu_tlu_sraddr_d   (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
            .ifu_tlu_rsr_inst_d (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
            .lsu_tlu_wsr_inst_e (`SPARC_CORE4.sparc0.tlu.tlu.lsu_tlu_wsr_inst_e), // Templated
            .tlu_wsr_inst_nq_g  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
            .tlu_wsr_data_w (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.tlu_wsr_data_w), // Templated
            .lsu_tlu_dcache_miss_w2(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .lsu_tlu_l2_dmiss   (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .lsu_tlu_stb_full_w2(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .lsu_tlu_dmmu_miss_g(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
            .ffu_tlu_fpu_tid    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
            .ffu_tlu_fpu_cmplt  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
            .tlu_pstate_priv    (`SPARC_CORE4.sparc0.tlu.tlu.local_pstate_priv), // Templated
            .tlu_hpstate_priv   (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hpstate_priv), // Templated
            .tlu_hpstate_enb    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_hpstate_enb), // Templated
            .tlu_pstate_ie  (`SPARC_CORE4.sparc0.tlu.tlu.local_pstate_ie), // Templated
            .wsr_thread_inst_g  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.wsr_thread_inst_g), // Templated
            .lsu_tlu_defr_trp_taken_g(`SPARC_CORE4.sparc0.tlu.tlu.lsu_tlu_defr_trp_taken_g), // Templated
            .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE4.sparc0.tlu.tlu.lsu_tlu_async_ttype_vld_g), // Templated
            .lsu_tlu_ttype_vld_m2(`SPARC_CORE4.sparc0.tlu.tlu.lsu_tlu_ttype_vld_m2), // Templated
            .tlu_ifu_flush_pipe_w(`SPARC_CORE4.sparc0.tlu.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
            .tcc_inst_w2    (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.tcc_inst_w2), // Templated
            .tlu_pib_rsr_data_e (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
            .tlu_pib_priv_act_trap_m(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
            .tlu_pib_picl_wrap  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pib_picl_wrap), // Templated
            .tlu_pib_pich_wrap  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pich_onebelow_flg), // Templated
            .tlu_ifu_trappc_vld_w1(`SPARC_CORE4.sparc0.tlu.tlu.tlu_ifu_trappc_vld_w1), // Templated
            .tlu_ifu_trappc_w2  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_ifu_trappc_w2), // Templated
            .tlu_final_ttype_w2 (`SPARC_CORE4.sparc0.tlu.tlu.tlu_final_ttype_w2), // Templated
            .tlu_ifu_trap_tid_w1(`SPARC_CORE4.sparc0.tlu.tlu.tlu_ifu_trap_tid_w1), // Templated
            .tlu_full_flush_pipe_w2(`SPARC_CORE4.sparc0.tlu.tlu.tlu_full_flush_pipe_w2), // Templated
            .rtl_pcr0       (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pcr0), // Templated
            .rtl_pcr1       (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pcr1), // Templated
            .rtl_pcr2       (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pcr2), // Templated
            .rtl_pcr3       (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pcr3), // Templated
            .rtl_pich_cnt0  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pich_cnt0), // Templated
            .rtl_pich_cnt1  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pich_cnt1), // Templated
            .rtl_pich_cnt2  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pich_cnt2), // Templated
            .rtl_pich_cnt3  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.pich_cnt3), // Templated
            .rtl_picl_cnt0  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.picl_cnt0), // Templated
            .rtl_picl_cnt1  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.picl_cnt1), // Templated
            .rtl_picl_cnt2  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.picl_cnt2), // Templated
            .rtl_picl_cnt3  (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.picl_cnt3), // Templated
            .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .rtl_fpu_cmplt_thread(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.fpu_cmplt_thread), // Templated
            .rtl_imiss_thread_g (`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.imiss_thread_g), // Templated
            .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .rtl_immu_miss_thread_g(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.immu_miss_thread_g), // Templated
            .rtl_dmmu_miss_thread_g(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
            .rtl_ifu_tlu_l2imiss(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE4.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .true_pil0      (`SPARC_CORE4.sparc0.tlu.tlu.tcl.true_pil0), // Templated
            .true_pil1      (`SPARC_CORE4.sparc0.tlu.tlu.tcl.true_pil1), // Templated
            .true_pil2      (`SPARC_CORE4.sparc0.tlu.tlu.tcl.true_pil2), // Templated
            .true_pil3      (`SPARC_CORE4.sparc0.tlu.tlu.tcl.true_pil3), // Templated
            .rtl_trp_lvl0   (`SPARC_CORE4.sparc0.tlu.tlu.tcl.trp_lvl0), // Templated
            .rtl_trp_lvl1   (`SPARC_CORE4.sparc0.tlu.tlu.tcl.trp_lvl1), // Templated
            .rtl_trp_lvl2   (`SPARC_CORE4.sparc0.tlu.tlu.tcl.trp_lvl2), // Templated
            .rtl_trp_lvl3   (`SPARC_CORE4.sparc0.tlu.tlu.tcl.trp_lvl3), // Templated
            .tlz_thread     (`SPARC_CORE4.sparc0.tlu.tlu.tcl.tlz_thread), // Templated
            .th0_sftint_15  (`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint0[15]), // Templated
            .th1_sftint_15  (`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint1[15]), // Templated
            .th2_sftint_15  (`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint2[15]), // Templated
            .th3_sftint_15  (`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint3[15]), // Templated
            .ifu_swint_g    (`SPARC_CORE4.sparc0.tlu.tlu.tcl.swint_g), // Templated
    `else
		    .ifu_tlu_thrid_d	(`SPARC_CORE4.sparc0.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`SPARC_CORE4.sparc0.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`SPARC_CORE4.sparc0.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`SPARC_CORE4.sparc0.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`SPARC_CORE4.sparc0.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`SPARC_CORE4.sparc0.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`SPARC_CORE4.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`SPARC_CORE4.sparc0.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`SPARC_CORE4.sparc0.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`SPARC_CORE4.sparc0.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`SPARC_CORE4.sparc0.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`SPARC_CORE4.sparc0.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`SPARC_CORE4.sparc0.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`SPARC_CORE4.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`SPARC_CORE4.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`SPARC_CORE4.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`SPARC_CORE4.sparc0.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`SPARC_CORE4.sparc0.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`SPARC_CORE4.sparc0.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`SPARC_CORE4.sparc0.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`SPARC_CORE4.sparc0.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`SPARC_CORE4.sparc0.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`SPARC_CORE4.sparc0.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`SPARC_CORE4.sparc0.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`SPARC_CORE4.sparc0.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE4.sparc0.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`SPARC_CORE4.sparc0.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`SPARC_CORE4.sparc0.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`SPARC_CORE4.sparc0.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`SPARC_CORE4.sparc0.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`SPARC_CORE4.sparc0.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`SPARC_CORE4.sparc0.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`SPARC_CORE4.sparc0.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`SPARC_CORE4.sparc0.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`SPARC_CORE4.sparc0.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`SPARC_CORE4.sparc0.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`SPARC_CORE4.sparc0.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`SPARC_CORE4.sparc0.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`SPARC_CORE4.sparc0.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`SPARC_CORE4.sparc0.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`SPARC_CORE4.sparc0.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`SPARC_CORE4.sparc0.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`SPARC_CORE4.sparc0.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`SPARC_CORE4.sparc0.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`SPARC_CORE4.sparc0.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`SPARC_CORE4.sparc0.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`SPARC_CORE4.sparc0.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`SPARC_CORE4.sparc0.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`SPARC_CORE4.sparc0.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`SPARC_CORE4.sparc0.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE4.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`SPARC_CORE4.sparc0.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`SPARC_CORE4.sparc0.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE4.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`SPARC_CORE4.sparc0.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`SPARC_CORE4.sparc0.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`SPARC_CORE4.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE4.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`SPARC_CORE4.sparc0.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`SPARC_CORE4.sparc0.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`SPARC_CORE4.sparc0.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`SPARC_CORE4.sparc0.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`SPARC_CORE4.sparc0.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`SPARC_CORE4.sparc0.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`SPARC_CORE4.sparc0.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`SPARC_CORE4.sparc0.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`SPARC_CORE4.sparc0.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`SPARC_CORE4.sparc0.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`SPARC_CORE4.sparc0.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`SPARC_CORE4.sparc0.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`SPARC_CORE4.sparc0.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`SPARC_CORE4.sparc0.tlu.tcl.swint_g), // Templated
    `endif
		    .core_id		(10'd4),			 // Templated
    `ifndef RTL_SPU
            .tlu_itlb_wr_vld_g  (`SPARC_CORE4.sparc0.tlu.tlu_itlb_wr_vld_g), // Templated
            .tlu_itlb_dmp_vld_g (`SPARC_CORE4.sparc0.tlu.tlu_itlb_dmp_vld_g), // Templated
            .tlu_itlb_tte_tag_w2(`SPARC_CORE4.sparc0.tlu.tlu_itlb_tte_tag_w2), // Templated
            .tlu_itlb_tte_data_w2(`SPARC_CORE4.sparc0.tlu.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE4.sparc0.ifu.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE4.sparc0.lsu.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE4.sparc0.tlu.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE4.sparc0.tlu.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `else
		    .tlu_itlb_wr_vld_g	(`SPARC_CORE4.sparc0.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`SPARC_CORE4.sparc0.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`SPARC_CORE4.sparc0.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`SPARC_CORE4.sparc0.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE4.sparc0.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE4.sparc0.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE4.sparc0.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE4.sparc0.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `endif
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon4 (/*AUTOINST*/
			      // Inputs
    `ifndef RTL_SPU
                  .rtl_softint0(`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint0), // Templated
                  .rtl_softint1(`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint1), // Templated
                  .rtl_softint2(`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint2), // Templated
                  .rtl_softint3(`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint3), // Templated
                  .rtl_wsr_data_w(`SPARC_CORE4.sparc0.tlu.tlu.tdp.wsr_data_w), // Templated
                  .rtl_sftint_en_l_g(`SPARC_CORE4.sparc0.tlu.tlu.tdp.tlu_sftint_en_l_g), // Templated
                  .rtl_sftint_b0_en(`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint_b0_en), // Templated
                  .rtl_tickcmp_int(`SPARC_CORE4.sparc0.tlu.tlu.tdp.tickcmp_int), // Templated
                  .rtl_sftint_b16_en(`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint_b16_en), // Templated
                  .rtl_stickcmp_int(`SPARC_CORE4.sparc0.tlu.tlu.tdp.stickcmp_int), // Templated
                  .rtl_sftint_b15_en(`SPARC_CORE4.sparc0.tlu.tlu.tdp.sftint_b15_en), // Templated
                  .rtl_pib_picl_wrap(`SPARC_CORE4.sparc0.tlu.tlu.tdp.pib_picl_wrap), // Templated
                  .rtl_pib_pich_wrap(`SPARC_CORE4.sparc0.tlu.tlu.tdp.pib_pich_wrap), // Templated
                  .rtl_wr_sftint_l_g(`SPARC_CORE4.sparc0.tlu.tlu.tdp.tlu_wr_sftint_l_g), // Templated
                  .rtl_set_sftint_l_g(`SPARC_CORE4.sparc0.tlu.tlu.tdp.tlu_set_sftint_l_g), // Templated
                  .rtl_clr_sftint_l_g(`SPARC_CORE4.sparc0.tlu.tlu.tdp.tlu_clr_sftint_l_g), // Templated
                  .rtl_clk  (`SPARC_CORE4.sparc0.tlu.tlu.tdp.rclk), // Templated
                  .rtl_reset(`SPARC_CORE4.sparc0.tlu.tlu.tdp.tlu_rst), // Templated
    `else
			      .rtl_softint0(`SPARC_CORE4.sparc0.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`SPARC_CORE4.sparc0.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`SPARC_CORE4.sparc0.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`SPARC_CORE4.sparc0.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`SPARC_CORE4.sparc0.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`SPARC_CORE4.sparc0.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`SPARC_CORE4.sparc0.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`SPARC_CORE4.sparc0.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`SPARC_CORE4.sparc0.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`SPARC_CORE4.sparc0.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`SPARC_CORE4.sparc0.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`SPARC_CORE4.sparc0.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`SPARC_CORE4.sparc0.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`SPARC_CORE4.sparc0.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`SPARC_CORE4.sparc0.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`SPARC_CORE4.sparc0.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`SPARC_CORE4.sparc0.tlu.tdp.rclk), // Templated
			      .rtl_reset(`SPARC_CORE4.sparc0.tlu.tdp.tlu_rst), // Templated
    `endif
			      .core_id	(10'd4));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon4(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
`ifndef RTL_SPU
                .thr_state0 (`SPARC_CORE4.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
                .thr_state1 (`SPARC_CORE4.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
                .thr_state2 (`SPARC_CORE4.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
                .thr_state3 (`SPARC_CORE4.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
                .rstthr (`SPARC_CORE4.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
                .nukeint    (`SPARC_CORE4.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
                .resumint   (`SPARC_CORE4.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
                .rstint (`SPARC_CORE4.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`else
			    .thr_state0	(`SPARC_CORE4.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
			    .thr_state1	(`SPARC_CORE4.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
			    .thr_state2	(`SPARC_CORE4.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
			    .thr_state3	(`SPARC_CORE4.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
			    .rstthr	(`SPARC_CORE4.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			    .nukeint	(`SPARC_CORE4.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
			    .resumint	(`SPARC_CORE4.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
			    .rstint	(`SPARC_CORE4.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`endif
			    .coreid	(10'd4));			 // Templated
   mask_mon mask_mon4(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
`ifndef RTL_SPU
              .wm_imiss     (`SPARC_CORE4.sparc0.ifu.ifu.swl.wm_imiss), // Templated
              .wm_other     (`SPARC_CORE4.sparc0.ifu.ifu.swl.wm_other), // Templated
              .wm_stbwait   (`SPARC_CORE4.sparc0.ifu.ifu.swl.wm_stbwait), // Templated
              .mul_wait     (`SPARC_CORE4.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait     (`SPARC_CORE4.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait      (`SPARC_CORE4.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_busy_e   (`SPARC_CORE4.sparc0.ifu.ifu.swl.mul_busy_e), // Templated
              .div_busy_e   (`SPARC_CORE4.sparc0.ifu.ifu.swl.div_busy_e), // Templated
              .fp_busy_e    (`SPARC_CORE4.sparc0.ifu.ifu.swl.fp_busy_e), // Templated
              .ldmiss       (`SPARC_CORE4.sparc0.ifu.ifu.swl.ldmiss), // Templated
`else
		      .wm_imiss		(`SPARC_CORE4.sparc0.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`SPARC_CORE4.sparc0.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`SPARC_CORE4.sparc0.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`SPARC_CORE4.sparc0.ifu.swl.mul_wait), // Templated
		      .div_wait		(`SPARC_CORE4.sparc0.ifu.swl.div_wait), // Templated
		      .fp_wait		(`SPARC_CORE4.sparc0.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`SPARC_CORE4.sparc0.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`SPARC_CORE4.sparc0.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`SPARC_CORE4.sparc0.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`SPARC_CORE4.sparc0.ifu.swl.ldmiss), // Templated
`endif
		      .coreid		(10'd4));			 // Templated
   pc_muxsel_mon pc_muxsel_mon4(/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
`ifndef RTL_SPU
                .t0pc_f (`SPARC_CORE4.sparc0.ifu.ifu.fdp.t0pc_f[47:0]), // Templated
                .t1pc_f (`SPARC_CORE4.sparc0.ifu.ifu.fdp.t1pc_f[47:0]), // Templated
                .t2pc_f (`SPARC_CORE4.sparc0.ifu.ifu.fdp.t2pc_f[47:0]), // Templated
                .t3pc_f (`SPARC_CORE4.sparc0.ifu.ifu.fdp.t3pc_f[47:0]), // Templated
                .pc_f   (`SPARC_CORE4.sparc0.ifu.ifu.fdp.pc_f[47:0]), // Templated
                .inst_vld_f(`SPARC_CORE4.sparc0.ifu.ifu.fcl.inst_vld_f), // Templated
                .dtu_fcl_running_s(`SPARC_CORE4.sparc0.ifu.ifu.dtu_fcl_running_s), // Templated
                .thr_f  (`SPARC_CORE4.sparc0.ifu.ifu.fcl.thr_f[3:0]), // Templated
`else
				.t0pc_f	(`SPARC_CORE4.sparc0.ifu.fdp.t0pc_f[47:0]), // Templated
				.t1pc_f	(`SPARC_CORE4.sparc0.ifu.fdp.t1pc_f[47:0]), // Templated
				.t2pc_f	(`SPARC_CORE4.sparc0.ifu.fdp.t2pc_f[47:0]), // Templated
				.t3pc_f	(`SPARC_CORE4.sparc0.ifu.fdp.t3pc_f[47:0]), // Templated
				.pc_f	(`SPARC_CORE4.sparc0.ifu.fdp.pc_f[47:0]), // Templated
				.inst_vld_f(`SPARC_CORE4.sparc0.ifu.fcl.inst_vld_f), // Templated
				.dtu_fcl_running_s(`SPARC_CORE4.sparc0.ifu.dtu_fcl_running_s), // Templated
				.thr_f	(`SPARC_CORE4.sparc0.ifu.fcl.thr_f[3:0]), // Templated
`endif
				.coreid	(10'd4));			 // Templated
   stb_ovfl_mon stb_ovfl_mon4(/*AUTOINST*/
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
`ifndef RTL_SPU
                  .lsu_ifu_stbcnt3(`SPARC_CORE4.sparc0.ifu.ifu.lsu_ifu_stbcnt3), // Templated
                  .lsu_ifu_stbcnt2(`SPARC_CORE4.sparc0.ifu.ifu.lsu_ifu_stbcnt2), // Templated
                  .lsu_ifu_stbcnt1(`SPARC_CORE4.sparc0.ifu.ifu.lsu_ifu_stbcnt1), // Templated
                  .lsu_ifu_stbcnt0(`SPARC_CORE4.sparc0.ifu.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE4.sparc0.lsu.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE4.sparc0.lsu.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE4.sparc0.lsu.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE4.sparc0.lsu.lsu.stb_ctl0.reset), // Templated
`else
			      .lsu_ifu_stbcnt3(`SPARC_CORE4.sparc0.ifu.lsu_ifu_stbcnt3), // Templated
			      .lsu_ifu_stbcnt2(`SPARC_CORE4.sparc0.ifu.lsu_ifu_stbcnt2), // Templated
			      .lsu_ifu_stbcnt1(`SPARC_CORE4.sparc0.ifu.lsu_ifu_stbcnt1), // Templated
			      .lsu_ifu_stbcnt0(`SPARC_CORE4.sparc0.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE4.sparc0.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE4.sparc0.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE4.sparc0.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE4.sparc0.lsu.stb_ctl0.reset), // Templated
`endif
			      .coreid	(10'd4));			 // Templated
   icache_mutex_mon icache_mutex_mon4(/*AUTOINST*/
				      // Inputs
				      .clk(clk),
				      .rst_l(rst_l),
`ifndef RTL_SPU
                      .waysel_buf_s1(`SPARC_CORE4.sparc0.ifu.ifu.wseldp.waysel_buf_s1), // Templated
                      .alltag_err_s1(`SPARC_CORE4.sparc0.ifu.ifu.errctl.alltag_err_s1), // Templated
                      .tlb_cam_miss_s1(`SPARC_CORE4.sparc0.ifu.ifu.fcl.tlb_cam_miss_s1), // Templated
                      .cam_vld_s1(`SPARC_CORE4.sparc0.ifu.ifu.fcl.cam_vld_s1), // Templated
`else
				      .waysel_buf_s1(`SPARC_CORE4.sparc0.ifu.wseldp.waysel_buf_s1), // Templated
				      .alltag_err_s1(`SPARC_CORE4.sparc0.ifu.errctl.alltag_err_s1), // Templated
				      .tlb_cam_miss_s1(`SPARC_CORE4.sparc0.ifu.fcl.tlb_cam_miss_s1), // Templated
				      .cam_vld_s1(`SPARC_CORE4.sparc0.ifu.fcl.cam_vld_s1), // Templated
`endif
				      .coreid(10'd4));		 // Templated
   nc_inv_chk nc_inv_chk4(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .cpxpkt_vld   (`SPARC_CORE4.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
              .cpxpkt_rtntype(`SPARC_CORE4.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
              .nc       (`SPARC_CORE4.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
              .wv       (`SPARC_CORE4.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`else
			  .cpxpkt_vld	(`SPARC_CORE4.sparc0.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`SPARC_CORE4.sparc0.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`SPARC_CORE4.sparc0.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`SPARC_CORE4.sparc0.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`endif
			  .coreid	(10'd4));			 // Templated

       // trin: we don't have spu
       // spu_ma_mon spu_ma_mon4(/* AUTOINST*/
    			//   // Inputs
    			//   .clk		(clk),
    			//   .wrmi_mamul_1sthalf(`SPARC_CORE4.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    			//   .wrmi_mamul_2ndhalf(`SPARC_CORE4.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    			//   .wrmi_maaeqb_1sthalf(`SPARC_CORE4.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    			//   .wrmi_maaeqb_2ndhalf(`SPARC_CORE4.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    			//   .iptr		(`SPARC_CORE4.sparc0.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    			//   .iminus_lenminus1(`SPARC_CORE4.sparc0.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    			//   .mul_data	(`SPARC_CORE4.sparc0.spu.spu_madp.spu_madp_evedata[63:0]));


always @ (negedge clk)
begin
    // if (`SPARC_CORE4.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE4.sparc0.lsu.lsu.qctl2.dfq_inv_data_val === 1'bx))
    if (`SPARC_CORE4.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE4.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val === 1'bx))
    begin
        $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received X invalidation");
        `ifndef VERILATOR
        repeat(5)@(posedge clk);
        `endif
        `MONITOR_PATH.fail("TILE0 lsu received X invalidation");
    end

    // if (`SPARC_CORE4.sparc0.lsu.lsu.qctl2.dfq_inv_data_val)
    if (`SPARC_CORE4.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val)
    begin
        if (|`SPARC_CORE4.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_way === 1'bx)
        begin
            $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received invalid way invalidation");
            `ifndef VERILATOR
            repeat(5)@(posedge clk);
            `endif
            `MONITOR_PATH.fail("TILE0 lsu received invalid way invalidation");
        end
    end
end



    //   cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
    //				// Inputs
    //				.clk	(clk),
    //				.rst_l	(rst_l),
    //				.spc_pcx_data_pa(`PCXPATH4.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
    //				.cpx_spc_data_cx(`PCXPATH4.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
    //				.cpu	(0));
   `endif


   `ifdef RTL_SPARC5
   l_cache_mon l_cache_mon5(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(0),			 // Templated
			    .index_f	(`ICTPATH5.index_y[`IC_SET_IDX_HI:0]), // Templated
			    .wrreq_f	(`ICTPATH5.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH5.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH5.ifq_ict_wrtag_f[`IC_TAG_SZ:0]), // Templated
			    .wr_data	(`ICVPATH5.write_bit_y),	 // Templated
                // .wr_data    (`ICVPATH5.din_d1),  // Templated
			    .wren_f	(`ICVPATH5.write_mask_y[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH5.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH5.wr_adr[`IC_SET_IDX_HI:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH5.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH5.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`SPARC_CORE5.sparc0.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`SPARC_CORE5.sparc0.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon5(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .wm_imiss (`SPARC_CORE5.sparc0.ifu.ifu.swl.wm_imiss[3:0]), // Templated
              .wm_other (`SPARC_CORE5.sparc0.ifu.ifu.swl.wm_other[3:0]), // Templated
              .wm_stbwait   (`SPARC_CORE5.sparc0.ifu.ifu.swl.wm_stbwait[3:0]), // Templated
              .thr_state0   (`SPARC_CORE5.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
              .thr_state1   (`SPARC_CORE5.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
              .thr_state2   (`SPARC_CORE5.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
              .thr_state3   (`SPARC_CORE5.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
              .rst_stallreq (`SPARC_CORE5.sparc0.ifu.ifu.fcl.rst_stallreq), // Templated
              .ifq_fcl_stallreq(`SPARC_CORE5.sparc0.ifu.ifu.fcl.ifq_fcl_stallreq), // Templated
              .lsu_ifu_stallreq(`SPARC_CORE5.sparc0.ifu.ifu.fcl.lsu_ifu_stallreq), // Templated
              .ffu_ifu_stallreq(`SPARC_CORE5.sparc0.ifu.ifu.fcl.ffu_ifu_stallreq), // Templated
              .completion   (`SPARC_CORE5.sparc0.ifu.ifu.swl.completion), // Templated
              .mul_wait (`SPARC_CORE5.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait (`SPARC_CORE5.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait  (`SPARC_CORE5.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_wait_nxt (`SPARC_CORE5.sparc0.ifu.ifu.swl.mul_wait_nxt), // Templated
              .div_wait_nxt (`SPARC_CORE5.sparc0.ifu.ifu.swl.div_wait_nxt), // Templated
              .fp_wait_nxt  (`SPARC_CORE5.sparc0.ifu.ifu.swl.fp_wait_nxt), // Templated
              .mul_busy_d   (`SPARC_CORE5.sparc0.ifu.ifu.swl.mul_busy_d), // Templated
              .div_busy_d   (`SPARC_CORE5.sparc0.ifu.ifu.swl.div_busy_d), // Templated
              .fp_busy_d    (`SPARC_CORE5.sparc0.ifu.ifu.swl.fp_busy_d), // Templated
              .ifet_ue_vec_d1(`SPARC_CORE5.sparc0.ifu.ifu.fcl.ifet_ue_vec_d1), // Templated
`else
			  .wm_imiss	(`SPARC_CORE5.sparc0.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`SPARC_CORE5.sparc0.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`SPARC_CORE5.sparc0.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`SPARC_CORE5.sparc0.ifu.swl.thr0_state[4:0]), // Templated
			  .thr_state1	(`SPARC_CORE5.sparc0.ifu.swl.thr1_state[4:0]), // Templated
			  .thr_state2	(`SPARC_CORE5.sparc0.ifu.swl.thr2_state[4:0]), // Templated
			  .thr_state3	(`SPARC_CORE5.sparc0.ifu.swl.thr3_state[4:0]), // Templated
			  .rst_stallreq	(`SPARC_CORE5.sparc0.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`SPARC_CORE5.sparc0.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`SPARC_CORE5.sparc0.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`SPARC_CORE5.sparc0.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`SPARC_CORE5.sparc0.ifu.swl.completion), // Templated
			  .mul_wait	(`SPARC_CORE5.sparc0.ifu.swl.mul_wait), // Templated
			  .div_wait	(`SPARC_CORE5.sparc0.ifu.swl.div_wait), // Templated
			  .fp_wait	(`SPARC_CORE5.sparc0.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`SPARC_CORE5.sparc0.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`SPARC_CORE5.sparc0.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`SPARC_CORE5.sparc0.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`SPARC_CORE5.sparc0.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`SPARC_CORE5.sparc0.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`SPARC_CORE5.sparc0.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`SPARC_CORE5.sparc0.ifu.fcl.ifet_ue_vec_d1), // Templated
`endif
			  .cpu_id	(10'd5));			 // Templated
   exu_mon exu_mon5(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH5.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH5.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH5.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH5.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH5.irf.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH5.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH5.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon5(/*AUTOINST*/
		    // Inputs
    `ifndef RTL_SPU
            .clk        (`SPARC_CORE5.sparc0.tlu.tlu.rclk), // Templated
            .grst_l     (`SPARC_CORE5.sparc0.tlu.tlu.grst_l), // Templated
            .rst_l      (`SPARC_CORE5.sparc0.tlu.tlu.tcl.tlu_rst_l), // Templated
    `else
		    .clk		(`SPARC_CORE5.sparc0.tlu.rclk), // Templated
		    .grst_l		(`SPARC_CORE5.sparc0.tlu.grst_l), // Templated
		    .rst_l		(`SPARC_CORE5.sparc0.tlu.tcl.tlu_rst_l), // Templated
    `endif
			.lsu_ifu_flush_pipe_w	(`SPARC_CORE5.sparc0.lsu_ifu_flush_pipe_w),
    `ifndef RTL_SPU
            .tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE5.sparc0.tlu.tlu_lsu_int_ldxa_vld_w2),
            .tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE5.sparc0.tlu.tlu_lsu_int_ld_ill_va_w2),
            .tlu_scpd_wr_vld_g      (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
            .cpu_mondo_head_wr_g    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
            .cpu_mondo_tail_wr_g    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
            .dev_mondo_head_wr_g    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_head_wr_g),
            .dev_mondo_tail_wr_g    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
            .resum_err_head_wr_g    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.resum_err_head_wr_g),
            .resum_err_tail_wr_g    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.resum_err_tail_wr_g),
            .nresum_err_head_wr_g   (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.nresum_err_head_wr_g),
            .nresum_err_tail_wr_g   (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.nresum_err_tail_wr_g),
            .ifu_lsu_ld_inst_e      (`SPARC_CORE5.sparc0.tlu.tlu.ifu_lsu_ld_inst_e),
            .ifu_lsu_st_inst_e      (`SPARC_CORE5.sparc0.tlu.tlu.ifu_lsu_st_inst_e),
            .ifu_lsu_alt_space_e    (`SPARC_CORE5.sparc0.tlu.tlu.ifu_lsu_alt_space_e),
            .tlu_early_flush_pipe_w (`SPARC_CORE5.sparc0.tlu.tlu.tlu_early_flush_pipe_w),
            .tlu_asi_state_e        (`SPARC_CORE5.sparc0.tlu.tlu.tlu_asi_state_e),
            .exu_lsu_ldst_va_e      (`SPARC_CORE5.sparc0.tlu.tlu.exu_lsu_ldst_va_e),
            .por_rstint0_w2 (`SPARC_CORE5.sparc0.tlu.tlu.tcl.por_rstint0_w2),
            .por_rstint1_w2 (`SPARC_CORE5.sparc0.tlu.tlu.tcl.por_rstint1_w2),
            .por_rstint2_w2 (`SPARC_CORE5.sparc0.tlu.tlu.tcl.por_rstint2_w2),
            .por_rstint3_w2 (`SPARC_CORE5.sparc0.tlu.tlu.tcl.por_rstint3_w2),
            .tlu_gl_lvl0    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.gl_lvl0),
            .tlu_gl_lvl1    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.gl_lvl1),
            .tlu_gl_lvl2    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.gl_lvl2),
            .tlu_gl_lvl3    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hyperv.gl_lvl3),
    `else
			.tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE5.sparc0.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE5.sparc0.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`SPARC_CORE5.sparc0.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`SPARC_CORE5.sparc0.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`SPARC_CORE5.sparc0.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`SPARC_CORE5.sparc0.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`SPARC_CORE5.sparc0.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`SPARC_CORE5.sparc0.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`SPARC_CORE5.sparc0.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`SPARC_CORE5.sparc0.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`SPARC_CORE5.sparc0.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`SPARC_CORE5.sparc0.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`SPARC_CORE5.sparc0.tlu.tlu_hyperv.gl_lvl3),
    `endif
            .exu_gl_lvl0	(`SPARC_CORE5.sparc0.exu.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`SPARC_CORE5.sparc0.exu.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`SPARC_CORE5.sparc0.exu.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`SPARC_CORE5.sparc0.exu.exu.rml.agp_thr3_next),
    `ifndef RTL_SPU
            .ifu_tlu_thrid_d    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
            .ifu_tlu_inst_vld_m (`SPARC_CORE5.sparc0.tlu.tlu.ifu_tlu_inst_vld_m), // Templated
            .ifu_tlu_imiss_e    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
            .ifu_tlu_immu_miss_m(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
            .tlu_thread_inst_vld_g(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
            .tlu_thread_wsel_g  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
            .ifu_tlu_l2imiss    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .ifu_tlu_flush_fd_w (`SPARC_CORE5.sparc0.tlu.tlu.ifu_tlu_flush_fd_w), // Templated
            .ifu_tlu_sraddr_d   (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
            .ifu_tlu_rsr_inst_d (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
            .lsu_tlu_wsr_inst_e (`SPARC_CORE5.sparc0.tlu.tlu.lsu_tlu_wsr_inst_e), // Templated
            .tlu_wsr_inst_nq_g  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
            .tlu_wsr_data_w (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.tlu_wsr_data_w), // Templated
            .lsu_tlu_dcache_miss_w2(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .lsu_tlu_l2_dmiss   (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .lsu_tlu_stb_full_w2(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .lsu_tlu_dmmu_miss_g(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
            .ffu_tlu_fpu_tid    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
            .ffu_tlu_fpu_cmplt  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
            .tlu_pstate_priv    (`SPARC_CORE5.sparc0.tlu.tlu.local_pstate_priv), // Templated
            .tlu_hpstate_priv   (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hpstate_priv), // Templated
            .tlu_hpstate_enb    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_hpstate_enb), // Templated
            .tlu_pstate_ie  (`SPARC_CORE5.sparc0.tlu.tlu.local_pstate_ie), // Templated
            .wsr_thread_inst_g  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.wsr_thread_inst_g), // Templated
            .lsu_tlu_defr_trp_taken_g(`SPARC_CORE5.sparc0.tlu.tlu.lsu_tlu_defr_trp_taken_g), // Templated
            .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE5.sparc0.tlu.tlu.lsu_tlu_async_ttype_vld_g), // Templated
            .lsu_tlu_ttype_vld_m2(`SPARC_CORE5.sparc0.tlu.tlu.lsu_tlu_ttype_vld_m2), // Templated
            .tlu_ifu_flush_pipe_w(`SPARC_CORE5.sparc0.tlu.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
            .tcc_inst_w2    (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.tcc_inst_w2), // Templated
            .tlu_pib_rsr_data_e (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
            .tlu_pib_priv_act_trap_m(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
            .tlu_pib_picl_wrap  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pib_picl_wrap), // Templated
            .tlu_pib_pich_wrap  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pich_onebelow_flg), // Templated
            .tlu_ifu_trappc_vld_w1(`SPARC_CORE5.sparc0.tlu.tlu.tlu_ifu_trappc_vld_w1), // Templated
            .tlu_ifu_trappc_w2  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_ifu_trappc_w2), // Templated
            .tlu_final_ttype_w2 (`SPARC_CORE5.sparc0.tlu.tlu.tlu_final_ttype_w2), // Templated
            .tlu_ifu_trap_tid_w1(`SPARC_CORE5.sparc0.tlu.tlu.tlu_ifu_trap_tid_w1), // Templated
            .tlu_full_flush_pipe_w2(`SPARC_CORE5.sparc0.tlu.tlu.tlu_full_flush_pipe_w2), // Templated
            .rtl_pcr0       (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pcr0), // Templated
            .rtl_pcr1       (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pcr1), // Templated
            .rtl_pcr2       (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pcr2), // Templated
            .rtl_pcr3       (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pcr3), // Templated
            .rtl_pich_cnt0  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pich_cnt0), // Templated
            .rtl_pich_cnt1  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pich_cnt1), // Templated
            .rtl_pich_cnt2  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pich_cnt2), // Templated
            .rtl_pich_cnt3  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.pich_cnt3), // Templated
            .rtl_picl_cnt0  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.picl_cnt0), // Templated
            .rtl_picl_cnt1  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.picl_cnt1), // Templated
            .rtl_picl_cnt2  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.picl_cnt2), // Templated
            .rtl_picl_cnt3  (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.picl_cnt3), // Templated
            .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .rtl_fpu_cmplt_thread(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.fpu_cmplt_thread), // Templated
            .rtl_imiss_thread_g (`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.imiss_thread_g), // Templated
            .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .rtl_immu_miss_thread_g(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.immu_miss_thread_g), // Templated
            .rtl_dmmu_miss_thread_g(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
            .rtl_ifu_tlu_l2imiss(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE5.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .true_pil0      (`SPARC_CORE5.sparc0.tlu.tlu.tcl.true_pil0), // Templated
            .true_pil1      (`SPARC_CORE5.sparc0.tlu.tlu.tcl.true_pil1), // Templated
            .true_pil2      (`SPARC_CORE5.sparc0.tlu.tlu.tcl.true_pil2), // Templated
            .true_pil3      (`SPARC_CORE5.sparc0.tlu.tlu.tcl.true_pil3), // Templated
            .rtl_trp_lvl0   (`SPARC_CORE5.sparc0.tlu.tlu.tcl.trp_lvl0), // Templated
            .rtl_trp_lvl1   (`SPARC_CORE5.sparc0.tlu.tlu.tcl.trp_lvl1), // Templated
            .rtl_trp_lvl2   (`SPARC_CORE5.sparc0.tlu.tlu.tcl.trp_lvl2), // Templated
            .rtl_trp_lvl3   (`SPARC_CORE5.sparc0.tlu.tlu.tcl.trp_lvl3), // Templated
            .tlz_thread     (`SPARC_CORE5.sparc0.tlu.tlu.tcl.tlz_thread), // Templated
            .th0_sftint_15  (`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint0[15]), // Templated
            .th1_sftint_15  (`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint1[15]), // Templated
            .th2_sftint_15  (`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint2[15]), // Templated
            .th3_sftint_15  (`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint3[15]), // Templated
            .ifu_swint_g    (`SPARC_CORE5.sparc0.tlu.tlu.tcl.swint_g), // Templated
    `else
		    .ifu_tlu_thrid_d	(`SPARC_CORE5.sparc0.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`SPARC_CORE5.sparc0.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`SPARC_CORE5.sparc0.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`SPARC_CORE5.sparc0.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`SPARC_CORE5.sparc0.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`SPARC_CORE5.sparc0.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`SPARC_CORE5.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`SPARC_CORE5.sparc0.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`SPARC_CORE5.sparc0.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`SPARC_CORE5.sparc0.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`SPARC_CORE5.sparc0.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`SPARC_CORE5.sparc0.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`SPARC_CORE5.sparc0.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`SPARC_CORE5.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`SPARC_CORE5.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`SPARC_CORE5.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`SPARC_CORE5.sparc0.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`SPARC_CORE5.sparc0.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`SPARC_CORE5.sparc0.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`SPARC_CORE5.sparc0.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`SPARC_CORE5.sparc0.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`SPARC_CORE5.sparc0.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`SPARC_CORE5.sparc0.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`SPARC_CORE5.sparc0.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`SPARC_CORE5.sparc0.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE5.sparc0.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`SPARC_CORE5.sparc0.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`SPARC_CORE5.sparc0.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`SPARC_CORE5.sparc0.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`SPARC_CORE5.sparc0.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`SPARC_CORE5.sparc0.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`SPARC_CORE5.sparc0.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`SPARC_CORE5.sparc0.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`SPARC_CORE5.sparc0.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`SPARC_CORE5.sparc0.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`SPARC_CORE5.sparc0.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`SPARC_CORE5.sparc0.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`SPARC_CORE5.sparc0.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`SPARC_CORE5.sparc0.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`SPARC_CORE5.sparc0.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`SPARC_CORE5.sparc0.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`SPARC_CORE5.sparc0.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`SPARC_CORE5.sparc0.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`SPARC_CORE5.sparc0.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`SPARC_CORE5.sparc0.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`SPARC_CORE5.sparc0.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`SPARC_CORE5.sparc0.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`SPARC_CORE5.sparc0.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`SPARC_CORE5.sparc0.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`SPARC_CORE5.sparc0.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE5.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`SPARC_CORE5.sparc0.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`SPARC_CORE5.sparc0.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE5.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`SPARC_CORE5.sparc0.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`SPARC_CORE5.sparc0.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`SPARC_CORE5.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE5.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`SPARC_CORE5.sparc0.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`SPARC_CORE5.sparc0.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`SPARC_CORE5.sparc0.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`SPARC_CORE5.sparc0.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`SPARC_CORE5.sparc0.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`SPARC_CORE5.sparc0.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`SPARC_CORE5.sparc0.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`SPARC_CORE5.sparc0.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`SPARC_CORE5.sparc0.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`SPARC_CORE5.sparc0.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`SPARC_CORE5.sparc0.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`SPARC_CORE5.sparc0.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`SPARC_CORE5.sparc0.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`SPARC_CORE5.sparc0.tlu.tcl.swint_g), // Templated
    `endif
		    .core_id		(10'd5),			 // Templated
    `ifndef RTL_SPU
            .tlu_itlb_wr_vld_g  (`SPARC_CORE5.sparc0.tlu.tlu_itlb_wr_vld_g), // Templated
            .tlu_itlb_dmp_vld_g (`SPARC_CORE5.sparc0.tlu.tlu_itlb_dmp_vld_g), // Templated
            .tlu_itlb_tte_tag_w2(`SPARC_CORE5.sparc0.tlu.tlu_itlb_tte_tag_w2), // Templated
            .tlu_itlb_tte_data_w2(`SPARC_CORE5.sparc0.tlu.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE5.sparc0.ifu.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE5.sparc0.lsu.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE5.sparc0.tlu.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE5.sparc0.tlu.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `else
		    .tlu_itlb_wr_vld_g	(`SPARC_CORE5.sparc0.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`SPARC_CORE5.sparc0.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`SPARC_CORE5.sparc0.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`SPARC_CORE5.sparc0.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE5.sparc0.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE5.sparc0.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE5.sparc0.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE5.sparc0.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `endif
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon5 (/*AUTOINST*/
			      // Inputs
    `ifndef RTL_SPU
                  .rtl_softint0(`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint0), // Templated
                  .rtl_softint1(`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint1), // Templated
                  .rtl_softint2(`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint2), // Templated
                  .rtl_softint3(`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint3), // Templated
                  .rtl_wsr_data_w(`SPARC_CORE5.sparc0.tlu.tlu.tdp.wsr_data_w), // Templated
                  .rtl_sftint_en_l_g(`SPARC_CORE5.sparc0.tlu.tlu.tdp.tlu_sftint_en_l_g), // Templated
                  .rtl_sftint_b0_en(`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint_b0_en), // Templated
                  .rtl_tickcmp_int(`SPARC_CORE5.sparc0.tlu.tlu.tdp.tickcmp_int), // Templated
                  .rtl_sftint_b16_en(`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint_b16_en), // Templated
                  .rtl_stickcmp_int(`SPARC_CORE5.sparc0.tlu.tlu.tdp.stickcmp_int), // Templated
                  .rtl_sftint_b15_en(`SPARC_CORE5.sparc0.tlu.tlu.tdp.sftint_b15_en), // Templated
                  .rtl_pib_picl_wrap(`SPARC_CORE5.sparc0.tlu.tlu.tdp.pib_picl_wrap), // Templated
                  .rtl_pib_pich_wrap(`SPARC_CORE5.sparc0.tlu.tlu.tdp.pib_pich_wrap), // Templated
                  .rtl_wr_sftint_l_g(`SPARC_CORE5.sparc0.tlu.tlu.tdp.tlu_wr_sftint_l_g), // Templated
                  .rtl_set_sftint_l_g(`SPARC_CORE5.sparc0.tlu.tlu.tdp.tlu_set_sftint_l_g), // Templated
                  .rtl_clr_sftint_l_g(`SPARC_CORE5.sparc0.tlu.tlu.tdp.tlu_clr_sftint_l_g), // Templated
                  .rtl_clk  (`SPARC_CORE5.sparc0.tlu.tlu.tdp.rclk), // Templated
                  .rtl_reset(`SPARC_CORE5.sparc0.tlu.tlu.tdp.tlu_rst), // Templated
    `else
			      .rtl_softint0(`SPARC_CORE5.sparc0.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`SPARC_CORE5.sparc0.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`SPARC_CORE5.sparc0.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`SPARC_CORE5.sparc0.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`SPARC_CORE5.sparc0.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`SPARC_CORE5.sparc0.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`SPARC_CORE5.sparc0.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`SPARC_CORE5.sparc0.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`SPARC_CORE5.sparc0.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`SPARC_CORE5.sparc0.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`SPARC_CORE5.sparc0.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`SPARC_CORE5.sparc0.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`SPARC_CORE5.sparc0.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`SPARC_CORE5.sparc0.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`SPARC_CORE5.sparc0.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`SPARC_CORE5.sparc0.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`SPARC_CORE5.sparc0.tlu.tdp.rclk), // Templated
			      .rtl_reset(`SPARC_CORE5.sparc0.tlu.tdp.tlu_rst), // Templated
    `endif
			      .core_id	(10'd5));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon5(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
`ifndef RTL_SPU
                .thr_state0 (`SPARC_CORE5.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
                .thr_state1 (`SPARC_CORE5.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
                .thr_state2 (`SPARC_CORE5.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
                .thr_state3 (`SPARC_CORE5.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
                .rstthr (`SPARC_CORE5.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
                .nukeint    (`SPARC_CORE5.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
                .resumint   (`SPARC_CORE5.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
                .rstint (`SPARC_CORE5.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`else
			    .thr_state0	(`SPARC_CORE5.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
			    .thr_state1	(`SPARC_CORE5.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
			    .thr_state2	(`SPARC_CORE5.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
			    .thr_state3	(`SPARC_CORE5.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
			    .rstthr	(`SPARC_CORE5.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			    .nukeint	(`SPARC_CORE5.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
			    .resumint	(`SPARC_CORE5.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
			    .rstint	(`SPARC_CORE5.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`endif
			    .coreid	(10'd5));			 // Templated
   mask_mon mask_mon5(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
`ifndef RTL_SPU
              .wm_imiss     (`SPARC_CORE5.sparc0.ifu.ifu.swl.wm_imiss), // Templated
              .wm_other     (`SPARC_CORE5.sparc0.ifu.ifu.swl.wm_other), // Templated
              .wm_stbwait   (`SPARC_CORE5.sparc0.ifu.ifu.swl.wm_stbwait), // Templated
              .mul_wait     (`SPARC_CORE5.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait     (`SPARC_CORE5.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait      (`SPARC_CORE5.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_busy_e   (`SPARC_CORE5.sparc0.ifu.ifu.swl.mul_busy_e), // Templated
              .div_busy_e   (`SPARC_CORE5.sparc0.ifu.ifu.swl.div_busy_e), // Templated
              .fp_busy_e    (`SPARC_CORE5.sparc0.ifu.ifu.swl.fp_busy_e), // Templated
              .ldmiss       (`SPARC_CORE5.sparc0.ifu.ifu.swl.ldmiss), // Templated
`else
		      .wm_imiss		(`SPARC_CORE5.sparc0.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`SPARC_CORE5.sparc0.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`SPARC_CORE5.sparc0.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`SPARC_CORE5.sparc0.ifu.swl.mul_wait), // Templated
		      .div_wait		(`SPARC_CORE5.sparc0.ifu.swl.div_wait), // Templated
		      .fp_wait		(`SPARC_CORE5.sparc0.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`SPARC_CORE5.sparc0.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`SPARC_CORE5.sparc0.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`SPARC_CORE5.sparc0.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`SPARC_CORE5.sparc0.ifu.swl.ldmiss), // Templated
`endif
		      .coreid		(10'd5));			 // Templated
   pc_muxsel_mon pc_muxsel_mon5(/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
`ifndef RTL_SPU
                .t0pc_f (`SPARC_CORE5.sparc0.ifu.ifu.fdp.t0pc_f[47:0]), // Templated
                .t1pc_f (`SPARC_CORE5.sparc0.ifu.ifu.fdp.t1pc_f[47:0]), // Templated
                .t2pc_f (`SPARC_CORE5.sparc0.ifu.ifu.fdp.t2pc_f[47:0]), // Templated
                .t3pc_f (`SPARC_CORE5.sparc0.ifu.ifu.fdp.t3pc_f[47:0]), // Templated
                .pc_f   (`SPARC_CORE5.sparc0.ifu.ifu.fdp.pc_f[47:0]), // Templated
                .inst_vld_f(`SPARC_CORE5.sparc0.ifu.ifu.fcl.inst_vld_f), // Templated
                .dtu_fcl_running_s(`SPARC_CORE5.sparc0.ifu.ifu.dtu_fcl_running_s), // Templated
                .thr_f  (`SPARC_CORE5.sparc0.ifu.ifu.fcl.thr_f[3:0]), // Templated
`else
				.t0pc_f	(`SPARC_CORE5.sparc0.ifu.fdp.t0pc_f[47:0]), // Templated
				.t1pc_f	(`SPARC_CORE5.sparc0.ifu.fdp.t1pc_f[47:0]), // Templated
				.t2pc_f	(`SPARC_CORE5.sparc0.ifu.fdp.t2pc_f[47:0]), // Templated
				.t3pc_f	(`SPARC_CORE5.sparc0.ifu.fdp.t3pc_f[47:0]), // Templated
				.pc_f	(`SPARC_CORE5.sparc0.ifu.fdp.pc_f[47:0]), // Templated
				.inst_vld_f(`SPARC_CORE5.sparc0.ifu.fcl.inst_vld_f), // Templated
				.dtu_fcl_running_s(`SPARC_CORE5.sparc0.ifu.dtu_fcl_running_s), // Templated
				.thr_f	(`SPARC_CORE5.sparc0.ifu.fcl.thr_f[3:0]), // Templated
`endif
				.coreid	(10'd5));			 // Templated
   stb_ovfl_mon stb_ovfl_mon5(/*AUTOINST*/
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
`ifndef RTL_SPU
                  .lsu_ifu_stbcnt3(`SPARC_CORE5.sparc0.ifu.ifu.lsu_ifu_stbcnt3), // Templated
                  .lsu_ifu_stbcnt2(`SPARC_CORE5.sparc0.ifu.ifu.lsu_ifu_stbcnt2), // Templated
                  .lsu_ifu_stbcnt1(`SPARC_CORE5.sparc0.ifu.ifu.lsu_ifu_stbcnt1), // Templated
                  .lsu_ifu_stbcnt0(`SPARC_CORE5.sparc0.ifu.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE5.sparc0.lsu.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE5.sparc0.lsu.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE5.sparc0.lsu.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE5.sparc0.lsu.lsu.stb_ctl0.reset), // Templated
`else
			      .lsu_ifu_stbcnt3(`SPARC_CORE5.sparc0.ifu.lsu_ifu_stbcnt3), // Templated
			      .lsu_ifu_stbcnt2(`SPARC_CORE5.sparc0.ifu.lsu_ifu_stbcnt2), // Templated
			      .lsu_ifu_stbcnt1(`SPARC_CORE5.sparc0.ifu.lsu_ifu_stbcnt1), // Templated
			      .lsu_ifu_stbcnt0(`SPARC_CORE5.sparc0.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE5.sparc0.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE5.sparc0.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE5.sparc0.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE5.sparc0.lsu.stb_ctl0.reset), // Templated
`endif
			      .coreid	(10'd5));			 // Templated
   icache_mutex_mon icache_mutex_mon5(/*AUTOINST*/
				      // Inputs
				      .clk(clk),
				      .rst_l(rst_l),
`ifndef RTL_SPU
                      .waysel_buf_s1(`SPARC_CORE5.sparc0.ifu.ifu.wseldp.waysel_buf_s1), // Templated
                      .alltag_err_s1(`SPARC_CORE5.sparc0.ifu.ifu.errctl.alltag_err_s1), // Templated
                      .tlb_cam_miss_s1(`SPARC_CORE5.sparc0.ifu.ifu.fcl.tlb_cam_miss_s1), // Templated
                      .cam_vld_s1(`SPARC_CORE5.sparc0.ifu.ifu.fcl.cam_vld_s1), // Templated
`else
				      .waysel_buf_s1(`SPARC_CORE5.sparc0.ifu.wseldp.waysel_buf_s1), // Templated
				      .alltag_err_s1(`SPARC_CORE5.sparc0.ifu.errctl.alltag_err_s1), // Templated
				      .tlb_cam_miss_s1(`SPARC_CORE5.sparc0.ifu.fcl.tlb_cam_miss_s1), // Templated
				      .cam_vld_s1(`SPARC_CORE5.sparc0.ifu.fcl.cam_vld_s1), // Templated
`endif
				      .coreid(10'd5));		 // Templated
   nc_inv_chk nc_inv_chk5(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .cpxpkt_vld   (`SPARC_CORE5.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
              .cpxpkt_rtntype(`SPARC_CORE5.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
              .nc       (`SPARC_CORE5.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
              .wv       (`SPARC_CORE5.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`else
			  .cpxpkt_vld	(`SPARC_CORE5.sparc0.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`SPARC_CORE5.sparc0.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`SPARC_CORE5.sparc0.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`SPARC_CORE5.sparc0.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`endif
			  .coreid	(10'd5));			 // Templated

       // trin: we don't have spu
       // spu_ma_mon spu_ma_mon5(/* AUTOINST*/
    			//   // Inputs
    			//   .clk		(clk),
    			//   .wrmi_mamul_1sthalf(`SPARC_CORE5.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    			//   .wrmi_mamul_2ndhalf(`SPARC_CORE5.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    			//   .wrmi_maaeqb_1sthalf(`SPARC_CORE5.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    			//   .wrmi_maaeqb_2ndhalf(`SPARC_CORE5.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    			//   .iptr		(`SPARC_CORE5.sparc0.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    			//   .iminus_lenminus1(`SPARC_CORE5.sparc0.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    			//   .mul_data	(`SPARC_CORE5.sparc0.spu.spu_madp.spu_madp_evedata[63:0]));


always @ (negedge clk)
begin
    // if (`SPARC_CORE5.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE5.sparc0.lsu.lsu.qctl2.dfq_inv_data_val === 1'bx))
    if (`SPARC_CORE5.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE5.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val === 1'bx))
    begin
        $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received X invalidation");
        `ifndef VERILATOR
        repeat(5)@(posedge clk);
        `endif
        `MONITOR_PATH.fail("TILE0 lsu received X invalidation");
    end

    // if (`SPARC_CORE5.sparc0.lsu.lsu.qctl2.dfq_inv_data_val)
    if (`SPARC_CORE5.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val)
    begin
        if (|`SPARC_CORE5.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_way === 1'bx)
        begin
            $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received invalid way invalidation");
            `ifndef VERILATOR
            repeat(5)@(posedge clk);
            `endif
            `MONITOR_PATH.fail("TILE0 lsu received invalid way invalidation");
        end
    end
end



    //   cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
    //				// Inputs
    //				.clk	(clk),
    //				.rst_l	(rst_l),
    //				.spc_pcx_data_pa(`PCXPATH5.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
    //				.cpx_spc_data_cx(`PCXPATH5.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
    //				.cpu	(0));
   `endif


   `ifdef RTL_SPARC6
   l_cache_mon l_cache_mon6(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(0),			 // Templated
			    .index_f	(`ICTPATH6.index_y[`IC_SET_IDX_HI:0]), // Templated
			    .wrreq_f	(`ICTPATH6.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH6.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH6.ifq_ict_wrtag_f[`IC_TAG_SZ:0]), // Templated
			    .wr_data	(`ICVPATH6.write_bit_y),	 // Templated
                // .wr_data    (`ICVPATH6.din_d1),  // Templated
			    .wren_f	(`ICVPATH6.write_mask_y[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH6.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH6.wr_adr[`IC_SET_IDX_HI:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH6.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH6.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`SPARC_CORE6.sparc0.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`SPARC_CORE6.sparc0.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon6(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .wm_imiss (`SPARC_CORE6.sparc0.ifu.ifu.swl.wm_imiss[3:0]), // Templated
              .wm_other (`SPARC_CORE6.sparc0.ifu.ifu.swl.wm_other[3:0]), // Templated
              .wm_stbwait   (`SPARC_CORE6.sparc0.ifu.ifu.swl.wm_stbwait[3:0]), // Templated
              .thr_state0   (`SPARC_CORE6.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
              .thr_state1   (`SPARC_CORE6.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
              .thr_state2   (`SPARC_CORE6.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
              .thr_state3   (`SPARC_CORE6.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
              .rst_stallreq (`SPARC_CORE6.sparc0.ifu.ifu.fcl.rst_stallreq), // Templated
              .ifq_fcl_stallreq(`SPARC_CORE6.sparc0.ifu.ifu.fcl.ifq_fcl_stallreq), // Templated
              .lsu_ifu_stallreq(`SPARC_CORE6.sparc0.ifu.ifu.fcl.lsu_ifu_stallreq), // Templated
              .ffu_ifu_stallreq(`SPARC_CORE6.sparc0.ifu.ifu.fcl.ffu_ifu_stallreq), // Templated
              .completion   (`SPARC_CORE6.sparc0.ifu.ifu.swl.completion), // Templated
              .mul_wait (`SPARC_CORE6.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait (`SPARC_CORE6.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait  (`SPARC_CORE6.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_wait_nxt (`SPARC_CORE6.sparc0.ifu.ifu.swl.mul_wait_nxt), // Templated
              .div_wait_nxt (`SPARC_CORE6.sparc0.ifu.ifu.swl.div_wait_nxt), // Templated
              .fp_wait_nxt  (`SPARC_CORE6.sparc0.ifu.ifu.swl.fp_wait_nxt), // Templated
              .mul_busy_d   (`SPARC_CORE6.sparc0.ifu.ifu.swl.mul_busy_d), // Templated
              .div_busy_d   (`SPARC_CORE6.sparc0.ifu.ifu.swl.div_busy_d), // Templated
              .fp_busy_d    (`SPARC_CORE6.sparc0.ifu.ifu.swl.fp_busy_d), // Templated
              .ifet_ue_vec_d1(`SPARC_CORE6.sparc0.ifu.ifu.fcl.ifet_ue_vec_d1), // Templated
`else
			  .wm_imiss	(`SPARC_CORE6.sparc0.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`SPARC_CORE6.sparc0.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`SPARC_CORE6.sparc0.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`SPARC_CORE6.sparc0.ifu.swl.thr0_state[4:0]), // Templated
			  .thr_state1	(`SPARC_CORE6.sparc0.ifu.swl.thr1_state[4:0]), // Templated
			  .thr_state2	(`SPARC_CORE6.sparc0.ifu.swl.thr2_state[4:0]), // Templated
			  .thr_state3	(`SPARC_CORE6.sparc0.ifu.swl.thr3_state[4:0]), // Templated
			  .rst_stallreq	(`SPARC_CORE6.sparc0.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`SPARC_CORE6.sparc0.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`SPARC_CORE6.sparc0.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`SPARC_CORE6.sparc0.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`SPARC_CORE6.sparc0.ifu.swl.completion), // Templated
			  .mul_wait	(`SPARC_CORE6.sparc0.ifu.swl.mul_wait), // Templated
			  .div_wait	(`SPARC_CORE6.sparc0.ifu.swl.div_wait), // Templated
			  .fp_wait	(`SPARC_CORE6.sparc0.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`SPARC_CORE6.sparc0.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`SPARC_CORE6.sparc0.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`SPARC_CORE6.sparc0.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`SPARC_CORE6.sparc0.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`SPARC_CORE6.sparc0.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`SPARC_CORE6.sparc0.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`SPARC_CORE6.sparc0.ifu.fcl.ifet_ue_vec_d1), // Templated
`endif
			  .cpu_id	(10'd6));			 // Templated
   exu_mon exu_mon6(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH6.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH6.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH6.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH6.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH6.irf.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH6.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH6.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon6(/*AUTOINST*/
		    // Inputs
    `ifndef RTL_SPU
            .clk        (`SPARC_CORE6.sparc0.tlu.tlu.rclk), // Templated
            .grst_l     (`SPARC_CORE6.sparc0.tlu.tlu.grst_l), // Templated
            .rst_l      (`SPARC_CORE6.sparc0.tlu.tlu.tcl.tlu_rst_l), // Templated
    `else
		    .clk		(`SPARC_CORE6.sparc0.tlu.rclk), // Templated
		    .grst_l		(`SPARC_CORE6.sparc0.tlu.grst_l), // Templated
		    .rst_l		(`SPARC_CORE6.sparc0.tlu.tcl.tlu_rst_l), // Templated
    `endif
			.lsu_ifu_flush_pipe_w	(`SPARC_CORE6.sparc0.lsu_ifu_flush_pipe_w),
    `ifndef RTL_SPU
            .tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE6.sparc0.tlu.tlu_lsu_int_ldxa_vld_w2),
            .tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE6.sparc0.tlu.tlu_lsu_int_ld_ill_va_w2),
            .tlu_scpd_wr_vld_g      (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
            .cpu_mondo_head_wr_g    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
            .cpu_mondo_tail_wr_g    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
            .dev_mondo_head_wr_g    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_head_wr_g),
            .dev_mondo_tail_wr_g    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
            .resum_err_head_wr_g    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.resum_err_head_wr_g),
            .resum_err_tail_wr_g    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.resum_err_tail_wr_g),
            .nresum_err_head_wr_g   (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.nresum_err_head_wr_g),
            .nresum_err_tail_wr_g   (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.nresum_err_tail_wr_g),
            .ifu_lsu_ld_inst_e      (`SPARC_CORE6.sparc0.tlu.tlu.ifu_lsu_ld_inst_e),
            .ifu_lsu_st_inst_e      (`SPARC_CORE6.sparc0.tlu.tlu.ifu_lsu_st_inst_e),
            .ifu_lsu_alt_space_e    (`SPARC_CORE6.sparc0.tlu.tlu.ifu_lsu_alt_space_e),
            .tlu_early_flush_pipe_w (`SPARC_CORE6.sparc0.tlu.tlu.tlu_early_flush_pipe_w),
            .tlu_asi_state_e        (`SPARC_CORE6.sparc0.tlu.tlu.tlu_asi_state_e),
            .exu_lsu_ldst_va_e      (`SPARC_CORE6.sparc0.tlu.tlu.exu_lsu_ldst_va_e),
            .por_rstint0_w2 (`SPARC_CORE6.sparc0.tlu.tlu.tcl.por_rstint0_w2),
            .por_rstint1_w2 (`SPARC_CORE6.sparc0.tlu.tlu.tcl.por_rstint1_w2),
            .por_rstint2_w2 (`SPARC_CORE6.sparc0.tlu.tlu.tcl.por_rstint2_w2),
            .por_rstint3_w2 (`SPARC_CORE6.sparc0.tlu.tlu.tcl.por_rstint3_w2),
            .tlu_gl_lvl0    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.gl_lvl0),
            .tlu_gl_lvl1    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.gl_lvl1),
            .tlu_gl_lvl2    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.gl_lvl2),
            .tlu_gl_lvl3    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hyperv.gl_lvl3),
    `else
			.tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE6.sparc0.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE6.sparc0.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`SPARC_CORE6.sparc0.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`SPARC_CORE6.sparc0.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`SPARC_CORE6.sparc0.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`SPARC_CORE6.sparc0.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`SPARC_CORE6.sparc0.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`SPARC_CORE6.sparc0.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`SPARC_CORE6.sparc0.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`SPARC_CORE6.sparc0.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`SPARC_CORE6.sparc0.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`SPARC_CORE6.sparc0.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`SPARC_CORE6.sparc0.tlu.tlu_hyperv.gl_lvl3),
    `endif
            .exu_gl_lvl0	(`SPARC_CORE6.sparc0.exu.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`SPARC_CORE6.sparc0.exu.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`SPARC_CORE6.sparc0.exu.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`SPARC_CORE6.sparc0.exu.exu.rml.agp_thr3_next),
    `ifndef RTL_SPU
            .ifu_tlu_thrid_d    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
            .ifu_tlu_inst_vld_m (`SPARC_CORE6.sparc0.tlu.tlu.ifu_tlu_inst_vld_m), // Templated
            .ifu_tlu_imiss_e    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
            .ifu_tlu_immu_miss_m(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
            .tlu_thread_inst_vld_g(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
            .tlu_thread_wsel_g  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
            .ifu_tlu_l2imiss    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .ifu_tlu_flush_fd_w (`SPARC_CORE6.sparc0.tlu.tlu.ifu_tlu_flush_fd_w), // Templated
            .ifu_tlu_sraddr_d   (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
            .ifu_tlu_rsr_inst_d (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
            .lsu_tlu_wsr_inst_e (`SPARC_CORE6.sparc0.tlu.tlu.lsu_tlu_wsr_inst_e), // Templated
            .tlu_wsr_inst_nq_g  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
            .tlu_wsr_data_w (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.tlu_wsr_data_w), // Templated
            .lsu_tlu_dcache_miss_w2(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .lsu_tlu_l2_dmiss   (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .lsu_tlu_stb_full_w2(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .lsu_tlu_dmmu_miss_g(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
            .ffu_tlu_fpu_tid    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
            .ffu_tlu_fpu_cmplt  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
            .tlu_pstate_priv    (`SPARC_CORE6.sparc0.tlu.tlu.local_pstate_priv), // Templated
            .tlu_hpstate_priv   (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hpstate_priv), // Templated
            .tlu_hpstate_enb    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_hpstate_enb), // Templated
            .tlu_pstate_ie  (`SPARC_CORE6.sparc0.tlu.tlu.local_pstate_ie), // Templated
            .wsr_thread_inst_g  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.wsr_thread_inst_g), // Templated
            .lsu_tlu_defr_trp_taken_g(`SPARC_CORE6.sparc0.tlu.tlu.lsu_tlu_defr_trp_taken_g), // Templated
            .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE6.sparc0.tlu.tlu.lsu_tlu_async_ttype_vld_g), // Templated
            .lsu_tlu_ttype_vld_m2(`SPARC_CORE6.sparc0.tlu.tlu.lsu_tlu_ttype_vld_m2), // Templated
            .tlu_ifu_flush_pipe_w(`SPARC_CORE6.sparc0.tlu.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
            .tcc_inst_w2    (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.tcc_inst_w2), // Templated
            .tlu_pib_rsr_data_e (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
            .tlu_pib_priv_act_trap_m(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
            .tlu_pib_picl_wrap  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pib_picl_wrap), // Templated
            .tlu_pib_pich_wrap  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pich_onebelow_flg), // Templated
            .tlu_ifu_trappc_vld_w1(`SPARC_CORE6.sparc0.tlu.tlu.tlu_ifu_trappc_vld_w1), // Templated
            .tlu_ifu_trappc_w2  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_ifu_trappc_w2), // Templated
            .tlu_final_ttype_w2 (`SPARC_CORE6.sparc0.tlu.tlu.tlu_final_ttype_w2), // Templated
            .tlu_ifu_trap_tid_w1(`SPARC_CORE6.sparc0.tlu.tlu.tlu_ifu_trap_tid_w1), // Templated
            .tlu_full_flush_pipe_w2(`SPARC_CORE6.sparc0.tlu.tlu.tlu_full_flush_pipe_w2), // Templated
            .rtl_pcr0       (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pcr0), // Templated
            .rtl_pcr1       (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pcr1), // Templated
            .rtl_pcr2       (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pcr2), // Templated
            .rtl_pcr3       (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pcr3), // Templated
            .rtl_pich_cnt0  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pich_cnt0), // Templated
            .rtl_pich_cnt1  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pich_cnt1), // Templated
            .rtl_pich_cnt2  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pich_cnt2), // Templated
            .rtl_pich_cnt3  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.pich_cnt3), // Templated
            .rtl_picl_cnt0  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.picl_cnt0), // Templated
            .rtl_picl_cnt1  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.picl_cnt1), // Templated
            .rtl_picl_cnt2  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.picl_cnt2), // Templated
            .rtl_picl_cnt3  (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.picl_cnt3), // Templated
            .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .rtl_fpu_cmplt_thread(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.fpu_cmplt_thread), // Templated
            .rtl_imiss_thread_g (`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.imiss_thread_g), // Templated
            .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .rtl_immu_miss_thread_g(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.immu_miss_thread_g), // Templated
            .rtl_dmmu_miss_thread_g(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
            .rtl_ifu_tlu_l2imiss(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE6.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .true_pil0      (`SPARC_CORE6.sparc0.tlu.tlu.tcl.true_pil0), // Templated
            .true_pil1      (`SPARC_CORE6.sparc0.tlu.tlu.tcl.true_pil1), // Templated
            .true_pil2      (`SPARC_CORE6.sparc0.tlu.tlu.tcl.true_pil2), // Templated
            .true_pil3      (`SPARC_CORE6.sparc0.tlu.tlu.tcl.true_pil3), // Templated
            .rtl_trp_lvl0   (`SPARC_CORE6.sparc0.tlu.tlu.tcl.trp_lvl0), // Templated
            .rtl_trp_lvl1   (`SPARC_CORE6.sparc0.tlu.tlu.tcl.trp_lvl1), // Templated
            .rtl_trp_lvl2   (`SPARC_CORE6.sparc0.tlu.tlu.tcl.trp_lvl2), // Templated
            .rtl_trp_lvl3   (`SPARC_CORE6.sparc0.tlu.tlu.tcl.trp_lvl3), // Templated
            .tlz_thread     (`SPARC_CORE6.sparc0.tlu.tlu.tcl.tlz_thread), // Templated
            .th0_sftint_15  (`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint0[15]), // Templated
            .th1_sftint_15  (`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint1[15]), // Templated
            .th2_sftint_15  (`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint2[15]), // Templated
            .th3_sftint_15  (`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint3[15]), // Templated
            .ifu_swint_g    (`SPARC_CORE6.sparc0.tlu.tlu.tcl.swint_g), // Templated
    `else
		    .ifu_tlu_thrid_d	(`SPARC_CORE6.sparc0.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`SPARC_CORE6.sparc0.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`SPARC_CORE6.sparc0.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`SPARC_CORE6.sparc0.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`SPARC_CORE6.sparc0.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`SPARC_CORE6.sparc0.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`SPARC_CORE6.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`SPARC_CORE6.sparc0.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`SPARC_CORE6.sparc0.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`SPARC_CORE6.sparc0.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`SPARC_CORE6.sparc0.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`SPARC_CORE6.sparc0.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`SPARC_CORE6.sparc0.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`SPARC_CORE6.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`SPARC_CORE6.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`SPARC_CORE6.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`SPARC_CORE6.sparc0.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`SPARC_CORE6.sparc0.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`SPARC_CORE6.sparc0.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`SPARC_CORE6.sparc0.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`SPARC_CORE6.sparc0.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`SPARC_CORE6.sparc0.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`SPARC_CORE6.sparc0.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`SPARC_CORE6.sparc0.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`SPARC_CORE6.sparc0.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE6.sparc0.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`SPARC_CORE6.sparc0.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`SPARC_CORE6.sparc0.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`SPARC_CORE6.sparc0.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`SPARC_CORE6.sparc0.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`SPARC_CORE6.sparc0.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`SPARC_CORE6.sparc0.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`SPARC_CORE6.sparc0.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`SPARC_CORE6.sparc0.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`SPARC_CORE6.sparc0.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`SPARC_CORE6.sparc0.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`SPARC_CORE6.sparc0.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`SPARC_CORE6.sparc0.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`SPARC_CORE6.sparc0.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`SPARC_CORE6.sparc0.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`SPARC_CORE6.sparc0.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`SPARC_CORE6.sparc0.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`SPARC_CORE6.sparc0.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`SPARC_CORE6.sparc0.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`SPARC_CORE6.sparc0.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`SPARC_CORE6.sparc0.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`SPARC_CORE6.sparc0.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`SPARC_CORE6.sparc0.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`SPARC_CORE6.sparc0.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`SPARC_CORE6.sparc0.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE6.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`SPARC_CORE6.sparc0.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`SPARC_CORE6.sparc0.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE6.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`SPARC_CORE6.sparc0.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`SPARC_CORE6.sparc0.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`SPARC_CORE6.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE6.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`SPARC_CORE6.sparc0.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`SPARC_CORE6.sparc0.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`SPARC_CORE6.sparc0.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`SPARC_CORE6.sparc0.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`SPARC_CORE6.sparc0.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`SPARC_CORE6.sparc0.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`SPARC_CORE6.sparc0.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`SPARC_CORE6.sparc0.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`SPARC_CORE6.sparc0.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`SPARC_CORE6.sparc0.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`SPARC_CORE6.sparc0.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`SPARC_CORE6.sparc0.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`SPARC_CORE6.sparc0.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`SPARC_CORE6.sparc0.tlu.tcl.swint_g), // Templated
    `endif
		    .core_id		(10'd6),			 // Templated
    `ifndef RTL_SPU
            .tlu_itlb_wr_vld_g  (`SPARC_CORE6.sparc0.tlu.tlu_itlb_wr_vld_g), // Templated
            .tlu_itlb_dmp_vld_g (`SPARC_CORE6.sparc0.tlu.tlu_itlb_dmp_vld_g), // Templated
            .tlu_itlb_tte_tag_w2(`SPARC_CORE6.sparc0.tlu.tlu_itlb_tte_tag_w2), // Templated
            .tlu_itlb_tte_data_w2(`SPARC_CORE6.sparc0.tlu.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE6.sparc0.ifu.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE6.sparc0.lsu.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE6.sparc0.tlu.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE6.sparc0.tlu.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `else
		    .tlu_itlb_wr_vld_g	(`SPARC_CORE6.sparc0.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`SPARC_CORE6.sparc0.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`SPARC_CORE6.sparc0.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`SPARC_CORE6.sparc0.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE6.sparc0.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE6.sparc0.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE6.sparc0.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE6.sparc0.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `endif
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon6 (/*AUTOINST*/
			      // Inputs
    `ifndef RTL_SPU
                  .rtl_softint0(`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint0), // Templated
                  .rtl_softint1(`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint1), // Templated
                  .rtl_softint2(`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint2), // Templated
                  .rtl_softint3(`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint3), // Templated
                  .rtl_wsr_data_w(`SPARC_CORE6.sparc0.tlu.tlu.tdp.wsr_data_w), // Templated
                  .rtl_sftint_en_l_g(`SPARC_CORE6.sparc0.tlu.tlu.tdp.tlu_sftint_en_l_g), // Templated
                  .rtl_sftint_b0_en(`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint_b0_en), // Templated
                  .rtl_tickcmp_int(`SPARC_CORE6.sparc0.tlu.tlu.tdp.tickcmp_int), // Templated
                  .rtl_sftint_b16_en(`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint_b16_en), // Templated
                  .rtl_stickcmp_int(`SPARC_CORE6.sparc0.tlu.tlu.tdp.stickcmp_int), // Templated
                  .rtl_sftint_b15_en(`SPARC_CORE6.sparc0.tlu.tlu.tdp.sftint_b15_en), // Templated
                  .rtl_pib_picl_wrap(`SPARC_CORE6.sparc0.tlu.tlu.tdp.pib_picl_wrap), // Templated
                  .rtl_pib_pich_wrap(`SPARC_CORE6.sparc0.tlu.tlu.tdp.pib_pich_wrap), // Templated
                  .rtl_wr_sftint_l_g(`SPARC_CORE6.sparc0.tlu.tlu.tdp.tlu_wr_sftint_l_g), // Templated
                  .rtl_set_sftint_l_g(`SPARC_CORE6.sparc0.tlu.tlu.tdp.tlu_set_sftint_l_g), // Templated
                  .rtl_clr_sftint_l_g(`SPARC_CORE6.sparc0.tlu.tlu.tdp.tlu_clr_sftint_l_g), // Templated
                  .rtl_clk  (`SPARC_CORE6.sparc0.tlu.tlu.tdp.rclk), // Templated
                  .rtl_reset(`SPARC_CORE6.sparc0.tlu.tlu.tdp.tlu_rst), // Templated
    `else
			      .rtl_softint0(`SPARC_CORE6.sparc0.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`SPARC_CORE6.sparc0.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`SPARC_CORE6.sparc0.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`SPARC_CORE6.sparc0.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`SPARC_CORE6.sparc0.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`SPARC_CORE6.sparc0.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`SPARC_CORE6.sparc0.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`SPARC_CORE6.sparc0.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`SPARC_CORE6.sparc0.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`SPARC_CORE6.sparc0.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`SPARC_CORE6.sparc0.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`SPARC_CORE6.sparc0.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`SPARC_CORE6.sparc0.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`SPARC_CORE6.sparc0.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`SPARC_CORE6.sparc0.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`SPARC_CORE6.sparc0.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`SPARC_CORE6.sparc0.tlu.tdp.rclk), // Templated
			      .rtl_reset(`SPARC_CORE6.sparc0.tlu.tdp.tlu_rst), // Templated
    `endif
			      .core_id	(10'd6));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon6(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
`ifndef RTL_SPU
                .thr_state0 (`SPARC_CORE6.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
                .thr_state1 (`SPARC_CORE6.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
                .thr_state2 (`SPARC_CORE6.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
                .thr_state3 (`SPARC_CORE6.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
                .rstthr (`SPARC_CORE6.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
                .nukeint    (`SPARC_CORE6.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
                .resumint   (`SPARC_CORE6.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
                .rstint (`SPARC_CORE6.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`else
			    .thr_state0	(`SPARC_CORE6.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
			    .thr_state1	(`SPARC_CORE6.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
			    .thr_state2	(`SPARC_CORE6.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
			    .thr_state3	(`SPARC_CORE6.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
			    .rstthr	(`SPARC_CORE6.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			    .nukeint	(`SPARC_CORE6.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
			    .resumint	(`SPARC_CORE6.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
			    .rstint	(`SPARC_CORE6.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`endif
			    .coreid	(10'd6));			 // Templated
   mask_mon mask_mon6(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
`ifndef RTL_SPU
              .wm_imiss     (`SPARC_CORE6.sparc0.ifu.ifu.swl.wm_imiss), // Templated
              .wm_other     (`SPARC_CORE6.sparc0.ifu.ifu.swl.wm_other), // Templated
              .wm_stbwait   (`SPARC_CORE6.sparc0.ifu.ifu.swl.wm_stbwait), // Templated
              .mul_wait     (`SPARC_CORE6.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait     (`SPARC_CORE6.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait      (`SPARC_CORE6.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_busy_e   (`SPARC_CORE6.sparc0.ifu.ifu.swl.mul_busy_e), // Templated
              .div_busy_e   (`SPARC_CORE6.sparc0.ifu.ifu.swl.div_busy_e), // Templated
              .fp_busy_e    (`SPARC_CORE6.sparc0.ifu.ifu.swl.fp_busy_e), // Templated
              .ldmiss       (`SPARC_CORE6.sparc0.ifu.ifu.swl.ldmiss), // Templated
`else
		      .wm_imiss		(`SPARC_CORE6.sparc0.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`SPARC_CORE6.sparc0.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`SPARC_CORE6.sparc0.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`SPARC_CORE6.sparc0.ifu.swl.mul_wait), // Templated
		      .div_wait		(`SPARC_CORE6.sparc0.ifu.swl.div_wait), // Templated
		      .fp_wait		(`SPARC_CORE6.sparc0.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`SPARC_CORE6.sparc0.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`SPARC_CORE6.sparc0.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`SPARC_CORE6.sparc0.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`SPARC_CORE6.sparc0.ifu.swl.ldmiss), // Templated
`endif
		      .coreid		(10'd6));			 // Templated
   pc_muxsel_mon pc_muxsel_mon6(/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
`ifndef RTL_SPU
                .t0pc_f (`SPARC_CORE6.sparc0.ifu.ifu.fdp.t0pc_f[47:0]), // Templated
                .t1pc_f (`SPARC_CORE6.sparc0.ifu.ifu.fdp.t1pc_f[47:0]), // Templated
                .t2pc_f (`SPARC_CORE6.sparc0.ifu.ifu.fdp.t2pc_f[47:0]), // Templated
                .t3pc_f (`SPARC_CORE6.sparc0.ifu.ifu.fdp.t3pc_f[47:0]), // Templated
                .pc_f   (`SPARC_CORE6.sparc0.ifu.ifu.fdp.pc_f[47:0]), // Templated
                .inst_vld_f(`SPARC_CORE6.sparc0.ifu.ifu.fcl.inst_vld_f), // Templated
                .dtu_fcl_running_s(`SPARC_CORE6.sparc0.ifu.ifu.dtu_fcl_running_s), // Templated
                .thr_f  (`SPARC_CORE6.sparc0.ifu.ifu.fcl.thr_f[3:0]), // Templated
`else
				.t0pc_f	(`SPARC_CORE6.sparc0.ifu.fdp.t0pc_f[47:0]), // Templated
				.t1pc_f	(`SPARC_CORE6.sparc0.ifu.fdp.t1pc_f[47:0]), // Templated
				.t2pc_f	(`SPARC_CORE6.sparc0.ifu.fdp.t2pc_f[47:0]), // Templated
				.t3pc_f	(`SPARC_CORE6.sparc0.ifu.fdp.t3pc_f[47:0]), // Templated
				.pc_f	(`SPARC_CORE6.sparc0.ifu.fdp.pc_f[47:0]), // Templated
				.inst_vld_f(`SPARC_CORE6.sparc0.ifu.fcl.inst_vld_f), // Templated
				.dtu_fcl_running_s(`SPARC_CORE6.sparc0.ifu.dtu_fcl_running_s), // Templated
				.thr_f	(`SPARC_CORE6.sparc0.ifu.fcl.thr_f[3:0]), // Templated
`endif
				.coreid	(10'd6));			 // Templated
   stb_ovfl_mon stb_ovfl_mon6(/*AUTOINST*/
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
`ifndef RTL_SPU
                  .lsu_ifu_stbcnt3(`SPARC_CORE6.sparc0.ifu.ifu.lsu_ifu_stbcnt3), // Templated
                  .lsu_ifu_stbcnt2(`SPARC_CORE6.sparc0.ifu.ifu.lsu_ifu_stbcnt2), // Templated
                  .lsu_ifu_stbcnt1(`SPARC_CORE6.sparc0.ifu.ifu.lsu_ifu_stbcnt1), // Templated
                  .lsu_ifu_stbcnt0(`SPARC_CORE6.sparc0.ifu.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE6.sparc0.lsu.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE6.sparc0.lsu.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE6.sparc0.lsu.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE6.sparc0.lsu.lsu.stb_ctl0.reset), // Templated
`else
			      .lsu_ifu_stbcnt3(`SPARC_CORE6.sparc0.ifu.lsu_ifu_stbcnt3), // Templated
			      .lsu_ifu_stbcnt2(`SPARC_CORE6.sparc0.ifu.lsu_ifu_stbcnt2), // Templated
			      .lsu_ifu_stbcnt1(`SPARC_CORE6.sparc0.ifu.lsu_ifu_stbcnt1), // Templated
			      .lsu_ifu_stbcnt0(`SPARC_CORE6.sparc0.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE6.sparc0.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE6.sparc0.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE6.sparc0.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE6.sparc0.lsu.stb_ctl0.reset), // Templated
`endif
			      .coreid	(10'd6));			 // Templated
   icache_mutex_mon icache_mutex_mon6(/*AUTOINST*/
				      // Inputs
				      .clk(clk),
				      .rst_l(rst_l),
`ifndef RTL_SPU
                      .waysel_buf_s1(`SPARC_CORE6.sparc0.ifu.ifu.wseldp.waysel_buf_s1), // Templated
                      .alltag_err_s1(`SPARC_CORE6.sparc0.ifu.ifu.errctl.alltag_err_s1), // Templated
                      .tlb_cam_miss_s1(`SPARC_CORE6.sparc0.ifu.ifu.fcl.tlb_cam_miss_s1), // Templated
                      .cam_vld_s1(`SPARC_CORE6.sparc0.ifu.ifu.fcl.cam_vld_s1), // Templated
`else
				      .waysel_buf_s1(`SPARC_CORE6.sparc0.ifu.wseldp.waysel_buf_s1), // Templated
				      .alltag_err_s1(`SPARC_CORE6.sparc0.ifu.errctl.alltag_err_s1), // Templated
				      .tlb_cam_miss_s1(`SPARC_CORE6.sparc0.ifu.fcl.tlb_cam_miss_s1), // Templated
				      .cam_vld_s1(`SPARC_CORE6.sparc0.ifu.fcl.cam_vld_s1), // Templated
`endif
				      .coreid(10'd6));		 // Templated
   nc_inv_chk nc_inv_chk6(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .cpxpkt_vld   (`SPARC_CORE6.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
              .cpxpkt_rtntype(`SPARC_CORE6.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
              .nc       (`SPARC_CORE6.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
              .wv       (`SPARC_CORE6.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`else
			  .cpxpkt_vld	(`SPARC_CORE6.sparc0.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`SPARC_CORE6.sparc0.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`SPARC_CORE6.sparc0.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`SPARC_CORE6.sparc0.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`endif
			  .coreid	(10'd6));			 // Templated

       // trin: we don't have spu
       // spu_ma_mon spu_ma_mon6(/* AUTOINST*/
    			//   // Inputs
    			//   .clk		(clk),
    			//   .wrmi_mamul_1sthalf(`SPARC_CORE6.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    			//   .wrmi_mamul_2ndhalf(`SPARC_CORE6.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    			//   .wrmi_maaeqb_1sthalf(`SPARC_CORE6.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    			//   .wrmi_maaeqb_2ndhalf(`SPARC_CORE6.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    			//   .iptr		(`SPARC_CORE6.sparc0.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    			//   .iminus_lenminus1(`SPARC_CORE6.sparc0.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    			//   .mul_data	(`SPARC_CORE6.sparc0.spu.spu_madp.spu_madp_evedata[63:0]));


always @ (negedge clk)
begin
    // if (`SPARC_CORE6.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE6.sparc0.lsu.lsu.qctl2.dfq_inv_data_val === 1'bx))
    if (`SPARC_CORE6.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE6.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val === 1'bx))
    begin
        $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received X invalidation");
        `ifndef VERILATOR
        repeat(5)@(posedge clk);
        `endif
        `MONITOR_PATH.fail("TILE0 lsu received X invalidation");
    end

    // if (`SPARC_CORE6.sparc0.lsu.lsu.qctl2.dfq_inv_data_val)
    if (`SPARC_CORE6.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val)
    begin
        if (|`SPARC_CORE6.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_way === 1'bx)
        begin
            $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received invalid way invalidation");
            `ifndef VERILATOR
            repeat(5)@(posedge clk);
            `endif
            `MONITOR_PATH.fail("TILE0 lsu received invalid way invalidation");
        end
    end
end



    //   cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
    //				// Inputs
    //				.clk	(clk),
    //				.rst_l	(rst_l),
    //				.spc_pcx_data_pa(`PCXPATH6.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
    //				.cpx_spc_data_cx(`PCXPATH6.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
    //				.cpu	(0));
   `endif


   `ifdef RTL_SPARC7
   l_cache_mon l_cache_mon7(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(0),			 // Templated
			    .index_f	(`ICTPATH7.index_y[`IC_SET_IDX_HI:0]), // Templated
			    .wrreq_f	(`ICTPATH7.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH7.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH7.ifq_ict_wrtag_f[`IC_TAG_SZ:0]), // Templated
			    .wr_data	(`ICVPATH7.write_bit_y),	 // Templated
                // .wr_data    (`ICVPATH7.din_d1),  // Templated
			    .wren_f	(`ICVPATH7.write_mask_y[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH7.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH7.wr_adr[`IC_SET_IDX_HI:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH7.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH7.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`SPARC_CORE7.sparc0.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`SPARC_CORE7.sparc0.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon7(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .wm_imiss (`SPARC_CORE7.sparc0.ifu.ifu.swl.wm_imiss[3:0]), // Templated
              .wm_other (`SPARC_CORE7.sparc0.ifu.ifu.swl.wm_other[3:0]), // Templated
              .wm_stbwait   (`SPARC_CORE7.sparc0.ifu.ifu.swl.wm_stbwait[3:0]), // Templated
              .thr_state0   (`SPARC_CORE7.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
              .thr_state1   (`SPARC_CORE7.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
              .thr_state2   (`SPARC_CORE7.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
              .thr_state3   (`SPARC_CORE7.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
              .rst_stallreq (`SPARC_CORE7.sparc0.ifu.ifu.fcl.rst_stallreq), // Templated
              .ifq_fcl_stallreq(`SPARC_CORE7.sparc0.ifu.ifu.fcl.ifq_fcl_stallreq), // Templated
              .lsu_ifu_stallreq(`SPARC_CORE7.sparc0.ifu.ifu.fcl.lsu_ifu_stallreq), // Templated
              .ffu_ifu_stallreq(`SPARC_CORE7.sparc0.ifu.ifu.fcl.ffu_ifu_stallreq), // Templated
              .completion   (`SPARC_CORE7.sparc0.ifu.ifu.swl.completion), // Templated
              .mul_wait (`SPARC_CORE7.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait (`SPARC_CORE7.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait  (`SPARC_CORE7.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_wait_nxt (`SPARC_CORE7.sparc0.ifu.ifu.swl.mul_wait_nxt), // Templated
              .div_wait_nxt (`SPARC_CORE7.sparc0.ifu.ifu.swl.div_wait_nxt), // Templated
              .fp_wait_nxt  (`SPARC_CORE7.sparc0.ifu.ifu.swl.fp_wait_nxt), // Templated
              .mul_busy_d   (`SPARC_CORE7.sparc0.ifu.ifu.swl.mul_busy_d), // Templated
              .div_busy_d   (`SPARC_CORE7.sparc0.ifu.ifu.swl.div_busy_d), // Templated
              .fp_busy_d    (`SPARC_CORE7.sparc0.ifu.ifu.swl.fp_busy_d), // Templated
              .ifet_ue_vec_d1(`SPARC_CORE7.sparc0.ifu.ifu.fcl.ifet_ue_vec_d1), // Templated
`else
			  .wm_imiss	(`SPARC_CORE7.sparc0.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`SPARC_CORE7.sparc0.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`SPARC_CORE7.sparc0.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`SPARC_CORE7.sparc0.ifu.swl.thr0_state[4:0]), // Templated
			  .thr_state1	(`SPARC_CORE7.sparc0.ifu.swl.thr1_state[4:0]), // Templated
			  .thr_state2	(`SPARC_CORE7.sparc0.ifu.swl.thr2_state[4:0]), // Templated
			  .thr_state3	(`SPARC_CORE7.sparc0.ifu.swl.thr3_state[4:0]), // Templated
			  .rst_stallreq	(`SPARC_CORE7.sparc0.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`SPARC_CORE7.sparc0.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`SPARC_CORE7.sparc0.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`SPARC_CORE7.sparc0.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`SPARC_CORE7.sparc0.ifu.swl.completion), // Templated
			  .mul_wait	(`SPARC_CORE7.sparc0.ifu.swl.mul_wait), // Templated
			  .div_wait	(`SPARC_CORE7.sparc0.ifu.swl.div_wait), // Templated
			  .fp_wait	(`SPARC_CORE7.sparc0.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`SPARC_CORE7.sparc0.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`SPARC_CORE7.sparc0.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`SPARC_CORE7.sparc0.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`SPARC_CORE7.sparc0.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`SPARC_CORE7.sparc0.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`SPARC_CORE7.sparc0.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`SPARC_CORE7.sparc0.ifu.fcl.ifet_ue_vec_d1), // Templated
`endif
			  .cpu_id	(10'd7));			 // Templated
   exu_mon exu_mon7(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH7.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH7.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH7.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH7.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH7.irf.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH7.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH7.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon7(/*AUTOINST*/
		    // Inputs
    `ifndef RTL_SPU
            .clk        (`SPARC_CORE7.sparc0.tlu.tlu.rclk), // Templated
            .grst_l     (`SPARC_CORE7.sparc0.tlu.tlu.grst_l), // Templated
            .rst_l      (`SPARC_CORE7.sparc0.tlu.tlu.tcl.tlu_rst_l), // Templated
    `else
		    .clk		(`SPARC_CORE7.sparc0.tlu.rclk), // Templated
		    .grst_l		(`SPARC_CORE7.sparc0.tlu.grst_l), // Templated
		    .rst_l		(`SPARC_CORE7.sparc0.tlu.tcl.tlu_rst_l), // Templated
    `endif
			.lsu_ifu_flush_pipe_w	(`SPARC_CORE7.sparc0.lsu_ifu_flush_pipe_w),
    `ifndef RTL_SPU
            .tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE7.sparc0.tlu.tlu_lsu_int_ldxa_vld_w2),
            .tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE7.sparc0.tlu.tlu_lsu_int_ld_ill_va_w2),
            .tlu_scpd_wr_vld_g      (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
            .cpu_mondo_head_wr_g    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
            .cpu_mondo_tail_wr_g    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
            .dev_mondo_head_wr_g    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_head_wr_g),
            .dev_mondo_tail_wr_g    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
            .resum_err_head_wr_g    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.resum_err_head_wr_g),
            .resum_err_tail_wr_g    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.resum_err_tail_wr_g),
            .nresum_err_head_wr_g   (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.nresum_err_head_wr_g),
            .nresum_err_tail_wr_g   (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.nresum_err_tail_wr_g),
            .ifu_lsu_ld_inst_e      (`SPARC_CORE7.sparc0.tlu.tlu.ifu_lsu_ld_inst_e),
            .ifu_lsu_st_inst_e      (`SPARC_CORE7.sparc0.tlu.tlu.ifu_lsu_st_inst_e),
            .ifu_lsu_alt_space_e    (`SPARC_CORE7.sparc0.tlu.tlu.ifu_lsu_alt_space_e),
            .tlu_early_flush_pipe_w (`SPARC_CORE7.sparc0.tlu.tlu.tlu_early_flush_pipe_w),
            .tlu_asi_state_e        (`SPARC_CORE7.sparc0.tlu.tlu.tlu_asi_state_e),
            .exu_lsu_ldst_va_e      (`SPARC_CORE7.sparc0.tlu.tlu.exu_lsu_ldst_va_e),
            .por_rstint0_w2 (`SPARC_CORE7.sparc0.tlu.tlu.tcl.por_rstint0_w2),
            .por_rstint1_w2 (`SPARC_CORE7.sparc0.tlu.tlu.tcl.por_rstint1_w2),
            .por_rstint2_w2 (`SPARC_CORE7.sparc0.tlu.tlu.tcl.por_rstint2_w2),
            .por_rstint3_w2 (`SPARC_CORE7.sparc0.tlu.tlu.tcl.por_rstint3_w2),
            .tlu_gl_lvl0    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.gl_lvl0),
            .tlu_gl_lvl1    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.gl_lvl1),
            .tlu_gl_lvl2    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.gl_lvl2),
            .tlu_gl_lvl3    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hyperv.gl_lvl3),
    `else
			.tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE7.sparc0.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE7.sparc0.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`SPARC_CORE7.sparc0.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`SPARC_CORE7.sparc0.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`SPARC_CORE7.sparc0.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`SPARC_CORE7.sparc0.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`SPARC_CORE7.sparc0.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`SPARC_CORE7.sparc0.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`SPARC_CORE7.sparc0.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`SPARC_CORE7.sparc0.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`SPARC_CORE7.sparc0.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`SPARC_CORE7.sparc0.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`SPARC_CORE7.sparc0.tlu.tlu_hyperv.gl_lvl3),
    `endif
            .exu_gl_lvl0	(`SPARC_CORE7.sparc0.exu.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`SPARC_CORE7.sparc0.exu.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`SPARC_CORE7.sparc0.exu.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`SPARC_CORE7.sparc0.exu.exu.rml.agp_thr3_next),
    `ifndef RTL_SPU
            .ifu_tlu_thrid_d    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
            .ifu_tlu_inst_vld_m (`SPARC_CORE7.sparc0.tlu.tlu.ifu_tlu_inst_vld_m), // Templated
            .ifu_tlu_imiss_e    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
            .ifu_tlu_immu_miss_m(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
            .tlu_thread_inst_vld_g(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
            .tlu_thread_wsel_g  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
            .ifu_tlu_l2imiss    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .ifu_tlu_flush_fd_w (`SPARC_CORE7.sparc0.tlu.tlu.ifu_tlu_flush_fd_w), // Templated
            .ifu_tlu_sraddr_d   (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
            .ifu_tlu_rsr_inst_d (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
            .lsu_tlu_wsr_inst_e (`SPARC_CORE7.sparc0.tlu.tlu.lsu_tlu_wsr_inst_e), // Templated
            .tlu_wsr_inst_nq_g  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
            .tlu_wsr_data_w (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.tlu_wsr_data_w), // Templated
            .lsu_tlu_dcache_miss_w2(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .lsu_tlu_l2_dmiss   (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .lsu_tlu_stb_full_w2(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .lsu_tlu_dmmu_miss_g(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
            .ffu_tlu_fpu_tid    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
            .ffu_tlu_fpu_cmplt  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
            .tlu_pstate_priv    (`SPARC_CORE7.sparc0.tlu.tlu.local_pstate_priv), // Templated
            .tlu_hpstate_priv   (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hpstate_priv), // Templated
            .tlu_hpstate_enb    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_hpstate_enb), // Templated
            .tlu_pstate_ie  (`SPARC_CORE7.sparc0.tlu.tlu.local_pstate_ie), // Templated
            .wsr_thread_inst_g  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.wsr_thread_inst_g), // Templated
            .lsu_tlu_defr_trp_taken_g(`SPARC_CORE7.sparc0.tlu.tlu.lsu_tlu_defr_trp_taken_g), // Templated
            .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE7.sparc0.tlu.tlu.lsu_tlu_async_ttype_vld_g), // Templated
            .lsu_tlu_ttype_vld_m2(`SPARC_CORE7.sparc0.tlu.tlu.lsu_tlu_ttype_vld_m2), // Templated
            .tlu_ifu_flush_pipe_w(`SPARC_CORE7.sparc0.tlu.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
            .tcc_inst_w2    (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.tcc_inst_w2), // Templated
            .tlu_pib_rsr_data_e (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
            .tlu_pib_priv_act_trap_m(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
            .tlu_pib_picl_wrap  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pib_picl_wrap), // Templated
            .tlu_pib_pich_wrap  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pich_onebelow_flg), // Templated
            .tlu_ifu_trappc_vld_w1(`SPARC_CORE7.sparc0.tlu.tlu.tlu_ifu_trappc_vld_w1), // Templated
            .tlu_ifu_trappc_w2  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_ifu_trappc_w2), // Templated
            .tlu_final_ttype_w2 (`SPARC_CORE7.sparc0.tlu.tlu.tlu_final_ttype_w2), // Templated
            .tlu_ifu_trap_tid_w1(`SPARC_CORE7.sparc0.tlu.tlu.tlu_ifu_trap_tid_w1), // Templated
            .tlu_full_flush_pipe_w2(`SPARC_CORE7.sparc0.tlu.tlu.tlu_full_flush_pipe_w2), // Templated
            .rtl_pcr0       (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pcr0), // Templated
            .rtl_pcr1       (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pcr1), // Templated
            .rtl_pcr2       (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pcr2), // Templated
            .rtl_pcr3       (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pcr3), // Templated
            .rtl_pich_cnt0  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pich_cnt0), // Templated
            .rtl_pich_cnt1  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pich_cnt1), // Templated
            .rtl_pich_cnt2  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pich_cnt2), // Templated
            .rtl_pich_cnt3  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.pich_cnt3), // Templated
            .rtl_picl_cnt0  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.picl_cnt0), // Templated
            .rtl_picl_cnt1  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.picl_cnt1), // Templated
            .rtl_picl_cnt2  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.picl_cnt2), // Templated
            .rtl_picl_cnt3  (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.picl_cnt3), // Templated
            .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .rtl_fpu_cmplt_thread(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.fpu_cmplt_thread), // Templated
            .rtl_imiss_thread_g (`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.imiss_thread_g), // Templated
            .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .rtl_immu_miss_thread_g(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.immu_miss_thread_g), // Templated
            .rtl_dmmu_miss_thread_g(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
            .rtl_ifu_tlu_l2imiss(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE7.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .true_pil0      (`SPARC_CORE7.sparc0.tlu.tlu.tcl.true_pil0), // Templated
            .true_pil1      (`SPARC_CORE7.sparc0.tlu.tlu.tcl.true_pil1), // Templated
            .true_pil2      (`SPARC_CORE7.sparc0.tlu.tlu.tcl.true_pil2), // Templated
            .true_pil3      (`SPARC_CORE7.sparc0.tlu.tlu.tcl.true_pil3), // Templated
            .rtl_trp_lvl0   (`SPARC_CORE7.sparc0.tlu.tlu.tcl.trp_lvl0), // Templated
            .rtl_trp_lvl1   (`SPARC_CORE7.sparc0.tlu.tlu.tcl.trp_lvl1), // Templated
            .rtl_trp_lvl2   (`SPARC_CORE7.sparc0.tlu.tlu.tcl.trp_lvl2), // Templated
            .rtl_trp_lvl3   (`SPARC_CORE7.sparc0.tlu.tlu.tcl.trp_lvl3), // Templated
            .tlz_thread     (`SPARC_CORE7.sparc0.tlu.tlu.tcl.tlz_thread), // Templated
            .th0_sftint_15  (`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint0[15]), // Templated
            .th1_sftint_15  (`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint1[15]), // Templated
            .th2_sftint_15  (`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint2[15]), // Templated
            .th3_sftint_15  (`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint3[15]), // Templated
            .ifu_swint_g    (`SPARC_CORE7.sparc0.tlu.tlu.tcl.swint_g), // Templated
    `else
		    .ifu_tlu_thrid_d	(`SPARC_CORE7.sparc0.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`SPARC_CORE7.sparc0.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`SPARC_CORE7.sparc0.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`SPARC_CORE7.sparc0.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`SPARC_CORE7.sparc0.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`SPARC_CORE7.sparc0.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`SPARC_CORE7.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`SPARC_CORE7.sparc0.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`SPARC_CORE7.sparc0.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`SPARC_CORE7.sparc0.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`SPARC_CORE7.sparc0.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`SPARC_CORE7.sparc0.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`SPARC_CORE7.sparc0.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`SPARC_CORE7.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`SPARC_CORE7.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`SPARC_CORE7.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`SPARC_CORE7.sparc0.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`SPARC_CORE7.sparc0.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`SPARC_CORE7.sparc0.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`SPARC_CORE7.sparc0.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`SPARC_CORE7.sparc0.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`SPARC_CORE7.sparc0.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`SPARC_CORE7.sparc0.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`SPARC_CORE7.sparc0.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`SPARC_CORE7.sparc0.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE7.sparc0.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`SPARC_CORE7.sparc0.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`SPARC_CORE7.sparc0.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`SPARC_CORE7.sparc0.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`SPARC_CORE7.sparc0.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`SPARC_CORE7.sparc0.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`SPARC_CORE7.sparc0.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`SPARC_CORE7.sparc0.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`SPARC_CORE7.sparc0.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`SPARC_CORE7.sparc0.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`SPARC_CORE7.sparc0.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`SPARC_CORE7.sparc0.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`SPARC_CORE7.sparc0.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`SPARC_CORE7.sparc0.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`SPARC_CORE7.sparc0.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`SPARC_CORE7.sparc0.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`SPARC_CORE7.sparc0.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`SPARC_CORE7.sparc0.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`SPARC_CORE7.sparc0.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`SPARC_CORE7.sparc0.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`SPARC_CORE7.sparc0.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`SPARC_CORE7.sparc0.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`SPARC_CORE7.sparc0.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`SPARC_CORE7.sparc0.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`SPARC_CORE7.sparc0.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE7.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`SPARC_CORE7.sparc0.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`SPARC_CORE7.sparc0.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE7.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`SPARC_CORE7.sparc0.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`SPARC_CORE7.sparc0.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`SPARC_CORE7.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE7.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`SPARC_CORE7.sparc0.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`SPARC_CORE7.sparc0.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`SPARC_CORE7.sparc0.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`SPARC_CORE7.sparc0.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`SPARC_CORE7.sparc0.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`SPARC_CORE7.sparc0.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`SPARC_CORE7.sparc0.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`SPARC_CORE7.sparc0.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`SPARC_CORE7.sparc0.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`SPARC_CORE7.sparc0.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`SPARC_CORE7.sparc0.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`SPARC_CORE7.sparc0.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`SPARC_CORE7.sparc0.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`SPARC_CORE7.sparc0.tlu.tcl.swint_g), // Templated
    `endif
		    .core_id		(10'd7),			 // Templated
    `ifndef RTL_SPU
            .tlu_itlb_wr_vld_g  (`SPARC_CORE7.sparc0.tlu.tlu_itlb_wr_vld_g), // Templated
            .tlu_itlb_dmp_vld_g (`SPARC_CORE7.sparc0.tlu.tlu_itlb_dmp_vld_g), // Templated
            .tlu_itlb_tte_tag_w2(`SPARC_CORE7.sparc0.tlu.tlu_itlb_tte_tag_w2), // Templated
            .tlu_itlb_tte_data_w2(`SPARC_CORE7.sparc0.tlu.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE7.sparc0.ifu.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE7.sparc0.lsu.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE7.sparc0.tlu.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE7.sparc0.tlu.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `else
		    .tlu_itlb_wr_vld_g	(`SPARC_CORE7.sparc0.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`SPARC_CORE7.sparc0.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`SPARC_CORE7.sparc0.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`SPARC_CORE7.sparc0.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE7.sparc0.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE7.sparc0.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE7.sparc0.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE7.sparc0.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `endif
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon7 (/*AUTOINST*/
			      // Inputs
    `ifndef RTL_SPU
                  .rtl_softint0(`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint0), // Templated
                  .rtl_softint1(`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint1), // Templated
                  .rtl_softint2(`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint2), // Templated
                  .rtl_softint3(`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint3), // Templated
                  .rtl_wsr_data_w(`SPARC_CORE7.sparc0.tlu.tlu.tdp.wsr_data_w), // Templated
                  .rtl_sftint_en_l_g(`SPARC_CORE7.sparc0.tlu.tlu.tdp.tlu_sftint_en_l_g), // Templated
                  .rtl_sftint_b0_en(`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint_b0_en), // Templated
                  .rtl_tickcmp_int(`SPARC_CORE7.sparc0.tlu.tlu.tdp.tickcmp_int), // Templated
                  .rtl_sftint_b16_en(`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint_b16_en), // Templated
                  .rtl_stickcmp_int(`SPARC_CORE7.sparc0.tlu.tlu.tdp.stickcmp_int), // Templated
                  .rtl_sftint_b15_en(`SPARC_CORE7.sparc0.tlu.tlu.tdp.sftint_b15_en), // Templated
                  .rtl_pib_picl_wrap(`SPARC_CORE7.sparc0.tlu.tlu.tdp.pib_picl_wrap), // Templated
                  .rtl_pib_pich_wrap(`SPARC_CORE7.sparc0.tlu.tlu.tdp.pib_pich_wrap), // Templated
                  .rtl_wr_sftint_l_g(`SPARC_CORE7.sparc0.tlu.tlu.tdp.tlu_wr_sftint_l_g), // Templated
                  .rtl_set_sftint_l_g(`SPARC_CORE7.sparc0.tlu.tlu.tdp.tlu_set_sftint_l_g), // Templated
                  .rtl_clr_sftint_l_g(`SPARC_CORE7.sparc0.tlu.tlu.tdp.tlu_clr_sftint_l_g), // Templated
                  .rtl_clk  (`SPARC_CORE7.sparc0.tlu.tlu.tdp.rclk), // Templated
                  .rtl_reset(`SPARC_CORE7.sparc0.tlu.tlu.tdp.tlu_rst), // Templated
    `else
			      .rtl_softint0(`SPARC_CORE7.sparc0.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`SPARC_CORE7.sparc0.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`SPARC_CORE7.sparc0.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`SPARC_CORE7.sparc0.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`SPARC_CORE7.sparc0.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`SPARC_CORE7.sparc0.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`SPARC_CORE7.sparc0.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`SPARC_CORE7.sparc0.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`SPARC_CORE7.sparc0.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`SPARC_CORE7.sparc0.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`SPARC_CORE7.sparc0.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`SPARC_CORE7.sparc0.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`SPARC_CORE7.sparc0.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`SPARC_CORE7.sparc0.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`SPARC_CORE7.sparc0.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`SPARC_CORE7.sparc0.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`SPARC_CORE7.sparc0.tlu.tdp.rclk), // Templated
			      .rtl_reset(`SPARC_CORE7.sparc0.tlu.tdp.tlu_rst), // Templated
    `endif
			      .core_id	(10'd7));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon7(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
`ifndef RTL_SPU
                .thr_state0 (`SPARC_CORE7.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
                .thr_state1 (`SPARC_CORE7.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
                .thr_state2 (`SPARC_CORE7.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
                .thr_state3 (`SPARC_CORE7.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
                .rstthr (`SPARC_CORE7.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
                .nukeint    (`SPARC_CORE7.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
                .resumint   (`SPARC_CORE7.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
                .rstint (`SPARC_CORE7.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`else
			    .thr_state0	(`SPARC_CORE7.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
			    .thr_state1	(`SPARC_CORE7.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
			    .thr_state2	(`SPARC_CORE7.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
			    .thr_state3	(`SPARC_CORE7.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
			    .rstthr	(`SPARC_CORE7.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			    .nukeint	(`SPARC_CORE7.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
			    .resumint	(`SPARC_CORE7.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
			    .rstint	(`SPARC_CORE7.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`endif
			    .coreid	(10'd7));			 // Templated
   mask_mon mask_mon7(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
`ifndef RTL_SPU
              .wm_imiss     (`SPARC_CORE7.sparc0.ifu.ifu.swl.wm_imiss), // Templated
              .wm_other     (`SPARC_CORE7.sparc0.ifu.ifu.swl.wm_other), // Templated
              .wm_stbwait   (`SPARC_CORE7.sparc0.ifu.ifu.swl.wm_stbwait), // Templated
              .mul_wait     (`SPARC_CORE7.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait     (`SPARC_CORE7.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait      (`SPARC_CORE7.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_busy_e   (`SPARC_CORE7.sparc0.ifu.ifu.swl.mul_busy_e), // Templated
              .div_busy_e   (`SPARC_CORE7.sparc0.ifu.ifu.swl.div_busy_e), // Templated
              .fp_busy_e    (`SPARC_CORE7.sparc0.ifu.ifu.swl.fp_busy_e), // Templated
              .ldmiss       (`SPARC_CORE7.sparc0.ifu.ifu.swl.ldmiss), // Templated
`else
		      .wm_imiss		(`SPARC_CORE7.sparc0.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`SPARC_CORE7.sparc0.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`SPARC_CORE7.sparc0.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`SPARC_CORE7.sparc0.ifu.swl.mul_wait), // Templated
		      .div_wait		(`SPARC_CORE7.sparc0.ifu.swl.div_wait), // Templated
		      .fp_wait		(`SPARC_CORE7.sparc0.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`SPARC_CORE7.sparc0.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`SPARC_CORE7.sparc0.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`SPARC_CORE7.sparc0.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`SPARC_CORE7.sparc0.ifu.swl.ldmiss), // Templated
`endif
		      .coreid		(10'd7));			 // Templated
   pc_muxsel_mon pc_muxsel_mon7(/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
`ifndef RTL_SPU
                .t0pc_f (`SPARC_CORE7.sparc0.ifu.ifu.fdp.t0pc_f[47:0]), // Templated
                .t1pc_f (`SPARC_CORE7.sparc0.ifu.ifu.fdp.t1pc_f[47:0]), // Templated
                .t2pc_f (`SPARC_CORE7.sparc0.ifu.ifu.fdp.t2pc_f[47:0]), // Templated
                .t3pc_f (`SPARC_CORE7.sparc0.ifu.ifu.fdp.t3pc_f[47:0]), // Templated
                .pc_f   (`SPARC_CORE7.sparc0.ifu.ifu.fdp.pc_f[47:0]), // Templated
                .inst_vld_f(`SPARC_CORE7.sparc0.ifu.ifu.fcl.inst_vld_f), // Templated
                .dtu_fcl_running_s(`SPARC_CORE7.sparc0.ifu.ifu.dtu_fcl_running_s), // Templated
                .thr_f  (`SPARC_CORE7.sparc0.ifu.ifu.fcl.thr_f[3:0]), // Templated
`else
				.t0pc_f	(`SPARC_CORE7.sparc0.ifu.fdp.t0pc_f[47:0]), // Templated
				.t1pc_f	(`SPARC_CORE7.sparc0.ifu.fdp.t1pc_f[47:0]), // Templated
				.t2pc_f	(`SPARC_CORE7.sparc0.ifu.fdp.t2pc_f[47:0]), // Templated
				.t3pc_f	(`SPARC_CORE7.sparc0.ifu.fdp.t3pc_f[47:0]), // Templated
				.pc_f	(`SPARC_CORE7.sparc0.ifu.fdp.pc_f[47:0]), // Templated
				.inst_vld_f(`SPARC_CORE7.sparc0.ifu.fcl.inst_vld_f), // Templated
				.dtu_fcl_running_s(`SPARC_CORE7.sparc0.ifu.dtu_fcl_running_s), // Templated
				.thr_f	(`SPARC_CORE7.sparc0.ifu.fcl.thr_f[3:0]), // Templated
`endif
				.coreid	(10'd7));			 // Templated
   stb_ovfl_mon stb_ovfl_mon7(/*AUTOINST*/
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
`ifndef RTL_SPU
                  .lsu_ifu_stbcnt3(`SPARC_CORE7.sparc0.ifu.ifu.lsu_ifu_stbcnt3), // Templated
                  .lsu_ifu_stbcnt2(`SPARC_CORE7.sparc0.ifu.ifu.lsu_ifu_stbcnt2), // Templated
                  .lsu_ifu_stbcnt1(`SPARC_CORE7.sparc0.ifu.ifu.lsu_ifu_stbcnt1), // Templated
                  .lsu_ifu_stbcnt0(`SPARC_CORE7.sparc0.ifu.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE7.sparc0.lsu.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE7.sparc0.lsu.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE7.sparc0.lsu.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE7.sparc0.lsu.lsu.stb_ctl0.reset), // Templated
`else
			      .lsu_ifu_stbcnt3(`SPARC_CORE7.sparc0.ifu.lsu_ifu_stbcnt3), // Templated
			      .lsu_ifu_stbcnt2(`SPARC_CORE7.sparc0.ifu.lsu_ifu_stbcnt2), // Templated
			      .lsu_ifu_stbcnt1(`SPARC_CORE7.sparc0.ifu.lsu_ifu_stbcnt1), // Templated
			      .lsu_ifu_stbcnt0(`SPARC_CORE7.sparc0.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE7.sparc0.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE7.sparc0.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE7.sparc0.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE7.sparc0.lsu.stb_ctl0.reset), // Templated
`endif
			      .coreid	(10'd7));			 // Templated
   icache_mutex_mon icache_mutex_mon7(/*AUTOINST*/
				      // Inputs
				      .clk(clk),
				      .rst_l(rst_l),
`ifndef RTL_SPU
                      .waysel_buf_s1(`SPARC_CORE7.sparc0.ifu.ifu.wseldp.waysel_buf_s1), // Templated
                      .alltag_err_s1(`SPARC_CORE7.sparc0.ifu.ifu.errctl.alltag_err_s1), // Templated
                      .tlb_cam_miss_s1(`SPARC_CORE7.sparc0.ifu.ifu.fcl.tlb_cam_miss_s1), // Templated
                      .cam_vld_s1(`SPARC_CORE7.sparc0.ifu.ifu.fcl.cam_vld_s1), // Templated
`else
				      .waysel_buf_s1(`SPARC_CORE7.sparc0.ifu.wseldp.waysel_buf_s1), // Templated
				      .alltag_err_s1(`SPARC_CORE7.sparc0.ifu.errctl.alltag_err_s1), // Templated
				      .tlb_cam_miss_s1(`SPARC_CORE7.sparc0.ifu.fcl.tlb_cam_miss_s1), // Templated
				      .cam_vld_s1(`SPARC_CORE7.sparc0.ifu.fcl.cam_vld_s1), // Templated
`endif
				      .coreid(10'd7));		 // Templated
   nc_inv_chk nc_inv_chk7(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .cpxpkt_vld   (`SPARC_CORE7.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
              .cpxpkt_rtntype(`SPARC_CORE7.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
              .nc       (`SPARC_CORE7.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
              .wv       (`SPARC_CORE7.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`else
			  .cpxpkt_vld	(`SPARC_CORE7.sparc0.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`SPARC_CORE7.sparc0.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`SPARC_CORE7.sparc0.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`SPARC_CORE7.sparc0.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`endif
			  .coreid	(10'd7));			 // Templated

       // trin: we don't have spu
       // spu_ma_mon spu_ma_mon7(/* AUTOINST*/
    			//   // Inputs
    			//   .clk		(clk),
    			//   .wrmi_mamul_1sthalf(`SPARC_CORE7.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    			//   .wrmi_mamul_2ndhalf(`SPARC_CORE7.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    			//   .wrmi_maaeqb_1sthalf(`SPARC_CORE7.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    			//   .wrmi_maaeqb_2ndhalf(`SPARC_CORE7.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    			//   .iptr		(`SPARC_CORE7.sparc0.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    			//   .iminus_lenminus1(`SPARC_CORE7.sparc0.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    			//   .mul_data	(`SPARC_CORE7.sparc0.spu.spu_madp.spu_madp_evedata[63:0]));


always @ (negedge clk)
begin
    // if (`SPARC_CORE7.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE7.sparc0.lsu.lsu.qctl2.dfq_inv_data_val === 1'bx))
    if (`SPARC_CORE7.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE7.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val === 1'bx))
    begin
        $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received X invalidation");
        `ifndef VERILATOR
        repeat(5)@(posedge clk);
        `endif
        `MONITOR_PATH.fail("TILE0 lsu received X invalidation");
    end

    // if (`SPARC_CORE7.sparc0.lsu.lsu.qctl2.dfq_inv_data_val)
    if (`SPARC_CORE7.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val)
    begin
        if (|`SPARC_CORE7.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_way === 1'bx)
        begin
            $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received invalid way invalidation");
            `ifndef VERILATOR
            repeat(5)@(posedge clk);
            `endif
            `MONITOR_PATH.fail("TILE0 lsu received invalid way invalidation");
        end
    end
end



    //   cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
    //				// Inputs
    //				.clk	(clk),
    //				.rst_l	(rst_l),
    //				.spc_pcx_data_pa(`PCXPATH7.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
    //				.cpx_spc_data_cx(`PCXPATH7.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
    //				.cpu	(0));
   `endif


   `ifdef RTL_SPARC8
   l_cache_mon l_cache_mon8(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(0),			 // Templated
			    .index_f	(`ICTPATH8.index_y[`IC_SET_IDX_HI:0]), // Templated
			    .wrreq_f	(`ICTPATH8.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH8.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH8.ifq_ict_wrtag_f[`IC_TAG_SZ:0]), // Templated
			    .wr_data	(`ICVPATH8.write_bit_y),	 // Templated
                // .wr_data    (`ICVPATH8.din_d1),  // Templated
			    .wren_f	(`ICVPATH8.write_mask_y[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH8.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH8.wr_adr[`IC_SET_IDX_HI:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH8.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH8.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`SPARC_CORE8.sparc0.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`SPARC_CORE8.sparc0.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon8(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .wm_imiss (`SPARC_CORE8.sparc0.ifu.ifu.swl.wm_imiss[3:0]), // Templated
              .wm_other (`SPARC_CORE8.sparc0.ifu.ifu.swl.wm_other[3:0]), // Templated
              .wm_stbwait   (`SPARC_CORE8.sparc0.ifu.ifu.swl.wm_stbwait[3:0]), // Templated
              .thr_state0   (`SPARC_CORE8.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
              .thr_state1   (`SPARC_CORE8.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
              .thr_state2   (`SPARC_CORE8.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
              .thr_state3   (`SPARC_CORE8.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
              .rst_stallreq (`SPARC_CORE8.sparc0.ifu.ifu.fcl.rst_stallreq), // Templated
              .ifq_fcl_stallreq(`SPARC_CORE8.sparc0.ifu.ifu.fcl.ifq_fcl_stallreq), // Templated
              .lsu_ifu_stallreq(`SPARC_CORE8.sparc0.ifu.ifu.fcl.lsu_ifu_stallreq), // Templated
              .ffu_ifu_stallreq(`SPARC_CORE8.sparc0.ifu.ifu.fcl.ffu_ifu_stallreq), // Templated
              .completion   (`SPARC_CORE8.sparc0.ifu.ifu.swl.completion), // Templated
              .mul_wait (`SPARC_CORE8.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait (`SPARC_CORE8.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait  (`SPARC_CORE8.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_wait_nxt (`SPARC_CORE8.sparc0.ifu.ifu.swl.mul_wait_nxt), // Templated
              .div_wait_nxt (`SPARC_CORE8.sparc0.ifu.ifu.swl.div_wait_nxt), // Templated
              .fp_wait_nxt  (`SPARC_CORE8.sparc0.ifu.ifu.swl.fp_wait_nxt), // Templated
              .mul_busy_d   (`SPARC_CORE8.sparc0.ifu.ifu.swl.mul_busy_d), // Templated
              .div_busy_d   (`SPARC_CORE8.sparc0.ifu.ifu.swl.div_busy_d), // Templated
              .fp_busy_d    (`SPARC_CORE8.sparc0.ifu.ifu.swl.fp_busy_d), // Templated
              .ifet_ue_vec_d1(`SPARC_CORE8.sparc0.ifu.ifu.fcl.ifet_ue_vec_d1), // Templated
`else
			  .wm_imiss	(`SPARC_CORE8.sparc0.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`SPARC_CORE8.sparc0.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`SPARC_CORE8.sparc0.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`SPARC_CORE8.sparc0.ifu.swl.thr0_state[4:0]), // Templated
			  .thr_state1	(`SPARC_CORE8.sparc0.ifu.swl.thr1_state[4:0]), // Templated
			  .thr_state2	(`SPARC_CORE8.sparc0.ifu.swl.thr2_state[4:0]), // Templated
			  .thr_state3	(`SPARC_CORE8.sparc0.ifu.swl.thr3_state[4:0]), // Templated
			  .rst_stallreq	(`SPARC_CORE8.sparc0.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`SPARC_CORE8.sparc0.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`SPARC_CORE8.sparc0.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`SPARC_CORE8.sparc0.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`SPARC_CORE8.sparc0.ifu.swl.completion), // Templated
			  .mul_wait	(`SPARC_CORE8.sparc0.ifu.swl.mul_wait), // Templated
			  .div_wait	(`SPARC_CORE8.sparc0.ifu.swl.div_wait), // Templated
			  .fp_wait	(`SPARC_CORE8.sparc0.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`SPARC_CORE8.sparc0.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`SPARC_CORE8.sparc0.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`SPARC_CORE8.sparc0.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`SPARC_CORE8.sparc0.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`SPARC_CORE8.sparc0.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`SPARC_CORE8.sparc0.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`SPARC_CORE8.sparc0.ifu.fcl.ifet_ue_vec_d1), // Templated
`endif
			  .cpu_id	(10'd8));			 // Templated
   exu_mon exu_mon8(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH8.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH8.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH8.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH8.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH8.irf.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH8.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH8.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon8(/*AUTOINST*/
		    // Inputs
    `ifndef RTL_SPU
            .clk        (`SPARC_CORE8.sparc0.tlu.tlu.rclk), // Templated
            .grst_l     (`SPARC_CORE8.sparc0.tlu.tlu.grst_l), // Templated
            .rst_l      (`SPARC_CORE8.sparc0.tlu.tlu.tcl.tlu_rst_l), // Templated
    `else
		    .clk		(`SPARC_CORE8.sparc0.tlu.rclk), // Templated
		    .grst_l		(`SPARC_CORE8.sparc0.tlu.grst_l), // Templated
		    .rst_l		(`SPARC_CORE8.sparc0.tlu.tcl.tlu_rst_l), // Templated
    `endif
			.lsu_ifu_flush_pipe_w	(`SPARC_CORE8.sparc0.lsu_ifu_flush_pipe_w),
    `ifndef RTL_SPU
            .tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE8.sparc0.tlu.tlu_lsu_int_ldxa_vld_w2),
            .tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE8.sparc0.tlu.tlu_lsu_int_ld_ill_va_w2),
            .tlu_scpd_wr_vld_g      (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
            .cpu_mondo_head_wr_g    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
            .cpu_mondo_tail_wr_g    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
            .dev_mondo_head_wr_g    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_head_wr_g),
            .dev_mondo_tail_wr_g    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
            .resum_err_head_wr_g    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.resum_err_head_wr_g),
            .resum_err_tail_wr_g    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.resum_err_tail_wr_g),
            .nresum_err_head_wr_g   (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.nresum_err_head_wr_g),
            .nresum_err_tail_wr_g   (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.nresum_err_tail_wr_g),
            .ifu_lsu_ld_inst_e      (`SPARC_CORE8.sparc0.tlu.tlu.ifu_lsu_ld_inst_e),
            .ifu_lsu_st_inst_e      (`SPARC_CORE8.sparc0.tlu.tlu.ifu_lsu_st_inst_e),
            .ifu_lsu_alt_space_e    (`SPARC_CORE8.sparc0.tlu.tlu.ifu_lsu_alt_space_e),
            .tlu_early_flush_pipe_w (`SPARC_CORE8.sparc0.tlu.tlu.tlu_early_flush_pipe_w),
            .tlu_asi_state_e        (`SPARC_CORE8.sparc0.tlu.tlu.tlu_asi_state_e),
            .exu_lsu_ldst_va_e      (`SPARC_CORE8.sparc0.tlu.tlu.exu_lsu_ldst_va_e),
            .por_rstint0_w2 (`SPARC_CORE8.sparc0.tlu.tlu.tcl.por_rstint0_w2),
            .por_rstint1_w2 (`SPARC_CORE8.sparc0.tlu.tlu.tcl.por_rstint1_w2),
            .por_rstint2_w2 (`SPARC_CORE8.sparc0.tlu.tlu.tcl.por_rstint2_w2),
            .por_rstint3_w2 (`SPARC_CORE8.sparc0.tlu.tlu.tcl.por_rstint3_w2),
            .tlu_gl_lvl0    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.gl_lvl0),
            .tlu_gl_lvl1    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.gl_lvl1),
            .tlu_gl_lvl2    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.gl_lvl2),
            .tlu_gl_lvl3    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hyperv.gl_lvl3),
    `else
			.tlu_lsu_int_ldxa_vld_w2(`SPARC_CORE8.sparc0.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`SPARC_CORE8.sparc0.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`SPARC_CORE8.sparc0.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`SPARC_CORE8.sparc0.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`SPARC_CORE8.sparc0.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`SPARC_CORE8.sparc0.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`SPARC_CORE8.sparc0.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`SPARC_CORE8.sparc0.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`SPARC_CORE8.sparc0.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`SPARC_CORE8.sparc0.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`SPARC_CORE8.sparc0.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`SPARC_CORE8.sparc0.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`SPARC_CORE8.sparc0.tlu.tlu_hyperv.gl_lvl3),
    `endif
            .exu_gl_lvl0	(`SPARC_CORE8.sparc0.exu.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`SPARC_CORE8.sparc0.exu.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`SPARC_CORE8.sparc0.exu.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`SPARC_CORE8.sparc0.exu.exu.rml.agp_thr3_next),
    `ifndef RTL_SPU
            .ifu_tlu_thrid_d    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
            .ifu_tlu_inst_vld_m (`SPARC_CORE8.sparc0.tlu.tlu.ifu_tlu_inst_vld_m), // Templated
            .ifu_tlu_imiss_e    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
            .ifu_tlu_immu_miss_m(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
            .tlu_thread_inst_vld_g(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
            .tlu_thread_wsel_g  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
            .ifu_tlu_l2imiss    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .ifu_tlu_flush_fd_w (`SPARC_CORE8.sparc0.tlu.tlu.ifu_tlu_flush_fd_w), // Templated
            .ifu_tlu_sraddr_d   (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
            .ifu_tlu_rsr_inst_d (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
            .lsu_tlu_wsr_inst_e (`SPARC_CORE8.sparc0.tlu.tlu.lsu_tlu_wsr_inst_e), // Templated
            .tlu_wsr_inst_nq_g  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
            .tlu_wsr_data_w (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.tlu_wsr_data_w), // Templated
            .lsu_tlu_dcache_miss_w2(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .lsu_tlu_l2_dmiss   (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .lsu_tlu_stb_full_w2(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .lsu_tlu_dmmu_miss_g(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
            .ffu_tlu_fpu_tid    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
            .ffu_tlu_fpu_cmplt  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
            .tlu_pstate_priv    (`SPARC_CORE8.sparc0.tlu.tlu.local_pstate_priv), // Templated
            .tlu_hpstate_priv   (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hpstate_priv), // Templated
            .tlu_hpstate_enb    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_hpstate_enb), // Templated
            .tlu_pstate_ie  (`SPARC_CORE8.sparc0.tlu.tlu.local_pstate_ie), // Templated
            .wsr_thread_inst_g  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.wsr_thread_inst_g), // Templated
            .lsu_tlu_defr_trp_taken_g(`SPARC_CORE8.sparc0.tlu.tlu.lsu_tlu_defr_trp_taken_g), // Templated
            .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE8.sparc0.tlu.tlu.lsu_tlu_async_ttype_vld_g), // Templated
            .lsu_tlu_ttype_vld_m2(`SPARC_CORE8.sparc0.tlu.tlu.lsu_tlu_ttype_vld_m2), // Templated
            .tlu_ifu_flush_pipe_w(`SPARC_CORE8.sparc0.tlu.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
            .tcc_inst_w2    (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.tcc_inst_w2), // Templated
            .tlu_pib_rsr_data_e (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
            .tlu_pib_priv_act_trap_m(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
            .tlu_pib_picl_wrap  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pib_picl_wrap), // Templated
            .tlu_pib_pich_wrap  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pich_onebelow_flg), // Templated
            .tlu_ifu_trappc_vld_w1(`SPARC_CORE8.sparc0.tlu.tlu.tlu_ifu_trappc_vld_w1), // Templated
            .tlu_ifu_trappc_w2  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_ifu_trappc_w2), // Templated
            .tlu_final_ttype_w2 (`SPARC_CORE8.sparc0.tlu.tlu.tlu_final_ttype_w2), // Templated
            .tlu_ifu_trap_tid_w1(`SPARC_CORE8.sparc0.tlu.tlu.tlu_ifu_trap_tid_w1), // Templated
            .tlu_full_flush_pipe_w2(`SPARC_CORE8.sparc0.tlu.tlu.tlu_full_flush_pipe_w2), // Templated
            .rtl_pcr0       (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pcr0), // Templated
            .rtl_pcr1       (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pcr1), // Templated
            .rtl_pcr2       (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pcr2), // Templated
            .rtl_pcr3       (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pcr3), // Templated
            .rtl_pich_cnt0  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pich_cnt0), // Templated
            .rtl_pich_cnt1  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pich_cnt1), // Templated
            .rtl_pich_cnt2  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pich_cnt2), // Templated
            .rtl_pich_cnt3  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.pich_cnt3), // Templated
            .rtl_picl_cnt0  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.picl_cnt0), // Templated
            .rtl_picl_cnt1  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.picl_cnt1), // Templated
            .rtl_picl_cnt2  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.picl_cnt2), // Templated
            .rtl_picl_cnt3  (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.picl_cnt3), // Templated
            .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
            .rtl_fpu_cmplt_thread(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.fpu_cmplt_thread), // Templated
            .rtl_imiss_thread_g (`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.imiss_thread_g), // Templated
            .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
            .rtl_immu_miss_thread_g(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.immu_miss_thread_g), // Templated
            .rtl_dmmu_miss_thread_g(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
            .rtl_ifu_tlu_l2imiss(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
            .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE8.sparc0.tlu.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
            .true_pil0      (`SPARC_CORE8.sparc0.tlu.tlu.tcl.true_pil0), // Templated
            .true_pil1      (`SPARC_CORE8.sparc0.tlu.tlu.tcl.true_pil1), // Templated
            .true_pil2      (`SPARC_CORE8.sparc0.tlu.tlu.tcl.true_pil2), // Templated
            .true_pil3      (`SPARC_CORE8.sparc0.tlu.tlu.tcl.true_pil3), // Templated
            .rtl_trp_lvl0   (`SPARC_CORE8.sparc0.tlu.tlu.tcl.trp_lvl0), // Templated
            .rtl_trp_lvl1   (`SPARC_CORE8.sparc0.tlu.tlu.tcl.trp_lvl1), // Templated
            .rtl_trp_lvl2   (`SPARC_CORE8.sparc0.tlu.tlu.tcl.trp_lvl2), // Templated
            .rtl_trp_lvl3   (`SPARC_CORE8.sparc0.tlu.tlu.tcl.trp_lvl3), // Templated
            .tlz_thread     (`SPARC_CORE8.sparc0.tlu.tlu.tcl.tlz_thread), // Templated
            .th0_sftint_15  (`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint0[15]), // Templated
            .th1_sftint_15  (`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint1[15]), // Templated
            .th2_sftint_15  (`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint2[15]), // Templated
            .th3_sftint_15  (`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint3[15]), // Templated
            .ifu_swint_g    (`SPARC_CORE8.sparc0.tlu.tlu.tcl.swint_g), // Templated
    `else
		    .ifu_tlu_thrid_d	(`SPARC_CORE8.sparc0.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`SPARC_CORE8.sparc0.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`SPARC_CORE8.sparc0.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`SPARC_CORE8.sparc0.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`SPARC_CORE8.sparc0.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`SPARC_CORE8.sparc0.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`SPARC_CORE8.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`SPARC_CORE8.sparc0.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`SPARC_CORE8.sparc0.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`SPARC_CORE8.sparc0.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`SPARC_CORE8.sparc0.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`SPARC_CORE8.sparc0.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`SPARC_CORE8.sparc0.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`SPARC_CORE8.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`SPARC_CORE8.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`SPARC_CORE8.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`SPARC_CORE8.sparc0.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`SPARC_CORE8.sparc0.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`SPARC_CORE8.sparc0.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`SPARC_CORE8.sparc0.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`SPARC_CORE8.sparc0.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`SPARC_CORE8.sparc0.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`SPARC_CORE8.sparc0.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`SPARC_CORE8.sparc0.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`SPARC_CORE8.sparc0.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`SPARC_CORE8.sparc0.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`SPARC_CORE8.sparc0.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`SPARC_CORE8.sparc0.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`SPARC_CORE8.sparc0.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`SPARC_CORE8.sparc0.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`SPARC_CORE8.sparc0.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`SPARC_CORE8.sparc0.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`SPARC_CORE8.sparc0.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`SPARC_CORE8.sparc0.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`SPARC_CORE8.sparc0.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`SPARC_CORE8.sparc0.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`SPARC_CORE8.sparc0.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`SPARC_CORE8.sparc0.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`SPARC_CORE8.sparc0.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`SPARC_CORE8.sparc0.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`SPARC_CORE8.sparc0.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`SPARC_CORE8.sparc0.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`SPARC_CORE8.sparc0.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`SPARC_CORE8.sparc0.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`SPARC_CORE8.sparc0.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`SPARC_CORE8.sparc0.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`SPARC_CORE8.sparc0.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`SPARC_CORE8.sparc0.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`SPARC_CORE8.sparc0.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`SPARC_CORE8.sparc0.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`SPARC_CORE8.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`SPARC_CORE8.sparc0.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`SPARC_CORE8.sparc0.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`SPARC_CORE8.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`SPARC_CORE8.sparc0.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`SPARC_CORE8.sparc0.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`SPARC_CORE8.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`SPARC_CORE8.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`SPARC_CORE8.sparc0.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`SPARC_CORE8.sparc0.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`SPARC_CORE8.sparc0.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`SPARC_CORE8.sparc0.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`SPARC_CORE8.sparc0.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`SPARC_CORE8.sparc0.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`SPARC_CORE8.sparc0.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`SPARC_CORE8.sparc0.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`SPARC_CORE8.sparc0.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`SPARC_CORE8.sparc0.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`SPARC_CORE8.sparc0.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`SPARC_CORE8.sparc0.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`SPARC_CORE8.sparc0.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`SPARC_CORE8.sparc0.tlu.tcl.swint_g), // Templated
    `endif
		    .core_id		(10'd8),			 // Templated
    `ifndef RTL_SPU
            .tlu_itlb_wr_vld_g  (`SPARC_CORE8.sparc0.tlu.tlu_itlb_wr_vld_g), // Templated
            .tlu_itlb_dmp_vld_g (`SPARC_CORE8.sparc0.tlu.tlu_itlb_dmp_vld_g), // Templated
            .tlu_itlb_tte_tag_w2(`SPARC_CORE8.sparc0.tlu.tlu_itlb_tte_tag_w2), // Templated
            .tlu_itlb_tte_data_w2(`SPARC_CORE8.sparc0.tlu.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE8.sparc0.ifu.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE8.sparc0.lsu.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE8.sparc0.tlu.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE8.sparc0.tlu.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `else
		    .tlu_itlb_wr_vld_g	(`SPARC_CORE8.sparc0.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`SPARC_CORE8.sparc0.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`SPARC_CORE8.sparc0.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`SPARC_CORE8.sparc0.tlu_itlb_tte_data_w2), // Templated
            .itlb_wr_vld    (`SPARC_CORE8.sparc0.ifu.itlb.tlb_wr_vld), // Templated
            .dtlb_wr_vld    (`SPARC_CORE8.sparc0.lsu.dtlb.tlb_wr_vld), // Templated
            .tlu_tlb_access_en_l_d1(`SPARC_CORE8.sparc0.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
            .tlu_lng_ltncy_en_l (`SPARC_CORE8.sparc0.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
    `endif
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon8 (/*AUTOINST*/
			      // Inputs
    `ifndef RTL_SPU
                  .rtl_softint0(`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint0), // Templated
                  .rtl_softint1(`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint1), // Templated
                  .rtl_softint2(`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint2), // Templated
                  .rtl_softint3(`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint3), // Templated
                  .rtl_wsr_data_w(`SPARC_CORE8.sparc0.tlu.tlu.tdp.wsr_data_w), // Templated
                  .rtl_sftint_en_l_g(`SPARC_CORE8.sparc0.tlu.tlu.tdp.tlu_sftint_en_l_g), // Templated
                  .rtl_sftint_b0_en(`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint_b0_en), // Templated
                  .rtl_tickcmp_int(`SPARC_CORE8.sparc0.tlu.tlu.tdp.tickcmp_int), // Templated
                  .rtl_sftint_b16_en(`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint_b16_en), // Templated
                  .rtl_stickcmp_int(`SPARC_CORE8.sparc0.tlu.tlu.tdp.stickcmp_int), // Templated
                  .rtl_sftint_b15_en(`SPARC_CORE8.sparc0.tlu.tlu.tdp.sftint_b15_en), // Templated
                  .rtl_pib_picl_wrap(`SPARC_CORE8.sparc0.tlu.tlu.tdp.pib_picl_wrap), // Templated
                  .rtl_pib_pich_wrap(`SPARC_CORE8.sparc0.tlu.tlu.tdp.pib_pich_wrap), // Templated
                  .rtl_wr_sftint_l_g(`SPARC_CORE8.sparc0.tlu.tlu.tdp.tlu_wr_sftint_l_g), // Templated
                  .rtl_set_sftint_l_g(`SPARC_CORE8.sparc0.tlu.tlu.tdp.tlu_set_sftint_l_g), // Templated
                  .rtl_clr_sftint_l_g(`SPARC_CORE8.sparc0.tlu.tlu.tdp.tlu_clr_sftint_l_g), // Templated
                  .rtl_clk  (`SPARC_CORE8.sparc0.tlu.tlu.tdp.rclk), // Templated
                  .rtl_reset(`SPARC_CORE8.sparc0.tlu.tlu.tdp.tlu_rst), // Templated
    `else
			      .rtl_softint0(`SPARC_CORE8.sparc0.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`SPARC_CORE8.sparc0.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`SPARC_CORE8.sparc0.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`SPARC_CORE8.sparc0.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`SPARC_CORE8.sparc0.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`SPARC_CORE8.sparc0.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`SPARC_CORE8.sparc0.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`SPARC_CORE8.sparc0.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`SPARC_CORE8.sparc0.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`SPARC_CORE8.sparc0.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`SPARC_CORE8.sparc0.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`SPARC_CORE8.sparc0.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`SPARC_CORE8.sparc0.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`SPARC_CORE8.sparc0.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`SPARC_CORE8.sparc0.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`SPARC_CORE8.sparc0.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`SPARC_CORE8.sparc0.tlu.tdp.rclk), // Templated
			      .rtl_reset(`SPARC_CORE8.sparc0.tlu.tdp.tlu_rst), // Templated
    `endif
			      .core_id	(10'd8));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon8(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
`ifndef RTL_SPU
                .thr_state0 (`SPARC_CORE8.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
                .thr_state1 (`SPARC_CORE8.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
                .thr_state2 (`SPARC_CORE8.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
                .thr_state3 (`SPARC_CORE8.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
                .rstthr (`SPARC_CORE8.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
                .nukeint    (`SPARC_CORE8.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
                .resumint   (`SPARC_CORE8.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
                .rstint (`SPARC_CORE8.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`else
			    .thr_state0	(`SPARC_CORE8.sparc0.ifu.ifu.swl.thr0_state[4:0]), // Templated
			    .thr_state1	(`SPARC_CORE8.sparc0.ifu.ifu.swl.thr1_state[4:0]), // Templated
			    .thr_state2	(`SPARC_CORE8.sparc0.ifu.ifu.swl.thr2_state[4:0]), // Templated
			    .thr_state3	(`SPARC_CORE8.sparc0.ifu.ifu.swl.thr3_state[4:0]), // Templated
			    .rstthr	(`SPARC_CORE8.sparc0.ifu.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			    .nukeint	(`SPARC_CORE8.sparc0.ifu.ifu.tlu_ifu_nukeint_i2), // Templated
			    .resumint	(`SPARC_CORE8.sparc0.ifu.ifu.tlu_ifu_resumint_i2), // Templated
			    .rstint	(`SPARC_CORE8.sparc0.ifu.ifu.tlu_ifu_rstint_i2), // Templated
`endif
			    .coreid	(10'd8));			 // Templated
   mask_mon mask_mon8(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
`ifndef RTL_SPU
              .wm_imiss     (`SPARC_CORE8.sparc0.ifu.ifu.swl.wm_imiss), // Templated
              .wm_other     (`SPARC_CORE8.sparc0.ifu.ifu.swl.wm_other), // Templated
              .wm_stbwait   (`SPARC_CORE8.sparc0.ifu.ifu.swl.wm_stbwait), // Templated
              .mul_wait     (`SPARC_CORE8.sparc0.ifu.ifu.swl.mul_wait), // Templated
              .div_wait     (`SPARC_CORE8.sparc0.ifu.ifu.swl.div_wait), // Templated
              .fp_wait      (`SPARC_CORE8.sparc0.ifu.ifu.swl.fp_wait), // Templated
              .mul_busy_e   (`SPARC_CORE8.sparc0.ifu.ifu.swl.mul_busy_e), // Templated
              .div_busy_e   (`SPARC_CORE8.sparc0.ifu.ifu.swl.div_busy_e), // Templated
              .fp_busy_e    (`SPARC_CORE8.sparc0.ifu.ifu.swl.fp_busy_e), // Templated
              .ldmiss       (`SPARC_CORE8.sparc0.ifu.ifu.swl.ldmiss), // Templated
`else
		      .wm_imiss		(`SPARC_CORE8.sparc0.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`SPARC_CORE8.sparc0.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`SPARC_CORE8.sparc0.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`SPARC_CORE8.sparc0.ifu.swl.mul_wait), // Templated
		      .div_wait		(`SPARC_CORE8.sparc0.ifu.swl.div_wait), // Templated
		      .fp_wait		(`SPARC_CORE8.sparc0.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`SPARC_CORE8.sparc0.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`SPARC_CORE8.sparc0.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`SPARC_CORE8.sparc0.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`SPARC_CORE8.sparc0.ifu.swl.ldmiss), // Templated
`endif
		      .coreid		(10'd8));			 // Templated
   pc_muxsel_mon pc_muxsel_mon8(/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
`ifndef RTL_SPU
                .t0pc_f (`SPARC_CORE8.sparc0.ifu.ifu.fdp.t0pc_f[47:0]), // Templated
                .t1pc_f (`SPARC_CORE8.sparc0.ifu.ifu.fdp.t1pc_f[47:0]), // Templated
                .t2pc_f (`SPARC_CORE8.sparc0.ifu.ifu.fdp.t2pc_f[47:0]), // Templated
                .t3pc_f (`SPARC_CORE8.sparc0.ifu.ifu.fdp.t3pc_f[47:0]), // Templated
                .pc_f   (`SPARC_CORE8.sparc0.ifu.ifu.fdp.pc_f[47:0]), // Templated
                .inst_vld_f(`SPARC_CORE8.sparc0.ifu.ifu.fcl.inst_vld_f), // Templated
                .dtu_fcl_running_s(`SPARC_CORE8.sparc0.ifu.ifu.dtu_fcl_running_s), // Templated
                .thr_f  (`SPARC_CORE8.sparc0.ifu.ifu.fcl.thr_f[3:0]), // Templated
`else
				.t0pc_f	(`SPARC_CORE8.sparc0.ifu.fdp.t0pc_f[47:0]), // Templated
				.t1pc_f	(`SPARC_CORE8.sparc0.ifu.fdp.t1pc_f[47:0]), // Templated
				.t2pc_f	(`SPARC_CORE8.sparc0.ifu.fdp.t2pc_f[47:0]), // Templated
				.t3pc_f	(`SPARC_CORE8.sparc0.ifu.fdp.t3pc_f[47:0]), // Templated
				.pc_f	(`SPARC_CORE8.sparc0.ifu.fdp.pc_f[47:0]), // Templated
				.inst_vld_f(`SPARC_CORE8.sparc0.ifu.fcl.inst_vld_f), // Templated
				.dtu_fcl_running_s(`SPARC_CORE8.sparc0.ifu.dtu_fcl_running_s), // Templated
				.thr_f	(`SPARC_CORE8.sparc0.ifu.fcl.thr_f[3:0]), // Templated
`endif
				.coreid	(10'd8));			 // Templated
   stb_ovfl_mon stb_ovfl_mon8(/*AUTOINST*/
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
`ifndef RTL_SPU
                  .lsu_ifu_stbcnt3(`SPARC_CORE8.sparc0.ifu.ifu.lsu_ifu_stbcnt3), // Templated
                  .lsu_ifu_stbcnt2(`SPARC_CORE8.sparc0.ifu.ifu.lsu_ifu_stbcnt2), // Templated
                  .lsu_ifu_stbcnt1(`SPARC_CORE8.sparc0.ifu.ifu.lsu_ifu_stbcnt1), // Templated
                  .lsu_ifu_stbcnt0(`SPARC_CORE8.sparc0.ifu.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE8.sparc0.lsu.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE8.sparc0.lsu.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE8.sparc0.lsu.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE8.sparc0.lsu.lsu.stb_ctl0.reset), // Templated
`else
			      .lsu_ifu_stbcnt3(`SPARC_CORE8.sparc0.ifu.lsu_ifu_stbcnt3), // Templated
			      .lsu_ifu_stbcnt2(`SPARC_CORE8.sparc0.ifu.lsu_ifu_stbcnt2), // Templated
			      .lsu_ifu_stbcnt1(`SPARC_CORE8.sparc0.ifu.lsu_ifu_stbcnt1), // Templated
			      .lsu_ifu_stbcnt0(`SPARC_CORE8.sparc0.ifu.lsu_ifu_stbcnt0), // Templated
                  .stb_ctl_reset3(`SPARC_CORE8.sparc0.lsu.stb_ctl3.reset), // Templated
                  .stb_ctl_reset2(`SPARC_CORE8.sparc0.lsu.stb_ctl2.reset), // Templated
                  .stb_ctl_reset1(`SPARC_CORE8.sparc0.lsu.stb_ctl1.reset), // Templated
                  .stb_ctl_reset0(`SPARC_CORE8.sparc0.lsu.stb_ctl0.reset), // Templated
`endif
			      .coreid	(10'd8));			 // Templated
   icache_mutex_mon icache_mutex_mon8(/*AUTOINST*/
				      // Inputs
				      .clk(clk),
				      .rst_l(rst_l),
`ifndef RTL_SPU
                      .waysel_buf_s1(`SPARC_CORE8.sparc0.ifu.ifu.wseldp.waysel_buf_s1), // Templated
                      .alltag_err_s1(`SPARC_CORE8.sparc0.ifu.ifu.errctl.alltag_err_s1), // Templated
                      .tlb_cam_miss_s1(`SPARC_CORE8.sparc0.ifu.ifu.fcl.tlb_cam_miss_s1), // Templated
                      .cam_vld_s1(`SPARC_CORE8.sparc0.ifu.ifu.fcl.cam_vld_s1), // Templated
`else
				      .waysel_buf_s1(`SPARC_CORE8.sparc0.ifu.wseldp.waysel_buf_s1), // Templated
				      .alltag_err_s1(`SPARC_CORE8.sparc0.ifu.errctl.alltag_err_s1), // Templated
				      .tlb_cam_miss_s1(`SPARC_CORE8.sparc0.ifu.fcl.tlb_cam_miss_s1), // Templated
				      .cam_vld_s1(`SPARC_CORE8.sparc0.ifu.fcl.cam_vld_s1), // Templated
`endif
				      .coreid(10'd8));		 // Templated
   nc_inv_chk nc_inv_chk8(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
`ifndef RTL_SPU
              .cpxpkt_vld   (`SPARC_CORE8.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
              .cpxpkt_rtntype(`SPARC_CORE8.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
              .nc       (`SPARC_CORE8.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
              .wv       (`SPARC_CORE8.sparc0.ifu.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`else
			  .cpxpkt_vld	(`SPARC_CORE8.sparc0.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`SPARC_CORE8.sparc0.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`SPARC_CORE8.sparc0.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`SPARC_CORE8.sparc0.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
`endif
			  .coreid	(10'd8));			 // Templated

       // trin: we don't have spu
       // spu_ma_mon spu_ma_mon8(/* AUTOINST*/
    			//   // Inputs
    			//   .clk		(clk),
    			//   .wrmi_mamul_1sthalf(`SPARC_CORE8.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    			//   .wrmi_mamul_2ndhalf(`SPARC_CORE8.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    			//   .wrmi_maaeqb_1sthalf(`SPARC_CORE8.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    			//   .wrmi_maaeqb_2ndhalf(`SPARC_CORE8.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    			//   .iptr		(`SPARC_CORE8.sparc0.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    			//   .iminus_lenminus1(`SPARC_CORE8.sparc0.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    			//   .mul_data	(`SPARC_CORE8.sparc0.spu.spu_madp.spu_madp_evedata[63:0]));


always @ (negedge clk)
begin
    // if (`SPARC_CORE8.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE8.sparc0.lsu.lsu.qctl2.dfq_inv_data_val === 1'bx))
    if (`SPARC_CORE8.sparc0.lsu.lsu.qctl2.dfq_vld_en && (`SPARC_CORE8.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val === 1'bx))
    begin
        $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received X invalidation");
        `ifndef VERILATOR
        repeat(5)@(posedge clk);
        `endif
        `MONITOR_PATH.fail("TILE0 lsu received X invalidation");
    end

    // if (`SPARC_CORE8.sparc0.lsu.lsu.qctl2.dfq_inv_data_val)
    if (`SPARC_CORE8.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_val)
    begin
        if (|`SPARC_CORE8.sparc0.lsu.lsu.qctl2.lsu_cpu_inv_data_way === 1'bx)
        begin
            $display("%d : Simulation -> FAIL(%0s)", $time, "TILE0 lsu received invalid way invalidation");
            `ifndef VERILATOR
            repeat(5)@(posedge clk);
            `endif
            `MONITOR_PATH.fail("TILE0 lsu received invalid way invalidation");
        end
    end
end



    //   cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
    //				// Inputs
    //				.clk	(clk),
    //				.rst_l	(rst_l),
    //				.spc_pcx_data_pa(`PCXPATH8.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
    //				.cpx_spc_data_cx(`PCXPATH8.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
    //				.cpu	(0));
   `endif






`ifdef RTL_SPARC0
`ifndef VERILATOR
   tso_mon tso_mon0( .clk       (clk), .rst_l   (rst_l));
`endif

   lsu_mon lsu_mon0( .clk       (clk), .rst_l   (rst_l));
   lsu_mon2 lsu_mon2( .clk       (clk), .rst_l   (rst_l));
`ifndef VERILATOR
   multicycle_mon multicycle_mon(.clk       (clk), .rst_l   (rst_l));
`endif

   `ifdef RTL_IOBDG
   ctu_mon ctu_mon0( );
   dbginit_mon dbginit_mon( );
   `endif

        // tlb monitor
//   tlb_mon tlb_mon0 ( /* AUTOINST*/
//                            // Outputs
//                            // Inputs
//                                .clk    (clk),
//                                .reset  (rst_l),
//                                .cpuid  (3'b000),
//                                .ifu_tlu_thrid_e(`SPARC_CORE0.sparc0.lsu.ifu_tlu_thrid_e),
//                                .exu_lsu_rs3_data_e(`SPARC_CORE0.sparc0.lsu.exu_lsu_rs3_data_e),
//                                .exu_lsu_ldst_va_e(`SPARC_CORE0.sparc0.lsu.exu_lsu_ldst_va_e),
//                                .ifu_lsu_ld_inst_e(`SPARC_CORE0.sparc0.lsu.ifu_lsu_ld_inst_e),
//                                .ifu_lsu_st_inst_e(`SPARC_CORE0.sparc0.lsu.ifu_lsu_st_inst_e),
//                                .asi_d(`SPARC_CORE0.sparc0.lsu.dctl.asi_d),
//                                .dtlb_wr_vld(`SPARC_CORE0.sparc0.lsu.dtlb.tlb_wr_vld),
//                                .dtlb_rw_index(`SPARC_CORE0.sparc0.lsu.dtlb.tlb_rw_index),
//                                .dtlb_rw_index_vld(`SPARC_CORE0.sparc0.lsu.dtlb.tlb_rw_index_vld),
//                                .tlu_dtlb_tte_data_w2(`SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_dtlb_tte_data_w2),
//                                .tlu_dtlb_tte_tag_w2(`SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_dtlb_tte_tag_w2),
//                                .dtlb_entry_replace(`SPARC_CORE0.sparc0.lsu.dtlb.tlb_entry_replace),
//                                .dtlb_entry_vld(`SPARC_CORE0.sparc0.lsu.dtlb.tlb_entry_vld),
//                                .tlb_access_sel_thrd0(`SPARC_CORE0.sparc0.lsu.dctl.tlb_access_sel_thrd0),
//                                .tlb_access_sel_thrd1(`SPARC_CORE0.sparc0.lsu.dctl.tlb_access_sel_thrd1),
//                                .tlb_access_sel_thrd2(`SPARC_CORE0.sparc0.lsu.dctl.tlb_access_sel_thrd2),
//                                .tlb_access_sel_thrd3(`SPARC_CORE0.sparc0.lsu.dctl.tlb_access_sel_thrd3),
//                                .lsu_tlu_tlb_st_inst_m(`SPARC_CORE0.sparc0.lsu.dctl.lsu_tlu_tlb_st_inst_m),
//`ifndef RTL_SPU
//                                .itlb_wr_vld(`SPARC_CORE0.sparc0.ifu.ifu.itlb.tlb_wr_vld),
//                                .itlb_rw_index(`SPARC_CORE0.sparc0.ifu.ifu.itlb.tlb_rw_index),
//                                .itlb_rw_index_vld(`SPARC_CORE0.sparc0.ifu.ifu.itlb.tlb_rw_index_vld),
//`else
//                                .itlb_wr_vld(`SPARC_CORE0.sparc0.ifu.itlb.tlb_wr_vld),
//                                .itlb_rw_index(`SPARC_CORE0.sparc0.ifu.itlb.tlb_rw_index),
//                                .itlb_rw_index_vld(`SPARC_CORE0.sparc0.ifu.itlb.tlb_rw_index_vld),
//`endif
//                                .tlu_itlb_tte_data_w2(`SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_itlb_tte_data_w2),
//                                .tlu_itlb_tte_tag_w2(`SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_itlb_tte_tag_w2),
//`ifndef RTL_SPU
//                                .itlb_entry_replace(`SPARC_CORE0.sparc0.ifu.ifu.itlb.tlb_entry_replace),
//                                .itlb_entry_vld(`SPARC_CORE0.sparc0.ifu.ifu.itlb.tlb_entry_vld),
//`else
//                                .itlb_entry_replace(`SPARC_CORE0.sparc0.ifu.itlb.tlb_entry_replace),
//                                .itlb_entry_vld(`SPARC_CORE0.sparc0.ifu.itlb.tlb_entry_vld),
//`endif
//                                .pg_size(`SPARC_CORE0.sparc0.tlu.mmu_ctl.pg_size)
//   ); // tlb monitor
`endif

`endif // ifdef GATE_SIM

`ifdef RTL_SPARC0
   //monitor good trap and bad trap.
   pc_cmp pc_cmp(clk, rst_l); // Sumti - Shifting it back to clk, sas race with +fast_boot.
//dump cache
`endif // ifdef RTL_SPARC0

`ifdef RTL_PICO0
   //monitor good trap and bad trap.
   pc_cmp pc_cmp(clk, rst_l); // Sumti - Shifting it back to clk, sas race with +fast_boot.
`endif // ifdef RTL_PICO0

`ifdef RTL_ARIANE0
   //monitor good trap and bad trap.
   pc_cmp pc_cmp(clk, rst_l); // Sumti - Shifting it back to clk, sas race with +fast_boot.
`endif // ifdef RTL_ARIANE0

	// dump_cache dump_cache();

	// Don't include this section if compiling for DRAM SAT Environment
	`ifdef DRAM_SAT
	`else

        
    `ifdef RTL_SPARC0
    cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
        // Inputs
        .clk	(clk),
        .rst_l	(rst_l),
        .spc_pcx_req_pq(`SPARC_CORE0.spc0_pcx_req_pq[4:0]),
        .spc_pcx_data_pa(`SPARC_CORE0.spc0_pcx_data_pa[`PCX_WIDTH-1:0]),
        .cpx_spc_data_cx(`SPARC_CORE0.cpx_spc0_data_cx2[`CPX_WIDTH-1:0]),
        // .cpu	(0));
        .cpu    (0));
    `endif

    `ifdef RTL_SPARC1
    cmp_pcxandcpx cmp_pcxandcpx1(/* AUTOINST*/
        // Inputs
        .clk	(clk),
        .rst_l	(rst_l),
        .spc_pcx_req_pq(`SPARC_CORE1.spc0_pcx_req_pq[4:0]),
        .spc_pcx_data_pa(`SPARC_CORE1.spc0_pcx_data_pa[`PCX_WIDTH-1:0]),
        .cpx_spc_data_cx(`SPARC_CORE1.cpx_spc0_data_cx2[`CPX_WIDTH-1:0]),
        // .cpu	(0));
        .cpu    (1));
    `endif

    `ifdef RTL_SPARC2
    cmp_pcxandcpx cmp_pcxandcpx2(/* AUTOINST*/
        // Inputs
        .clk	(clk),
        .rst_l	(rst_l),
        .spc_pcx_req_pq(`SPARC_CORE2.spc0_pcx_req_pq[4:0]),
        .spc_pcx_data_pa(`SPARC_CORE2.spc0_pcx_data_pa[`PCX_WIDTH-1:0]),
        .cpx_spc_data_cx(`SPARC_CORE2.cpx_spc0_data_cx2[`CPX_WIDTH-1:0]),
        // .cpu	(0));
        .cpu    (2));
    `endif

    `ifdef RTL_SPARC3
    cmp_pcxandcpx cmp_pcxandcpx3(/* AUTOINST*/
        // Inputs
        .clk	(clk),
        .rst_l	(rst_l),
        .spc_pcx_req_pq(`SPARC_CORE3.spc0_pcx_req_pq[4:0]),
        .spc_pcx_data_pa(`SPARC_CORE3.spc0_pcx_data_pa[`PCX_WIDTH-1:0]),
        .cpx_spc_data_cx(`SPARC_CORE3.cpx_spc0_data_cx2[`CPX_WIDTH-1:0]),
        // .cpu	(0));
        .cpu    (3));
    `endif

    `ifdef RTL_SPARC4
    cmp_pcxandcpx cmp_pcxandcpx4(/* AUTOINST*/
        // Inputs
        .clk	(clk),
        .rst_l	(rst_l),
        .spc_pcx_req_pq(`SPARC_CORE4.spc0_pcx_req_pq[4:0]),
        .spc_pcx_data_pa(`SPARC_CORE4.spc0_pcx_data_pa[`PCX_WIDTH-1:0]),
        .cpx_spc_data_cx(`SPARC_CORE4.cpx_spc0_data_cx2[`CPX_WIDTH-1:0]),
        // .cpu	(0));
        .cpu    (4));
    `endif

    `ifdef RTL_SPARC5
    cmp_pcxandcpx cmp_pcxandcpx5(/* AUTOINST*/
        // Inputs
        .clk	(clk),
        .rst_l	(rst_l),
        .spc_pcx_req_pq(`SPARC_CORE5.spc0_pcx_req_pq[4:0]),
        .spc_pcx_data_pa(`SPARC_CORE5.spc0_pcx_data_pa[`PCX_WIDTH-1:0]),
        .cpx_spc_data_cx(`SPARC_CORE5.cpx_spc0_data_cx2[`CPX_WIDTH-1:0]),
        // .cpu	(0));
        .cpu    (5));
    `endif

    `ifdef RTL_SPARC6
    cmp_pcxandcpx cmp_pcxandcpx6(/* AUTOINST*/
        // Inputs
        .clk	(clk),
        .rst_l	(rst_l),
        .spc_pcx_req_pq(`SPARC_CORE6.spc0_pcx_req_pq[4:0]),
        .spc_pcx_data_pa(`SPARC_CORE6.spc0_pcx_data_pa[`PCX_WIDTH-1:0]),
        .cpx_spc_data_cx(`SPARC_CORE6.cpx_spc0_data_cx2[`CPX_WIDTH-1:0]),
        // .cpu	(0));
        .cpu    (6));
    `endif

    `ifdef RTL_SPARC7
    cmp_pcxandcpx cmp_pcxandcpx7(/* AUTOINST*/
        // Inputs
        .clk	(clk),
        .rst_l	(rst_l),
        .spc_pcx_req_pq(`SPARC_CORE7.spc0_pcx_req_pq[4:0]),
        .spc_pcx_data_pa(`SPARC_CORE7.spc0_pcx_data_pa[`PCX_WIDTH-1:0]),
        .cpx_spc_data_cx(`SPARC_CORE7.cpx_spc0_data_cx2[`CPX_WIDTH-1:0]),
        // .cpu	(0));
        .cpu    (7));
    `endif

    `ifdef RTL_SPARC8
    cmp_pcxandcpx cmp_pcxandcpx8(/* AUTOINST*/
        // Inputs
        .clk	(clk),
        .rst_l	(rst_l),
        .spc_pcx_req_pq(`SPARC_CORE8.spc0_pcx_req_pq[4:0]),
        .spc_pcx_data_pa(`SPARC_CORE8.spc0_pcx_data_pa[`PCX_WIDTH-1:0]),
        .cpx_spc_data_cx(`SPARC_CORE8.cpx_spc0_data_cx2[`CPX_WIDTH-1:0]),
        // .cpu	(0));
        .cpu    (8));
    `endif



	`endif  // ifdef DRAM_SAT

endmodule
// Local Variables:
// verilog-library-directories:("." "../../../design/sparc/rtl")
// verilog-library-extensions:(".v" ".h")
// End:












