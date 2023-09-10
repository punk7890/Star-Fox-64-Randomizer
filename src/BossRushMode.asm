	
	/* Boss Rush Mode logic function. Text display logic is in SUB_InGameText at BossRushRenderText */

.n64		
.autoregion

;if MA mode on, in training stop timer from counting down and have more enemies on a 1 minute timer then end level
;make special training mode a bonus stage if passed x score?
;put previous level in initlevelvars
;there's some ending logic in SUB_CustomEndScreenHook already
;soft reseting might not have BRM values to restore properly in LoadPlayerInfoToGame
;make timer for Venom 2 regular
;kill item function
;put SZ stuff in timerchecks
;speed up missiles on SZ? check if all dead / alive?
;MA mode goes to training bug

TBL_FUNC_BossRushMode:

	lw at, orga(gBossRushModeFlag) (gp)
	beq at, r0, (@@Exit)
	la s0, LOC_PLAYER_TOTAL_HITS32	;load player score address to s0
	jal GetLevelID
	nop
	or s2, v0, r0	;move level ID into s2
	jal CheckMapScreenState
	li v1, 3
	beq v1, v0, (@@MapScreenStuff)
	nop
	jal CheckFoxState
	nop
	or s1, v0, r0 ;move fox state in s1 for checks later
	li v1, -1
	beq s1, v1, (@@Exit)
	nop 
	jal @DoTimerChecks
	nop
	jal @DoTimerLogic
	nop
	lb v0, (LOC_ENDSCREEN_FLAG8)
	bne v0, r0, (@@EndSceneChecks)	;check if only end screen is displaying
	addu v0, s1, v0
	li v1, 8
	beq v0, v1, (@@EndSceneChecks)	;add Fox state and end screen flag together to see if in end scene = 8 (fail safe check)
	li v1, 7
	beq s1, v1, (@@EndSceneChecks)	;check if only in end scene state
	li v1, 0x0
	beq s2, v1, (@@OnCorn)
	li v1, 0x1
	beq s2, v1, (@@OnMet)
	li v1, 0xE
	beq s2, v1, (@@OnFortuna)
	li v1, 0x2
	beq s2, v1, (@@OnSX)
	li v1, 0xC
	beq s2, v1, (@@OnTIT)
	li v1, 0x11
	beq s2, v1, (@@OnBOLSE)
	li v1, 0x6
	beq s2, v1, (@@OnVE1)
	li v1, 0x9
	beq s2, v1, (@@OnTunnels)
	li v1, 0x13
	beq s2, v1, (@@OnVE2)
	li v1, 0x10
	beq s2, v1, (@@OnKatina)
	li v1, 0x7
	beq s2, v1, (@@OnSolar)
	li v1, 0xB
	beq s2, v1, (@@OnMacBeth)
	li v1, 0x5
	beq s2, v1, (@@OnSY)
	li v1, 0xD
	beq s2, v1, (@@OnAquas)
	li v1, 0x8
	beq s2, v1, (@@OnZoness)
	li v1, 0x12
	beq s2, v1, (@@OnSZ)
	li v1, 0x3
	beq s2, v1, (@@OnA6)
	nop
	j NextTableEntry
	nop
	
@@OnCorn:
	lui t0, 0x8024
	lh v0, 0xd1a4 (t0)
	li v1, 0x041A
	bne v0, v1, (@@Exit)	;exit if objects in level aren't loaded
	lw v0, orga(gCornFlag) (gp)
	bne v0, r0, (@@Corn2Boss)	;flag not zero so do 2nd boss
	li v0, 0x0124	;first boss ID which also moves to all range mode
	j NextTableEntry
	sh v0, 0xd1a4 (t0)
	nop
@@Corn2Boss:
	li v0, 0x0125	;load boss ID
	sh v0, 0xd1a4 (t0)	;change first level object to boss ID
	sh r0, 0xd19a (t0)	;Going off old code, I think this moves pos to 0
	sh r0, 0xd19c (t0)
	li v0, -1
	sh v0, 0xd1b8 (t0)	;change 2nd level object to end data flag
	li v0, 0x10000017
	sw.u v0, (0x80181DAC) ;put branch in 2nd boss's function. I believe this removes some conditional checks
	j NextTableEntry
	sw.l v0, (0x80181DAC)
	nop
	
@@OnMet:
	lui t0, 0x8022
	lh v0, 0xE874(t0)
	li v1, 0x041A
	bne v0, v1, (@@Exit)
	li v1, 0x129	;put boss ID in level data
	sh v1, 0xE874(t0)
	li v1, 0x13
	sb v1, 0xE82B(t0)
	li v1, -1
	j NextTableEntry
	sh v1, 0xE888(t0)
	nop
	
@@OnFortuna:
	li v0, 1
	beq s1, v0, (@@FortunaForceCheckPoint)	;if spawning / retrying force checkpoint
	li v0, 2
	beq s1, v0, (@@FortunaForceTimer)	;if intro is playing force timer
	li v0, 3
	beq s1, v0, (@@FortunaForceCheckPoint)	;if alive only force checkpoint
	nop
	j NextTableEntry
	nop
@@FortunaForceTimer:
	li v0, 0xB3E
	sw v0, (LOC_ALLRANGEMODE_TIMER)
@@FortunaForceCheckPoint:
	li v0, 1
	sw.u v0, (LOC_CHECKPOINT_ALLRANGEMODE_FLAG)
	j NextTableEntry
	sw.l v0, (LOC_CHECKPOINT_ALLRANGEMODE_FLAG)
	nop
	
@@OnSX:
	lui t0, 0x8022
	lh v0, 0x1d14(t0)
	li v1, 0x0422
	bne v0, v1, (@@Exit)
	li v0, 0x8015
	sh v0, 0x1cca(t0)
	sw r0, 0x1d08(t0)
	sw r0, 0x1d0C(t0)
	sw r0, 0x1d10(t0)
	li v0, 0x12F
	sh v0, 0x1d14(t0)
	li v0, 0xE5000000
	sw v0, 0x1d1c(t0)
	li v0, 0x02000000
	sw v0, 0x1d20(t0)
	sw r0, 0x1d24(t0)
	li v0, -1
	j NextTableEntry
	sh v0, 0x1d28(t0)
	nop
	
@@OnTIT:
	lui t0, 0x8022
	lh v0, 0x61D0(t0)
	li v1, 0x03E9
	bne v0, v1, (@@Exit)
	li v0, 0x132
	sh v0, 0x61D0(t0)
	sh r0, 0x61DE(t0)
	sh r0, 0x61E0(t0)
	li v0, -1
	j NextTableEntry
	sh v0, 0x61E4(t0)
	nop
	
@@OnBOLSE:
	li v0, 3
	beq s1, v0, (@@BolseForceStageState)	;if regular state force shield down
	nop
	j NextTableEntry
	nop
@@BolseForceStageState:
	li v0, 0x2
	sw v0, (0x801653D6)
@@BolseSpawnWolfFlags:
	lw v0, orga(gExtraStarWolfsFlag) (gp)
	bne v0, r0, (@@BolseForceCheckPoint)
	li v0, 1
	sw.u v0, (0x8016DB40)
	sw.l v0, (0x8016DB40)	;set wolf team flags to spawnable for game code
	sw.l v0, (0x8016DB44)
	sw.l v0, (0x8016DB48)
	sw.l v0, (0x8016DB4c)
@@BolseForceCheckPoint:
	sw.u v0, (LOC_CHECKPOINT_ALLRANGEMODE_FLAG)
	j NextTableEntry
	sw.l v0, (LOC_CHECKPOINT_ALLRANGEMODE_FLAG)
	nop
	
@@OnVE1:
	lw a0, (LOC_ALIVE_TIMER32)
	bne a0, r0, (@@Exit)
	li v0, 154414.90625		;store pos and section of level to spawn into
	sw v0, (LOC_CHECKPOINT_LEVEL_POS32)
	li v0, 0x498
	sw v0, (LOC_CHECKPOINT_SECTION_ID32)
	lw v0, orga(gMarathonModeFlag) (gp)
	bne v0, r0, (@@MarathonModeVE1)
	lw v0, orga(gBRMVenom1TimeREGULAR) (gp)
	j NextTableEntry
	sw v0, orga(gTimerScoreToDisplay) (gp)
	nop
@@MarathonModeVE1:
	lw v0, orga(gBRMVenom1TimeMARATHON) (gp)
	j NextTableEntry
	sw v0, orga(gTimerScoreToDisplay) (gp)
	nop
	
@@OnTunnels:
	li v0, 1
	lw a0, (LOC_ALIVE_TIMER32)
	bne a0, v0, (@@Exit)	;some check for retries?
	lw a0, orga(gLastTimerVenoms) (gp)
	j NextTableEntry
	sw a0, orga(gTimerScoreToDisplay) (gp)
	nop
	
@@OnVE2:
	lw a0, (LOC_ALIVE_TIMER32)
	bne a0, r0, (@@Exit)
	lw v0, orga(gMarathonModeFlag) (gp)
	bne v0, r0, (@@OnVE2Marathon)	;don't store new timer since marathon mode isn't on
	lw a0, orga(gBRMVenom2TimeREGULAR) (gp)
	sw a0, orga(gTimerScoreToDisplay) (gp)
	j NextTableEntry
	sw a0, orga(gLastTimerVenoms) (gp)
	nop
@@OnVE2Marathon:
	lw a0, orga(gTimerScoreToDisplay) (gp)
	j NextTableEntry
	sw a0, orga(gLastTimerVenoms) (gp)
	nop
@@OnKatina:
	lw a0, (LOC_ALIVE_TIMER32)
	bgt a0, 5, (@@Exit)
	li v0, 1
	sw.u v0, (LOC_CHECKPOINT_ALLRANGEMODE_FLAG)
	j NextTableEntry
	sw.l v0, (LOC_CHECKPOINT_ALLRANGEMODE_FLAG)
	nop
	
@@OnSolar:
	lui t0, 0x8025
	lhu v0, 0xd5f8(t0)
	li v1, 0xF380
	bne v0, v1, (@@Exit)
	li v0, 0x013B
	sw r0, 0xD5F8(t0)
	sw r0, 0xD600(t0)
	sh v0, 0xD604(t0)
	sw r0, 0xD60C(t0)
	li v0, -1
	j NextTableEntry
	sh v0, 0xD618(t0)
	nop
	
@@OnMacBeth:
	lui t0, 0x8025
	lh v0, 0x28ec(t0)
	li v1, 0x47CD
	bne v0, v1, (@@Exit)
	li v0, 0x0151
	sh v0, 0x28E8(t0)
	sh v0, 0x21F4(t0)
	sh v0, 0x29EC(t0)
	li v0, 0x014D
	sw.u v0, (LOC_CHECKPOINT_SECTION_ID32)	;start in checkpoint area
	sw.l v0, (LOC_CHECKPOINT_SECTION_ID32)
	li v0, 73050.0
	j NextTableEntry
	sw.l v0, (LOC_CHECKPOINT_SECTION_ID32 + 0x10)	;LOC_CHECKPOINT_LEVEL_POS32
	nop
	
@@OnSY:
	lui t0, 0x8024
	lh v0, 0x8744(t0)
	li v1, 0x03E8
	bne v0, v1, (@@Exit)
	li v0, 0x013A
	j NextTableEntry
	sh v0, 0x8744(t0)
	nop
	
@@OnAquas:
	lui t0, 0x8024
	lhu v0, 0x9EEC(t0)
	li v1, 0xF676
	bne v0, v1, (@@Exit)
	li v0, 0x13E
	lui t0, 0x8025
	sh v0, 0x9EF8(t0)
	sw r0, 0x9EEC(t0)
	li v0, -1
	j NextTableEntry
	sh v0, 0x9F0C(t0)
	nop
	
@@OnZoness:
	lui t0, 0x8025
	lhu v0, 0x4AD8(t0)
	li v1, 0xEC78
	bne v0, v1, (@@Exit)
	li v0, 0x133
	sh r0, 0x4AD8(t0)
	sh v0, 0x4AE4(t0)
	li v0, 0xF8000000
	sw v0, 0x4AEC(t0)
	li v0, 0x04000000
	sw v0, 0x4AF0(t0)
	li v0, -1
	j NextTableEntry
	sh v0, 0x4AF8(t0)
	nop
	
@@OnSZ:
	/* put this in timerchecks */
	lui t0, 0x8016
	li v0, 0xA
	lh v1, 0x4FD0(t0)	;check if Rob was hit with missile
	bne v0, v1, (@@RobNotHit)
	lw a0, 0x0000(s0)	;LOC_PLAYER_TOTAL_HITS32
	lw a1, orga(gTimerScoreToDisplay) (gp)
	subu a0, a0, a1		;start substracting score
	sw r0, (LOC_PLAYER_HITS32)
	sw a0, orga(gTimerFinalScore) (gp)	;store new score
	sw a0, 0x0000(s0)	;LOC_PLAYER_TOTAL_HITS32
	bgt a0, r0, (@@NoUnderFlow)	;if below zero, set zero to scores since underflowed
	nop
	sw r0, orga(gTimerFinalScore) (gp)
	sw r0, 0x0000(s0)
@@NoUnderFlow:
	sw r0, orga(gTimerActive) (gp)
	sw r0, orga(gTimerScoreToDisplay) (gp)
	/* end timerchecks */
@@RobNotHit:
	la t0, (LOC_ALLRANGEMODE_TIMER)
	lw v0, 0x0000(t0)
	li v1, 0x68
	bne v0, v1, (@@Missile2GroupCheck)
	lui at, 0x8019
	sw r0, 0x1900(at)	;can't remember what this does
	sw r0, 0x0AF4(at)
	li v0, 0x07BE
	j NextTableEntry
	sw v0, 0x0000(t0)	;force new time
	nop	
@@Missile2GroupCheck:
	lw v0, 0x0000(t0)	;check if timer equal, then store new timer if equal
	li v1, 0x0E31
	bne v0, v1, (@@Missile3GroupCheck)
	li v1, 0x0F80
	sw v1, 0x0000(t0)
@@Missile3GroupCheck:
	li v1, 0x1540
	bne v0, v1, (@@Exit)
	li v1, 0x1750
	j NextTableEntry
	sw v1, 0x0000(t0)
	nop
	
@@OnA6:
	lui t0, 0x8025
	lh v0, 0xA1C4(t0)
	li v1, 0x03E8
	bne v0, v1, (@@Exit)
	li v0, 0x012E
	sh v0, 0xA1C4(t0)
	sw r0, 0xA1D0(t0)
	sw r0, 0xA1D4(t0)
	li v0, -1
	j NextTableEntry
	sh v0, 0xA1D8(t0)
	nop


@@EndSceneChecks:
	li v0, 1
	sw v0, orga(gBRMAddToCompletedTimesFlag) (gp)	;gets unset at planet screen for moving to next level
	lw v0, orga(gMarathonModeFlag) (gp)
	bne v0, r0, (@@MarathonModeEndingSceneChecks)
	li v0, 0xB
	beq s1, v0, (@@IfMacBethNotMarathon)
	nop
	j NextTableEntry
	nop
@@MarathonModeEndingSceneChecks:
	li v0, 0x11
	beq s1, v0, (@@IfBolse)
	li v0, 0x13
	beq s1, v0, (@@IfVE2)
	li v0, 0xB
	beq s1, v0, (@@IfMacBeth)
	li v0, 0x3
	beq s1, v0, (@@IfA6)
	nop
	j NextTableEntry
	nop
@@IfBolse:
	jal CheckFoxState2
	li a0, 0x01D0
	li v1, 0xC
	bne v0, v1, (@@Exit)	;if special ending state not equal, end
	nop
	jal DoSoftResetWithFlag
	li a0, 4
	j NextTableEntry
	nop
@@IfVE2:
	lw a0, (LOC_INTRO_OUTRO_TIMER32)
	li v0, 0x500
	bne a0, v0, (@@Exit)
	lw a0, orga(gTunnels2IsDoneFlag) (gp)
	bne a0, v0, (@@Exit)
	nop
	jal DoSoftResetWithFlag
	li a0, 4
	j NextTableEntry
	nop
@@IfMacBeth:
	li v1, 1
	lw v0, orga(gQuickScoreScreensFlag) (gp)
	beq v0, r0, (@@Exit)
	sw v1, orga(gCornFlag) (gp)
	lw a0, (LOC_INTRO_OUTRO_TIMER32)
	li v0, 0x440
	bne a0, v0, (@@Exit)
	nop
	jal DoSoftResetWithFlag
	li a0, 4
	j NextTableEntry
	nop
@@IfMacBethNotMarathon:
	li v1, 1
	j NextTableEntry
	sw v1, orga(gCornFlag) (gp)
	nop
@@IfA6:
	lui at, 0x8018
	li v0, 0x7
	sh v0, 0x58EE(at)	;do soft reset to venom 1 by overwriting op codes in map logic, equivalent to calling DoSoftReset with a0 0x00060007
	li v0, 0x6
	j NextTableEntry
	sh v0, 0x58FE(at)
	nop
	
	
	
@@MapScreenStuff:
	lw v0, orga(gMarathonModeFlag) (gp)
	beq v0, r0, (@@MarathonNotOn)
	lw a0, orga(gCornFlag) (gp)		;randomize what boss to enter on corneria since marathon isn't on
	xori a0, a0, 1
	sw a0, orga(gCornFlag) (gp)
@@MarathonNotOn:
	sw r0, orga(gTimerActive) (gp)
	;sw r0, orga(gBRMAddToCompletedTimesFlag) (gp)
	lw a0, orga(gTimerScoreREGULAR) (gp)
	sw a0, orga(gTimerScoreToDisplay) (gp)
	lw a1, 0x0000(s0)	;total hits
	sw a1, orga(gTimerFinalScore) (gp)
	jal KillLevelStoreFunction
	nop
	lw v0, orga(gBRMAddToCompletedTimesFlag) (gp)
	beq v0, r0, (@@CheckLives)
	lw a0, orga(gBRMAddToCompletedTimes) (gp)
	addiu a0, a0, 1
	sw a0, orga(gBRMAddToCompletedTimes) (gp)	;add to completed times then unset flags
	sw r0, orga(gBRMAddToCompletedTimesFlag) (gp)
@@CheckLives:
	jal @CheckPrevLivesBRM	;check if player retried
	nop
@@IfMarathonModeCheck:
	lw v0, orga(gMarathonModeFlag) (gp)
	beq v0, r0, (@@Exit)
	nop
	;put prevscore logic here and move marathon mode check -- doesn't this work already???
	la t0, gBRMLevelList
	lw a0, orga(gBRMAddToCompletedTimes) (gp)
	addu t0, a0, t0
	lb a0, 0x0000(t0)	;get level based on completed times
	jal StoreLevelID	;store level
	nop
	j NextTableEntry
	nop
	
	
	
	
@@Exit:
	j (NextTableEntry)
	nop
	
	
	/* sub functions */
	
	
@CheckPrevLivesBRM:
	lw a0, orga(gPlayerLivesNotEqualFlagBRM) (gp)
	bne a0, r0, (@@End)
	lw v0, orga(gPreviousLives)(gp)
	lb v1, (LOC_PLAYER_LIVES8)
	sltu v0, v1, v0
	beq v0, r0, (@@End)
	lw v0, orga(gMarathonModeFlag) (gp)
	beq v0, r0, (@@SkipMarathonMode)
	lw a0, orga(gBRMAddToCompletedTimes) (gp)
	addiu a0, a0, -1
	sw a0, orga(gBRMAddToCompletedTimes) (gp)
@@SkipMarathonMode:
	li v0, 1
	sw v0, orga(gPlayerLivesNotEqualFlagBRM)(gp)	;Unsets in TBL_FUNC_InitLevelStartVars
@@End:
	jr ra
	nop
	
@DoTimerChecks:		;do timer last stopped at logic for when stopping and resuming? store into prev stopped timer if stopped, store into active state again after?
	lb v0, (LOC_ENDSCREEN_FLAG8)
	bne v0, r0, (@@DoEndScreenCalcs)
	addu v0, s1, v0
	li v1, 8
	beq v0, v1, (@@DoEndScreenCalcs)
	li v0, 7
	beq s1, v0, (@@DoEndScreenCalcs)
	lw v0, (LOC_HAS_CONTROL_FLAG32)
	beq v0, r0, (@@StopTimer)
	lb v0, (LOC_HAS_CONTROL_FLAG8)
	beq v0, r0, (@@StopTimer)
	lw v0, (LOC_SPECIAL_STATE)
	li v1, 0x64
	beq v0, v1, (@@StopTimer)
	li v0, 1
	sw v0, orga(gTimerActive) (gp)
@@EndCalcs1:
	jr ra
	nop
@@StopTimer:
	jr ra
	sw r0, orga(gTimerActive) (gp)
	nop
	
@@DoEndScreenCalcs:
	lw v0, orga(gTimerActive) (gp)
	beq v0, r0, (@@EndCalcs2)
	; lw v0, (LOC_EXPERT_FLAG32)
	; bne v0, r0, (@@IsExpert)
	lw v1, (LOC_PLAYER_HITS32)
	lw a0, (LOC_PLAYER_TOTAL_HITS32)
	lw a1, orga(gTimerScoreToDisplay) (gp)
	sw a1, orga(gLastTimerVenoms) (gp)
	addu a3, a0, v1
	addu a3, a3, a1		;full totals in a3
	addu a2, a0, a1 	;only add player total hits and boss timer score into a2 as level hits automatically get added by game logic
	;sw a2, (LOC_PLAYER_TOTAL_HITS32)
	sw r0, orga(gTimerActive) (gp)
	li v0, 0x9
	beq s2, v0, (@@OnTunnelsEnd)
	li v0, 0x13
	beq s2, v0, (@@OnSurfaceEnd)
	nop
	sw a2, (LOC_PLAYER_TOTAL_HITS32)
	jr ra
	sw a3, orga(gTimerFinalScore) (gp)
	nop
@@OnTunnelsEnd:
	lw v0, (LOC_SUB_SECTION_FLAG32)
	beq v0, r0, (@@OnTunnelsEndNotTunnels2)	;player not in ending state in tunnels 2
	li v0, 1
	sw v0, orga(gTunnels2IsDoneFlag) (gp)
	;addu a3, a0, v1	;only add player hits and totals
	jr ra
	;sw a3, orga(gTimerFinalScore) (gp)
	nop
@@OnTunnelsEndNotTunnels2:
	lw v0, orga(gMarathonModeFlag) (gp)
	beq v0, r0, (@@EndCalcs2)
	li v0, 1
	sw v0, orga(gTunnels2IsDoneFlag) (gp)
	jr ra
	;sw a3, orga(gTimerFinalScore) (gp)
	nop
@@OnSurfaceEnd:
	lw v0, orga(gTunnels2IsDoneFlag) (gp)
	beq v0, r0, (@@NotDoneTunnels2)
	nop
	;sw a2, (LOC_PLAYER_TOTAL_HITS32) ;not needed?
	sw a3, orga(gTimerFinalScore) (gp)
	jr ra
	nop
@@NotDoneTunnels2:
	; lw v0, orga(gMarathonModeFlag) (gp)
	; bne v0, r0, (@@NotDoneTunnels2Marathon)
	; nop
	jr ra
	;sw a2, orga(gTimerFinalScore) (gp)
	nop
; @@NotDoneTunnels2Marathon:
	; jr ra
	; nop
@@EndCalcs2:
	jr ra
	nop
	
@DoTimerLogic:	;might not work for death state 0 for andross brain checks
	lw v0, orga(gTimerActive) (gp)
	beq v0, r0, (@@EndLogic)
@@DeadStateChecks:
	li v0, 0x4
	beq s1, v0, (@@IsDead)	;checks for if dead or retrying
	li v0, 0x0
	beq s1, v0, (@@IsDead)
	lw a0, orga(gTimerScoreToDisplay) (gp)
	addiu a0, a0, -1
	bltl a0, 0, (@@UnderflowStore)
	or a0, r0, r0
@@UnderflowStore:
	sw a0, orga(gTimerScoreToDisplay) (gp)
	jr ra
	nop
@@IsDead:
	sw r0, orga(gTimerActive) (gp)
	lui t0, 0x8016
	li a0, 0x02000141
	lw v0, 0x4F80(t0)	;check if andross brain is loaded in memory
	beq v0, a0, (@@AndrossBrainChecks)
	li v0, 0x13
	beq s2, v0, (@@OnSurfaceDeadChecks)
	lw a0, orga(gTimerScoreREGULAR) (gp)	;Andross 2 isn't in memory when player died, so get regular planet timer
	jr ra
	sw a0, orga(gTimerScoreToDisplay) (gp)
	nop
@@OnSurfaceDeadChecks:
	lw v0, orga(gMarathonModeFlag) (gp)
	beq v0, r0, (@@EndLogic)	;player doesn't have marathon mode on
	lw a0, orga(gLastTimerVenoms) (gp)
	jr ra
	sw a0, orga(gTimerScoreToDisplay) (gp)
	nop
	
@@AndrossBrainChecks:
	li v1, 0x14
	lh v0, 0x4FCE(t0)
	beq v0, v1, (@@AndrossBrainDeadState1)
	li v1, 0x15
	beq v0, v1, (@@AndrossBrainDeadState2)
	lw a0, orga(gLastTimerVenoms) (gp)
	jr ra
	sw a0, orga(gTimerScoreToDisplay) (gp)
	nop
@@AndrossBrainDeadState1:
	lw a0, orga(gTimerScoreToDisplay) (gp)
	sw a0, orga(gLastAND2Timer) (gp)
	li v0, 1
	jr ra
	sw v0, orga(gTunnels2IsDoneFlag) (gp)
	nop
@@AndrossBrainDeadState2:
	lw a0, orga(gLastAND2Timer) (gp)
	jr ra
	sw a0, orga(gTimerScoreToDisplay) (gp)
	nop
@@EndLogic:
	jr ra
	nop

.endautoregion