// <one line to give the program's name and a brief idea of what it does.>
//     Copyright (C) <year>  <name of author>

//     This program is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.

//     This program is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU General Public License for more details.

//     You should have received a copy of the GNU General Public License
//     along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// DETAILS
//
// Interface for the mac_tx component.
interface mac_tx_if (input clk);
  logic       reset;
  logic       ready;
  logic       valid;
  logic [7:0] data;
  logic       sof;
  logic       eof;
  logic       txen;
  logic [1:0] txd;
  logic       data_starvation;
endinterface; // mac_tx_if
