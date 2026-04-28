////////////////////////////////////////////////////////////////////////////////
//  <32 bit CRC with parameterized polynomial and seed.>
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
//   -- Take in 8-bit data and output 32-bit CRC.
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

endmodule // crc_32
