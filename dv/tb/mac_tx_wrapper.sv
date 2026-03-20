////////////////////////////////////////////////////////////////////////////////
//  <Wrapper for the mac_tx component.>
//  Copyright (C) 2026 James Hicks
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////
module mac_tx_wrapper (dut_if _if);
  mac_tx dut_mac_tx (
                     .clk            (_if.clk),
                     .reset          (_if.reset),
                     .ready          (_if.ready),
                     .valid          (_if.valid),
                     .data           (_if.data),
                     .sof            (_if.sof),
                     .eof            (_if.eof),
                     .txen           (_if.txen),
                     .data_starvation(_if.data_starvation)
                     );
endmodule // mac_tx_wrapper
