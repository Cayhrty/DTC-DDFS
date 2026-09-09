# DTC-DDFS - Chip RTL Source Code

**DTC based DDFS RTL for radar FMCW synthesis**

This repository contains a complete RTL (Register Transfer Level) chip source code for a Direct Digital Synthesis (DDS) based radar FMCW signal synthesizer. The design is implemented in Verilog.

> ⚠️ **Important Notice**: This is chip RTL source code that can be directly used for iVerilog simulation after adding technology library files.

## Overview

The DDS (Direct Digital Synthesizer) chip top-level module integrates the following core functionalities:

- **SPI Slave Controller** (`spi_slv_top`) - For register access and configuration
- **Reset Synchronization** for reference and high-speed clocks - Multi-clock domain synchronization design
- **Frame/Idle Control State Machine** - `enable_state_machine.v`
- **Core Computation Module** - `dtcdds` DDS signal generation
- **Output Selection Logic** (`output_select`) - Channel selection
- **Test Mode RAM** - For injecting pre-computed edge data

## Register Map

Registers are accessed via SPI with format: 1-bit read/write flag, 5-bit length, 10-bit address, followed by `length*8` bits of data. The address space covers at least 0–79.

| Address | Description | Width | Notes |
|---------|-------------|-------|-------|
| 0 | `dphi_slope` | 8 | DDS slope parameter |
| 1 | `iacc_slope` | 16 | Integration slope |
| 3 | `inv_delta_phi_Preset` | 16 | Phase derivative preset |
| 5 | `phiApreset` | 18 | Only lower bits of 24-bit field are valid |
| 8 | `phiBpreset` | 18 | Phase preset B |
| 11 | `phiCpreset` | 18 | Phase preset C |
| 14 | `phiDpreset` | 18 | Phase preset D |
| 17 | `dPhiPresetA` | 18 | Phase derivative preset A |
| 20 | `dPhiPresetB` | 18 | Phase derivative preset B |
| 23 | `dPhiPresetC` | 18 | Phase derivative preset C |
| 26 | `dPhiPresetD` | 18 | Phase derivative preset D |
| 29 | `CONTROL_REG` | 8 | [ram_cs(1), output_select_mode(1), test_mode_enable(1), rst_n(1), command(4)] |
| 30 | `TEST_MODE_RAM_REG` | 8 | [wr_en(1), wr_addr(4), reserved(3)] |
| 31 | `frame_len` | 16 | State machine frame length |
| 33 | `idle_len` | 16 | State machine idle length |
| 35-79 | `RAM DATA IN` | 8 per entry | Write RAM data when test mode is enabled |

> **Note**: Registers above address 79 are currently unused in the logic.

### Control Register Bit Allocation

**CONTROL_REG (Address 29):**
```
[7]   ram_cs              // Active low
[6]   output_select_mode  // 0=FIFO mode, 1=Test mode
[5]   test_mode_enable    // 0=FIFO mode, 1=Test mode
[4]   rst_n               // Reset signal
[3:0] command             // 0=NOP, 1=RUN, 2=AUTO
```

**TEST_MODE_RAM_REG (Address 30):**
```
[7]   wr_en       // Write enable
[6:3] wr_addr     // Write address
[2:0] Reserved
```

## Programming Sequence

### 1. SPI Initialization
- Pull high `spi_csn_pad`
- Set `spi_rstn_pad` to 0 then 1 to reset

### 2. Write Configuration Registers
- Send write command with address 0 and length covering all required registers
- **SPI protocol supports maximum 32 bytes per transaction. Multiple transactions are required for data ranges exceeding 32 bytes**
- Multi-byte write operation first transmits 16-bit command word, then data bytes
- Test platform example writes addresses 0–31 in a single transaction

### 3. Set Frame/Idle Length
- Write `frame_len` at address 31
- Write `idle_len` at address 33

### 4. Optional: Load RAM
- Set `test_mode_enable` to 1 in CONTROL_REG
- Write TEST_MODE_RAM_REG with `wr_en` set to 1, select write address, then transmit 8-bit data starting from address 35
- Toggle `ram_cs` to latch data

### 5. Release Reset
- Set `rst_n` to 1 in CONTROL_REG and set `command` to desired state

### 6. Start Operation
CONTROL_REG `command` field:
- **1 = RUN** - Single frame execution
- **2 = AUTO** - Continuous automatic mode
- **0 = STOP** - Stop operation

`enable_state_machine` handles frame counting and pipeline timing.

### 7. Monitor Output
- Edge data output on 8-bit buses `edgeA_out`–`edgeH_out`
- Selection signals (`selAA`, etc.) indicate current channel
- DAC selection signals (`DAC_selA`–`DAC_selH`) for external DAC

## State Machine Operation

`enable_state_machine.v` implements four main states:

### 1. IDLE (State 0)
- `enable`=0, frame counter cleared, waits for `command` RUN or AUTO
- RUN command enters RUN state; AUTO command enters AUTO state
- `reset_calc_module` held low keeps computation module in reset

### 2. RUN (State 1)
- `frame_counter` increments until reaching `frame_len`, then returns to IDLE and resets computation module
- When `pipeline_counter` reaches 3, `enable` is set to 1 for valid output data

### 3. AUTO continue (State 2)
- Similar to RUN, but enters AUTO idle state after `frame_len` is reached unless STOP command received
- `reset_calc_module` remains active, `enable` varies with pipeline counter

### 4. AUTO idle (State 3)
- After idle count reaches `idle_len`, returns to AUTO continue state
- `reset_calc_module` performs reset in this state

State machine transitions are driven by `command` changes.

## Project Structure

```
iVerilog/
├── chip_top.v                 # Chip top-level module
├── chip_top_tb.v              # Test platform
├── spi_slv_top.v              # SPI slave controller
├── enable_state_machine.v      # State machine
├── dtcdds.v                   # DDS core computation
├── output_select.v            # Output selection logic
└── [Other supporting modules]
```

## Required Technology Library Files

To run iVerilog simulation and synthesis, the following technology library files are required:

- **tpfn65gpgv2od3.v** - Standard cell library definitions
- **tcbn65gplus.v** - Core standard cell library 
- **DW_ram_r_w_a_lat.v** - Designware RAM compiler module (read/write with latches)

These files must be included when compiling and simulating:

```bash
iverilog -o sim.out \
  tpfn65gpgv2od3.v \
  tcbn65gplus.v \
  DW_ram_r_w_a_lat.v \
  chip_top_tb.v \
  chip_top.v \
  [other source files]
```

## Design Timing

- **Reference Clock** - 625 MHz
- **High-Speed Clock** - 2.5 GHz (4x reference clock)

## Simulation Usage

### Test Platform
`chip_top_tb.v` provides a comprehensive simulation example including:
- 500 MHz and 2 GHz clock generation
- SPI transaction handling
- File logging output

### Running iVerilog Simulation

```bash
# Compile
iverilog -o sim.out \
  tpfn65gpgv2od3.v \
  tcbn65gplus.v \
  DW_ram_r_w_a_lat.v \
  chip_top_tb.v \
  chip_top.v \
  spi_slv_top.v \
  enable_state_machine.v \
  dtcdds.v \
  output_select.v

# Run
vvp sim.out

# View waveform
gtkwave wave.vcd
```

### Output Files
- `wave.vcd` - Waveform file for viewing with gtkwave
- `final_p2s_data_out.txt` - Edge output data log

File logging records edge outputs and selection signals on each `clk_hs` rising edge.

## Technology Library Integration

This RTL code can be integrated with standard technology libraries. After adding the following, you can proceed with complete synthesis and place & route:

1. Technology library files (`.lib`, `.lef`, `.gds`)
2. Constraint files (`.sdc`, `.xdc`)
3. Power integrity definitions

## License

MIT

## Contact

This readme is generated by AI. For questions and feedback, please contact the project maintainers.

---

**Last Updated**: September 2026
