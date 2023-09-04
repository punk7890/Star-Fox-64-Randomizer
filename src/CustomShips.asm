
.n64
.autoregion	
	
	;custom ship spawns for Survival mode and Protect the Targets.
	
SpawnBill:
	addiu sp, sp, 0xffe0		
	sw	ra, 0x001c(sp)
	li.u a0, 0x8015b8e4	
	jal	0x8005cf54		;clear craft space
	li.l a0, 0x8015b8e4	
	mtc1 r0, f4
	li t6, 2
	li at, 0x8015b8e4	
	sb t6, 0x0000(at)		;state active
	swc1 f4, 0x0004(at)		;starting pos?
	lui	at, 0x447a		;starting pos?
	mtc1 at, f6			
	li at, 0x8015b8e4	
	li t7, 1	
	swc1 f6, 0x0008(at)	;starting pos?		
	sh t7, 0x00B8(at)	;state of craft		
	li t8, 9		
	sh t8, 0x00E4(at)		;craft model	
	li t9, 0x1B		
	sh t9, 0x00E6(at)		;craft to target
	li t0, 2	
	sh t0, 0x00B6(at)		;other state
	li t1, 300		
	sh t1, 0x00CE(at)	;health		
	li t2, 1		
	sw t2, 0x007C(at)	;?		
	li t3, 2		
	sb t3, 0x00C9(at)	;? toggles other models if craft model is 0xA +, other wise laser type	
	li t4, 0x1E	
	sh t4, 0x00C2(at)	;invulnerable timer	
	li a1, 0xC5				;must be in a1 to pass to function (level specfic object ID. BE = missle, BF as well)
	li	a0, 0x8015b900			;+0x1C of ship space in memory
	jal	0x8005ce48		
	sh	a1, 0x0002(at)		
	mtc1 r0, f8		
	li at, 0x8015b8e4	;starting space
	li a3, 0x800c18b4	
	li t5, 0x800c18bc		
	swc1 f8, 0x0038(at)			
	;lui	at, 0x8016			
	li a0, 0x3100000c		;engine sound	
	li a1, 0x8015b9e4	;+0x100 starting of space
	sb r0, 0x003C(at)		;hits when killed	
	sw t5, 0x0014(sp)		
	sw a3, 0x0010(sp)		
	jal	0x80019218	;set engine sound
	li a2, 4		
	lw ra, 0x001c(sp)				
	jr ra
	addiu sp, sp, 0x0020	
	nop	
	
SpawnKatt:
	addiu sp, sp, 0xffe0		
	sw	ra, 0x001c(sp)
	li.u a0, 0x8015BBD8	
	jal	0x8005cf54		;clear craft space
	li.l a0, 0x8015BBD8
	mtc1 r0, f4		;x
	li t6, 2
	li at, 0x8015BBD8	
	sb t6, 0x0000(at)		;state active
	swc1 f4, 0x0004(at)		;starting pos?
	lui	at, 0x447a		
	mtc1 at, f6			
	li at, 0x8015BBD8	
	li t7, 1	
	swc1 f6, 0x0008(at)	;y
	;swc1 f6, 0x000C(at)	;z
	sh t7, 0x00B8(at)	;state of craft		
	li t8, 8		
	sh t8, 0x00E4(at)		;craft model	
	li t9, 0x1A		
	sh t9, 0x00E6(at)		;craft to target
	li t0, 2	
	sh t0, 0x00B6(at)		;other state
	li t1, 300		
	sh t1, 0x00CE(at)	;health		
	li t2, 1		
	sw t2, 0x007C(at)	;?		
	li t3, 2		
	sb t3, 0x00C9(at)	;? toggles other models if craft model is 0xA +, other wise laser type	
	li t4, 0x1E	
	sh t4, 0x00C2(at)	;invulnerable timer	
	li a1, 0xC5				;must be in a1 to pass to function (level specfic object ID. BE = missle, BF as well)
	li	a0, 0x8015BBF4			;+0x1C of ship space in memory
	jal	0x8005ce48		
	sh	a1, 0x0002(at)		
	mtc1 r0, f8		
	li at, 0x8015BBD8		;starting space	
	li a3, 0x800c18b4	
	li t5, 0x800c18bc		
	swc1 f8, 0x0038(at)			
	;lui	at, 0x8016			
	li a0, 0x3100000c		;engine sound	
	li a1, 0x8015BCD8	;+0x100 of starting space
	sb r0, 0x003C(at)		;hits when killed	
	sw t5, 0x0014(sp)		
	sw a3, 0x0010(sp)		
	;jal	0x80019218	;set engine sound
	li a2, 4		
	lw ra, 0x001c(sp)				
	jr ra
	addiu sp, sp, 0x0020	
	nop	
	
SpawnBasicShips:	;pass a0 to spawn x amount. Currently spawns to fixed addresses. ships that do nothing but fly around. only tested in Katina.

	addiu sp, sp, 0xFFDC		
	sw ra, 0x0020(sp)
	sw a0, 0x001C(sp)
	lw t8, 0x001C(sp)
	li a0, 0x8015DF48
@@Loop1:
	jal	0x8005cf54		;clear craft space
	nop
	addiu t8, t8, -1
	addiu a0, a0, 0x2F4
	bne t8, r0, (@@Loop1)
	nop
	li s0, 0x8015DF48
	lui s4, 0x4200
	lui s1, 0x4440
	lui	s2, 0x4540	;above
@@Loop2:
	mtc1 s1, f4		;x
	mtc1 s2, f6		;y
	swc1 f4, 0x0004(s0)
	swc1 f6, 0x0008(s0)
	li t6, 2	
	sb t6, 0x0000(s0)		;state active	
	li t7, 1		
	;swc1 f6, 0x000C(s0)	;z
	sh t7, 0x00B8(s0)	;state of craft		
	li t8, 0xA		
	sh t8, 0x00E4(s0)		;craft model	
	li t9, 0xFFFF		
	sh t9, 0x00E6(s0)		;craft to target
	li t0, 0	
	sh t0, 0x00B6(s0)		;toggles other models if craft model is 0xA +, other wise laser type	
	li t1, 24		
	sh t1, 0x00CE(s0)	;health		
	li t2, 1		
	sw t2, 0x007C(s0)	;?		
	li t3, 0		
	sb t3, 0x00C9(s0)	;? 
	li t4, 0x80	
	sh t4, 0x00C2(s0)	;invulnerable timer	
	li a1, 0xC5			;must be in a1 to pass to function (level specfic object ID. BE = missle, BF as well)
	addiu a0, s0, 0x1C			;+0x1C of ship space in memory
	jal	0x8005ce48		
	sh	a1, 0x0002(s0)		
	mtc1 r0, f8		
	;li at, 0x8015DF48		;starting space	
	li a3, 0x800c18b4	
	li t5, 0x800c18bc		
	sw s4, 0x0038(s0)	;can be targeted		
	;lui	at, 0x8016			
	li a0, 0x3100000c	;engine sound	
	addiu a1, s0, 0x100	;+0x100 of starting space
	li t0, 1
	sb t0, 0x003C(s0)		;hits when killed	
	sw t5, 0x0014(sp)		
	sw a3, 0x0010(sp)		
	;jal	0x80019218	;set engine sound
	li a2, 4
	lw t8, 0x001C(sp)
	addiu s0, s0, 0x2F4
	addiu s1, s1, 0xE000
	addiu t8, t8, -1
	bne t8, r0, (@@Loop2)
	sw t8, 0x001C(sp)
	lw ra, 0x0020(sp)				
	jr ra
	addiu sp, sp, 0x0024	
	nop
	
SpawnBasicFriendlyShips:	;pass a0 to spawn x amount. Currently spawns to fixed addresses. These fight the previous 10 enemies

	addiu sp, sp, 0xFFDC		
	sw ra, 0x0020(sp)
	sw a0, 0x001C(sp)
	lw t8, 0x001C(sp)
	li a0, 0x80161A58
@@Loop1:
	jal	0x8005cf54		;clear craft space
	nop
	addiu t8, t8, -1
	addiu a0, a0, 0x2F4
	bne t8, r0, (@@Loop1)
	nop
	li s0, 0x80161A58
	;lui s4, 0x3F80
	lui s1, 0x4140
	lui	s2, 0x4340	;above
	li s3, 0x16
@@Loop2:
	mtc1 s1, f4		;x
	mtc1 s2, f6		;y
	swc1 f4, 0x0004(s0)
	swc1 f6, 0x0008(s0)
	;sw s4, 0x0038(s0)	;can be targeted
	li t6, 2	
	sb t6, 0x0000(s0)		;state active	
	li t7, 1		
	;swc1 f6, 0x000C(s0)	;z
	sh t7, 0x00B8(s0)	;state of craft		
	li t8, 0xB		
	sh t8, 0x00E4(s0)		;craft model			
	sh s3, 0x00E6(s0)		;craft to target
	li t0, 1	
	sh t0, 0x00B6(s0)		;toggles other models if craft model is 0xA +, otherwise laser type	
	li t1, 34		
	sh t1, 0x00CE(s0)	;health		
	li t2, 1		
	sw t2, 0x007C(s0)	;?		
	li t3, 0		
	sb t3, 0x00C9(s0)	;? 
	li t4, 0x22	
	sh t4, 0x00C2(s0)	;invulnerable timer	
	li a1, 0xC5			;must be in a1 to pass to function (level specfic object ID. BE = missle, BF as well)
	addiu a0, s0, 0x1C			;+0x1C of ship space in memory
	jal	0x8005ce48		
	sh	a1, 0x0002(s0)		
	mtc1 r0, f8		
	;li at, 0x8015DF48		;starting space	
	li a3, 0x800c18b4	
	li t5, 0x800c18bc		
	swc1 f8, 0x0038(s0)			
	;lui	at, 0x8016			
	li a0, 0x3100000c	;engine sound	
	addiu a1, s0, 0x100	;+0x100 of starting space
	li t0, 0
	sb t0, 0x003C(s0)		;hits when killed	
	sw t5, 0x0014(sp)		
	sw a3, 0x0010(sp)		
	;jal	0x80019218	;set engine sound
	li a2, 4
	lw t8, 0x001C(sp)
	addiu s0, s0, 0x2F4
	addiu s1, s1, -0xF000
	addiu s3, s3, 1
	addiu t8, t8, -1
	bne t8, r0, (@@Loop2)
	sw t8, 0x001C(sp)
	lw ra, 0x0020(sp)				
	jr ra
	addiu sp, sp, 0x0024	
	nop	
	
SpawnSingleStarWolf:	;pass a0 as the memory address to spawn in. a1 the craft ID to target.

	addiu sp, sp, 0xFFD8		
	sw ra, 0x0024(sp)
	sw a0, 0x0020(sp)
	sw a1, 0x001C(sp)
	lw s0, 0x0020(sp)
	jal	0x8005cf54		;clear craft space
	or a0, s0, r0
	lui s4, 0x4200
	lui s1, 0x45AB
	lui	s2, 0x450B	;y
	lui	s3, 0xC53E
	mtc1 s1, f4		;x
	mtc1 s2, f6		;y
	mtc1 s3, f7		;z
	swc1 f4, 0x0004(s0)
	swc1 f6, 0x0008(s0)
	swc1 f7, 0x000C(s0)
	li t6, 2	
	sb t6, 0x0000(s0)		;state active	
	li t7, 2		
	sh t7, 0x00B8(s0)	;state of craft		
	li t8, 0x4		
	sh t8, 0x00E4(s0)		;craft model	
	lw t9, 0x001C(sp)		
	sh t9, 0x00E6(s0)		;craft to target
	li t0, 0	
	sh t0, 0x00B6(s0)		;toggles other models if craft model is 0xA +, other wise laser type	
	li t1, 100		
	sh t1, 0x00CE(s0)	;health	
	li t2, 1		
	sb t2, 0x0044(s0)	;ring drop
	li t2, 1		
	sw t2, 0x007C(s0)	;?		
	li t3, 0		
	sb t3, 0x00C9(s0)	;? 
	li t4, 0x26	
	sh t4, 0x00C2(s0)	;invulnerable timer	
	li a1, 0xC5			;must be in a1 to pass to function (level specfic object ID. BE = missle, BF as well)
	addiu a0, s0, 0x1C			;+0x1C of ship space in memory
	jal	0x8005ce48		
	sh	a1, 0x0002(s0)		
	mtc1 r0, f8		
	;li at, 0x8015DF48		;starting space	
	li a3, 0x800c18b4	
	li t5, 0x800c18bc		
	sw s4, 0x0038(s0)	;can be targeted		
	;lui	at, 0x8016			
	li a0, 0x31004006	;engine sound	
	addiu a1, s0, 0x100	;+0x100 of starting space
	li t0, 3
	sb t0, 0x003C(s0)		;hits when killed	
	sw t5, 0x0014(sp)		
	sw a3, 0x0010(sp)		
	jal	0x80019218	;set engine sound
	li a2, 4
	lw ra, 0x0024(sp)				
	jr ra
	addiu sp, sp, 0x0028	
	nop
	
SpawnSingleStarWolfRegularMode:		;For Extra Star Wolfs. pass a0 as the memory address to spawn in. a1 the craft ID to target, a2 model.

	addiu sp, sp, -48		
	sw ra, 0x0024(sp)
	sw a0, 0x0020(sp)
	sw a1, 0x001C(sp)
	sw a2, 0x0028(sp)
	lw s0, 0x0020(sp)
	jal	0x8005cf54		;clear craft space
	or a0, s0, r0
	lui s4, 0x4200
	lui s1, 0x45AB
	lui	s2, 0x450B	;y
	lui	s3, 0xC53E
	mtc1 s1, f4		;x
	mtc1 s2, f6		;y
	mtc1 s3, f7		;z
	swc1 f4, 0x0004(s0)
	swc1 f6, 0x0008(s0)
	swc1 f7, 0x000C(s0)
	li t6, 2	
	sb t6, 0x0000(s0)		;state active	
	li t7, 2		
	sh t7, 0x00B8(s0)	;state of craft		
	lw t8, 0x0028(sp)		
	sh t8, 0x00E4(s0)		;craft model	
	lw t9, 0x001C(sp)		
	sh t9, 0x00E6(s0)		;craft to target
	li t0, 0	
	sh t0, 0x00B6(s0)		;toggles other models if craft model is 0xA +, other wise laser type	
	li t1, 100		
	sh t1, 0x00CE(s0)	;health	
	li t2, 1		
	sb t2, 0x0044(s0)	;ring drop
	li t2, 1		
	sw t2, 0x007C(s0)	;?		
	li t3, 0		
	sb t3, 0x00C9(s0)	;? 
	li t4, 0x26	
	sh t4, 0x00C2(s0)	;invulnerable timer	
	li a1, 0xC5			;must be in a1 to pass to function (level specfic object ID. BE = missle, BF as well)
	addiu a0, s0, 0x1C			;+0x1C of ship space in memory
	jal	0x8005ce48		
	sh	a1, 0x0002(s0)		
	mtc1 r0, f8		
	;li at, 0x8015DF48		;starting space	
	li a3, 0x800c18b4	
	li t5, 0x800c18bc		
	sw s4, 0x0038(s0)	;can be targeted		
	;lui	at, 0x8016			
	li a0, 0x31004006	;engine sound	
	addiu a1, s0, 0x100	;+0x100 of starting space
	li t0, 3
	sb t0, 0x003C(s0)		;hits when killed	
	sw t5, 0x0014(sp)		
	sw a3, 0x0010(sp)		
	jal	0x80019218	;set engine sound
	li a2, 4
	lw ra, 0x0024(sp)				
	jr ra
	addiu sp, sp, +48	
	nop

SpawnSingleCraft:	;pass a0 as the memory address to spawn in. a1 the craft ID to target. a2 item to drop. Basic enemy craft

	addiu sp, sp, 0xFFD4		
	sw ra, 0x0028(sp)
	sw a0, 0x0020(sp)
	sw a1, 0x001C(sp)
	sw a2, 0x0024(sp)
	lw s0, 0x0020(sp)
	jal	0x8005cf54		;clear craft space
	or a0, s0, r0
	lw a2, 0x0024(sp)
	sb a2, 0x0044(s0)
	lui s4, 0x4200
	lui s1, 0x44AB
	lui	s2, 0x450B	;y
	lui	s3, 0xC53E
	mtc1 s1, f4		;x
	mtc1 s2, f6		;y
	mtc1 s3, f7		;z
	swc1 f4, 0x0004(s0)
	swc1 f6, 0x0008(s0)
	swc1 f7, 0x000C(s0)
	li t6, 2	
	sb t6, 0x0000(s0)		;state active	
	li t7, 1		
	sh t7, 0x00B8(s0)	;state of craft		
	li t8, 0xB		
	sh t8, 0x00E4(s0)		;craft model	
	lw t9, 0x001C(sp)		
	sh t9, 0x00E6(s0)		;craft to target
	li t0, 0	
	sh t0, 0x00B6(s0)		;toggles other models if craft model is 0xA +, other wise laser type	
	li t1, 34		
	sh t1, 0x00CE(s0)	;health		
	li t2, 1		
	sw t2, 0x007C(s0)	;?		
	li t3, 0		
	sb t3, 0x00C9(s0)	;? 
	li t4, 0x36	
	sh t4, 0x00C2(s0)	;invulnerable timer	
	li a1, 0xC5			;must be in a1 to pass to function (level specfic object ID. BE = missle, BF as well)
	addiu a0, s0, 0x1C			;+0x1C of ship space in memory
	jal	0x8005ce48		
	sh	a1, 0x0002(s0)		
	mtc1 r0, f8		
	;li at, 0x8015DF48		;starting space	
	li a3, 0x800c18b4	
	li t5, 0x800c18bc		
	sw s4, 0x0038(s0)	;can be targeted		
	;lui	at, 0x8016			
	li a0, 0x31004005	;engine sound	
	addiu a1, s0, 0x100	;+0x100 of starting space
	li t0, 1
	sb t0, 0x003C(s0)		;hits when killed	
	sw t5, 0x0014(sp)		
	sw a3, 0x0010(sp)		
	;jal	0x80019218	;set engine sound
	li a2, 4
	lw ra, 0x0028(sp)				
	jr ra
	addiu sp, sp, 0x002C	
	nop
	
SpawnSingleMissleOrShip:	;pass a0 as the memory address to spawn in. a1 the craft ID to target(only 00 fox, 02 slippy, 03 peppy). a3 0 missle or ship 1 that shoots. Basic enemy missile or ship

	addiu sp, sp, 0xFFD4		
	sw ra, 0x0028(sp)
	sw a0, 0x0020(sp)
	sw a1, 0x001C(sp)
	sw a3, 0x0024(sp)
	lw s0, 0x0020(sp)
	jal	0x8005cf54		;clear craft space
	or a0, s0, r0
	lw a1, 0x001C(sp)
	sh a1, 0x0054(s0)
	lui s4, 0x4250
	lui s1, 0x4400
	lui	s2, 0x450B	;y
	lui	s3, 0xC55E
	lui	s5, 0x4240
	mtc1 s1, f4		;x
	mtc1 s2, f6		;y
	mtc1 s3, f7		;z
	mtc1 s5, f5		;speed
	swc1 f4, 0x0004(s0)
	swc1 f6, 0x0008(s0)
	swc1 f7, 0x000C(s0)
	swc1 f5, 0x0128(s0)
	li t6, 2	
	sb t6, 0x0000(s0)		;state active	
	li t7, 1		
	sh t7, 0x00B8(s0)	;state of craft		
	lw t8, 0x0024(sp)	
	sh t8, 0x00B4(s0)		;craft model	
	lw t9, 0x001C(sp)		
	sh t9, 0x0054(s0)		;craft to target
	li t0, 0	
	sh t0, 0x00B6(s0)		;toggles other models if craft model is 0xA +, other wise laser type	
	li t1, 34		
	sh t1, 0x00CE(s0)	;health		
	li t2, 1		
	sw t2, 0x007C(s0)	;?		
	li t3, 0		
	sb t3, 0x00C9(s0)	;? 
	li t4, 0x36	
	sh t4, 0x00C2(s0)	;invulnerable timer	
	li a1, 0xBF			;must be in a1 to pass to function (level specfic object ID. BE = missle, BF as well)
	addiu a0, s0, 0x1C			;+0x1C of ship space in memory
	jal	0x8005ce48		
	sh	a1, 0x0002(s0)		
	mtc1 r0, f8		
	;li at, 0x8015DF48		;starting space	
	li a3, 0x800c18b4	
	li t5, 0x800c18bc		
	sw s4, 0x0038(s0)	;can be targeted		
	;lui	at, 0x8016			
	li a0, 0x31004005	;engine sound	
	addiu a1, s0, 0x100	;+0x100 of starting space
	li t0, 1
	sb t0, 0x003C(s0)		;hits when killed	
	sw t5, 0x0014(sp)		
	sw a3, 0x0010(sp)		
	;jal	0x80019218	;set engine sound
	li a2, 4
	lw ra, 0x0028(sp)				
	jr ra
	addiu sp, sp, 0x002C	
	nop

SpawnWingMen:		;pass mem space in a0, a1 ID. a3 craft to target
	addiu sp, sp, 0xFFD4		
	sw ra, 0x0028(sp)
	sw a0, 0x0020(sp)
	sw a1, 0x001C(sp)
	sw a3, 0x0024(sp)
	lw s0, 0x0020(sp)
	jal	0x8005cf54		;clear craft space
	or a0, s0, r0
	lw a1, 0x001C(sp)
	sh a1, 0x00E4(s0)
	;lui s4, 0x0000
	lui s1, 0x4400
	lui	s2, 0x450B	;above
	lui	s3, 0xC55E
	lui	s5, 0x4240
	mtc1 s1, f4		;x
	mtc1 s2, f6		;y
	mtc1 s3, f7		;z
	mtc1 s5, f5		;speed
	swc1 f4, 0x0004(s0)
	swc1 f6, 0x0008(s0)
	swc1 f7, 0x000C(s0)
	swc1 f5, 0x0128(s0)
	li t6, 2	
	sb t6, 0x0000(s0)		;state active	
	li t7, 1		
	sh t7, 0x00B8(s0)	;state of craft			
	lw t9, 0x0024(sp)		
	sh t9, 0x00E6(s0)		;craft to target
	li t0, 2	
	sh t0, 0x00B6(s0)		;toggles other models if craft model is 0xA +, other wise laser type	
	li t1, 999		
	sh t1, 0x00CE(s0)	;health		
	li t2, 1		
	sw t2, 0x007C(s0)	;?		
	li t3, 0		
	sb t3, 0x00C9(s0)	;? 
	li t4, 0xFFFF	
	sh t4, 0x00C2(s0)	;invulnerable timer	
	li a1, 0xC5			;must be in a1 to pass to function (level specfic object ID. BE = missle, BF as well)
	addiu a0, s0, 0x1C			;+0x1C of ship space in memory
	jal	0x8005ce48		
	sh	a1, 0x0002(s0)		
	mtc1 r0, f8		
	;li at, 0x8015DF48		;starting space	
	li a3, 0x800c18b4	
	li t5, 0x800c18bc		
	swc1 f8, 0x0038(s0)	;can be targeted		
	;lui	at, 0x8016			
	li a0, 0x31004005	;engine sound	
	addiu a1, s0, 0x100	;+0x100 of starting space
	li t0, 0
	sb t0, 0x003C(s0)		;hits when killed	
	sw t5, 0x0014(sp)		
	sw a3, 0x0010(sp)		
	;jal	0x80019218	;set engine sound
	li a2, 4
	lw ra, 0x0028(sp)				
	jr ra
	addiu sp, sp, 0x002C	
	nop
	
GetFreeShipSpace:		;gets next free ship space after SpawnBasicFriendlyShips and returns it in v0

	li v0, -1		;throw invalid address if over
	lui a1, 0x0000	;overwrite if was spawned, but now dead
	ori a1, a1, 0x00C5
	li t0, 0x80161A58	;last space after friendly spawns
	li t1, 0x80164C8C	;last valid space I think
@@Loop:
	beq t0, t1, (@@Exit)
	lw a0, 0x0000(t0)
	beql a0, r0, (@@Exit)
	or v0, t0, r0
	beql a0, a1, (@@Exit)
	or v0, t0, r0
	addiu t0, t0, 0x2F4
	b (@@Loop)
	nop
@@Exit:
	jr ra
	nop
	
CheckIfBasicEnemyGroupDead:		;checks if the first 20 basic ships are dead. If so, returns v0=1, otherwise -1

	li v0, -1
	lui a1, 0x0000
	ori a1, a1, 0x00C5
	lui a2, 0x0200
	ori a2, a2, 0x00C5	;alive
	li t0, 0x8015DF48	;first spot of enemy
	li t1, 0x80161764	;20th enemy
@@Loop:
	lw a0, 0x0000(t0)
	beq a0, a2, (@@Exit)
	addiu t0, t0, 0x2F4
	bgtl t0, t1, (@@Exit)
	li v0, 1
	beq a0, r0, (@@Loop)
	nop
	beq a0, a1, (@@Loop)
	nop
	b (@@Exit)
	li v0, 1
	nop
@@Exit:
	jr ra
	nop
	
CheckIfStarWolfDead:		;checks if a star wolf is dead. It will respawn it if so. Pass starting point in memory in a0.

	addiu sp, sp, -4
	sw ra, 0x0000(sp)
	lui a1, 0x0000
	ori a1, a1, 0x00C5
	lw v0, 0x0000(a0)
	beq v0, a1, (@@Respawn)
	nop
	b (@@Exit)
	nop
@@Respawn:
	addiu a1, a0, 0xE6
	jal SpawnSingleStarWolf
	lhu a1, 0x0000(a1)
@@Exit:
	lw ra, 0x0000(sp)
	jr ra
	addiu sp, sp, 4
	nop
	
KillShip:		;kills ship in memory space from a0.
	
	li v1, 0x0
	jr ra
	sb v1, 0x0000(a0)
	nop

	
	
.endautoregion