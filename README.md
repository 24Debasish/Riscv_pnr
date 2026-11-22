# RISCV_PNR

## Overview
**RISCV-PNR** is a physical design project focused on the complete Place and Route (PnR) flow for a RISC-V processor, covering **Floorplanning, Placement, Clock Tree Synthesis (CTS), and Routing**.

## Tools Used
* **Synopsys IC Compiler II (ICC2)** – Physical implementation (Floorplan, Placement, CTS, Routing)
* **Synopsys PrimeTime** – Static Timing Analysis (STA) 

## Challenges & Solutions

| Issue Encountered | Root Cause / Context | Resolution Applied |
| :--- | :--- | :--- |
| **Cell Overlapping** | Standard cells overlapping during initial placement stages | Manually adjusted cell positions and ran placement legalization |
| **Filler Cell Insertion** | Gaps in standard cell rows affecting power rail continuity and well tap rules | Adjusted cell spacing and inserted filler cells accordingly |
| **Capacitance & Timing Violations** | High net capacitance causing setup/hold timing degradation | Performed cell sizing and inserted buffers along critical paths |

## Results & Outcomes
* ✅ **Zero Routing/Result Errors:** All physical design rule and connectivity errors resolved.
* ✅ **Zero PG DRC Errors:** Clean Power/Ground Design Rule Check verification.
* ✅ **Zero Capacitance Violations:** Eliminated all `max_capacitance` and `min_capacitance` violations.
* ✅ **Improved Timing Slack:** Optimized cell sizing to reduce timing slack violations.
* ✅ **Timing Closure Achieved:** All setup and hold timing requirements successfully met.

## Conclusion
* Gained hands-on understanding of the end-to-end ASIC physical design (RTL-to-GDSII) flow.
* Developed practical debugging skills to identify and resolve placement, DRC, and timing violations.
* Successfully generated a clean, timing-closed final layout.

## Future Scope: Physical Verification & Signoff
To take the generated layout from PnR completion to tape-out readiness, the next phase of this project will focus on complete physical verification using industry-standard signoff tools (such as **Synopsys IC Validator** or **Siemens Calibre**):

* **Design Rule Check (DRC):** Perform full-chip foundry rule verification on the final GDSII layout to ensure manufacturability (metal spacing, width, enclosure, and density rules).
* **Layout Versus Schematic (LVS):** Compare the extracted layout netlist against the post-PnR gate-level netlist to verify electrical connectivity, device dimensions, and zero shorts/opens.
* **Antenna Effect Checks:** Identify and resolve charge accumulation issues on long metal interconnects during fabrication by inserting antenna diodes or layer jumping.
* **Electrical Rule Check (ERC):** Verify proper well/substrate taps, floating gates, and power/ground connections across all hierarchy levels.
* **Dummy Metal Fill & Density Balancing:** Insert non-functional metal shapes to meet foundry planarization (CMP) density requirements and re-verify timing after parasitic extraction (RC extraction).
* **IR Drop & Electromigration (EM) Analysis:** Perform static and dynamic power integrity checks to ensure voltage stability and long-term interconnect reliability.

## Author
**Debasish Ghosh**  
* **Email:** (mailto:ghosh2001debasish@gmail.com)  
* **LinkedIn:** (www.linkedin.com/in/debasish-ghosh-410537263)
