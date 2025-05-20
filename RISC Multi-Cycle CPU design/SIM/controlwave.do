onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /control_tb/clk
add wave -noupdate /control_tb/rst
add wave -noupdate /control_tb/ld
add wave -noupdate /control_tb/mov
add wave -noupdate /control_tb/add
add wave -noupdate /control_tb/sub
add wave -noupdate /control_tb/jmp
add wave -noupdate /control_tb/jc
add wave -noupdate /control_tb/jnc
add wave -noupdate /control_tb/andd
add wave -noupdate /control_tb/CFlag
add wave -noupdate /control_tb/IRin
add wave -noupdate /control_tb/Imm1_in
add wave -noupdate /control_tb/Imm2_in
add wave -noupdate /control_tb/RFin
add wave -noupdate /control_tb/RFout
add wave -noupdate /control_tb/PCin
add wave -noupdate /control_tb/Ain
add wave -noupdate /control_tb/ALUFN
add wave -noupdate /control_tb/PCsel
add wave -noupdate /control_tb/RFaddr_wr
add wave -noupdate /control_tb/RFaddr_rd
add wave -noupdate /control_tb/done_FSM
add wave -noupdate /control_tb/ControlUnit/prv_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1539128 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2048 ns}
