
		/* Custom mode where the player must protect Bill and Katt from dying. */

.autoregion

TBL_FUNC_ProtectTheTargetsMode:
	lw at, orga(gProtectTheTargetsModeFlag) (gp)
	beq at, r0, (NextTableEntry)
	nop
	jal CheckMapScreenState
	li t7, 3
	bne v0, t7, (@@OnKatinaCheck)
	nop
	li at, 0x800AD69F	
	li v1, 3
	sb v1, 0x0000(at)	;skip intro scene
	li v1, 6
	sw v1, (0x801C37c4)		;force map cursor to katina, maybe do checks if other modes are on for this to be a regular level?
@@OnKatinaCheck:
	lui at, 0x8022
	lhu a0, 0xB4D8(at)
	li a1, 0xADA7
	bne a0, a1, (NextTableEntry)	;check if Katina map data
	li v1, 0x2E
	sb v1, 0xB4DB(at)
	li v1, 0x3D6
	sw v1, 0xB4E8(at)
	li v0, 0x03e00008
	li t0, 0x8018A534
	li t1, 0x8002BC9C	;I don't even remember
	sw v0, 0x0000(t0)
	sw r0, 0x0004(t0)
	sw v0, 0x0000(t1)
	sw r0, 0x0004(t1)
	lui at, 0x8003		;disables teammates spawning in
	sw v0, 0xAD10(at)
	sw r0, 0xAD14(at)
	;lui at, 0x8017
	;sw r0, 0xD724(at)	;falco, slip, pep down
	;sw r0, 0xD728(at)
	;sw r0, 0xD72C(at)
	li t0, 0x8002e858
	sw r0, 0x0000(t0)		;disable level checks so enemies can shoot.
	
@@Resume:
	li s7, LOC_ALIVE_TIMER32
	lw a0, 0x0000(s7)
	lw at, LOC_EXPERT_FLAG32
	bne at, r0, (@@FirstCheck)	;give the player no lasers and default bombs if expert
	li v1, 2
	bne v1, a0, (@@FirstCheck)	;give player items if second frame of starting
	nop
	sb v1, (LOC_PLAYER_LASER8)
	li v1, 5
	sb v1, (LOC_PLAYER_BOMBS8)
@@FirstCheck:
	li v1, 0x300
	bne a0, v1, (@@SpawnBasicShips)
	nop
	jal SpawnBill
	nop
@@SpawnBasicShips:
	lw a0, 0x0000(s7)
	li v1, 0x10
	blt a0, v1, (@@SpawnFriendlyCheck)
	nop
	jal CheckIfBasicEnemyGroupDead
	nop
	blt v0, r0, (@@SpawnFriendlyCheck)
	nop
	jal SpawnBasicShips		;respawns if dead
	li a0, 20
@@SpawnFriendlyCheck:
	lw a0, 0x0000(s7)
	li v1, 0x200
	bne a0, v1, (@@KattSpawnCheck)
	nop
	jal SpawnBasicFriendlyShips
	li a0, 10
@@KattSpawnCheck:
	lw a0, 0x0000(s7)
	li v1, 0x301
	bne a0, v1, (@@SpawnWolfCheck1)
	nop
	jal SpawnKatt
	nop
@@SpawnWolfCheck1:
	lw a0, 0x0000(s7)
	li v1, 0x550
	bne a0, v1, (@@SpawnWolfCheck2)
	li a0, 0x8015BECC
	jal SpawnSingleStarWolf
	li a1, 0xA
@@SpawnWolfCheck2:
	lw a0, 0x0000(s7)
	li v1, 0x720
	bne a0, v1, (@@SpawnBasicEnemies2)
	li a0, 0x8015C1C0
	jal SpawnSingleStarWolf
	li a1, 0x9
	li a0, 0x8015C4B4
	jal SpawnSingleStarWolf
	li a1, 0x9
	jal GetFreeShipSpace
	nop
	or a0, v0, r0
	li a2, 1
	jal SpawnSingleCraft
	li a1, 10
	jal GetFreeShipSpace
	nop
	or a0, v0, r0
	li a2, 1
	jal SpawnSingleCraft
	li a1, 9
@@SpawnBasicEnemies2:
	lw a0, 0x0000(s7)
	li v1, 0x900
	bne a0, v1, (@@Timer1)
	nop
	li a0, 0x8015C7A8
	jal SpawnSingleStarWolf
	li a1, 0x0
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer1)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 0
@@Timer1:
	lw a0, 0x0000(s7)
	li v1, 0x940
	bne a0, v1, (@@Timer2)
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer2)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 0
@@Timer2:
	lw a0, 0x0000(s7)
	li v1, 0x980
	bne a0, v1, (@@Timer3)
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer3)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 0
@@Timer3:
	lw a0, 0x0000(s7)
	li v1, 0x9A0
	bne a0, v1, (@@Timer4)
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer4)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 0
@@Timer4:
	lw a0, 0x0000(s7)
	li v1, 0x9E0
	bne a0, v1, (@@Timer5)
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer5)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 1
@@Timer5:
	lw a0, 0x0000(s7)
	li v1, 0xA40
	bne a0, v1, (@@Timer6)
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer6)
	or a0, v0, r0
	li a1, 10
	jal SpawnSingleCraft
	li a2, 1
@@Timer6:
	lw a0, 0x0000(s7)
	li v1, 0xA80
	bne a0, v1, (@@Timer7)
	nop
	li a0, 0x8015CD90
	jal SpawnSingleStarWolf
	li a1, 0x9
	li a0, 0x8015BECC
	jal CheckIfStarWolfDead
	nop
@@Timer7:
	lw a0, 0x0000(s7)
	li v1, 0xAE0
	bne a0, v1, (@@Timer8)
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer8)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 1
@@Timer8:
	lw a0, 0x0000(s7)
	li v1, 0xD00
	bne a0, v1, (@@Timer9)
	nop
	li a0, 0x8015C1C0
	jal CheckIfStarWolfDead
	nop
	li a0, 0x8015C4B4
	jal CheckIfStarWolfDead
	nop
	li a0, 0x8015C7A8
	jal CheckIfStarWolfDead
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer9)
	or a0, v0, r0
	li a2, 0xE
	jal SpawnSingleCraft
	li a1, 10
@@Timer9:
	lw a0, 0x0000(s7)
	li v1, 0xE50
	bne a0, v1, (@@Timer10)
	nop
	jal SpawnBasicFriendlyShips
	li a0, 5
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer10)
	or a0, v0, r0
	li a2, 0
	jal SpawnSingleCraft
	li a1, 10
@@Timer10:
	lw a0, 0x0000(s7)
	li v1, 0x1020
	bne a0, v1, (@@Timer11)
	nop
	li a0, 0x8015CD90
	jal CheckIfStarWolfDead
	nop
	li a0, 0x8015BECC
	jal CheckIfStarWolfDead
	nop
	li a0, 0x8015D084
	jal SpawnSingleStarWolf
	li a1, 0xA
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer11)
	or a0, v0, r0
	li a2, 5
	jal SpawnSingleCraft
	li a1, 0
@@Timer11:
	lw a0, 0x0000(s7)
	li v1, 0x1120
	bne a0, v1, (@@Timer12)
	nop
	li a0, 0x8015BECC
	jal CheckIfStarWolfDead
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer12)
	or a0, v0, r0
	li a2, 9
	jal SpawnSingleCraft
	li a1, 9
@@Timer12:
	lw a0, 0x0000(s7)
	li v1, 0x1310
	bne a0, v1, (@@Timer13)
	nop
	li a0, 0x8015C1C0
	jal CheckIfStarWolfDead
	nop
	li a0, 0x8015C4B4
	jal CheckIfStarWolfDead
	nop
	li a0, 0x8015CD90
	jal CheckIfStarWolfDead
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer13)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 0
@@Timer13:
	lw a0, 0x0000(s7)
	li v1, 0x1520
	bne a0, v1, (@@Timer14)
	nop
	li a0, 0x80159e50
	li a1, 0x1
	jal SpawnWingMen
	li a3, 0xB
	li a0, 0x8015D378
	jal SpawnSingleStarWolf
	li a1, 0xA
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer14)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 1
@@Timer14:
	lw a0, 0x0000(s7)
	li v1, 0x16E0
	bne a0, v1, (@@Timer15)
	nop
	li a0, 0x8015a144
	li a1, 0x2
	jal SpawnWingMen
	li a3, 0xC
	li a0, 0x8015CD90
	jal CheckIfStarWolfDead
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer15)
	or a0, v0, r0
	li a2, 0
	jal SpawnSingleCraft
	li a1, 9
@@Timer15:
	lw a0, 0x0000(s7)
	li v1, 0x1900
	bne a0, v1, (@@Timer16)
	nop
	li a0, 0x8015D084
	jal CheckIfStarWolfDead
	nop
	li a0, 0x8015BECC
	jal CheckIfStarWolfDead
	nop
	li a0, 0x8015C1C0
	jal CheckIfStarWolfDead
	nop
	li a0, 0x8015C4B4
	jal CheckIfStarWolfDead
	nop
	li a0, 0x8015a438
	li a1, 0x3
	jal SpawnWingMen
	li a3, 0xD
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer16)
	or a0, v0, r0
	li a2, 5
	jal SpawnSingleCraft
	li a1, 0
@@Timer16:
	lw a0, 0x0000(s7)
	li v1, 0x1B00
	bne a0, v1, (@@Timer17)
	nop
	li a0, 0x8015D66C
	jal SpawnSingleStarWolf
	li a1, 0xA
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer17)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 0
@@Timer17:
	lw a0, 0x0000(s7)
	li v1, 0x1C00
	bne a0, v1, (@@Timer18)
	nop
	li a0, 0x8015BECC
	jal CheckIfStarWolfDead
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@Timer18)
	or a0, v0, r0
	li a2, 0xE
	jal SpawnSingleCraft
	li a1, 10
@@Timer18:
	lw a0, 0x0000(s7)
	li v1, 0x1E00
	bne a0, v1, (@@FinalPhase)
	nop
	li a0, 0x8015D960
	jal SpawnSingleStarWolf
	li a1, 0x9
@@FinalPhase:
	lw a0, 0x0000(s7)
	li v1, 0x2200
	bne a0, v1, (@@End)
	nop
	li a0, 0x8015BECC
	jal KillShip
	nop
	li a0, 0x8015C1C0
	jal KillShip
	nop
	li a0, 0x8015C4B4
	jal KillShip
	nop
	li a0, 0x8015C7A8
	jal KillShip
	nop
	li a0, 0x8015CD90
	jal KillShip
	nop
	li a0, 0x8015D084
	jal KillShip
	nop
	li a0, 0x8015D378
	jal KillShip
	nop
	li a0, 0x8015D66C
	jal KillShip
	nop
	li a0, 0x8015D960
	jal KillShip
	nop
@@End:
	lw a0, 0x0000(s7)
	li v1, 0x2300
	bne a0, v1, (@@EndWolfSpawn1)
	nop
	li a0, 0x8015BECC
	jal CheckIfStarWolfDead
	nop
@@EndWolfSpawn1:
	lw a0, 0x0000(s7)
	li v1, 0x2350
	bne a0, v1, (@@EndWolfSpawn2)
	nop
	li a0, 0x8015C1C0
	jal CheckIfStarWolfDead
	nop
@@EndWolfSpawn2:
	lw a0, 0x0000(s7)
	li v1, 0x2400
	bne a0, v1, (@@EndWolfSpawn3)
	nop
	li a0, 0x8015C4B4
	jal CheckIfStarWolfDead
	nop
@@EndWolfSpawn3:
	lw a0, 0x0000(s7)
	li v1, 0x2500
	bne a0, v1, (@@EndWolfSpawn4)
	nop
	li a0, 0x8015C7A8
	jal CheckIfStarWolfDead
	nop
@@EndWolfSpawn4:
	lw a0, 0x0000(s7)
	li v1, 0x2600
	bne a0, v1, (@@EndWolfSpawn5)
	nop
	li a0, 0x8015CD90
	jal CheckIfStarWolfDead
	nop
@@EndWolfSpawn5:
	lw a0, 0x0000(s7)
	li v1, 0x2700
	bne a0, v1, (@@EndWolfSpawn6)
	nop
	li a0, 0x8015D084
	jal CheckIfStarWolfDead
	nop
@@EndWolfSpawn6:
	lw a0, 0x0000(s7)
	li v1, 0x2800
	bne a0, v1, (@@EndWolfSpawn7)
	nop
	li a0, 0x8015D378
	jal CheckIfStarWolfDead
	nop
@@EndWolfSpawn7:
	lw a0, 0x0000(s7)
	li v1, 0x2900
	bne a0, v1, (@@EndWolfSpawn8)
	nop
	li a0, 0x8015D66C
	jal CheckIfStarWolfDead
	nop
@@EndWolfSpawn8:
	lw a0, 0x0000(s7)
	li v1, 0x2A00
	bne a0, v1, (@@EndWolfSpawn9)
	nop
	li a0, 0x8015D960
	jal CheckIfStarWolfDead
	nop
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@EndWolfSpawn9)
	or a0, v0, r0
	li a2, 0xE
	jal SpawnSingleCraft
	li a1, 0
@@EndWolfSpawn9:
	lw a0, 0x0000(s7)
	li v1, 0x3000
	bne a0, v1, (@@EndWolfSpawn10)
	nop
	li a0, 0x8015CD90
	jal CheckIfStarWolfDead
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@EndWolfSpawn10)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 0
@@EndWolfSpawn10:
	lw a0, 0x0000(s7)
	li v1, 0x3100
	bne a0, v1, (@@EndWolfSpawn11)
	nop
	li a0, 0x8015C4B4
	jal CheckIfStarWolfDead
	nop
@@EndWolfSpawn11:
	lw a0, 0x0000(s7)
	li v1, 0x3200
	bne a0, v1, (@@EndWolfSpawn12)
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@EndWolfSpawn12)
	or a0, v0, r0
	li a1, 0
	jal SpawnSingleMissleOrShip
	li a3, 0
@@EndWolfSpawn12:
	lw a0, 0x0000(s7)
	li v1, 0x3300
	bne a0, v1, (@@EndWolfSpawn13)
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@EndWolfSpawn13)
	or a0, v0, r0
	li a2, 5
	jal SpawnSingleCraft
	li a1, 0
@@EndWolfSpawn13:
	lw a0, 0x0000(s7)
	li v1, 0x3400
	bne a0, v1, (@@EndWolfSpawn14)
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@EndWolfSpawn14)
	or a0, v0, r0
	li a2, 5
	jal SpawnSingleCraft
	li a1, 10
@@EndWolfSpawn14:
	lw a0, 0x0000(s7)
	li v1, 0x3500
	bne a0, v1, (@@EndWolfSpawn15)
	nop
	jal GetFreeShipSpace
	nop
	li v1, -1
	beq v0, v1, (@@EndWolfSpawn15)
	or a0, v0, r0
	li a2, 5
	jal SpawnSingleCraft
	li a1, 0
@@EndWolfSpawn15:
	lw a0, 0x0000(s7)
	li v1, 0x3500
	bne a0, v1, (@@CheckKattBill)
	nop
	li a0, 0x8015DC54
	jal SpawnSingleStarWolf
	li a1, 0xA
@@CheckKattBill:
	lw a0, 0x0000(s7)
	li v1, 0x305
	blt a0, v1, (@@End2)
	nop
	lhu a0, (0x8015B9B2)	;check bill health
	bne a0, r0, (@@End2)
	nop
	lhu a0, (0x8015BCA6)	;check katt health
	bne a0, r0, (@@End2)
	nop
	lw at, (LOC_SPECIAL_STATE)
	li v1, 0x64
	beq at, v1, (@@Reset)	;reset timer or logic would keep running
	li a0, 0x01C8
	jal SetFoxState		;game crashes when forcing a game over screen, so player just loses a life
	li a1, 4
@@Reset:
	sw r0, 0x0000(s7)
	b (NextTableEntry)
	nop
@@End2:					;check if timer over to end
	lw a0, 0x0000(s7)
	li v1, 0x3A99
	bne a0, v1, (@@RemoveEndScreenAndReset)
	nop
	jal DoSpecialState
	li a0, 3
	li v0, 0x1
	sb v0, (LOC_ENDSCREEN_FLAG8)
@@RemoveEndScreenAndReset:
	lw a0, 0x0000(s7)
	li v1, 0x3B92
	bne a0, v1, (@@Exit)
	nop
	jal DoSpecialState
	li a0, 2
	sb r0, (LOC_ENDSCREEN_FLAG8)
	jal DoSoftReset
	li a0, 1
	lui at, 0x8022
	sh r0, 0xB4D8(at)
@@Exit:
	b (NextTableEntry)
	nop
	
	
.endautoregion