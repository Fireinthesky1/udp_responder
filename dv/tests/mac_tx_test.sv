////////////////////////////////////////////////////////////////////////////////
//  <Test Class for mac_tx component.>
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
// - TODO
////////////////////////////////////////////////////////////////////////////////
class base_test extends uvm_test;
  // Register the base_test class with the UVM factory.
  `uvm_component_utils (base_test);

  // Class Properties
  mac_tx_env m_top_env;         // Environment
  virtual mac_tx_if mac_tx_vi;  // Pointer to the mac_tx interface.

  // Constructor for the base_test class
  function new (string name, uvm_component parent = null);
    super.new (name, parent); // Call the parent constructor
  endfunction : new

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);

    // TODO(HICKS): what's going on here?
    m_top_env = mac_tx_env::type_id::create ("m_top_env", this);
