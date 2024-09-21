
	/* Special mode that the player can go to after reaching x amount of score in certain modes before entering venoms */

.n64
.autoregion

;currently no logic for Endurance mode
;use gSpecialStageChoosePlanetsFlag to force this stage if wanting to use this mode outside of regular logic already defined
;s7 = planet ID from map screen -1
;s0 = actual level ID until calls to game code are made (outside of randomizer calls)
;s1 = training level ID until calls to game code are made (outside of randomizer calls)

TBL_FUNC_SpecialStage:
	lw v0, orga(gSpecialStageFlag) (gp)
	beq v0, r0, (@@Exit)
	lui t0, 0x8017
	lw a0, 0xD9B8(t0) 	;LOC_NUM_PLANETS_COMPLETED32
	sll t1, a0, 2
	addu t1, t1, t0
	lw s7, 0xDA00(t1)	;get last planet completed by game logic (map screen planet IDs).
	lw s0, (LOC_LEVEL_ID32)
	li s1, 0xA	;training level ID
	lw v0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	bne v0, r0, (@@BypassPlanetsDoneCheck)
	nop
	beq a0, r0, (@@Exit)	;exit if completed times is 0 for assuming marathon mode
	nop
	jal CheckFoxState
	li a1, 0x7
	beq v0, a1, (@@CheckForPlanet)
	nop
@@BypassPlanetsDoneCheck:
	lb v0, (LOC_ENDSCREEN_FLAG8)
	beq v0, r0, (@@CheckIfTrainingLoaded)	;used only to end training
	nop
	beq s0, s1, (@@InEndingSpecialStage)	;in ending screen on training
	nop
	j NextTableEntry
	nop
@@CheckForPlanet:
	lh v0, (0x801578a0)		;check if soft reset map ID is training otherwise map colors won't update on transition
	beq s1, v0, (@@CheckIfMapLoaded)
	li v0, 0x13
	beq s0, v0, (@@Exit)	;exit if in ending state on venoms or tunnels
	li v0, 0x9
	beq s0, v0, (@@Exit)
	li v0, 0x6
	beq s0, v0, (@@Exit)
	li v0, PLANET_BOLSE
	beq s7, v0, (@@IfBolse)	;check for planet ID from map screen is equal
	li v0, PLANET_A6
	beq s7, v0, (@@IfA6)
	nop
	j NextTableEntry
	nop
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
	j NextTableEntry
	nop
@@BolseBRM:
	lw v0, orga(gMarathonModeFlag) (gp)
	bne v0, r0, (@@BolseBRMMarathon)
	li v1, 1
	beq a0, v1, (@@BolseScoreCheckBRM)
	li v1, 2
	beq a0, v1, (@@BolseRandomFlagCheck)
	nop
	j NextTableEntry
	nop
	
@@BolseMarathon:
	j NextTableEntry
	nop
@@BolseBRMMarathon:
	j NextTableEntry
	nop
	
@@BolseScoreCheck:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageRegularScore) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li v0, 0xA
	sh v0, (0x80186502)	;overwrite planet to go into from bolse level function
	jal LoadPlayerInfoToGP
	nop
	j NextTableEntry
	nop
@@BolseScoreCheckBRM:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageBRMScore) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li v0, 0xA
	sh v0, (0x80186502)	;overwrite planet to go into from bolse level function
	jal LoadPlayerInfoToGP
	nop
	j NextTableEntry
	nop
	
@@BolseRandomFlagCheck:
	lw a0, orga(gSpecialStageRandomFlag) (gp)
	beq a0, r0, (@@Exit)	;bad luck
	li v0, 0xA
	sh v0, (0x80186502)	;overwrite planet to go into from bolse level function
	jal LoadPlayerInfoToGP
	nop
	j NextTableEntry
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
	j NextTableEntry
	nop

@@A6BRM:
	lw v0, orga(gMarathonModeFlag) (gp)
	bne v0, r0, (@@A6BRMMarathon)
	li v1, 1
	beq a0, v1, (@@A6ScoreCheckBRM)
	li v1, 2
	beq a0, v1, (@@A6RandomFlagCheck)
	nop
	j NextTableEntry
	nop
	
@@A6BRMMarathon:
	li v1, 1
	beq a0, v1, (@@A6ScoreCheckBRMMarathon)
	li v1, 2
	beq a0, v1, (@@A6RandomFlagCheck)
	nop
	j NextTableEntry
	nop
	
@@A6Marathon:
	li v1, 1
	beq a0, v1, (@@A6ScoreCheckMarathon)
	li v1, 2
	beq a0, v1, (@@A6RandomFlagCheck)
	nop
	j NextTableEntry
	nop
	
@@A6ScoreCheck:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageRegularScore) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li v0, 0xA
	sh v0, (0x801858FE)	;overwrite planet to go into from A6 level function
	jal LoadPlayerInfoToGP
	nop
	j NextTableEntry
	nop
@@A6ScoreCheckBRM:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageBRMScore) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li v0, 0xA
	sh v0, (0x801858FE)	;overwrite planet to go into from A6 level function
	jal LoadPlayerInfoToGP
	nop
	j NextTableEntry
	nop
@@A6ScoreCheckBRMMarathon:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageBRMMarathonScore) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li v0, 0xA
	sh v0, (0x801858FE)	;overwrite planet to go into from A6 level function
	jal LoadPlayerInfoToGP
	nop
	li v0, 1
	sw v0, orga(gSpecialStagePlayerActive) (gp)
	j NextTableEntry
	nop
@@A6ScoreCheckMarathon:
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gSpecialStageMarathonScore) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@Exit)	;player didn't get the correct score
	nop
	li v0, 0xA
	sh v0, (0x801858FE)	;overwrite planet to go into from A6 level function
	jal LoadPlayerInfoToGP
	nop
	li v0, 1
	sw v0, orga(gSpecialStagePlayerActive) (gp)
	j NextTableEntry
	nop
	
@@A6RandomFlagCheck:
	lw a0, orga(gSpecialStageRandomFlag) (gp)
	beq a0, r0, (@@Exit)	;bad luck
	li v0, 0xA
	sh v0, (0x801858FE)	;overwrite planet to go into from A6 level function
	jal LoadPlayerInfoToGP
	nop
	li v0, 1
	sw v0, orga(gSpecialStagePlayerActive) (gp)
	j NextTableEntry
	nop

@@InEndingSpecialStage:
	;do teammate alive bonus cals for score adding ?
	lw a0, orga(gSpecialStageEndWaitTimer) (gp)
	addiu a0, a0, 1
	sw a0, orga(gSpecialStageEndWaitTimer) (gp)
	sltiu v0, a0, 250
	bne v0, r0, (@@Exit)	;wait 250 frames
	lui t0, 0x8017
	lw a0, 0xD9B8(t0) 	;LOC_NUM_PLANETS_COMPLETED32
	addiu a0, a0, -1	;subtract 1 completed time since a6/bolse auto
						;adds completed times on the last few frames when the levels are ending. 
	sll t1, a0, 2
	addu t1, t1, t0
	lw s7, 0xDA00(t1)	;get last planet completed by game logic (map screen planet IDs).
	li v0, PLANET_BOLSE
	beq s7, v0, (@@WarpToVE1)
	li v0, PLANET_A6
	beq s7, v0, (@@WarpToVE2)
	nop
	;shouldn't go here unless choose planets was on and last completed level wasn't bolse/a6
	jal DoSoftResetWithFlag
	li a0, 4
	sw r0, orga(gSpecialStageEndWaitTimer) (gp)
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag2) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag3) (gp)
	sw r0, orga(gSpecialStagePlayerActive) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	nop
@@WarpToVE1:
	sw r0, orga(gSpecialStageEndWaitTimer) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag2) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag3) (gp)
	li.u a0, 0x00060007
	jal DoSoftResetWithFlag
	li.l a0, 0x00060007
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	sw r0, orga(gSpecialStagePlayerActive) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	nop
@@WarpToVE2:
	sw r0, orga(gSpecialStageEndWaitTimer) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag2) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag3) (gp)
	li.u a0, 0x00130007
	jal DoSoftResetWithFlag
	li.l a0, 0x00130007
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	sw r0, orga(gSpecialStagePlayerActive) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	nop
	
	
@@CheckIfTrainingLoaded:
	beq s0, s1, (@@CheckIfBossRush)
	nop
	j NextTableEntry	;exit since not training level
	nop
@@CheckIfBossRush:
	lw v0, orga(gBossRushModeFlag) (gp)
	lw v1, orga(gSpecialStageBRMBasicScore) (gp)
	bnel v0, r0, (@@DoRetryAndDeadLogic)
	sw v1, orga(gTimerScoreToDisplay) (gp)	;set and force timer to 5000 points if BRM is on.
	
@@DoRetryAndDeadLogic:
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
	lui t0, 0x8017
	lw a0, 0xD9B8(t0) 	;LOC_NUM_PLANETS_COMPLETED32
	addiu a0, a0, -1	;subtract 1 completed time since a6/bolse auto
						;adds completed times on the last few frames when the levels are ending. 
	sll t1, a0, 2
	addu t1, t1, t0
	lw s7, 0xDA00(t1)	;get last planet completed by game logic (map screen planet IDs).
	li v0, PLANET_BOLSE
	beq s7, v0, (@@DeadGoingToVE1)
	li v0, PLANET_A6
	beq s7, v0, (@@DeadGoingToVE2)
	nop
	;shouldn't go here unless choose planets was on
	sw r0, (LOC_PLAYER_HITS32)
	jal DoSoftResetWithFlag
	li a0, 4
	jal LoadPlayerInfoToGP
	nop
	sw r0, (LOC_PAUSE_STATE32)
	lui at, 0x8015
	sw r0, 0x57A0(at)
	sw r0, 0x57A4(at)
	sw r0, 0x57A8(at)
	sw r0, 0x57AC(at)
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	sw r0, orga(gSpecialStageEndWaitTimer) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag2) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag3) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	nop
	
@@DeadGoingToVE1:
	sw r0, (LOC_PAUSE_STATE32)
	lui at, 0x8015
	sw r0, 0x57A0(at)
	sw r0, 0x57A4(at)
	sw r0, 0x57A8(at)
	sw r0, 0x57AC(at)
	sw r0, orga(gSpecialStageEndWaitTimer) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag2) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag3) (gp)
	sw r0, (LOC_PLAYER_HITS32)
	li.u a0, 0x00060007
	jal DoSoftResetWithFlag
	li.l a0, 0x00060007
	jal LoadPlayerInfoToGP
	nop
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	sw r0, orga(gSpecialStagePlayerActive) (gp)
	j NextTableEntry
	sw r0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	nop
@@DeadGoingToVE2:
	sw r0, (LOC_PAUSE_STATE32)
	lui at, 0x8015
	sw r0, 0x57A0(at)
	sw r0, 0x57A4(at)
	sw r0, 0x57A8(at)
	sw r0, 0x57AC(at)
	sw r0, orga(gSpecialStageEndWaitTimer) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag2) (gp)
	sw r0, orga(gSpecialStageSuperWolfFlag3) (gp)
	sw r0, (LOC_PLAYER_HITS32)
	li.u a0, 0x00130007
	jal DoSoftResetWithFlag
	li.l a0, 0x00130007
	jal LoadPlayerInfoToGP
	nop
	sw r0, orga(gSpecialStageRandomFlag) (gp)
	sw r0, orga(gSpecialStagePlayerActive) (gp)
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
	li v0, 0x40
	sw v0, 0xCA60(t0)	;green fog amount
	li v0, 0x70
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
	sw r0, 0x8018F544	;remove dialog from level
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
	nop
	jal LoadPlayerInfoToGame
	nop
	li v0, 0x0303
	sh v0, (0x80157900)	;give player double health
	la v1, LOC_PLAYER_LASER8
	li at, 2
	sb at, 0x0000(v1) ;give player hypers
	; li at, 1
	; lb a0, 0x0000(v1)
	; sltiu v0, a0, 2
	; bnel v0, r0, (@@GiveBombs)
	; sb at, 0x0000(v1)	;give player twin lasers if not hypers
@@GiveBombs:
	la v1, LOC_PLAYER_BOMBS8
	li at, 5
	lb a0, 0x0000(v1)
	sltiu v0, a0, 6
	bnel v0, r0, (@@FalcoSpawn)
	sb at, 0x0000(v1)	;give player 5 bombs if not over 5 already
@@FalcoSpawn:
	lui at, 0x8017
	lw v0, 0xD724(at)	;falco health
	ble v0, r0, (@@SlippySpawn)
	;Falco	memory id 0x1
	li a0, 0x8015A144	;mem space to spawn
	li a1, 0x1E			;craft to target
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
	li t0, 157.744552612	;x coords to spawn at
	li t1, 2860.24169922	;y coords to spawn at
	li t2, -833.482788086	;z coords to spawn at
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
	li t8, 0	;engine sound
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
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
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
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
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
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
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
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
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
	li t8, 0			;engine sound
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
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
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
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
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
	li t4, 0xA			;model of craft
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
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RegularMissileChecks:
	li v0, 3200
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
	li v0, 2500
	bne s7, v0, (@@RespawnWolf3)
	;wolf2 id 0x23
	li a0, 0x801605AC	;mem space to spawn
	li a1, 4			;craft to target
	li a2, 0xE			;item to drop
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
	li a1, 5			;craft to target
	li a2, 0xE			;item to drop
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
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
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
	li a1, 4			;craft to target
	li a2, 0xE			;item to drop
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
	li a1, 5			;craft to target
	li a2, 0xE			;item to drop
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
	bne v0, v1, (@@SpawnDummyWolf678)
	;dummy wolf5 id 0x25
	li a0, 0x80160B94	;mem space to spawn
	li a1, 0xF			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@SpawnDummyWolf678:
	li v0, 3200
	bne s7, v0, (@@RespawnDummyWolf6)
	;dummy wolf678 id 0x29, 0x2A, 0x2B, wolfs 0x2C, 0x2D
	li a0, 0x80161764	;mem space to spawn
	li a1, 0x1			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC6A019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	li a0, 0x80161A58	;mem space to spawn
	li a1, 0x2			;craft to target
	li a2, 2			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC6E019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	li a0, 0x80161D4C	;mem space to spawn
	li a1, 0x2			;craft to target
	li a2, 2			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC71019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	li a0, 0x80162040	;mem space to spawn
	li a1, 5			;craft to target
	li a2, 0x5			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x4			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
	li a0, 0x80162334	;mem space to spawn
	li a1, 4			;craft to target
	li a2, 0x5			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC63019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x5			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnDummyWolf6:
	li.u a0, 0x80161764
	jal CheckShipDead
	li.l a0, 0x80161764
	li v1, 1
	bne v0, v1, (@@RespawnDummyWolf7)
	;dummy wolf6 id 0x29
	li a0, 0x80161764	;mem space to spawn
	li a1, 0x1			;craft to target
	li a2, 0			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC6A019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnDummyWolf7:
	li.u a0, 0x80161A58
	jal CheckShipDead
	li.l a0, 0x80161A58
	li v1, 1
	bne v0, v1, (@@RespawnDummyWolf8)
	;dummy wolf7 id 0x2A
	li a0, 0x80161A58	;mem space to spawn
	li a1, 0x2			;craft to target
	li a2, 2			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC6E019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnDummyWolf8:
	li.u a0, 0x80161D4C
	jal CheckShipDead
	li.l a0, 0x80161D4C
	li v1, 1
	bne v0, v1, (@@RespawnWolf5)
	;dummy wolf8 id 0x2B
	li a0, 0x80161D4C	;mem space to spawn
	li a1, 0x2			;craft to target
	li a2, 2			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC71019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0xA			;model of craft
	li t5, 2			;laser type / other model
	li t6, 32			;health
	li t7, 3			;hits when killed
	li t8, 0x0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	
@@RespawnWolf5:
	li.u a0, 0x80162040
	jal CheckShipDead
	li.l a0, 0x80162040
	li v1, 1
	bne v0, v1, (@@RespawnWolf6)
	;wolf5 id 0x2C
	li a0, 0x80162040	;mem space to spawn
	li a1, 5			;craft to target
	li a2, 0x5			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x4			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type

@@RespawnWolf6:
	li.u a0, 0x80162334
	jal CheckShipDead
	li.l a0, 0x80162334
	li v1, 1
	bne v0, v1, (@@SuperWolfCheck)
	;wolf6 id 0x2D
	li a0, 0x80162334	;mem space to spawn
	li a1, 4			;craft to target
	li a2, 0x5			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC63019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x5			;model of craft
	li t5, 2			;laser type / other model
	li t6, 64			;health
	li t7, 10			;hits when killed
	li t8, 0	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type

@@SuperWolfCheck:
	lw v0, (LOC_PLAYER_HITS32)
	sltiu v1, v0, 150	;check if level hits is 200 or more
	bne v1, r0, (@@SuperWolfAliveCheck)
	lw v0, orga(gSpecialStageSuperWolfFlag) (gp)
	bne v0, r0, (@@SuperWolfAliveCheck)
	;super wolf id 0x26
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
	bne v1, v0, (@@SuperWolfCheck2)
	la t0, 0x80160E88	;super wolf mem space
	lw v0, (LOC_EXPERT_FLAG32)
	bne v0, r0, (@@SuperWolfExpertStates)
@@SuperWolfRegularStates:
	li v0, 0x40100000
	sw v0, 0x011C(t0)	;state change speed
	li v0, 0x42400000
	sw v0, 0x0118(t0)	;speed
	li v0, 0x40480000
	b (@@SuperWolfCheck2)
	sw v0, 0x0188(t0)	;back engine amount
@@SuperWolfExpertStates:
	li v0, 0x40140000
	sw v0, 0x011C(t0)	;state change speed
	li v0, 0x428E0000
	sw v0, 0x0118(t0)	;speed
	li v0, 0x404E0000
	sw v0, 0x0188(t0)	;back engine amount
	
@@SuperWolfCheck2:
	lw v0, (LOC_PLAYER_HITS32)
	sltiu v1, v0, 250	;check if level hits is 400 or more
	bne v1, r0, (@@SuperWolfAliveCheck2)
	lw v0, orga(gSpecialStageSuperWolfFlag2) (gp)
	bne v0, r0, (@@SuperWolfAliveCheck2)
	;super wolf id 0x27
	li a0, 0x8016117C	;mem space to spawn
	li a1, 0x0			;craft to target
	li a2, 0x19			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x4			;model of craft
	li t5, 2			;laser type / other model
	lw v0, (LOC_EXPERT_FLAG32)
	bne v0, r0, (@@SuperWolfExpertMode2)
@@SuperWolfRegularMode2:
	li t6, 300			;health
	b (@@SuperWolfResume2)
	li t7, 50			;hits when killed
@@SuperWolfExpertMode2:
	li t6, 500			;health
	li t7, 100			;hits when killed
@@SuperWolfResume2:
	li t8, 0x31004006	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	li v0, 1
	sw v0, orga(gSpecialStageSuperWolfFlag2) (gp)
	
@@SuperWolfAliveCheck2:
	lh v0, (0x8016117C)
	li v1, 0x0200
	bne v1, v0, (@@SuperWolfCheck3)
	la t0, 0x8016117C	;super wolf mem space
	lw v0, (LOC_EXPERT_FLAG32)
	bne v0, r0, (@@SuperWolfExpertStates2)
@@SuperWolfRegularStates2:
	li v0, 0x40100000
	sw v0, 0x011C(t0)	;state change speed
	li v0, 0x42400000
	sw v0, 0x0118(t0)	;speed
	li v0, 0x40480000
	b (@@SuperWolfCheck3)
	sw v0, 0x0188(t0)	;back engine amount
@@SuperWolfExpertStates2:
	li v0, 0x40140000
	sw v0, 0x011C(t0)	;state change speed
	li v0, 0x428E0000
	sw v0, 0x0118(t0)	;speed
	li v0, 0x404E0000
	sw v0, 0x0188(t0)	;back engine amount
	
@@SuperWolfCheck3:
	lw v0, (LOC_PLAYER_HITS32)
	sltiu v1, v0, 350	;check if level hits is 600 or more
	bne v1, r0, (@@SuperWolfAliveCheck3)
	lw v0, orga(gSpecialStageSuperWolfFlag3) (gp)
	bne v0, r0, (@@SuperWolfAliveCheck3)
	;super wolf id 0x28
	li a0, 0x80161470	;mem space to spawn
	li a1, 0x5			;craft to target
	li a2, 0x19			;item to drop
	li t0, 0xC4E8F89D	;x coords to spawn at
	li t1, 0x45300721	;y coords to spawn at
	li t2, 0xC69019A0	;z coords to spawn at
	li t3, 0x42000000	;can be targeted or not
	li t4, 0x4			;model of craft
	li t5, 2			;laser type / other model
	lw v0, (LOC_EXPERT_FLAG32)
	bne v0, r0, (@@SuperWolfExpertMode3)
@@SuperWolfRegularMode3:
	li t6, 300			;health
	b (@@SuperWolfResume3)
	li t7, 50			;hits when killed
@@SuperWolfExpertMode3:
	li t6, 500			;health
	li t7, 100			;hits when killed
@@SuperWolfResume3:
	li t8, 0x31004006	;engine sound
	jal SpawnSingleCraftSpecial
	li v0, 0x00C5		;main craft type
	li v0, 1
	sw v0, orga(gSpecialStageSuperWolfFlag3) (gp)
	
@@SuperWolfAliveCheck3:
	lh v0, (0x80161470)
	li v1, 0x0200
	bne v1, v0, (@@CheckForDeadSuperWolfs)
	la t0, 0x80161470	;super wolf mem space
	lw v0, (LOC_EXPERT_FLAG32)
	bne v0, r0, (@@SuperWolfExpertStates3)
@@SuperWolfRegularStates3:
	li v0, 0x40100000
	sw v0, 0x011C(t0)	;state change speed
	li v0, 0x42400000
	sw v0, 0x0118(t0)	;speed
	li v0, 0x40480000
	b (@@CheckForDeadSuperWolfs)
	sw v0, 0x0188(t0)	;back engine amount
@@SuperWolfExpertStates3:
	li v0, 0x40140000
	sw v0, 0x011C(t0)	;state change speed
	li v0, 0x428E0000
	sw v0, 0x0118(t0)	;speed
	li v0, 0x404E0000
	sw v0, 0x0188(t0)	;back engine amount
	
@@CheckForDeadSuperWolfs:	;check if dying to apply special fx
	la at, 0x80160E88
	lb v0, 0x0000(at)
	li v1, 3
	bne v1, v0, (@@CheckForDeadSuperWolf2)
	lh v0, 0x00BE(at)
	li v1, 2
	bne v1, v0, (@@CheckForDeadSuperWolf2)
	or a0, at, r0
	jal GrabObjectCoordinates
	nop
	li a0, 20.0
	jal PlaceSpecialEffect
	li t0, 0x017F
@@CheckForDeadSuperWolf2:
	la at, 0x8016117C
	lb v0, 0x0000(at)
	li v1, 3
	bne v1, v0, (@@CheckForDeadSuperWolf3)
	lh v0, 0x00BE(at)
	li v1, 2
	bne v1, v0, (@@CheckForDeadSuperWolf3)
	or a0, at, r0
	jal GrabObjectCoordinates
	nop
	li a0, 20.0
	jal PlaceSpecialEffect
	li t0, 0x017F
@@CheckForDeadSuperWolf3:
	la at, 0x80161470
	lb v0, 0x0000(at)
	li v1, 3
	bne v1, v0, (@@TimerEndingCheck)
	lh v0, 0x00BE(at)
	li v1, 2
	bne v1, v0, (@@TimerEndingCheck)
	or a0, at, r0
	jal GrabObjectCoordinates
	nop
	li a0, 20.0
	jal PlaceSpecialEffect
	li t0, 0x017F
	
@@TimerEndingCheck:
	sltiu v0, s7, 300
	bne v0, r0, (@@JamesCheck)
	li v1, 3
	sb v1, (0x8015bc14)		;give star wolf enemy spawned by game code +3 hits for killing
	lui at, 0x8015
	lw v0, 0x57A0(at)
	bne v0, r0, (@@JamesCheck)
	lw v0, 0x57A4(at)
	bne v0, r0, (@@JamesCheck)
	lw v0, 0x57A8(at)
	bne v0, r0, (@@JamesCheck)
	li v0, 1
	sw r0, 0x57AC(at)
	sb v0, (LOC_ENDSCREEN_FLAG8)
	li a0, 0x01C8
	jal SetFoxState
	li a1, 0
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
	bne v0, v1, (@@IfRobBombCheck)
	li v0, 0x56
	sw v0, (0x8016A5B4)	;set new timer
@@IfRobBombCheck:
	;dumb check for new sfx for rob bomb
	lw v1, (0x8016A594)
	li v0, 0x40200000
	bne v0, v1, (@@IfPauseCheck)
	; li.u a0, 0x2940C00A
	; jal PlaySFX
	; li.l a0, 0x2940C00A
	li a0, 86.0
	la v0, 0x8016A550	;Fox bomb address
	lw a1, 0x0004(v0)	;x
	lw a2, 0x0008(v0)	;y
	lw a3, 0x000C(v0)	;z
	li t0, 0x017F
	jal PlaceSpecialEffect
	nop
	
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
	li a0, 0x8015B5F0
	li.u a1, 0x80162628
	jal LockOnScan
	li.l a1, 0x80162628
	beq v0, r0, (@@RegularBomb)
	nop
@@LockOnBomb:
	jal @PlaceBombSpecial
	li a0, 0x8
	b (@@ChangeBombParameters)
	nop
@@RegularBomb:
	jal @PlaceBombSpecial
	li a0, 0x3
@@ChangeBombParameters:
	li v0, 157.744552612
	sw.u v0, (0x8016A554)
	sw.l v0, (0x8016A554)
	li v0, 2300.24169922
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
	
@PlaceBombSpecial:	;bomb id a0
	addiu sp, sp, -24
	sw ra, 0(sp)
	sw a0, 16(sp)
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
	
@GreatFoxDummyFunc:
	jr ra
	nop
	
; @SubBRMScore:
; jr ra
; nop

SUB_CheckIfModelAOnTraining:	;the game really likes to hardcode things, 
								;this changes all craft models if 0xA to change to red wolfs for training only.
								;normally they only change craft models if targetting Fox...
								;no need to restore this function in game code.
								;replaces branch at 0x80031804
	lh t7, 0x00E4(s1)
	li v0, 0xA
	beq t7, v0, (@@Equal)
	lh t7, 0x00E6(s1)
	j 0x80031864
	nop
@@Equal:
	j 0x8003180C
	nop
	
HOOK_CheckIfModeAOnTraining:	;dumb
j SUB_CheckIfModelAOnTraining
nop
	
	
.endautoregion