
	/* Special mode that the player can go to after reaching x amount of score in certain modes before entering venoms */

.n64
.autoregion

;currently no logic for Endurance mode
;use gSpecialStageChoosePlanetsFlag when selecting in choose planets

TBL_FUNC_SpecialStage:
	lw v0, orga(gSpecialStageFlag) (gp)
	beq v0, r0, (@@Exit)
	lui t0, 0x8017
	lw a0, 0xD9B8(t0) ;LOC_NUM_PLANETS_COMPLETED32
	lw v0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	bne v0, r0, (@@BypassPlanetsDoneCheck)
	nop
	beq a0, r0, (@@Exit)	;if completed times is zero, assume marathon mode or just starting game so exit
	nop
@@BypassPlanetsDoneCheck:
	sll t1, a0, 2
	addu t1, t1, t0
	lw s0, (LOC_LEVEL_ID32)
	li s1, 0xA	;training level ID
	lw s7, 0xDA00(t1)	;get last planet completed by game logic (map screen planet IDs). training mode doesn't get added by game logic
	lb v0, (LOC_ENDSCREEN_FLAG8)
	beq v0, r0, (@@CheckIfTrainingLoaded)
	nop
	beq s0, s1, (@@InEndingSpecialStage)	;in ending screen on training
	li v0, PLANET_BOLSE
	beq s7, v0, (@@IfBolse)
	li v0, PLANET_A6
	beq s7, v0, (@@IfA6)
	nop
	b @@Exit
	nop
; @@MarathonModeCheck:
	; lw v0, orga(gMarathonModeFlag) (gp)
	; beq v0, r0, (@@Exit)
	; nop
	; b @@Exit
	; nop
@@IfBolse:
	lw v0, orga(gBossRushModeFlag) (gp)
	bne v0, r0, (@@BolseBRM)
	lw a0, orga(gSpecialStageFlag) (gp)
	lw v0, orga(gMarathonModeFlag) (gp)
	bne v0, r0, (@@BolseMarathon)
	li v1, 1
	beq a0, v1, (@@BolseScoreCheck)
	li v1, 2
	beq a0, v1, (@@BolseRandomFlagCheck)
	nop
	b @@Exit
	nop
@@BolseBRM:
	lw v0, orga(gMarathonModeFlag) (gp)
	bne v0, r0, (@@BolseBRMMarathon)
	li v1, 1
	beq a0, v1, (@@BolseScoreCheckBRM)
	li v1, 2
	beq a0, v1, (@@BolseRandomFlagCheck)
	nop
	b @@Exit
	nop
	
@@BolseMarathon:
	b (@@Exit)
	nop
@@BolseBRMMarathon:
	b (@@Exit)
	nop
	
@@BolseScoreCheck:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageRegularScore) (gp)
	sltu v0, a1, a0
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li a0, 0xA
	sh v0, (0x80186502)	;overwrite planet to go into from bolse level function
	b @@Exit
	nop
@@BolseScoreCheckBRM:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageBRMScore) (gp)
	sltu v0, a1, a0
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li a0, 0xA
	sh v0, (0x80186502)	;overwrite planet to go into from bolse level function
	b @@Exit
	nop
	
@@BolseRandomFlagCheck:
	lw a0, orga(gSpecialStageRandomFlag) (gp)
	beq a0, r0, (@@Exit)	;bad luck
	li a0, 0xA
	sh v0, (0x80186502)	;overwrite planet to go into from bolse level function
	b @@Exit
	nop
	
@@IfA6:
	lw v0, orga(gBossRushModeFlag) (gp)
	bne v0, r0, (@@A6BRM)
	lw a0, orga(gSpecialStageFlag) (gp)
	lw v0, orga(gMarathonModeFlag) (gp)
	bne v0, r0, (@@A6Marathon)
	li v1, 1
	beq a0, v1, (@@A6ScoreCheck)
	li v1, 2
	beq a0, v1, (@@A6RandomFlagCheck)
	nop
	b @@Exit
	nop

@@A6BRM:
	lw v0, orga(gMarathonModeFlag) (gp)
	bne v0, r0, (@@A6BRMMarathon)
	li v1, 1
	beq a0, v1, (@@A6ScoreCheckBRM)
	li v1, 2
	beq a0, v1, (@@A6RandomFlagCheck)
	nop
	b @@Exit
	nop
	
@@A6BRMMarathon:
	li v1, 1
	beq a0, v1, (@@A6ScoreCheckBRMMarathon)
	li v1, 2
	beq a0, v1, (@@A6RandomFlagCheck)
	nop
	b @@Exit
	nop
	
@@A6Marathon:
	li v1, 1
	beq a0, v1, (@@A6ScoreCheckMarathon)
	li v1, 2
	beq a0, v1, (@@A6RandomFlagCheck)
	nop
	b @@Exit
	nop
	
@@A6ScoreCheck:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageRegularScore) (gp)
	sltu v0, a1, a0
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li a0, 0xA
	sh v0, (0x801858FE)	;overwrite planet to go into from A6 level function
	b @@Exit
	nop
@@A6ScoreCheckBRM:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageBRMScore) (gp)
	sltu v0, a1, a0
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li a0, 0xA
	sh v0, (0x801858FE)	;overwrite planet to go into from A6 level function
	b @@Exit
	nop
@@A6ScoreCheckBRMMarathon:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageBRMMarathonScore) (gp)
	sltu v0, a1, a0
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li a0, 0xA
	sh v0, (0x801858FE)	;overwrite planet to go into from A6 level function
	b @@Exit
	nop
@@A6ScoreCheckMarathon:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageMarathonScore) (gp)
	sltu v0, a1, a0
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li a0, 0xA
	sh v0, (0x801858FE)	;overwrite planet to go into from A6 level function
	b @@Exit
	nop
	
@@A6RandomFlagCheck:
	lw a0, orga(gSpecialStageRandomFlag) (gp)
	beq a0, r0, (@@Exit)	;bad luck
	li a0, 0xA
	sh v0, (0x801858FE)	;overwrite planet to go into from A6 level function
	b @@Exit
	nop

@@InEndingSpecialStage:
	;do teammate alive bonus cals for score adding
	jal DoSpecialState
	li a0, 3
	lw a0, orga(gSpecialStageEndWaitTimer) (gp)
	addiu a0, a0, 1
	sw a0, orga(gSpecialStageEndWaitTimer) (gp)
	sltiu v0, a0, 200
	bne v0, r0, (@@Exit)	;wait 200 frames
	li a0, 2
	jal DoSpecialState
	nop
	li v0, PLANET_BOLSE
	beq s7, v0, (@@WarpToVE1)
	li v0, PLANET_A6
	beq s7, v0, (@@WarpToVE2)
	nop
	;shouldn't go here unless choose planets was on
	jal DoSoftResetWithFlag
	li a0, 4
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	nop
@@WarpToVE1:
	li.u a0, 0x00060007
	jal DoSoftResetWithFlag
	li.l a0, 0x00060007
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	nop
@@WarpToVE2:
	li.u a0, 0x00130007
	jal DoSoftResetWithFlag
	li.l a0, 0x00130007
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	nop
	
	
@@CheckIfTrainingLoaded:
	beq s0, s1, (@@CheckIfBossRush)
	nop
	b (@@Exit)	;exit since not training level
	nop
@@CheckIfBossRush:
	lw v0, orga(gBossRushModeFlag) (gp)
	lw v1, orga(gSpecialStageBRMBasicScore) (gp)
	bnel v0, r0, (@@DoRetryAndDeadLogic)
	sw v1, orga(gTimerScoreToDisplay) (gp)	;set and force timer to 5000 points if BRM is on.
	
@@DoRetryAndDeadLogic:
	;do retry and dead logic
	lw a0, (LOC_PAUSE_STATE32)
	li v0, 2
	beq a0, v0, (@@FindPlanet)	;check if quit from pause screen
	nop
	jal CheckFoxState
	nop
	li v1, 6
	beq v0, v1, (@@FindPlanet)	;check if dead
	nop
	b (@@CheckIfMapLoaded)
	nop
	
@@FindPlanet:
	li v0, PLANET_BOLSE
	beq s7, v0, (@@DeadGoingToVE1)
	li v0, PLANET_A6
	beq s7, v0, (@@DeadGoingToVE2)
	nop
	;shouldn't go here unless choose planets was on
	sw r0, (LOC_PLAYER_HITS32)
	jal DoSoftResetWithFlag
	li a0, 4
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	nop
	
@@DeadGoingToVE1:
	sw r0, (LOC_PLAYER_HITS32)
	li.u a0, 0x00060007
	jal DoSoftResetWithFlag
	li.l a0, 0x00060007
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	nop
@@DeadGoingToVE2:
	sw r0, (LOC_PLAYER_HITS32)
	li.u a0, 0x00130007
	jal DoSoftResetWithFlag
	li.l a0, 0x00130007
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	nop
	
@@CheckIfMapLoaded:
	lui t0, 0x8021
	lh v0,0xCAC2(t0)
	li v1, 0x04B0
	bne v0, v1, (@@Exit)	;training level objects not loaded
	lw v0, 0xCA80(t0)
	li v1, 0xC8
	bne v0, v1, (@@InGameChecks)	;if equal, continue level inits
	li v0, 0x802E
	sw v0, 0xCA58(t0)	;change music to versus music
	li v0, 0x03E0
	sw v0, 0xCA68(t0)	;overwrite fog density level
	li v0, 0x36
	sw v0, 0xCA60(t0)	;green fog amount
	li v0, 0x60
	sw v0, 0xCA64(t0)	;blue fog amount
	li v0, 0xFF
	sw v0, 0xCA7C(t0)	;red ambient color
	sw r0, 0xCA80(t0)	;green ambient color
	sw v0, 0xCA84(t0)	;blue ambient color
	li v0, 0x86
	sw v0, 0xCA88(t0)	;red ambient floor color
	la t1, 0x800C7184	;load address to training mode ROM assets
	li v0, 0x00950880
	sw v0, 0x0080(t1)
	li v0, 0x0095D2F0
	sw v0, 0x0084(t1)	;enable Bill/Katt assets
	li v0, 0x0092A250
	sw v0, 0x0088(t1)
	li v0, 0x0093C0E0
	sw v0, 0x008C(t1)	;enable Great Fox assets
	sw r0, 0x8018F2EC	;remove first dummy wolf ship 100 hits check
@@InGameChecks:
	lw s7, (LOC_ALIVE_TIMER32)	;timer value in s7
	li v0, 3
	bne s7, v0, (@@AllRangeChecks)
	li a0, 0x01C8
	jal SetFoxState
	li a1, 0x9
	
@@AllRangeChecks:
	li v0, 255
	bne s7, v0, (@@CheckForRespawn)
	;init all range mode starts
	lui at, 0x8017
	lw v0, 0xD724(at)	;falco health
	ble v0, r0, (@@SlippySpawn)
	;Falco	memory id 0x1
	li a0, 0x8015A144	;mem space to spawn
	li a1, 0x1A			;craft to target
	li a2, 0			;item to drop
	li t0, 0x4334D3BC	;x coords to spawn at
	li t1, 0x448EC3E2	;y coords to spawn at
	li t2, 0x43574000	;z coords to spawn at
	li t3, 0			;can be targeted or not
	li t4, 0x1			;model of craft
	li t5, 0			;laser type / other model
	li t6, 255			;health
	li t7, 0			;hits when killed
	li t8, 0			;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@SlippySpawn:
	lui at, 0x8017
	lw v0, 0xD728(at)	;slip health
	ble v0, r0, (@@PeppySpawn)
	;Slippy	memory id 0x2
	li a0, 0x8015A438	;mem space to spawn
	li a1, 0x1B			;craft to target
	li a2, 0			;item to drop
	li t0, 0x4434D3BC	;x coords to spawn at
	li t1, 0x448EC3E2	;y coords to spawn at
	li t2, 0x43574000	;z coords to spawn at
	li t3, 0			;can be targeted or not
	li t4, 0x2			;model of craft
	li t5, 0			;laser type / other model
	li t6, 255			;health
	li t7, 0			;hits when killed
	li t8, 0			;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type

@@PeppySpawn:
	lui at, 0x8017
	lw v0, 0xD72C(at)	;peppy health
	ble v0, r0, (@@KattSpawn)
	;Peppy	memory id 0x3
	li a0, 0x8015A72C	;mem space to spawn
	li a1, 0xC			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC380D3BC	;x coords to spawn at
	li t1, 0x448EC3E2	;y coords to spawn at
	li t2, 0x43574000	;z coords to spawn at
	li t3, 0			;can be targeted or not
	li t4, 0x3			;model of craft
	li t5, 0			;laser type / other model
	li t6, 255			;health
	li t7, 0			;hits when killed
	li t8, 0			;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@KattSpawn:
	;katt	memory id 0x4
	li a0, 0x8015AA20	;mem space to spawn
	li a1, 0xA			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC420D3BC	;x coords to spawn at
	li t1, 0x448EC3E2	;y coords to spawn at
	li t2, 0x43574000	;z coords to spawn at
	li t3, 0			;can be targeted or not
	li t4, 0x8			;model of craft
	li t5, 0			;laser type / other model
	li t6, 300			;health
	li t7, 0			;hits when killed
	li t8, 0			;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	;bill	memory id 0x5
	li a0, 0x8015AD14	;mem space to spawn
	li a1, 0xB			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC470D3BC	;x coords to spawn at
	li t1, 0x448EC3E2	;y coords to spawn at
	li t2, 0x43574000	;z coords to spawn at
	li t3, 0			;can be targeted or not
	li t4, 0x9			;model of craft
	li t5, 0			;laser type / other model
	li t6, 300			;health
	li t7, 0			;hits when killed
	li t8, 0			;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	;Great Fox	memory id 0x7
	li a0, 0x8015B2FC	;mem space to spawn
	li a1, -1			;craft to target
	li a2, 0			;item to drop
	li t0, 0x431DBE9B	;x coords to spawn at
	li t1, 0x453D63DE	;y coords to spawn at
	li t2, 0xC4505EE6	;z coords to spawn at
	li t3, 0			;can be targeted or not
	li t4, 0x64			;model of craft
	li t5, 3			;laser type / other model
	li t6, 999			;health
	li t7, 0			;hits when killed
	li t8, 0			;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	;make him a do nothing
	li v0, 0x46000000
	sw r0, (0x8015B30C)
	sw v0, (0x8015B310)	;rotate him
	sw r0, (0x8015B314)
	la v0, @GreatFoxDummyFunc	;empty logic function
	sw v0, (0x8015B320)
	
	;wolf1 id 0x1A
	li a0, 0x8015EB18	;mem space to spawn
	li a1, 0x4			;craft to target
	li a2, 5			;item to drop
	li t0, 0x4375F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x4			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0x31004005	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	;dummy wolf1 id 0x1B
	li a0, 0x8015EE0C	;mem space to spawn
	li a1, 0x5			;craft to target
	li a2, 2			;item to drop
	li t0, 0x4440F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x1B			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 5			;hits when killed
	li t8, 0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	;wolf2 id 0x1C
	li a0, 0x8015F100	;mem space to spawn
	li a1, 0x0			;craft to target
	li a2, 9			;item to drop
	li t0, 0x4470F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x5			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0x31004005	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	;dummy wolf2 id 0x1D
	li a0, 0x8015F3F4	;mem space to spawn
	li a1, 0x3			;craft to target
	li a2, 2			;item to drop
	li t0, 0x44B0F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x1D			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 5			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	;dummy wolf3 id 0x1E
	li a0, 0x8015F6E8	;mem space to spawn
	li a1, 0x2			;craft to target
	li a2, 2			;item to drop
	li t0, 0x44E0F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x1E			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 5			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	;dummy wolf4 id 0x1F
	li a0, 0x8015F9DC	;mem space to spawn
	li a1, 0x1			;craft to target
	li a2, 2			;item to drop
	li t0, 0x4510F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x1F			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 5			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	li v0, 2
	sw.u v0, (LOC_KATINA_TIMER32)	;store minutes
	sw.l v0, (LOC_KATINA_TIMER32)
	li v0, 30
	sw.l v0, (LOC_KATINA_TIMER32 + 4)	;store seconds
	sw.l r0, (LOC_KATINA_TIMER32 + 8)	;store milliseconds
	li v0, 1
	sw.l v0, (LOC_KATINA_TIMER32 + 12)	;store active
	li v0, 1.0	;size of timer
	sw.l v0, (LOC_KATINA_TIMER32 + 20)	;store size
	
@@CheckForRespawn:
	li.u a0, 0x8015EB18
	jal CheckShipDead
	li.l a0, 0x8015EB18
	li v1, 1
	bne v0, v1, (@@RespawnDummyWolf1)
	;wolf1 respawn
	li a0, 0x8015EB18	;mem space to spawn
	li a1, 0x4			;craft to target
	li a2, 5			;item to drop
	li t0, 0x4375F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x4			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0x31004005	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnDummyWolf1:
	li.u a0, 0x8015EE0C
	jal CheckShipDead
	li.l a0, 0x8015EE0C
	li v1, 1
	bne v0, v1, (@@RespawnWolf2)
	;dummy wolf1 id 0x1B
	li a0, 0x8015EE0C	;mem space to spawn
	li a1, 0x5			;craft to target
	li a2, 2			;item to drop
	li t0, 0x4440F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x1B			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 5			;hits when killed
	li t8, 0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
@@RespawnWolf2:
	li.u a0, 0x8015F100
	jal CheckShipDead
	li.l a0, 0x8015F100
	li v1, 1
	bne v0, v1, (@@RespawnDummyWolf2)
	;wolf2 id 0x1C
	li a0, 0x8015F100	;mem space to spawn
	li a1, 0x0			;craft to target
	li a2, 9			;item to drop
	li t0, 0x4470F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x5			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0x31004005	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnDummyWolf2:
	li.u a0, 0x8015F3F4
	jal CheckShipDead
	li.l a0, 0x8015F3F4
	li v1, 1
	bne v0, v1, (@@RespawnDummyWolf3)
	;dummy wolf2 id 0x1D
	li a0, 0x8015F3F4	;mem space to spawn
	li a1, 0x3			;craft to target
	li a2, 2			;item to drop
	li t0, 0x44B0F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x1D			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 5			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnDummyWolf3:
	li.u a0, 0x8015F6E8
	jal CheckShipDead
	li.l a0, 0x8015F6E8
	li v1, 1
	bne v0, v1, (@@RespawnDummyWolf4)
	;dummy wolf3 id 0x1E
	li a0, 0x8015F6E8	;mem space to spawn
	li a1, 0x2			;craft to target
	li a2, 2			;item to drop
	li t0, 0x44E0F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x1E			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 5			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnDummyWolf4:
	li.u a0, 0x8015F9DC
	jal CheckShipDead
	li.l a0, 0x8015F9DC
	li v1, 1
	bne v0, v1, (@@RegularMissileChecks)
	;dummy wolf4 id 0x1F
	li a0, 0x8015F9DC	;mem space to spawn
	li a1, 0x1			;craft to target
	li a2, 2			;item to drop
	li t0, 0x4510F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x1F			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 5			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RegularMissileChecks:
	li v0, 2200
	bne s7, v0, (@@MissileRespawnCheck1)
	;missile id 0x20
	li a0, 0x8015FCD0
	li a1, 0
	li a2, 46.0
	li t0, 0x45900000
	li t1, 0x450B0000
	li t2, 0x46600000
	jal SpawnSingleMissileOrShipSpecial
	li a3, 0
	
	;missile ship id 0x21
	li a0, 0x8015FFC4
	li a1, 2
	li a2, 45.0
	li t0, 0x45900000
	li t1, 0x450B0000
	li t2, 0x46700000
	jal SpawnSingleMissileOrShipSpecial
	li a3, 1

@@MissileRespawnCheck1:
	li a0, 0x8015FCD0
	jal CheckShipDeadMissile
	li a1, 0x00BF
	li v1, 1
	bne v0, v1, (@@MissileRespawnCheck2)
	;missile id 0x20
	li a0, 0x8015FCD0
	li a1, 0
	li a2, 44.0
	li t0, 0x45900000
	li t1, 0x450B0000
	li t2, 0x46600000
	jal SpawnSingleMissileOrShipSpecial
	li a3, 0
@@MissileRespawnCheck2:
	li a0, 0x8015FFC4
	jal CheckShipDeadMissile
	li a1, 0x00BF
	li v1, 1
	bne v0, v1, (@@MissileCheck3)
	;missile ship id 0x21
	li a0, 0x8015FFC4
	li a1, 2
	li a2, 45.0
	li t0, 0x45900000
	li t1, 0x450B0000
	li t2, 0x46700000
	jal SpawnSingleMissileOrShipSpecial
	li a3, 1
	
@@MissileCheck3:
	li v0, 3000
	bne s7, v0, (@@MissileRespawnCheck3)
	;missile ship id 0x22
	li a0, 0x801602B8
	li a1, 3
	li a2, 45.0
	li t0, 0x45900000
	li t1, 0x450B0000
	li t2, 0x46800000
	jal SpawnSingleMissileOrShipSpecial
	li a3, 1
	
@@MissileRespawnCheck3:
	li a0, 0x801602B8
	jal CheckShipDeadMissile
	li a1, 0x00BF
	li v1, 1
	bne v0, v1, (@@SpawnWolf345)
	;missile ship id 0x22
	li a0, 0x801602B8
	li a1, 3
	li a2, 45.0
	li t0, 0x45900000
	li t1, 0x450B0000
	li t2, 0x46800000
	jal SpawnSingleMissileOrShipSpecial
	li a3, 1
	
@@SpawnWolf345:
	li v0, 3400
	bne s7, v0, (@@RespawnWolf3)
	;wolf2 id 0x23
	li a0, 0x801605AC	;mem space to spawn
	li a1, 0xD			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC4B8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x6			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	;wolf3 id 0x24
	li a0, 0x801608A0	;mem space to spawn
	li a1, 0xE			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x6			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	;dummy wolf5 id 0x25
	li a0, 0x80160B94	;mem space to spawn
	li a1, 0xF			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x25			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 5			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnWolf3:
	li.u a0, 0x801605AC
	jal CheckShipDead
	li.l a0, 0x801605AC
	li v1, 1
	bne v0, v1, (@@RespawnWolf4)
	;wolf2 id 0x23
	li a0, 0x801605AC	;mem space to spawn
	li a1, 0xD			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC4B8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x6			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnWolf4:
	li.u a0, 0x801608A0
	jal CheckShipDead
	li.l a0, 0x801608A0
	li v1, 1
	bne v0, v1, (@@RespawnDummyWolf5)
	;wolf3 id 0x24
	li a0, 0x801608A0	;mem space to spawn
	li a1, 0xE			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x6			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnDummyWolf5:
	li.u a0, 0x80160B94
	jal CheckShipDead
	li.l a0, 0x80160B94
	li v1, 1
	bne v0, v1, (@@SuperWolfCheck)
	;dummy wolf5 id 0x25
	li a0, 0x80160B94	;mem space to spawn
	li a1, 0xF			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x25			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 5			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@SuperWolfCheck:
	lw v0, (LOC_PLAYER_HITS32)
	sltiu v1, v0, 150	;check if level hits is 150 or more
	bne v1, r0, (@@SuperWolfAliveCheck)
	lw v0, orga(gSpecialStageSuperWolfFlag) (gp)
	bne v0, r0, (@@SuperWolfAliveCheck)
	;super wolf id 0x25
	li a0, 0x80160E88	;mem space to spawn
	li a1, 0x0			;craft to target
	li a2, 0xD			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x4			;model of craft
	li t5, 2			;laser type / other model
	lw v0, (LOC_EXPERT_FLAG32)
	bne v0, r0, (@@SuperWolfExpertMode)
@@SuperWolfRegularMode:
	li t6, 300			;health
	b (@@SuperWolfResume)
	li t7, 50			;hits when killed
@@SuperWolfExpertMode:
	li t6, 500			;health
	li t7, 100			;hits when killed
@@SuperWolfResume:
	li t8, 0x31004006	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	li v0, 1
	sw v0, orga(gSpecialStageSuperWolfFlag) (gp)
	
@@SuperWolfAliveCheck:
	lh v0, (0x80160E88)
	li v1, 0x0200
	bne v1, v0, (@@TimerEndingCheck)
	la t0, 0x80160E88	;super wolf mem space
	lw v0, (LOC_EXPERT_FLAG32)
	bne v0, r0, (@@SuperWolfExpertStates)
@@SuperWolfRegularStates:
	li v0, 0x40120000
	sw v0, 0x011C(t0)	;state change speed
	li v0, 0x41700000
	sw v0, 0x0118(t0)	;speed
	li v0, 0x40420000
	b (@@TimerEndingCheck)
	sw v0, 0x0188(t0)	;back engine amount
@@SuperWolfExpertStates:
	li v0, 0x40230000
	sw v0, 0x011C(t0)	;state change speed
	li v0, 0x41780000
	sw v0, 0x0118(t0)	;speed
	li v0, 0x40480000
	sw v0, 0x0188(t0)	;back engine amount
	
@@TimerEndingCheck:
	sltiu v0, s7, 300
	bne v0, r0, (@@JamesCheck)
	lui at, 0x8015
	lw v0, 0x57a0(at)
	bne v0, r0, (@@JamesCheck)
	lw v0, 0x57a4(at)
	bne v0, r0, (@@JamesCheck)
	lw v0, 0x57a8(at)
	bne v0, r0, (@@JamesCheck)
	li v0, 1
	sb v0, (LOC_ENDSCREEN_FLAG8)
	sw r0, 0x57aC(at)
	b (@@Exit)
	nop
@@JamesCheck:
	li v0, 1200
	bne s7, v0, (@@JamesCheckIsSpawned)
	nop
	;james	memory id 0x6
	li a0, 0x8015B008	;mem space to spawn
	li a1, 0x1C			;craft to target
	li a2, 0			;item to drop
	li t0, 157.744552612	;x coords to spawn at
	li t1, 2920.24169922	;y coords to spawn at
	li t2, -833.482788086	;z coords to spawn at
	li t3, 0			;can be targeted or not
	li t4, 0x0			;model of craft
	li t5, 3			;laser type / other model
	li t6, 300			;health
	li t7, 0			;hits when killed
	li t8, 0			;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@JamesCheckIsSpawned:	;james spawned, change to hidden icon or it'd be falco
	sltiu v0, s7, 1206
	bne v0, r0, (@@BombReadyCheck)
	nop
	la t0, 0x8015B008	;james
	lh v0, 0x0000(t0)
	li v1, 3
	beq v0, v1, (@@BombReadyCheck)	;skip if in dying state. not sure why this happens sometimes
	li v0, 0xC3
	sh v0, 0x0002(t0)
	li v0, 0x41100000
	sw v0, 0x011C(t0)
	li v0, 0x2
	sh v0, 0x0092(t0)
	li v0, 0x42600000
	sw v0, 0x0118(t0)
	li v0, 0x40400000
	sw v0, 0x0188(t0)
	
@@BombReadyCheck:
	lw v0, (0x8016A594)
	li v1, 0x3F800000
	bne v0, v1, (@@IfPauseCheck)
	li v0, 0x56
	sw v0, (0x8016A5B4)	;set new timer
@@IfPauseCheck:
	lw v0, LOC_SPECIAL_STATE
	li v1, 0x64
	beq v0, v1, (@@Exit)
	lw v0, orga(gSpecialStageBombReadyTimer) (gp)
	addiu v0, v0, 1
	sw v0, orga(gSpecialStageBombReadyTimer) (gp)
	li v1, 500
	sltiu a0, v0, 500
	beql a0, r0, (@@BombIsReady)
	sw v1, orga(gSpecialStageBombReadyTimer) (gp)
	b @@Exit
	nop
@@BombIsReady:
	jal CheckButtons
	li a0, 0
	andi a0, v1, BUTTON_L16
	beq a0, r0, (@@Exit)
	nop
	jal @PlaceBombSpecial
	nop
	;change bomb parameters
	li v0, 157.744552612
	sw.u v0, (0x8016A554)
	sw.l v0, (0x8016A554)
	li v0, 2308.24169922
	sw.l v0, (0x8016A554 + 4)
	li v0, -833.482788086
	sw.l v0, (0x8016A554 + 8)
	li v0, -52.1184997559
	sw.l v0, (0x8016A554 + 32)
	li v0, 576.0
	sw.l v0, (0x8016A554 + 68)
	sw r0, orga(gSpecialStageBombReadyTimer) (gp)
	b @@Exit
	nop
; @@BombCheck:
	; lw v0, (0x8016A594)
	; li v1, 0x3F800000
	; bne v0, v1, (@@Exit)
	; li v0, 0x56
	; sw v0, (0x8016A5B4)	;set new timer

@@Exit:
	j NextTableEntry
	nop
	
	/* Sub Functions */
	/* Game Code Call Defines */
		@FUNC_MAKE_PLAYER_OBJECT equ 0x800A7E04
	
@PlaceBombSpecial:
	addiu sp, sp, -24
	sw ra, 0(sp)
	li v0, 3 ;bomb id
	sw v0, 16(sp)
	mtc1 r0, F0
	li at, 11.25	;speed default 180.0
	mtc1 at, F4
	swc1 F4, 20(sp)
	mfc1 a2, F0
	mfc1 a3, F0
	li a1, 0x8016A550 ;location in memory to put bomb (fixed to certain spots)
	lw.u a0, LOC_FOX_POINTER32	;or find proper coords to other ships later?
	jal @FUNC_MAKE_PLAYER_OBJECT
	lw.l a0, LOC_FOX_POINTER32
	lw ra, 0(sp)
	jr ra
	addiu sp, sp, 24
	nop
;0903A010 other explosion sfx, time with bomb?
	
@GreatFoxDummyFunc:
	jr ra
	nop
	
; @SubBRMScore:
; jr ra
; nop
	
.endautoregion