////////////////////////////////////////////////////////////////////////////////
//  <32 bit CRC with parameterized polynomial.>
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
//
// DETAILS
//
// Responsibilities of this component are the following
//   -- Take in 8-bit data and output 32-bit CRC 1 clock cycle later.
////////////////////////////////////////////////////////////////////////////////

module crc_32
  #(
  parameter [32:0] POLYNOMIAL=33'h104611DB7; // As per 802.3.
  )
  (
  // System signals
  input logic         clk,
  input logic         reset,
  // Control signals
  input logic         en,     // Enable signal for the CRC.
  input logic         init,   // Resets the CRC calculation to it initial value.
  output logic        valid,  // Indicates the CRC is valid
  // Input output
  input logic [7:0]   din,
  output logic [31:0] crc_out
  );


  // Return the control byte given an input byte
  function logic[7:0] compute_control_byte (input logic[7:0] top_byte);
    logic [7:0] control_byte;

    control_byte[7] = input[7];
    control_byte[6] = control_byte[7] ^ input[6];
    control_byte[5] = control_byte[6] ^ input[5];
    control_byte[4] = control_byte[5] ^ input[4];
    control_byte[3] = control_byte[4] ^ input[3];
    control_byte[2] = control_byte[3] ^ input[2];
    control_byte[1] = control_byte[2] ^ input[1];
    control_byte[0] = control_byte[1] ^ input[0];

    return control_byte;
  endfunction // compute_control_byte

  // Returns a logic array created by summing the POLYNOMIAL at different
  // offsets dictated by the input control byte.
  function logic [31:0] compute_summed_poly (input logic[7:0] control_byte);
    logic [31:0] summed_poly;
    // TODO: Implement
  endfunction // compute_summed_poly


  logic [32:0] crc_reg;

  always_ff @(posedge clk) begin
    // TODO
  end
endmodule // crc_32
