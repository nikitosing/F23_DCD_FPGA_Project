# [F23] DCD_FPGA_Project
# Digital Circuit Design FPGA project
### Oscilloscope FPGA Project Readme

This FPGA project is designed to emulate an oscilloscope functionality on the DE10_Lite board. It leverages various hardware components and functionalities to achieve the desired oscilloscope behavior. Here's an overview of the project:

#### Module Structure

- **Inputs:**
  - Clocks for ADC and MAX10 (`ADC_CLK_10`, `MAX10_CLK1_50`, `MAX10_CLK2_50`)
  - Control inputs for keys (`KEY`) and switches (`SW`)
- **Outputs:**
  - LED outputs (`LEDR`)
  - Hexadecimal displays (`HEX0` to `HEX5`)
  - Various output signals for SDRAM, VGA, Clock Generator I2C, GSENSOR, GPIO, and ARDUINO interfaces

#### Functionality Overview

- **VGA Display:** Utilizes the VGA interface to display pixels on a screen based on specific conditions and coordinates.
- **ADC Interface:** Interfaces with the Analog to Digital Converter (ADC), processes sampled data, and performs calculations for voltage values based on the received ADC samples.
- **Frequency Calculation:** Measures and calculates frequency based on the sampled data from the ADC.
- **LED and 7-Segment Displays:** Displays calculated frequency and voltage values on LEDs (`LEDR`) and 7-segment displays (`HEX0` to `HEX5`) respectively.
- **Control Logic:** Implements various control logics for data processing, frequency measurement, and display operations.

#### Usage Notes

- **Input Configuration:** Ensure proper connectivity and configuration of input ports (`ADC_CLK_10`, `MAX10_CLK1_50`, `MAX10_CLK2_50`, `KEY`, `SW`) based on the hardware setup.
- **Signal Handling:** Verify synchronization and handling of clock signals for accurate operation of the oscilloscope functionalities.
- **Peripheral Interfaces:** Interfacing with external peripherals (VGA, ADC, etc.) must be appropriately configured for expected functionality.
- **Output Displays:** Monitor LED (`LEDR`) and 7-segment display (`HEX0` to `HEX5`) outputs for the displayed frequency and voltage values.

#### Important Information

- This project is tailored for the DE10_Lite board and might require adjustments for compatibility with other FPGA boards or custom hardware setups.
- Ensure proper understanding and synchronization of clock signals for precise functionality.
- Consider hardware limitations and constraints when utilizing various interfaces and peripherals.
