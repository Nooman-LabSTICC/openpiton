/* Copyright 2018 ETH Zurich and University of Bologna.
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * File: $filename.v
 *
 * Description: Auto-generated bootrom
 */

// Auto-generated code
module bootrom_linux (
   input  logic         clk_i,
   input  logic         req_i,
   input  logic [63:0]  addr_i,
   output logic [63:0]  rdata_o
);
    localparam int RomSize = 1050;

    const logic [RomSize-1:0][63:0] mem = {
        64'h000000ff_f0c2c004,
        64'h000000ff_f0c2c003,
        64'h000000ff_f0c2c001,
        64'h000000ff_f0c2c005,
        64'h00000000_00000000,
        64'h0a0d2165_6e6f6420,
        64'h00000000_00206567,
        64'h616d6920_746f6f62,
        64'h20676e69_79706f63,
        64'h00000000_00000009,
        64'h3a656d61_6e090a0d,
        64'h00093a73_65747562,
        64'h69727474_61090a0d,
        64'h00000009_3a61626c,
        64'h20747361_6c090a0d,
        64'h0000093a_61626c20,
        64'h74737269_66090a0d,
        64'h00000000_00000000,
        64'h09202020_20203a64,
        64'h69756720_6e6f6974,
        64'h69747261_70090a0d,
        64'h00000000_00000000,
        64'h093a6469_75672065,
        64'h70797420_6e6f6974,
        64'h69747261_70090a0d,
        64'h00000000_20797274,
        64'h6e65206e_6f697469,
        64'h74726170_20747067,
        64'h00000009_20203a73,
        64'h65697274_6e65206e,
        64'h6f697469_74726170,
        64'h20657a69_73090a0d,
        64'h00000009_3a736569,
        64'h72746e65_206e6f69,
        64'h74697472_61702072,
        64'h65626d75_6e090a0d,
        64'h00000009_2020203a,
        64'h61626c20_73656972,
        64'h746e6520_6e6f6974,
        64'h69747261_70090a0d,
        64'h00093a61_646c2070,
        64'h756b6361_62090a0d,
        64'h00000000_00000000,
        64'h093a6162_6c20746e,
        64'h65727275_63090a0d,
        64'h00000009_3a646576,
        64'h72657365_72090a0d,
        64'h00093a72_65646165,
        64'h685f6372_63090a0d,
        64'h00000000_00000909,
        64'h3a657a69_73090a0d,
        64'h00000009_3a6e6f69,
        64'h73697665_72090a0d,
        64'h0000093a_65727574,
        64'h616e6769_73090a0d,
        64'h00000000_003a7265,
        64'h64616568_20656c62,
        64'h6174206e_6f697469,
        64'h74726170_20747067,
        64'h0000203a_65756c61,
        64'h76206e72_75746572,
        64'h2079706f_63206473,
        64'h00000000_0000000a,
        64'h0d216465_6c696166,
        64'h20647261_63204453,
        64'h00000000_0a0d676e,
        64'h69746978_65202e2e,
        64'h2e647320_657a696c,
        64'h61697469_6e692074,
        64'h6f6e2064_6c756f63,
        64'h00000000_00292520,
        64'h00000000_00000028,
        64'h20736b63_6f6c6220,
        64'h00000000_20666f20,
        64'h0000206b_636f6c62,
        64'h20676e69_79706f63,
        64'h00000000_00000008,
        64'h0000000a_0d202e2e,
        64'h2e445320_676e697a,
        64'h696c6169_74696e69,
        64'h00000000_203f3f79,
        64'h74706d65_20746f6e,
        64'h206f6669_66207872,
        64'h00000000_00000a0d,
        64'h2164657a_696c6169,
        64'h74696e69_20495053,
        64'h00000000_00007830,
        64'h203a7375_74617473,
        64'h00000000_00000a0d,
        64'h49505320_74696e69,
        64'h00000000_0000000a,
        64'h0d216465_7a696c61,
        64'h6974696e_69206473,
        64'h00000000_00766564,
        64'h6e2c7663_73697200,
        64'h79746972_6f697270,
        64'h2d78616d_2c766373,
        64'h69720073_656d616e,
        64'h2d676572_00646564,
        64'h6e657478_652d7374,
        64'h70757272_65746e69,
        64'h00746669_68732d67,
        64'h65720073_74707572,
        64'h7265746e_6900746e,
        64'h65726170_2d747075,
        64'h72726574_6e690064,
        64'h65657073_2d746e65,
        64'h72727563_00736567,
        64'h6e617200_656c646e,
        64'h61687000_72656c6c,
        64'h6f72746e_6f632d74,
        64'h70757272_65746e69,
        64'h00736c6c_65632d74,
        64'h70757272_65746e69,
        64'h23007469_6c70732d,
        64'h626c7400_65707974,
        64'h2d756d6d_00617369,
        64'h2c766373_69720073,
        64'h75746174_73006765,
        64'h72006570_79745f65,
        64'h63697665_64007963,
        64'h6e657571_6572662d,
        64'h6b636f6c_63007963,
        64'h6e657571_6572662d,
        64'h65736162_656d6974,
        64'h006c6564_6f6d0065,
        64'h6c626974_61706d6f,
        64'h6300736c_6c65632d,
        64'h657a6973_2300736c,
        64'h6c65632d_73736572,
        64'h64646123_09000000,
        64'h02000000_02000000,
        64'h02000000_01000000,
        64'ha9000000_04000000,
        64'h03000000_01000000,
        64'h1d010000_04000000,
        64'h03000000_07000000,
        64'h0a010000_04000000,
        64'h03000000_00000004,
        64'h00000000_000010f1,
        64'hff000000_5b000000,
        64'h10000000_03000000,
        64'h09000000_0a000000,
        64'h0b000000_0a000000,
        64'h09000000_09000000,
        64'h0b000000_09000000,
        64'h09000000_08000000,
        64'h0b000000_08000000,
        64'h09000000_07000000,
        64'h0b000000_07000000,
        64'h09000000_06000000,
        64'h0b000000_06000000,
        64'h09000000_05000000,
        64'h0b000000_05000000,
        64'h09000000_04000000,
        64'h0b000000_04000000,
        64'h09000000_03000000,
        64'h0b000000_03000000,
        64'h09000000_02000000,
        64'h0b000000_02000000,
        64'hec000000_90000000,
        64'h03000000_94000000,
        64'h00000000_03000000,
        64'h00306369_6c702c76,
        64'h63736972_1b000000,
        64'h0c000000_03000000,
        64'h01000000_83000000,
        64'h04000000_03000000,
        64'h00000000_00000000,
        64'h04000000_03000000,
        64'h00303030_30303131,
        64'h66666640_63696c70,
        64'h01000000_02000000,
        64'h006c6f72_746e6f63,
        64'h00010000_08000000,
        64'h03000000_00000c00,
        64'h00000000_000002f1,
        64'hff000000_5b000000,
        64'h10000000_03000000,
        64'h07000000_0a000000,
        64'h03000000_0a000000,
        64'h07000000_09000000,
        64'h03000000_09000000,
        64'h07000000_08000000,
        64'h03000000_08000000,
        64'h07000000_07000000,
        64'h03000000_07000000,
        64'h07000000_06000000,
        64'h03000000_06000000,
        64'h07000000_05000000,
        64'h03000000_05000000,
        64'h07000000_04000000,
        64'h03000000_04000000,
        64'h07000000_03000000,
        64'h03000000_03000000,
        64'h07000000_02000000,
        64'h03000000_02000000,
        64'hec000000_90000000,
        64'h03000000_00000000,
        64'h30746e69_6c632c76,
        64'h63736972_1b000000,
        64'h0d000000_03000000,
        64'h00000000_30303030,
        64'h32303166_66664074,
        64'h6e696c63_01000000,
        64'h02000000_006c6f72,
        64'h746e6f63_00010000,
        64'h08000000_03000000,
        64'h00100000_00000000,
        64'h000000f1_ff000000,
        64'h5b000000_10000000,
        64'h03000000_ffff0000,
        64'h0a000000_ffff0000,
        64'h09000000_ffff0000,
        64'h08000000_ffff0000,
        64'h07000000_ffff0000,
        64'h06000000_ffff0000,
        64'h05000000_ffff0000,
        64'h04000000_ffff0000,
        64'h03000000_ffff0000,
        64'h02000000_ec000000,
        64'h48000000_03000000,
        64'h00333130_2d677562,
        64'h65642c76_63736972,
        64'h1b000000_10000000,
        64'h03000000_00303030,
        64'h30303031_66666640,
        64'h72656c6c_6f72746e,
        64'h6f632d67_75626564,
        64'h01000000_02000000,
        64'h00000000_e2000000,
        64'h04000000_03000000,
        64'h01000000_d7000000,
        64'h04000000_03000000,
        64'h01000000_c6000000,
        64'h04000000_03000000,
        64'h00c20100_b8000000,
        64'h04000000_03000000,
        64'h80f0fa02_3f000000,
        64'h04000000_03000000,
        64'h00400d00_00000000,
        64'h00c0c2f0_ff000000,
        64'h5b000000_10000000,
        64'h03000000_00303535,
        64'h3631736e_1b000000,
        64'h08000000_03000000,
        64'h00303030_63326330,
        64'h66666640_74726175,
        64'h01000000_b1000000,
        64'h00000000_03000000,
        64'h00007375_622d656c,
        64'h706d6973_00636f73,
        64'h2d657261_622d656e,
        64'h61697261_2c687465,
        64'h1b000000_1f000000,
        64'h03000000_02000000,
        64'h0f000000_04000000,
        64'h03000000_02000000,
        64'h00000000_04000000,
        64'h03000000_00636f73,
        64'h01000000_02000000,
        64'h00000040_00000000,
        64'h00000080_00000000,
        64'h5b000000_10000000,
        64'h03000000_00007972,
        64'h6f6d656d_4f000000,
        64'h07000000_03000000,
        64'h00303030_30303030,
        64'h38407972_6f6d656d,
        64'h01000000_02000000,
        64'h02000000_02000000,
        64'h0a000000_a9000000,
        64'h04000000_03000000,
        64'h00006374_6e692d75,
        64'h70632c76_63736972,
        64'h1b000000_0f000000,
        64'h03000000_94000000,
        64'h00000000_03000000,
        64'h01000000_83000000,
        64'h04000000_03000000,
        64'h00000000_72656c6c,
        64'h6f72746e_6f632d74,
        64'h70757272_65746e69,
        64'h01000000_79000000,
        64'h00000000_03000000,
        64'h00003933_76732c76,
        64'h63736972_70000000,
        64'h0b000000_03000000,
        64'h00006364_66616d69,
        64'h34367672_66000000,
        64'h0b000000_03000000,
        64'h00000076_63736972,
        64'h00656e61_69726120,
        64'h2c687465_1b000000,
        64'h12000000_03000000,
        64'h00000000_79616b6f,
        64'h5f000000_05000000,
        64'h03000000_08000000,
        64'h5b000000_04000000,
        64'h03000000_00757063,
        64'h4f000000_04000000,
        64'h03000000_80f0fa02,
        64'h3f000000_04000000,
        64'h03000000_00000038,
        64'h40757063_01000000,
        64'h02000000_02000000,
        64'h09000000_a9000000,
        64'h04000000_03000000,
        64'h00006374_6e692d75,
        64'h70632c76_63736972,
        64'h1b000000_0f000000,
        64'h03000000_94000000,
        64'h00000000_03000000,
        64'h01000000_83000000,
        64'h04000000_03000000,
        64'h00000000_72656c6c,
        64'h6f72746e_6f632d74,
        64'h70757272_65746e69,
        64'h01000000_79000000,
        64'h00000000_03000000,
        64'h00003933_76732c76,
        64'h63736972_70000000,
        64'h0b000000_03000000,
        64'h00006364_66616d69,
        64'h34367672_66000000,
        64'h0b000000_03000000,
        64'h00000076_63736972,
        64'h00656e61_69726120,
        64'h2c687465_1b000000,
        64'h12000000_03000000,
        64'h00000000_79616b6f,
        64'h5f000000_05000000,
        64'h03000000_07000000,
        64'h5b000000_04000000,
        64'h03000000_00757063,
        64'h4f000000_04000000,
        64'h03000000_80f0fa02,
        64'h3f000000_04000000,
        64'h03000000_00000037,
        64'h40757063_01000000,
        64'h02000000_02000000,
        64'h08000000_a9000000,
        64'h04000000_03000000,
        64'h00006374_6e692d75,
        64'h70632c76_63736972,
        64'h1b000000_0f000000,
        64'h03000000_94000000,
        64'h00000000_03000000,
        64'h01000000_83000000,
        64'h04000000_03000000,
        64'h00000000_72656c6c,
        64'h6f72746e_6f632d74,
        64'h70757272_65746e69,
        64'h01000000_79000000,
        64'h00000000_03000000,
        64'h00003933_76732c76,
        64'h63736972_70000000,
        64'h0b000000_03000000,
        64'h00006364_66616d69,
        64'h34367672_66000000,
        64'h0b000000_03000000,
        64'h00000076_63736972,
        64'h00656e61_69726120,
        64'h2c687465_1b000000,
        64'h12000000_03000000,
        64'h00000000_79616b6f,
        64'h5f000000_05000000,
        64'h03000000_06000000,
        64'h5b000000_04000000,
        64'h03000000_00757063,
        64'h4f000000_04000000,
        64'h03000000_80f0fa02,
        64'h3f000000_04000000,
        64'h03000000_00000036,
        64'h40757063_01000000,
        64'h02000000_02000000,
        64'h07000000_a9000000,
        64'h04000000_03000000,
        64'h00006374_6e692d75,
        64'h70632c76_63736972,
        64'h1b000000_0f000000,
        64'h03000000_94000000,
        64'h00000000_03000000,
        64'h01000000_83000000,
        64'h04000000_03000000,
        64'h00000000_72656c6c,
        64'h6f72746e_6f632d74,
        64'h70757272_65746e69,
        64'h01000000_79000000,
        64'h00000000_03000000,
        64'h00003933_76732c76,
        64'h63736972_70000000,
        64'h0b000000_03000000,
        64'h00006364_66616d69,
        64'h34367672_66000000,
        64'h0b000000_03000000,
        64'h00000076_63736972,
        64'h00656e61_69726120,
        64'h2c687465_1b000000,
        64'h12000000_03000000,
        64'h00000000_79616b6f,
        64'h5f000000_05000000,
        64'h03000000_05000000,
        64'h5b000000_04000000,
        64'h03000000_00757063,
        64'h4f000000_04000000,
        64'h03000000_80f0fa02,
        64'h3f000000_04000000,
        64'h03000000_00000035,
        64'h40757063_01000000,
        64'h02000000_02000000,
        64'h06000000_a9000000,
        64'h04000000_03000000,
        64'h00006374_6e692d75,
        64'h70632c76_63736972,
        64'h1b000000_0f000000,
        64'h03000000_94000000,
        64'h00000000_03000000,
        64'h01000000_83000000,
        64'h04000000_03000000,
        64'h00000000_72656c6c,
        64'h6f72746e_6f632d74,
        64'h70757272_65746e69,
        64'h01000000_79000000,
        64'h00000000_03000000,
        64'h00003933_76732c76,
        64'h63736972_70000000,
        64'h0b000000_03000000,
        64'h00006364_66616d69,
        64'h34367672_66000000,
        64'h0b000000_03000000,
        64'h00000076_63736972,
        64'h00656e61_69726120,
        64'h2c687465_1b000000,
        64'h12000000_03000000,
        64'h00000000_79616b6f,
        64'h5f000000_05000000,
        64'h03000000_04000000,
        64'h5b000000_04000000,
        64'h03000000_00757063,
        64'h4f000000_04000000,
        64'h03000000_80f0fa02,
        64'h3f000000_04000000,
        64'h03000000_00000034,
        64'h40757063_01000000,
        64'h02000000_02000000,
        64'h05000000_a9000000,
        64'h04000000_03000000,
        64'h00006374_6e692d75,
        64'h70632c76_63736972,
        64'h1b000000_0f000000,
        64'h03000000_94000000,
        64'h00000000_03000000,
        64'h01000000_83000000,
        64'h04000000_03000000,
        64'h00000000_72656c6c,
        64'h6f72746e_6f632d74,
        64'h70757272_65746e69,
        64'h01000000_79000000,
        64'h00000000_03000000,
        64'h00003933_76732c76,
        64'h63736972_70000000,
        64'h0b000000_03000000,
        64'h00006364_66616d69,
        64'h34367672_66000000,
        64'h0b000000_03000000,
        64'h00000076_63736972,
        64'h00656e61_69726120,
        64'h2c687465_1b000000,
        64'h12000000_03000000,
        64'h00000000_79616b6f,
        64'h5f000000_05000000,
        64'h03000000_03000000,
        64'h5b000000_04000000,
        64'h03000000_00757063,
        64'h4f000000_04000000,
        64'h03000000_80f0fa02,
        64'h3f000000_04000000,
        64'h03000000_00000033,
        64'h40757063_01000000,
        64'h02000000_02000000,
        64'h04000000_a9000000,
        64'h04000000_03000000,
        64'h00006374_6e692d75,
        64'h70632c76_63736972,
        64'h1b000000_0f000000,
        64'h03000000_94000000,
        64'h00000000_03000000,
        64'h01000000_83000000,
        64'h04000000_03000000,
        64'h00000000_72656c6c,
        64'h6f72746e_6f632d74,
        64'h70757272_65746e69,
        64'h01000000_79000000,
        64'h00000000_03000000,
        64'h00003933_76732c76,
        64'h63736972_70000000,
        64'h0b000000_03000000,
        64'h00006364_66616d69,
        64'h34367672_66000000,
        64'h0b000000_03000000,
        64'h00000076_63736972,
        64'h00656e61_69726120,
        64'h2c687465_1b000000,
        64'h12000000_03000000,
        64'h00000000_79616b6f,
        64'h5f000000_05000000,
        64'h03000000_02000000,
        64'h5b000000_04000000,
        64'h03000000_00757063,
        64'h4f000000_04000000,
        64'h03000000_80f0fa02,
        64'h3f000000_04000000,
        64'h03000000_00000032,
        64'h40757063_01000000,
        64'h02000000_02000000,
        64'h03000000_a9000000,
        64'h04000000_03000000,
        64'h00006374_6e692d75,
        64'h70632c76_63736972,
        64'h1b000000_0f000000,
        64'h03000000_94000000,
        64'h00000000_03000000,
        64'h01000000_83000000,
        64'h04000000_03000000,
        64'h00000000_72656c6c,
        64'h6f72746e_6f632d74,
        64'h70757272_65746e69,
        64'h01000000_79000000,
        64'h00000000_03000000,
        64'h00003933_76732c76,
        64'h63736972_70000000,
        64'h0b000000_03000000,
        64'h00006364_66616d69,
        64'h34367672_66000000,
        64'h0b000000_03000000,
        64'h00000076_63736972,
        64'h00656e61_69726120,
        64'h2c687465_1b000000,
        64'h12000000_03000000,
        64'h00000000_79616b6f,
        64'h5f000000_05000000,
        64'h03000000_01000000,
        64'h5b000000_04000000,
        64'h03000000_00757063,
        64'h4f000000_04000000,
        64'h03000000_80f0fa02,
        64'h3f000000_04000000,
        64'h03000000_00000031,
        64'h40757063_01000000,
        64'h02000000_02000000,
        64'h02000000_a9000000,
        64'h04000000_03000000,
        64'h00006374_6e692d75,
        64'h70632c76_63736972,
        64'h1b000000_0f000000,
        64'h03000000_94000000,
        64'h00000000_03000000,
        64'h01000000_83000000,
        64'h04000000_03000000,
        64'h00000000_72656c6c,
        64'h6f72746e_6f632d74,
        64'h70757272_65746e69,
        64'h01000000_79000000,
        64'h00000000_03000000,
        64'h00003933_76732c76,
        64'h63736972_70000000,
        64'h0b000000_03000000,
        64'h00006364_66616d69,
        64'h34367672_66000000,
        64'h0b000000_03000000,
        64'h00000076_63736972,
        64'h00656e61_69726120,
        64'h2c687465_1b000000,
        64'h12000000_03000000,
        64'h00000000_79616b6f,
        64'h5f000000_05000000,
        64'h03000000_00000000,
        64'h5b000000_04000000,
        64'h03000000_00757063,
        64'h4f000000_04000000,
        64'h03000000_80f0fa02,
        64'h3f000000_04000000,
        64'h03000000_00000030,
        64'h40757063_01000000,
        64'he1f50500_2c000000,
        64'h04000000_03000000,
        64'h00000000_0f000000,
        64'h04000000_03000000,
        64'h01000000_00000000,
        64'h04000000_03000000,
        64'h00000000_73757063,
        64'h01000000_00657261,
        64'h622d656e_61697261,
        64'h2c687465_26000000,
        64'h10000000_03000000,
        64'h00766564_2d657261,
        64'h622d656e_61697261,
        64'h2c687465_1b000000,
        64'h14000000_03000000,
        64'h02000000_0f000000,
        64'h04000000_03000000,
        64'h02000000_00000000,
        64'h04000000_03000000,
        64'h00000000_01000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'hd40e0000_28010000,
        64'h00000000_10000000,
        64'h11000000_28000000,
        64'h0c0f0000_38000000,
        64'h34100000_edfe0dd0,
        64'h00000000_0a0d0a0d,
        64'h0a0d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d0a0d_20202020,
        64'h20202020_20203420,
        64'h2f20426b_20343620,
        64'h20203a63_6f737341,
        64'h202f2065_7a695320,
        64'h20324c0a_0d202020,
        64'h20202020_20202034,
        64'h202f2042_6b203820,
        64'h2020203a_636f7373,
        64'h41202f20_657a6953,
        64'h2035314c_0a0d2020,
        64'h20202020_20202020,
        64'h34202f20_426b2038,
        64'h20202020_3a636f73,
        64'h7341202f_20657a69,
        64'h53204431_4c0a0d20,
        64'h20202020_20202020,
        64'h2034202f_20426b20,
        64'h36312020_203a636f,
        64'h73734120_2f20657a,
        64'h69532049_314c0a0d,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h0a0d2020_20202020,
        64'h20202020_20202020,
        64'h2020424d_20343230,
        64'h31202020_20202020,
        64'h20203a65_7a695320,
        64'h4d415244_0a0d2020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20687365_6d5f6432,
        64'h20202020_20202020,
        64'h2020203a_6b726f77,
        64'h74654e0a_0d202020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h6e776f6e_6b6e5520,
        64'h20202020_20202020,
        64'h3a716572_46206572,
        64'h6f430a0d_20202020,
        64'h20202020_20202020,
        64'h20202020_20202039,
        64'h20202020_20202020,
        64'h20202020_3a736572,
        64'h6f43230a_0d202020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h33202020_20202020,
        64'h2020203a_73656c69,
        64'h542d5923_0a0d2020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20332020_20202020,
        64'h20202020_3a73656c,
        64'h69542d58_230a0d20,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202020_2020200a,
        64'h0d202020_20202020,
        64'h20202020_20202020,
        64'h20202020_39313a30,
        64'h313a3831_20313230,
        64'h32203332_20766f4e,
        64'h20202020_20202020,
        64'h3a657461_4420646c,
        64'h6975420a_0d202020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h296e6f69_74616c75,
        64'h6d695328_20656e6f,
        64'h4e202020_20202020,
        64'h203a6472_616f4220,
        64'h41475046_0a0d2020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202020_20200a0d,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202065_34633531,
        64'h63313520_2020203a,
        64'h6e6f6973_72655620,
        64'h656e6169_72410a0d,
        64'h20202020_20202020,
        64'h20202020_20202020,
        64'h20202065_34633531,
        64'h63313520_3a6e6f69,
        64'h73726556_206e6f74,
        64'h69506e65_704f0a0d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h0a0d2d2d_20202020,
        64'h20206d72_6f667461,
        64'h6c502065_6e616972,
        64'h412b6e6f_7469506e,
        64'h65704f20_20202020,
        64'h2d2d0a0d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_2d2d2d2d,
        64'h2d2d2d2d_0a0d0a0d,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h46454443_42413938,
        64'h37363534_33323130,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h80820141_450160a2,
        64'hd0bff0ef_057e65a1,
        64'h4505913f_f0ef5665,
        64'h05130000_151791ff,
        64'hf0ef18a5_05130000,
        64'h05178d1f_f0efe406,
        64'h38050513_20058593,
        64'h114101c9_c53765f1,
        64'hbb85943f_f0ef84e5,
        64'h05130000_2517b3c5,
        64'h5e850513_00001517,
        64'ha5dff0ef_852695ff,
        64'hf0ef6aa5_05130000,
        64'h151796bf_f0ef69e5,
        64'h05130000_1517c50d,
        64'h84aac93f_f0ef8552,
        64'h865a020a_a583987f,
        64'hf0ef6225_05130000,
        64'h1517993f_f0ef8865,
        64'h05130000_2517f579,
        64'h93e30804_84939a7f,
        64'hf0ef2985_64450513,
        64'h00001517_ff2c1be3,
        64'hb01ff0ef_09050009,
        64'h45039c3f_f0ef8a65,
        64'h05130000_2517ad3f,
        64'hf0ef7088_9d5ff0ef,
        64'h8a850513_00002517,
        64'hae5ff0ef_6c889e7f,
        64'hf0ef8aa5_05130000,
        64'h2517af7f_f0ef0704,
        64'h8c130284_89136888,
        64'ha01ff0ef_8b450513,
        64'h00002517_ff2c1be3,
        64'hb59ff0ef_09050009,
        64'h45030109_0c13a1ff,
        64'hf0ef8b25_05130000,
        64'h2517fe99_1be3b77f,
        64'hf0ef0905_00094503,
        64'hff048913_a3dff0ef,
        64'h8b050513_00002517,
        64'hb91ff0ef_0ff9f513,
        64'ha51ff0ef_8ac50513,
        64'h00002517_b5fd6f65,
        64'h05130000_1517b6bf,
        64'hf0ef854e_a6dff0ef,
        64'h7b850513_00001517,
        64'ha79ff0ef_7ac50513,
        64'h00001517_c50d0804,
        64'h89aa8a8a_da5ff0ef,
        64'h850a4605_71010489,
        64'h2583a9bf_f0ef7365,
        64'h05130000_1517b69f,
        64'hf0ef4556_aadff0ef,
        64'h8e850513_00002517,
        64'hb7bff0ef_4546abff,
        64'hf0ef8da5_05130000,
        64'h2517bcff_f0ef6526,
        64'had1ff0ef_8cc50513,
        64'h00002517_be1ff0ef,
        64'h7502ae3f_f0ef8ce5,
        64'h05130000_2517bf3f,
        64'hf0ef6562_af5ff0ef,
        64'h8c850513_00002517,
        64'hbc3ff0ef_4552b07f,
        64'hf0ef8ca5_05130000,
        64'h2517bd5f_f0ef4542,
        64'hb19ff0ef_8cc50513,
        64'h00002517_be7ff0ef,
        64'h4532b2bf_f0ef8ce5,
        64'h05130000_2517bf9f,
        64'hf0ef4522_b3dff0ef,
        64'h8d050513_00002517,
        64'hc4dff0ef_4b916502,
        64'hb51ff0ef_8d450513,
        64'h00002517_b5dff0ef,
        64'h8c050513_00002517,
        64'hbf6154f9_b6dff0ef,
        64'h80850513_00002517,
        64'hc7dff0ef_8526b7ff,
        64'hf0ef8ca5_05130000,
        64'h2517b8bf_f0ef8be5,
        64'h05130000_2517c905,
        64'h84aa890a_eb5ff0ef,
        64'h850a4585_46057101,
        64'hba9ff0ef_7fc50513,
        64'h00001517_80826161,
        64'h6c026ba2_6b426ae2,
        64'h7a0279a2_794274e2,
        64'h64068526_60a6fb04,
        64'h011354fd_bd5ff0ef,
        64'h8e050513_00002517,
        64'hc51dee3f_f0ef8b2e,
        64'h8a2a0880_e062e45e,
        64'hec56f44e_f84afc26,
        64'he486e85a_f052e0a2,
        64'h715db7bd_2a85c07f,
        64'hf0ef8da5_05130000,
        64'h2517bf81_2985200b,
        64'h0b1384ae_fee59ae3,
        64'hfed7bc23_07a1ff85,
        64'hb68305a1_85a687da,
        64'h20048713_9c29c37f,
        64'hf0ef93a5_05130000,
        64'h25179c29_c93ff0ef,
        64'h0325553b_4585033a,
        64'h053b9c29_c55ff0ef,
        64'h94850513_00002517,
        64'h9c29cb1f_f0ef854a,
        64'h9c294585_c6dff0ef,
        64'h95850513_00002517,
        64'h9c29cc9f_f0ef854e,
        64'h0005041b_4585c87f,
        64'hf0ef9625_05130000,
        64'h25170954_1263060a,
        64'h93630349_fabb8082,
        64'h61214501_6b026aa2,
        64'h6a4269e2_790274a2,
        64'h744270e2_cb5ff0ef,
        64'h95050513_00002517,
        64'h03299363_06400a13,
        64'h44014981_94ae8932,
        64'h8b2ae456_fc06e05a,
        64'he852ec4e_f04af822,
        64'h149281dd_44bd1582,
        64'hf4267139_80820141,
        64'h450160a2_cf5ff0ef,
        64'he4069b45_05131141,
        64'h00002517_8082557d,
        64'hb7e900d7_00230785,
        64'h00f60733_06c82683,
        64'hff798b05_5178bf4d,
        64'hd6b80785_0007c703,
        64'h80824501_d3b84719,
        64'hdbb8577d_200007b7,
        64'h00b6ef63_0007869b,
        64'h20000837_20000537,
        64'hfff58b85_537c2000,
        64'h0737d3b8_200007b7,
        64'h10600713_fff537fd,
        64'h00010320_079304b7,
        64'h616340a7_873b87aa,
        64'h200006b7_dbb85779,
        64'h200007b7_06b7ec63,
        64'h10000793_80826105,
        64'h64a2d3b8_4719dbb8,
        64'h644260e2_0ff47513,
        64'h577d2000_07b7d9ff,
        64'hf0efa3a5_05130000,
        64'h2517eaff_f0ef9101,
        64'h15024088_db5ff0ef,
        64'ha5850513_00002517,
        64'he3958b85_240153fc,
        64'h57e0ff65_8b050647,
        64'h849353f8_d3b81060,
        64'h07132000_07b7fff5,
        64'h37fd0001_06400793,
        64'hd7a8dbb8_5779e426,
        64'he822ec06_200007b7,
        64'h1101dfbf_f06f6105,
        64'ha8850513_00002517,
        64'h64a260e2_6442d03c,
        64'h4799e13f_f0efaae5,
        64'h05130000_2517f23f,
        64'hf0ef9101_02049513,
        64'h2481e2bf_f0efaa65,
        64'h05130000_25175064,
        64'hd03c1660_0793e3ff,
        64'hf0efada5_05130000,
        64'h2517f4ff_f0ef9101,
        64'h02049513_2481e57f,
        64'hf0efad25_05130000,
        64'h25175064_d03c1040,
        64'h07932000_0437fff5,
        64'h37fd0001_47a9c3b8,
        64'h47292000_07b7e7ff,
        64'hf0efe426_e822ec06,
        64'haf250513_11010000,
        64'h25178082_41088082,
        64'hc10c8082_61054509,
        64'h60e2e27f_f0ef0091,
        64'h4503e2ff_f0ef0081,
        64'h4503eddf_f0efec06,
        64'h002c1101_80826145,
        64'h45416942_64e27402,
        64'h70a2fe94_10e3e53f,
        64'hf0ef0091_4503e5bf,
        64'hf0ef3461_00814503,
        64'hf0bff0ef_0ff57513,
        64'h002c0089_553354e1,
        64'h03800413_892af406,
        64'he84aec26_f0227179,
        64'h80826145_45216942,
        64'h64e27402_70a2fe94,
        64'h10e3e97f_f0ef0091,
        64'h4503e9ff_f0ef3461,
        64'h00814503_f4fff0ef,
        64'h0ff57513_002c0089,
        64'h553b54e1_4461892a,
        64'hf406e84a_ec26f022,
        64'h71798082_61216b02,
        64'h6aa26a42_69e27902,
        64'h74a2854e_744270e2,
        64'hfd5914e3_0004851b,
        64'h397d85d2_ee9ff0ef,
        64'h29850007_c50397ba,
        64'h6da78793_8b3d0000,
        64'h079700ba_7e63e399,
        64'h0364543b_028574bb,
        64'h0007079b_00090a1b,
        64'h0285573b_5afd4b29,
        64'h49814925_a0040413,
        64'he852f426_fc06e05a,
        64'he456ec4e_f04a3b9a,
        64'hd437f822_71398082,
        64'h00f58023_0007c783,
        64'h00e580a3_97aa8111,
        64'h00074703_973e00f5,
        64'h771373a7_87930000,
        64'h0797b7d5_0405f63f,
        64'hf0ef853e_80826105,
        64'h64a26442_60e2e791,
        64'h4094053b_00044783,
        64'h842a84aa_ec06e426,
        64'he8221101_808200e7,
        64'h80230200_0713f3e7,
        64'hb7830000_279700f7,
        64'h0023478d_00a68023,
        64'h0ff57513_00c78023,
        64'h0085551b_0ff57613,
        64'h07ba30b7_879303ff,
        64'hc7b700f7_0023f800,
        64'h07930006_8023f6e7,
        64'hb7030000_2797f6e7,
        64'hb6830000_279702b5,
        64'h553b0045_959b8082,
        64'h00a78023_07ba30b7,
        64'h879303ff_c7b7dbe5,
        64'h0207f793_0007c783,
        64'hf907b783_00002797,
        64'h80820205_75130007,
        64'hc503fa27_b7830000,
        64'h27978082_00054503,
        64'h808200b5_00238082,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00000000,
        64'h00000000_00048067,
        64'h01f49493_0010049b,
        64'hd5058593_00001597,
        64'hf1402573_ff2496e3,
        64'h00900493_0004a903,
        64'h04048493_01a49493,
        64'h0210049b_0924a4af,
        64'h00190913_04048493,
        64'h01a49493_0210049b,
        64'hff2496e3_f14024f3,
        64'h0004a903_04048493,
        64'h01a49493_0210049b,
        64'h04d000ef_01a11113,
        64'h0210011b_01249863,
        64'hf1402973_00000493
    };

    logic [$clog2(RomSize)-1:0] addr_q;

    always_ff @(posedge clk_i) begin
        if (req_i) begin
            addr_q <= addr_i[$clog2(RomSize)-1+3:3];
        end
    end

    // this prevents spurious Xes from propagating into
    // the speculative fetch stage of the core
    assign rdata_o = (addr_q < RomSize) ? mem[addr_q] : '0;
endmodule
