.data
    .global _counterPeriodicTask
_counterPeriodicTask:
.long 0x0
    .global status
status:
.long 0x0
    .global epdBusyStatus
epdBusyStatus:
.long 0x0
    .global entry
.text
entry:
	reg_wr 0x3ff4848c,24,24,0
	move r2,status
	ld r2,r2,0
	and r2,r2,1
	move r2,r2 #if r2 == 0 goto L.2
	jump L.2, eq
	reg_rd 0x3ff48424,20,20
	move r1,epdBusyStatus
	st r0,r1,0
	move r2,epdBusyStatus
	ld r2,r2,0
	move r2,r2 #if r2 == 0 goto L.4
	jump L.4, eq
	move r2,status
	ld r1,r2,0
	and r1,r1,0xfffe
	st r1,r2,0
	reg_wr 0x3ff48484,27,27,0
	reg_wr 0x3ff48408,23,23,1
L.4:
L.2:
	reg_wr 0x3ff4848c,24,24,1
	move r2,_counterPeriodicTask
	ld r1,r2,0
	add r1,r1,1
	st r1,r2,0
	ld r2,r2,0
	move r1,3600
	sub r2,r2,r1 #{ if r2 < r1 goto L.6
	add r2,r2,r1
	jump L.6, ov #}
	move r2,_counterPeriodicTask
	move r1,0
	st r1,r2,0
	wake 
	reg_wr 0x3ff4848c,24,24,0
	halt 
L.6:
L.1:

halt
