transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+E:/395\ Project {E:/395 Project/vga_controller.sv}
vlog -sv -work work +incdir+E:/395\ Project {E:/395 Project/test2.sv}
vlog -sv -work work +incdir+E:/395\ Project {E:/395 Project/SCCB_master.sv}
vlog -sv -work work +incdir+E:/395\ Project {E:/395 Project/RGB_reader.sv}
vlog -sv -work work +incdir+E:/395\ Project {E:/395 Project/HexDriver.sv}

