		
		
		/* Main randomizer code and loop. Most main functions are here, larger functions are in other .asm files. */

.n64

.org 0x80410000		;main entry to function. Hardcoded to this offset.

.region 0x4000 ;increase this if need more space in the future


@@BeginRando:

	addiu sp, sp, -40 	;On entry, save stuff to stack
	sw ra, 0(sp)
	sw a0, 4(sp)
	sw s0, 8(sp)
	sw s1, 12(sp)
	sw s2, 16(sp)
	sw s3, 20(sp)
	sw s4, 24(sp)
	sw s5, 28(sp)
	sw s6, 32(sp)
	sw s7, 36(sp)
	jal RandoSetups		;init useful values
	nop
	j RandoLoop 	;go and loop in the randomizer
	nop

RandoLoop:		;get new table entry, exit if loaded 0

	lw t8, orga(gRandoSeekEntry) (gp)
	sll t8, t8, 2
	addu at, t8, gp
	lw t8, orga(gRandoTable) (at)		;Load table entry or exit loop if 0.
	beq t8, r0, (ExitRandomizer)
		nop
		jr t8		;go to next entry in table
		nop
	
TBL_FUNC_InitLevelStartVars:		;stores player related info and global values when level begins when certain flags are set

	jal CheckFoxState		;check if Fox is in spawning, intro or alive state, if not end routine
	li t7, 0x1
	beq v0, t7, (@@ContinueChecks)
	li t7, 0x2
	beq v0, t7, (@@ContinueChecks)
	li t7, 0x3
	beq v0, t7, (@@ContinueChecks)
	nop
	j NextTableEntry
	nop
@@ContinueChecks:
		lw v0, (LOC_ALIVE_TIMER32)		;check if second frame of entering level
		li v1, 0x2
		bne v0, v1, (NextTableEntry)
		nop
			sw r0, orga(gPlayerLivesNotEqualFlag)(gp)
			sw r0, orga(gPlayerLivesNotEqualFlagBRM) (gp)
			jal GetLevelID
			nop
			sw v0, orga(gPreviousLevel) (gp)
			jal CheckIfSoftReset
			nop
			beq v0, r0, (@@CheckRandomPlanetsFlag)		;check if did a soft reset, if so restore old states
			lw t7, orga(gRandomPlanetsFlag) (gp)
				jal UnsetFlagDidSoftReset
				nop
				jal LoadPlayerInfoToGame
				nop
				
							
@@CheckRandomPlanetsFlag:		beq t7, r0, (@@Exit)		;don't order planets if random planets is off
								nop
								jal OrderPlanets
								nop
@@Exit:
	j NextTableEntry
	nop
	
TBL_FUNC_InitLevelEndVarsHOOK:		;Hooks into the end screen total hits display once and stores various randomizer values

	lw v0, orga(gEndScreenHookCreated) (gp)
	bne v0, r0, (NextTableEntry)	;end if hook created
	li t0, 0x80083b9c	;place hook is created
	lw a0, orga(gInitLevelEndVarsHookValue) (gp)
	sw a0, 0x0000(t0)
	sw r0, 0x0004(t0)
	li v0, 1
	j NextTableEntry
	sw v0, orga(gEndScreenHookCreated) (gp)
	nop
	
SUB_CustomEndScreenHook:	;level end screen custom function. Runs twice when on-screen. Can't remember all registers that are free to use, going off old code

	addiu sp, sp, -8
	sw ra, 0x0000(sp)
	sw a0, 0x0004(sp)
	lw t6, 0x7908(t6)	;current hits
	sw t6, 0x0004(t1)	;can't remember, I think used for score tally counting down hits
	lui at, 0x8017
	lw t7, 0xe0a4(at) 	;level ID
	sw t7, orga(gPreviousLevel) (gp)
	lw a2, 0xd868(at)	;expert flag
	sw a2, orga(gPreviousExpertFlag) (gp)
	lb a2, 0xdc13(at)	;bomb count
	sw a2, orga(gPreviousBombs) (gp)
	lw v0, 0xd9b8(at)	;completed times
	li t6, gPreviousLevelList
	addu t6, v0, t6
	sb t7, 0x0000(t6)	;store level into gPreviousLevelList based on num planets completed
	lw a2, orga(gBossRushModeFlag) (gp)
	beq a2, r0, (@@SkipBRMCheck)	;skip some boss rush mode exclusive value stores
	sll a1, v0, 2
	addu a1, at, a1
	lw a2, orga(gTimerScoreToDisplay) (gp)
	lui a3, 0x8015
	lw a3, 0x7908(a3)	;grab current hits
	addu a2, a2, a3
	sw a2, 0xd9e0(a1)	;store planet score
@@SkipBRMCheck:
	lw a2, orga(gEnduranceModeFlag) (gp)		;endurance mode checks
	beq a2, r0, (@@SkipEnduranceModeCheck)
	lw a2, orga(gEnduranceModeDonePlanetTimerAddFlag) (gp)
	bne a2, r0, (@@SkipEnduranceModeCheck)
	lw a2, 0xd868(at)	;expert check
	beq a2, r0, (@@Normalscore)
	lw a1, orga(gEnduranceModeCurrentTimer) (gp)
	lw a0, orga(gEnduranceModePlanetTimerYellowExpert) (gp)
	blt a1, a0, (@@ExpertGreenAdd)
	lw a0, orga(gEnduranceModePlanetTimerRedExpert) (gp)
	bgt a1, a0, (@@ExpertRedAdd)
	lw a0, orga(gEnduranceModePlanetTimerYellowExpert) (gp)
	bgt a1, a0, (@@ExpertYellowAdd)
	nop
	b (@@SkipEnduranceModeCheck)
	nop
@@Normalscore:
	lw a1, orga(gEnduranceModeCurrentTimer) (gp)
	lw a0, orga(gEnduranceModePlanetTimerYellowNormal) (gp)
	blt a1, a0, (@@NormalGreenAdd)
	lw a0, orga(gEnduranceModePlanetTimerRedNormal) (gp)
	bgt a1, a0, (@@NormalRedAdd)
	lw a0, orga(gEnduranceModePlanetTimerYellowNormal) (gp)
	bgt a1, a0, (@@NormalYellowAdd)
	nop
	b (@@SkipEnduranceModeCheck)
	nop
@@NormalGreenAdd:
	lw a0, orga(gEnduranceModePlanetTimerNormalScoreGreenAdd) (gp)
	addu a1, a1, a0
	li a0, 1
	sw a0, orga(gEnduranceModeDonePlanetTimerAddFlag) (gp)
	b (@@SkipEnduranceModeCheck)
	sw a1, orga(gEnduranceModeCurrentTimer) (gp)
	nop
@@NormalYellowAdd:
	lw a0, orga(gEnduranceModePlanetTimerNormalScoreYellowAdd) (gp)
	addu a1, a1, a0
	li a0, 1
	sw a0, orga(gEnduranceModeDonePlanetTimerAddFlag) (gp)
	b (@@SkipEnduranceModeCheck)
	sw a1, orga(gEnduranceModeCurrentTimer) (gp)
	nop
@@NormalRedAdd:
	lw a0, orga(gEnduranceModePlanetTimerNormalScoreRedAdd) (gp)
	addu a1, a1, a0
	li a0, 1
	sw a0, orga(gEnduranceModeDonePlanetTimerAddFlag) (gp)
	b (@@SkipEnduranceModeCheck)
	sw a1, orga(gEnduranceModeCurrentTimer) (gp)
	nop
@@ExpertGreenAdd:
	lw a0, orga(gEnduranceModePlanetTimerExpertScoreGreenAdd) (gp)
	addu a1, a1, a0
	li a0, 1
	sw a0, orga(gEnduranceModeDonePlanetTimerAddFlag) (gp)
	b (@@SkipEnduranceModeCheck)
	sw a1, orga(gEnduranceModeCurrentTimer) (gp)
	nop
@@ExpertYellowAdd:
	lw a0, orga(gEnduranceModePlanetTimerExpertScoreYellowAdd) (gp)
	addu a1, a1, a0
	li a0, 1
	sw a0, orga(gEnduranceModeDonePlanetTimerAddFlag) (gp)
	b (@@SkipEnduranceModeCheck)
	sw a1, orga(gEnduranceModeCurrentTimer) (gp)
	nop
@@ExpertRedAdd:
	lw a0, orga(gEnduranceModePlanetTimerExpertScoreRedAdd) (gp)
	addu a1, a1, a0
	li a0, 1
	sw a0, orga(gEnduranceModeDonePlanetTimerAddFlag) (gp)
	b (@@SkipEnduranceModeCheck)
	sw a1, orga(gEnduranceModeCurrentTimer) (gp)
	nop
	; or a3, r0, r0
	; lw a0, orga(gEnduranceModePreviousHits) (gp)
	; lw a1, 0x7908(at)
; @@DoLoopUntilEqual:
	; addiu a0, a0, 1
	; beq a1, a0, (@@DoScoreChecks)
	; addiu a3, a3, 1
	; b (@@DoLoopUntilEqual)
	; nop
; @@DoScoreChecks:
	; jal CheckIfExpert
	; nop
	; beq v0, r0, (@@ScoreNotExpert)
	; lw a2, orga(gEnduranceModeRegularScoreTimesExpert) (gp)
	; mult a3, a2
	; mflo a3
	; addu a1, a3, a0
	; b (@@SkipEnduranceModeCheck)
	; sw a1, orga(gEnduranceModeCurrentTimer) (gp)
	; nop
; @@ScoreNotExpert:
	; lw a2, orga(gEnduranceModeRegularScoreTimesNormal) (gp)
	; mult a3, a2
	; mflo a3
	; addu a1, a3, a0
	; b (@@SkipEnduranceModeCheck)
	; sw a1, orga(gEnduranceModeCurrentTimer) (gp)
	; nop
@@SkipEnduranceModeCheck:
	lui at, 0x8015
	lb a2, 0x7911(at)	;lives
	sw a2, orga(gPreviousLives) (gp)
	lb a2, 0x791b(at)	;lasers
	sw a2, orga(gPreviousLasers) (gp)
	lw a2, 0x7584(at)	;total hits
	sw a2, orga(gPreviousTotalScore) (gp)
	lw at, orga(gQuickScoreScreensFlag) (gp)
	beq at, r0, (@@PlanetSelectionsCheck)
	li a0, 0xE000
	sw a0, (LOC_INTRO_OUTRO_TIMER32)
	sb r0, (LOC_ENDSCREEN_FLAG8)
	jal GetLevelID
	li a0, 0x11		;bolse check
	beq v0, a0, (@@Bolse)
	li a0, 0x1		;meteo check
	beq v0, a0, (@@Meteo)
	nop
	b (@@PlanetSelectionsCheck)
	nop
@@Bolse:
	li a1, 0xC
	jal SetFoxState
	li a0, 0x01D0
	li a1, 0x1
	jal SetFoxState
	li a0, 0x01F8
	b (@@PlanetSelectionsCheck)
	nop
@@Meteo:
	li a1, 0x1
	jal SetFoxState
	li a0, 0x01D0
	b (@@PlanetSelectionsCheck)
	nop
@@PlanetSelectionsCheck:
	lw a2, orga(gEnablePlanetSelections) (gp)
	beq a2, r0, (@@Exit)		;CHANGE THIS LATER check for hardcoded levels below if on, then does reset if x number of times completed planets
	li a2, 0x3
	beq a2, t7, (@@Exit)
	li a2, 0x9
	beq a2, t7, (@@Exit)
	li a2, 0x11
	beq a2, t7, (@@Exit)
	li a2, 0x13
	beq a2, t7, (@@Exit)
	li a2, 0x5
	beq a2, v0, (@@DoReset)
	li a2, 0x6
	beq a2, v0, (@@DoReset)
	nop
	b (@@Exit)
	nop
@@DoReset:
	jal DoSoftResetWithFlag
	li a0, 4
@@Exit:
	lw ra, 0x0000(sp)
	lw a0, 0x0004(sp)
	jr ra
	addiu sp, sp, 8
	nop
	
TBL_FUNC_QuickScoreScreens:		;allows quick end score screens

	lw at, orga(gQuickScoreScreensFlag) (gp)
	beq at, r0, (NextTableEntry)
	nop
	jal CheckMapScreenState
	li a0, 3
	beql a0, v0, (@@CheckIfEndScene)
	sw r0, orga(gDidQuickScoreScreensFlag) (gp)
@@CheckIfEndScene:
	lw at, orga(gDidQuickScoreScreensFlag) (gp)
	bne at, r0, (NextTableEntry)
	nop
	jal CheckFoxState
	li t7, 7
	bne v0, t7, (NextTableEntry)
	li t0, 0x8016D6A0	;displays end score screen
	lw a3, (LOC_INTRO_OUTRO_TIMER32)
	jal GetLevelID
	li v1, 0x7
	beq v0, v1, (@@OnSolar)
	li v1, 0x3
	beq v0, v1, (@@OnA6)
	li v1, 0x12
	beq v0, v1, (@@OnSZ)
	li v1, 0x10
	beq v0, v1, (@@OnKatinaandZoness)
	li v1, 0x8
	beq v0, v1, (@@OnKatinaandZoness)
	li v1, 0x11
	beq v0, v1, (@@OnBolse)
	li v1, 0x2
	beq v0, v1, (@@OnSXandSY)
	li v1, 0x5
	beq v0, v1, (@@OnSXandSY)
	li v1, 0xD
	beq v0, v1, (@@OnAquas)
	li v1, 0xB
	beq v0, v1, (@@OnMacBeth)
	li v1, 0xE
	beq v0, v1, (@@OnFortuna)
	li v1, 0x6
	beq v0, v1, (NextTableEntry)	;skip venoms for now
	li v1, 0x9
	beq v0, v1, (NextTableEntry)
	li v1, 0x13
	beq v0, v1, (NextTableEntry)
	li v1, 1
	sb v1, 0x0000(t0)
	li a1, 4
	jal SetFoxState
	li a0, 0x01D0
	b (NextTableEntry)
	sw v1, orga(gDidQuickScoreScreensFlag) (gp)
	nop
@@OnSolar:
	li v1, 0xA6
	bne v1, a3, (NextTableEntry)
	li v1, 1
	sb v1, 0x0000(t0)
	li a1, 4
	jal SetFoxState
	li a0, 0x01D0
	b (NextTableEntry)
	sw v1, orga(gDidQuickScoreScreensFlag) (gp)
	nop
@@OnMacBeth:
	lw t1, (LOC_FOX_POINTER32)
	beq t1, r0, (NextTableEntry)
	li v1, 0x7
	lw t1, 0x01D0(t1)
	beq t1, v1, (@@MacBethDoQuickEnd)
	li v1, 0xB
	lw t1, 0x01D0(t1)
	beq t1, v1, (@@MacBethDoQuickEnd)
	nop
	b (NextTableEntry)
	nop
@@MacBethDoQuickEnd:
	li v1, 1
	sb v1, 0x0000(t0)
	li a1, 4
	jal SetFoxState
	li a0, 0x01D0
	b (NextTableEntry)
	sw v1, orga(gDidQuickScoreScreensFlag) (gp)
	nop
@@OnFortuna:
	lw t1, (LOC_FOX_POINTER32)
	beq t1, r0, (NextTableEntry)
	li v1, 1
	sb v1, 0x0000(t0)
	li a1, 0x16
	jal SetFoxState
	li a0, 0x01D0
	b (NextTableEntry)
	sw v1, orga(gDidQuickScoreScreensFlag) (gp)
	nop
	
@@OnSXandSY:
	lw t1, (LOC_FOX_POINTER32)
	beq t1, r0, (NextTableEntry)
	li v1, 1
	sb v1, 0x0000(t0)
	li a1, 0x2
	jal SetFoxState
	li a0, 0x01D0
	b (NextTableEntry)
	sw v1, orga(gDidQuickScoreScreensFlag) (gp)
	nop
@@OnBolse:
	lw t1, (LOC_FOX_POINTER32)
	beq t1, r0, (NextTableEntry)
	li v1, 1
	sb v1, 0x0000(t0)
	li a1, 0x1
	jal SetFoxState
	li a0, 0x01D0
	b (NextTableEntry)
	sw v1, orga(gDidQuickScoreScreensFlag) (gp)
	nop
@@OnKatinaandZoness:
	lw t1, (LOC_FOX_POINTER32)
	beq t1, r0, (NextTableEntry)
	li v1, 1
	sb v1, 0x0000(t0)
	li a1, 0x3
	jal SetFoxState
	li a0, 0x01D0
	b (NextTableEntry)
	sw v1, orga(gDidQuickScoreScreensFlag) (gp)
	nop
@@OnAquas:
	lw t1, (LOC_FOX_POINTER32)
	beq t1, r0, (NextTableEntry)
	li v1, 1
	sb v1, 0x0000(t0)
	li a1, 0xA
	jal SetFoxState
	li a0, 0x01D0
	b (NextTableEntry)
	sw v1, orga(gDidQuickScoreScreensFlag) (gp)
	nop
@@OnSZ:
	lw t1, (LOC_FOX_POINTER32)
	beq t1, r0, (NextTableEntry)
	li v1, 1
	sb v1, 0x0000(t0)
	li a1, 0xB
	jal SetFoxState
	li a0, 0x01D0
	b (NextTableEntry)
	sw v1, orga(gDidQuickScoreScreensFlag) (gp)
	nop
@@OnA6:
	lw t1, (LOC_FOX_POINTER32)
	beq t1, r0, (NextTableEntry)
	li v1, 1
	sb v1, 0x0000(t0)
	li a1, 0x1
	jal SetFoxState
	li a0, 0x01D0
	b (NextTableEntry)
	sw v1, orga(gDidQuickScoreScreensFlag) (gp)
	nop
	

TBL_FUNC_ChoosePlanets:		;allows the player to choose planets with L button at the planet screen.

	lw at, orga(gEnablePlanetSelections) (gp)
	beq at, r0, (NextTableEntry)
	nop
	jal CheckMapScreenState
	li v1, 3
	bne v0, v1, (NextTableEntry)
	lui at, 0x801C
	lw a1, 0x37c4(at)	;map cursor
	jal CheckButtons
	li a0, 0
	or t7, v0, r0
	or t6, v1, r0
	li a0, BUTTON_D_PAD_DOWN16
	bne a0, t7, (@@CheckIfUp)
	li.u a0, 0x00060007
	jal DoSoftResetWithFlag
	li.l a0, 0x00060007
	b (NextTableEntry)
	nop
@@CheckIfUp:
	li a0, BUTTON_D_PAD_UP16
	bne a0, t7, (@@CheckIfLeft)
	li.u a0, 0x00130007
	jal DoSoftResetWithFlag
	li.l a0, 0x00130007
	b (NextTableEntry)
	nop
@@CheckIfLeft:
	lw v0, orga(gSpecialStageFlag) (gp)
	beq v0, r0, (@@CheckIfL)
	li a0, BUTTON_D_PAD_LEFT16
	bne a0, t7, (@@CheckIfL)
	li v0, 1
	sw v0, orga(gSpecialStageChoosePlanetsFlag) (gp)
	li.u a0, 0x000A0007
	jal DoSoftResetWithFlag
	li.l a0, 0x000A0007
@@CheckIfL:
	li a2, 0x437f
	li a0, BUTTON_L16
	bnel a0, t7, (@@ButtonPress)
	sw r0, 0x37d4(at)	;hide map name
	li a3, 0x42b0
	lui t0, 0x801A
	sh a3, 0xF822(t0)	;overrides position of map text
	
@@ButtonPress:
	sh a2, 0x48dc(at)	;puts map name on-screen 
	li v1, 1
	beql a0, t6, (@@OrderCursor)
	sw v1, 0x37d4(at)	;display map name
	b (NextTableEntry)
	nop
@@OrderCursor:
	li v1, 0x9
	beq a1, v1, (@@P1)
	li v1, 0x0
	beq a1, v1, (@@P2)
	li v1, 0xC
	beq a1, v1, (@@P3)
	li v1, 0x4
	beq a1, v1, (@@P4)
	li v1, 0xA
	beq a1, v1, (@@P5)
	li v1, 0x2
	beq a1, v1, (@@P6)
	li v1, 0x6
	beq a1, v1, (@@P7)
	li v1, 0xE
	beq a1, v1, (@@P8)
	li v1, 0x7
	beq a1, v1, (@@P9)
	li v1, 0x5
	beq a1, v1, (@@P10)
	li v1, 0xB
	beq a1, v1, (@@P11)
	li v1, 0x8
	beq a1, v1, (@@P12)
	li v1, 0x3
	beq a1, v1, (@@P13)
	li v1, 0x9
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P1:
	li v1, 0x0
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P2:li v1, 0xC
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P3:li v1, 0x4
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P4:li v1, 0xA
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P5:li v1, 0x2
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P6:li v1, 0x6
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P7:li v1, 0xE
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P8:li v1, 0x7
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P9:li v1, 0x5
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P10:li v1, 0xB
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P11:li v1, 0x8
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P12:li v1, 0x3
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop
@@P13:li v1, 0x1
	b (NextTableEntry)
	sw v1, 0x37c4(at)
	nop

TBL_FUNC_RandomPlanets:		;randomizes at planet screen only, then chooses actual level right before entering

	lw at, orga(gRandomPlanetsFlag) (gp)
	beq at, r0, (NextTableEntry)	;end if random planets isn't on
		nop
		jal CheckMapScreenState
		li t7, 0x3
		or t6, v0, r0 				;move result to t6.
		bne v0, t7, (@@Continue3)	;check if in planet screen
			li t7, 0x5	
			jal KillLevelStoreFunction
			nop
			jal CheckPrevLives
			nop
			li v1, 0x1
			beq v0, v1, (@@CheckCompletedTimes)		;if lives are equal, jump and continue, otherwise set prev level and exit
				lw a0, orga(gPreviousLevel) (gp)
				jal StoreLevelID
				nop
				b (NextTableEntry)
				sw r0, orga(gRandomPlanetsDoneFlag) (gp)	;unset gRandomPlanetsDoneFlag since the player retried
				nop
				
@@CheckCompletedTimes:
				lw v1, (LOC_NUM_PLANETS_COMPLETED32)
				sltiu v0, v1, 0x0005
				bne v0, r0, (@@Continue2)
					lw v0, (LOC_POWER_ON_TIMER32)
					andi v1, v0, 0x0001
					beql v1, r0, (@@A6orBolse)
						lw a0, orga(gLevelA6) (gp)
@@A6orBolse:
						jal StoreLevelID
						lw a0, orga(gLevelBO) (gp)
						li v0, 0x1
						b (NextTableEntry)
						sw v0, orga(gRandomPlanetsDoneFlag) (gp)	;set gRandomPlanetsDoneFlag to true
						nop
@@Continue2:
					jal SeekToNewLevel
					nop
					lw at, orga(gAllowSamePlanetsFlag) (gp)
					bne at, r0, (@@Continue3)
					nop
					jal CheckSameLevels
					nop
@@Continue3:						 ;check if in planet screen select menu
			bne t6, t7, (@@Exit)
				nop
				jal SeekToNewLevel
				nop
				lw at, orga(gAllowSamePlanetsFlag) (gp)
				bne at, r0, (@@Exit)
				nop
				jal CheckSameLevels
				nop
; @@Continue4:
	; jal CheckIfMainMenu
	; li t7, 0x3E8
	; bne v0, t7, (NextTableEntry)
		; nop
		; jal SeekToNewLevel
		; nop
@@Exit:
	j NextTableEntry
	nop
	
TBL_FUNC_RandomItems:		;random item spawns

	/* Item ID defines and locations */
		@ID_LASER equ 0x142
		@LOC_LASER1 equ 0x800cb428
		@LOC_LASER2 equ 0x800cb42C
		@LOC_LASER3 equ 0x800cb430
		@LOC_LASER4 equ 0x800cb434
		@LOC_LASER5 equ 0x800cb450
		@ID_SILVER equ 0x144
		@LOC_TABLE_START_AND_SILVER1 equ 0x800cb408
		@LOC_SILVER2 equ 0x800cb40C
		@LOC_SILVER3 equ 0x800cb410
		@LOC_SILVER4 equ 0x800cb414
		@LOC_SILVER5 equ 0x800cb458
		@LOC_SILVER6 equ 0x800cb45C
		@ID_STAR equ 0x145
		@LOC_STAR_AND_END equ 0x800cb468
		@ID_BOMB equ 0x147
		@LOC_BOMB1 equ 0x800cb418
		@LOC_BOMB2 equ 0x800cb41C
		@LOC_BOMB3 equ 0x800cb420
		@LOC_BOMB4 equ 0x800cb424
		@LOC_BOMB5 equ 0x800cb454
		@ID_LIFE equ 0x14F
		@LOC_LIFE equ 0x800cb438
		@ID_GOLD equ 0x150
		@LOC_GOLD1 equ 0x800cb43C
		@LOC_GOLD2 equ 0x800cb440
		@LOC_GOLD3 equ 0x800cb448
		@LOC_GOLD4 equ 0x800cb44C
		@ID_REPAIR equ 0x151
		@LOC_REPAIR equ 0x800cb460
		@LOC_ZERO equ 0x800cb464	;was empty for some reason
		@RESTORE_HOOK equ 0x86020010 ;for restoring from custom hook lh v0, $0010(s0)
		@LOC_ITEM_HOOK equ 0x8005e588
		

	jal CheckIfMainMenu
	li t7, 0x3E8
	beq t7, v0, (@@IfMainMenu)
		lw at, orga(gRandomItemDropsFlag) (gp)
		beq at, r0, (NextTableEntry)	;next table entry if the user doesn't have random items on
			nop
			jal SeekRandomItem
			nop
			li v1, -1
			beq v0, v1, (@@LoadFirstValidID)		;begin loop store if valid id
				nop
				jal LoadRandomItem
				nop
				li v1, -1
				beq v0, v1, (@@LoadFirstValidID)
				nop
					b @@StartLoop
					nop
			
@@LoadFirstValidID:	lw v0, orga(gRandomItemDropsTable) (gp) 	;load from first item entry since it was invalid
@@StartLoop:		li t0, @LOC_TABLE_START_AND_SILVER1
					li t1, @LOC_STAR_AND_END
@@DoStoreLoop:		sw v0, 0x0000(t0)
					beq t0, t1, (NextTableEntry)	;fill item table entries and exit when filled
						nop
						b (@@DoStoreLoop)
						addiu t0, t0, 0x0004
						nop

@@IfMainMenu:
	bne at, r0, (@@IfRandomItemIsOn)	;if in main menu, and random items is on, go to branch and only create hook in menu
		li v0, @ID_LASER	;restore items and custom call if at main menu and random items is off
		li.u at, (@LOC_TABLE_START_AND_SILVER1)
		sw.l v0, (@LOC_LASER1)
		sw.l v0, (@LOC_LASER2)
		sw.l v0, (@LOC_LASER3)
		sw.l v0, (@LOC_LASER4)
		sw.l v0, (@LOC_LASER5)
		li v0, @ID_SILVER
		sw.l v0, (@LOC_TABLE_START_AND_SILVER1)
		sw.l v0, (@LOC_SILVER2)
		sw.l v0, (@LOC_SILVER3)
		sw.l v0, (@LOC_SILVER4)
		sw.l v0, (@LOC_SILVER5)
		sw.l v0, (@LOC_SILVER6)
		li v0, @ID_STAR
		sw.l v0, (@LOC_STAR_AND_END)
		li v0, @ID_BOMB
		sw.l v0, (@LOC_BOMB1)
		sw.l v0, (@LOC_BOMB2)
		sw.l v0, (@LOC_BOMB3)
		sw.l v0, (@LOC_BOMB4)
		sw.l v0, (@LOC_BOMB5)
		li v0, @ID_LIFE
		sw.l v0, (@LOC_LIFE)
		li v0, @ID_GOLD
		sw.l v0, (@LOC_GOLD1)
		sw.l v0, (@LOC_GOLD2)
		sw.l v0, (@LOC_GOLD3)
		sw.l v0, (@LOC_GOLD4)
		li v0, @ID_REPAIR
		sw.l v0, (@LOC_REPAIR)
		sw.l r0, (@LOC_ZERO)
		li v0, @RESTORE_HOOK
		sw.u v0, @LOC_ITEM_HOOK
		j (NextTableEntry)
		sw.l v0, @LOC_ITEM_HOOK
		nop
		
@@IfRandomItemIsOn:		;create in-game hook for level item spawn checks

	lw v0, orga(gItemDropFunctionHookValue) (gp)
	sw.u v0, (@LOC_ITEM_HOOK)
	j NextTableEntry
	sw.l v0, (@LOC_ITEM_HOOK)
	nop
	
	
SUB_CustomItemDropFunction:

	/* custom call sent to game code to excute. Every map object about to load on-screen gets checked for a valid item ID. If it's an item, it grabs a new item from gRandomItemDropsTable. Hook is at 0x8005e588 */
	
	lh v0, 0x0010(s0) ;load item ID from current level data pointer
	li t3, gRandomItemDropsTable ;load wherever table is
@@ItemCheckLoop:
	lw t4, 0x0000(t3)		;load new item in t4 for checks
	ble t4, r0, (@@End)		;end if item loaded is zero or -1
	nop
	beq t4, v0, (@@StoreNewItem)
	addiu t3, t3, 0x0004 ;move table address by 4
	b @@ItemCheckLoop
	nop
@@StoreNewItem:		;gets current seek ID, loads new item and stores in map data
	lw t3,  orga(gRandomItemDropsSeek) (gp)
	sll t3, t3, 2
	addu t3, t3, gp
	lw t3, orga(gRandomItemDropsTable)(t3)
	sh t3, 0x0010(s0)
@@End:
	lui at, 0x8017	;restore value on return since ble t4, r0, (@@End) uses AT
	jr ra
	lh v0, 0x0010(s0)
	nop
	
TBL_FUNC_RandomDeathItem:		;Randomizes death item in main menu, and map screen. Overrides certain op codes depending on item. Restores item op codes when in main menu if this option is off.

	/* Item ID defines */
	@ID_CHECKPOINT equ 0x143
	@ID_BLUEWARP equ 0x146


	lw v0, orga(gRandomDeathItemFlag)(gp)
	beq v0, r0, (@@MainMenuFixOpCodes)
	nop
		jal CheckIfMainMenu
		li t0, 0x3E8
		beql v0, t0, (@@CycleStates)
		sw r0, orga(gRandomDeathItemInGameFlag) (gp)
			jal CheckMapScreenState
			li t0, 3
			beq v0, t0, (@@CycleStates)
			li t0, 6
				beq v0, t0, (@@CycleStates)
				nop
@@Ingamechecks:
					jal CheckFoxState		;check if in end scene, if so unset flag and cycle states
					li t1, 0x7
					beql v0, t1, (@@CycleStates) ;(@@ContinueInGameChecks1)
					sw r0, orga(gRandomDeathItemInGameFlag) (gp)
@@ContinueInGameChecks1:
						lw v0, (LOC_ALIVE_TIMER32)
						li v1, 0x3
						beq v0, v1, (@@FixOpCodes)	;check if third frame of entering level, if so restore other op codes
						li v1, 0x2
						beq v0, v1, (@@CheckIfFoxAlive)	;check if second frame of entering level
						nop
								
@@EndInGameChecks:
	j (NextTableEntry)
	nop
@@CheckIfFoxAlive:
	jal CheckFoxState		;check if Fox is alive or in intro state. If not, don't set in-game flag and end.
	li t0, 0x2
	beq t0, v0, (@@SetFlagAndEnd)
	li t0, 0x3
	beq t0, v0, (@@SetFlagAndEnd)
	li t0, 0x5
	beq t0, v0, (@@SetFlagAndEnd)
	nop
	j (NextTableEntry)
	nop
@@SetFlagAndEnd:
	jal @@SetDoneInGameFlag
	nop
	j (NextTableEntry)
	nop
@@CycleStates:
	lw a0, orga(gRandomDeathItemCycle)(gp)
	addiu a0, a0, 1
	sltiu v1, a0, 9
	beql v1, r0, (@@ResetSeek)	;if 9 or over, take delay slot to reset seek
	or a0, r0, r0
@@ResetSeek:
	sw a0, orga(gRandomDeathItemCycle)(gp)
	lw v0, orga(gRandomDeathItemInGameFlag) (gp)
	bne v0, r0, (@@End)		;if in-game flag set, end routine
	sll a1, a0, 2
	addu t9, gp, a1
	lw a2, orga(gRandomDeathItemTable)(t9)
	sw a2, orga(gRandomDeathItemCurrentItem) (gp)
	jal GetLevelID
	lw t1, orga(gRandomItemDropsFlag) (gp)	;random item flag in t1
	beq v0, r0, (@@CorneriaChecks)
	li v1, 0x1
	beq v0, v1, (@@MeteoChecks)
	li v1, 0x2
	beq v0, v1, (@@MeteoChecks) ;(@@SEXChecks)	Sector X and Meteo are the same
	li v1, 0x3
	beq v0, v1, (@@CorneriaChecks) ;(@@A6Checks) Area 6 is the same as Corneria
	li v1, 0x5
	beq v0, v1, (@@CorneriaChecks) ;(@@SYChecks)
	li v1, 0x6
	beq v0, v1, (@@VE1Checks)
	li v1, 0x7
	beq v0, v1, (@@CorneriaChecks) ;(@@SolarChecks)
	li v1, 0x8
	beq v0, v1, (@@ZonessChecks)
	li v1, 0x9
	beq v0, v1, (@@TunnelsChecks)
	li v1, 0xA
	beq v0, v1, (@@TrainingChecks)	;to do
	li v1, 0xB
	beq v0, v1, (@@MacBethChecks)
	li v1, 0xC
	beq v0, v1, (@@MacBethChecks) ;(@@TitChecks)
	li v1, 0xD
	beq v0, v1, (@@AquasChecks)
	li v1, 0xE
	beq v0, v1, (@@FortunaChecks)
	li v1, 0x10
	beq v0, v1, (@@FortunaChecks) ;(@@KatinaChecks)
	li v1, 0x11
	beq v0, v1, (@@FortunaChecks) ;(@@BolseChecks)
	li v1, 0x12
	beq v0, v1, (@@FortunaChecks) ;(@@SZChecks)
	li v1, 0x13
	beq v0, v1, (@@VESurfaceChecks)
	nop
	j (NextTableEntry)
	nop
	
@@CorneriaChecks:
	; jal @@SetDoneInGameFlag		;when entering, set done in-game flag.
	; nop
	beq t1, r0, (@@CornNormal)		;checks for if random items is on or not, t1 = gRandomItemDropsFlag
	li v1, @ID_BLUEWARP		;if blue warp, get new item since it's not valid on this level
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER	;delay slot is new death item.
	b (@@ItemChecks)
	nop
	
@@CornNormal:
	li v1, @ID_STAR		;stars are rare enough to omit, so get new item
	beql v1, a2, (@@SortItem)	;delay slot is new item
	li a2, @ID_BOMB
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	li v1, @ID_LIFE		;lifes are rare enough to omit, so get new item
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	b (@@ItemChecks)
	nop
	
@@MeteoChecks:
	; jal @@SetDoneInGameFlag	
	; nop
	beq t1, r0, (@@MeteoNormal)	;if random items is on, no need to cycle to a new item as all items are in this level
	nop
	b (@@ItemChecks)
	nop
	
@@MeteoNormal:
	li v1, @ID_STAR		;stars are rare enough to omit, so get new item
	beql v1, a2, (@@SortItem)
	li a2, @ID_BOMB
	li v1, @ID_LIFE		;lifes are rare enough to omit, so get new item
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	b (@@ItemChecks)
	nop
	
@@MacBethChecks:
	; jal @@SetDoneInGameFlag	
	; nop
	beq t1, r0, (@@MacBethNormal)
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	b (@@ItemChecks)
	nop
	
@@MacBethNormal:
	li v1, @ID_STAR
	beql v1, a2, (@@SortItem)
	li a2, @ID_BOMB
	li v1, @ID_LIFE
	beql v1, a2, (@@SortItem)
	li a2, @ID_GOLD
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	li v1, @ID_LASER
	beql v1, a2, (@@SortItem)
	li a2, @ID_CHECKPOINT
	li v1, @ID_REPAIR
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	b (@@ItemChecks)
	nop
	
@@AquasChecks:
	; jal @@SetDoneInGameFlag	
	; nop
	beq t1, r0, (@@AquasNormal)
	nop
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	b (@@ItemChecks)
	nop
	
@@AquasNormal:
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	li v1, @ID_LIFE
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	li v1, @ID_BOMB
	beql v1, a2, (@@SortItem)
	li a2, @ID_GOLD
	b (@@ItemChecks)
	nop
	
@@ZonessChecks:
	; jal @@SetDoneInGameFlag		
	; nop
	beq t1, r0, (@@ZonessNormal)		
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	li v1, @ID_BOMB
	beql v1, a2, (@@SortItem)
	li a2, @ID_STAR
	b (@@ItemChecks)
	nop
	
@@ZonessNormal:
	li v1, @ID_STAR
	beql v1, a2, (@@SortItem)
	li a2, @ID_GOLD
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	li v1, @ID_LIFE
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	li v1, @ID_BOMB
	beql v1, a2, (@@SortItem)
	li a2, @ID_CHECKPOINT
	b (@@ItemChecks)
	nop
	
@@FortunaChecks:
	; jal @@SetDoneInGameFlag	
	; nop
	beq t1, r0, (@@FortunaNormal)
	nop
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	li v1, @ID_CHECKPOINT
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	b (@@ItemChecks)
	nop
	
@@FortunaNormal:
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	li v1, @ID_CHECKPOINT
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	li v1, @ID_LIFE
	beql v1, a2, (@@SortItem)
	li a2, @ID_GOLD
	b (@@ItemChecks)
	nop
	
@@VE1Checks:
	; jal @@SetDoneInGameFlag	
	; nop
	beq t1, r0, (@@VE1Normal)
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	b (@@ItemChecks)
	nop
	
@@VE1Normal:
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	li v1, @ID_LIFE
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	b (@@ItemChecks)
	nop
	
	
@@TunnelsChecks:
	; jal @@SetDoneInGameFlag	
	; nop
	lw v1, (LOC_SUB_SECTION_FLAG32)		;load flag if on tunnels 2
	beq t1, r0, (@@TunnelsNotRandomItems)
	nop
	beq v1, r0, (@@Tunnels2)	;check if on tunnels 2
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_GOLD
	li v1, @ID_CHECKPOINT
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	b (@@ItemChecks)
	nop
	
@@TunnelsNotRandomItems:
	beq v1, r0, (@@Tunnels2)	;check if on tunnels 2
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_GOLD
	li v1, @ID_LIFE
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	li v1, @ID_CHECKPOINT
	beql v1, a2, (@@SortItem)
	li a2, @ID_BOMB
	b (@@ItemChecks)
	nop
	
@@Tunnels2:
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_GOLD
	li v1, @ID_CHECKPOINT
	beql v1, a2, (@@SortItem)
	li a2, @ID_BOMB
	b (@@ItemChecks)
	nop
	
@@TrainingChecks:
	; jal @@SetDoneInGameFlag	
	; nop
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_LASER
	li v1, @ID_CHECKPOINT
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	b (@@ItemChecks)
	nop
	
@@VESurfaceChecks:
	; jal @@SetDoneInGameFlag	
	; nop
	beq t1, r0, (@@VESurfaceNormal)
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	li v1, @ID_CHECKPOINT
	beql v1, a2, (@@SortItem)
	li a2, @ID_BOMB
	b (@@ItemChecks)
	nop
	
@@VESurfaceNormal:
	li v1, @ID_BLUEWARP
	beql v1, a2, (@@SortItem)
	li a2, @ID_SILVER
	li v1, @ID_CHECKPOINT
	beql v1, a2, (@@SortItem)
	li a2, @ID_BOMB
	li v1, @ID_GOLD
	beql v1, a2, (@@SortItem)
	li a2, @ID_STAR
	li v1, @ID_LIFE
	beql v1, a2, (@@SortItem)
	li a2, @ID_REPAIR
	b (@@ItemChecks)
	nop
	
	
@@SortItem:
	b (@@ItemChecks)
	sw a2, orga(gRandomDeathItemCurrentItem) (gp)
	nop

@@SetDoneInGameFlag:		;simply sets done in-game flag.
	li v0, 1
	jr ra
	sw v0, orga(gRandomDeathItemInGameFlag) (gp)
	nop
	
@@ItemChecks:		;Checks if item then overwrites op codes from in-game code
	lui t3, 0x8006
	li v1, @ID_LASER
	bne v1, a2, (@@IfCheckPoint)
	li v1, 0x240F0004
	sw v1, 0x38f4(t3)
	li v1, 0x8CE80000
	sw v1, 0x3900(t3)
	li v1, 0xAD0F01C8
	sw v1, 0x3918(t3)
@@IfCheckPoint:
	li v1, @ID_CHECKPOINT
	bne v1, a2, (@@IfSilverRing)
	li v1, 0x24030004
	sw v1, 0x46bc(t3)
	li v1, 0xA200004C
	sw v1, 0x46c0(t3)
	li v1, 0x080191F1
	sw v1, 0x46c4(t3)
	li v1, 0xAC4301C8
	sw v1, 0x46c8(t3)
@@IfSilverRing:
	li v1, @ID_SILVER
	bne v1, a2, (@@IfStar)
	li v1, 0x240D0004
	sw v1, 0x3c6c(t3)
	li v1, 0xAC4D01C8
	sw v1, 0x3c70(t3)
@@IfStar:
	li v1, @ID_STAR
	bne v1, a2, (@@IfBlueWarp)
	li v1, 0x240F0004
	sw v1, 0x3e44(t3)
	li v1, 0xAC4F01C8
	sw v1, 0x3e48(t3)
@@IfBlueWarp:
	li v1, @ID_BLUEWARP
	bne v1, a2, (@@IfBomb)
	li v1, 0x4
	sh v1, 0x43ae(t3)
	li v1, 0x1C8
	sh v1, 0x43b6(t3)
@@IfBomb:
	li v1, @ID_BOMB
	bne v1, a2, (@@IfLife)
	li v1, 0x240D0004
	sw v1, 0x3824(t3)
	li v1, 0xADCD01C8
	sw v1, 0x3828(t3)
@@IfLife:
	li v1, @ID_LIFE
	bne v1, a2, (@@IfGoldRing)
	li v1, 0x3C018017
	sw v1, 0x3720(t3)
	li v1, 0x8C21E0F0
	sw v1, 0x3724(t3)
	li v1, 0x240C0004
	sw v1, 0x3744(t3)
	li v1, 0xAC2C01C8
	sw v1, 0x3748(t3)
@@IfGoldRing:
	li v1, @ID_GOLD
	bne v1, a2, (@@IfWingRepair)
	li v1, 0x24180004
	sw v1, 0x3dec(t3)
	li v1, 0xAC5801C8
	sw v1, 0x3df0(t3)
@@IfWingRepair:
	li v1, @ID_REPAIR
	bne v1, a2, (@@EndItemChecks)
	li v1, 0x4
	sb v1, 0x361b(t3)
	li v1, 0xAC5901C8
	sw v1, 0x362c(t3)
@@EndItemChecks:
	j (NextTableEntry)
	nop
	
	
@@FixOpCodes:		;if death item is a given item, skip restoring game op codes for that item.
	lw a2, orga(gRandomDeathItemCurrentItem) (gp)
	li v1, @ID_LASER
	beq v1, a2, (@@IfCheckPointFix)
	lui t3, 0x8006
	li v1, 0xAC4F0000
	sw v1, 0x38f4(t3)
	li v1, 0x24080002
	sw v1, 0x3900(t3)
	li v1, 0x54200004
	sw v1, 0x3918(t3)
@@IfCheckPointFix:
	li v1, @ID_CHECKPOINT
	beq v1, a2, (@@IfSilverRingFix)
	li v1, 0x8609004E
	sw v1, 0x46bc(t3)
	li v1, 0x3C068017
	sw v1, 0x46c0(t3)
	li v1, 0x24C6E0F0
	sw v1, 0x46c4(t3)
	li v1, 0x00095080
	sw v1, 0x46c8(t3)
@@IfSilverRingFix:
	li v1, @ID_SILVER
	beq v1, a2, (@@IfStarFix)
	li v1, 0x258D0020
	sw v1, 0x3c6c(t3)
	li v1, 0xAC4D026C
	sw v1, 0x3c70(t3)
@@IfStarFix:
	li v1, @ID_STAR
	beq v1, a2, (@@IfBlueWarpFix)
	li v1, 0x25CF0080
	sw v1, 0x3e44(t3)
	li v1, 0xAC4F026C
	sw v1, 0x3e48(t3)
@@IfBlueWarpFix:
	li v1, @ID_BLUEWARP
	beq v1, a2, (@@IfBombFix)
	li v1, 0x64
	sh v1, 0x43ae(t3)
	li v1, 0x27C
	sh v1, 0x43b6(t3)
@@IfBombFix:
	li v1, @ID_BOMB
	beq v1, a2, (@@IfLifeFix)
	li v1, 0x258D0001
	sw v1, 0x3824(t3)
	li v1, 0xAC4D0000
	sw v1, 0x3828(t3)
@@IfLifeFix:
	li v1, @ID_LIFE
	beq v1, a2, (@@IfGoldRingFix)
	li v1, 0x2401000A
	sw v1, 0x3720(t3)
	li v1, 0x5321000A
	sw v1, 0x3724(t3)
	li v1, 0x256C0001
	sw v1, 0x3744(t3)
	li v1, 0xA44C0000
	sw v1, 0x3748(t3)
@@IfGoldRingFix:
	li v1, @ID_GOLD
	beq v1, a2, (@@IfWingRepair)
	li v1, 0x25F80020
	sw v1, 0x3dec(t3)
	li v1, 0xAC58026C
	sw v1, 0x3df0(t3)
@@IfWingRepairFix:
	li v1, @ID_REPAIR
	beq v1, a2, (@@EndFixOpCodes)
	li v1, 0x2
	sb v1, 0x361b(t3)
	li v1, 0x10200006
	sw v1, 0x362c(t3)
@@EndFixOpCodes:
	j (NextTableEntry)
	nop
	

@@MainMenuFixOpCodes:		;fixes all op codes when at main menu
	jal CheckIfMainMenu
	li t0, 0x3E8
	bne v0, t0, (@@End)
	lui t3, 0x8006
	li v1, 0xAC4F0000
	sw v1, 0x38f4(t3)
	li v1, 0x24080002
	sw v1, 0x3900(t3)
	li v1, 0x54200004
	sw v1, 0x3918(t3)
	li v1, 0x8609004E
	sw v1, 0x46bc(t3)
	li v1, 0x3C068017
	sw v1, 0x46c0(t3)
	li v1, 0x24C6E0F0
	sw v1, 0x46c4(t3)
	li v1, 0x00095080
	sw v1, 0x46c8(t3)
	li v1, 0x258D0020
	sw v1, 0x3c6c(t3)
	li v1, 0xAC4D026C
	sw v1, 0x3c70(t3)
	li v1, 0x25CF0080
	sw v1, 0x3e44(t3)
	li v1, 0xAC4F026C
	sw v1, 0x3e48(t3)
	li v1, 0x64
	sh v1, 0x43ae(t3)
	li v1, 0x27C
	sh v1, 0x43b6(t3)
	li v1, 0x258D0001
	sw v1, 0x3824(t3)
	li v1, 0xAC4D0000
	sw v1, 0x3828(t3)
	li v1, 0x2401000A
	sw v1, 0x3720(t3)
	li v1, 0x5321000A
	sw v1, 0x3724(t3)
	li v1, 0x256C0001
	sw v1, 0x3744(t3)
	li v1, 0xA44C0000
	sw v1, 0x3748(t3)
	li v1, 0x25F80020
	sw v1, 0x3dec(t3)
	li v1, 0xAC58026C
	sw v1, 0x3df0(t3)
	li v1, 0x2
	sb v1, 0x361b(t3)
	li v1, 0x10200006
	sw v1, 0x362c(t3)
@@End:
	j (NextTableEntry)
	nop
	
	
TBL_FUNC_RainbowBombs:		;overrides the color entry for bomb color per frame

	lw v0, orga(gRainbowBombsFlag) (gp)
	beq v0, r0, (@@Restore)
	lw v0, orga(gRainbowBombsHookValue) (gp)
	sw v0, (0x80035dd4)
	lw v0, orga(gRainbowBombColorSeek) (gp)
	addiu v0, v0, 1
	sw v0, orga(gRainbowBombColorSeek) (gp)
	blt v0, 46, (@@End)	;46 valid entries, if over reset it
	nop
	sw r0, orga(gRainbowBombColorSeek) (gp)
@@End:
	j NextTableEntry
	nop
@@Restore:
	li v0, 0x2401FF00 ;addiu at, r0, 0xff00
	sw.u v0, (0x80035dd4)
	j NextTableEntry
	sw.l v0, (0x80035dd4)
	nop
	
SUB_RainbowBombs:		;hook into original bomb color and load from table instead

	lw at, orga(gRainbowBombColorSeek) (gp)
	sll at, at, 2
	addu at, at, gp
	jr ra
	lw at, orga(gRainbowBombColorTable) (at)
	nop
	
TBL_FUNC_RandomPortraits:		;creates a call to game code based on level ID. There's very small possibility that it may grab the wrong ID from a previous level if the player enters a level very quickly

	lw v0, orga(gRandomPortraitsFlag) (gp)
	beq v0, r0, (@@RestoreOpCodes)
	lw a0, orga(gRandomPortraitsHookValue) (gp)
	sw a0, (0x800b6490)	;create call to sub RandomPortraits
	sw.l r0, (0x800b6498)
	jal GetLevelID
	sw.l r0, (0x800b64a8)
	beq v0, r0, (@@Corn)	;checks for level
	li v1, 0x1
	beq v0, v1, (@@Met)
	li v1, 0x2
	beq v0, v1, (@@SX)
	li v1, 0x3
	beq v0, v1, (@@A6)
	li v1, 0x5
	beq v0, v1, (@@SY)
	li v1, 0x6
	beq v0, v1, (@@VE1)
	li v1, 0x7
	beq v0, v1, (@@SolorAndSZ)
	li v1, 0x12
	beq v0, v1, (@@SolorAndSZ)
	li v1, 0x8
	beq v0, v1, (@@Zoness)
	li v1, 0x9
	beq v0, v1, (@@VEtunnels)
	li v1, 0xB
	beq v0, v1, (@@MacBeth)
	li v1, 0xC
	beq v0, v1, (@@TitAndAquas)
	li v1, 0xD
	beq v0, v1, (@@TitAndAquas)
	li v1, 0xE
	beq v0, v1, (@@FortBolseVE2)
	li v1, 0x10
	beq v0, v1, (@@Kat)
	li v1, 0x11
	beq v0, v1, (@@FortBolseVE2)
	li v1, 0x13
	beq v0, v1, (@@FortBolseVE2)
	nop
	b @@RestoreOpCodes
	nop
	
@@Corn:

	lw v0, orga(gRandomPortraitSeek) (gp)	;load seek
	addiu v0, v0, 1		;add 1
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		;align to 32 bit
	li a1, gCorneriaPorts	;load start pos
	addu a0, at, a1		;get new address
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)	;store new address
	bgt v0, 8, (@@ResetSeek)		;if greater than max portraits in level, reset
	nop
	b NextTableEntry
	nop
	
@@Met:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gMeteoPorts
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 7, (@@ResetSeek)
	nop
	b NextTableEntry
	nop

@@FortBolseVE2:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gFortunaBolseAndVE2Ports
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 14, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@Kat:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gKatinaPorts
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 18, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@SX:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gSectorXPorts
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 12, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@VE1:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gVenom1LevelPorts
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 6, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@VEtunnels:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gVenomTunnelPorts
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 14, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@SolorAndSZ:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gSolorSectorZPorts
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 11, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@MacBeth:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gMacBethPorts
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 12, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@SY:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gSectorYPorts
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 7, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@TitAndAquas:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gAquasAndTitaniaPorts
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 6, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@A6:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gArea6Ports
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 9, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@Zoness:

	lw v0, orga(gRandomPortraitSeek) (gp)
	addiu v0, v0, 1		
	sw v0, orga(gRandomPortraitSeek) (gp)
	sll at, v0, 2		
	li a1, gZonessPorts
	addu a0, at, a1		
	sw a0, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	bgt v0, 12, (@@ResetSeek)
	nop
	b NextTableEntry
	nop
	
@@ResetSeek:
	sw a1, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	sw r0, orga(gRandomPortraitSeek) (gp)
	j NextTableEntry
	nop
	
	
@@RestoreOpCodes:

	li v0, 0x468021a0
	sw v0, (0x800b6490)		;cvt.s.w f6, f4
	li v0, 0xac250080
	sw.l v0, (0x800b6498)	;sw a1, 0x0080(at)
	lui v0, 0xE446
	ori v0, v0, 0x0000		;li v0, 0xe4460000 is a small bug in the compiler. Doesn't fill lower bits.
	j NextTableEntry
	sw.l v0, (0x800b64a8)	;swc1 f6, 0x0000(v0)
	nop

SUB_RandomPortraits:		;loads new ID and stores into game address that reads it later

	lw at, orga(gRandomPortraitsCurrentBeginAddress) (gp)
	lw a1, 0x0000(at)
	jr ra
	sw a1, 0x0000(v0)
	nop

TBL_FUNC_RandomDialog:		;creates a call to game code to execute sub randomdialog, seeks inside a table in code, then checks if its the end of the table or not. Resets the table address if so.

	lw v0, orga(gRandomDialogFlag) (gp)
	beq v0, r0, (@@RestoreOpCodes)
	lw v0, orga(gRandomDialogHookValue) (gp)
	sw v0, (0x800b6394)		;places call
	lw a0, orga(gRandomDialogSeek) (gp)
	addiu a0, a0, 2
	sw a0, orga(gRandomDialogSeek) (gp)
	sll a0, a0, 2
	lui t0, 0x8018	;upper bytes to table start
	addu t0, t0, a0
	lw a1, 0xbb68(t0)	;load new table pointer
	li v0, 0x8017bad8	;table end location
	beql v0, a1, (NextTableEntry)	;reset seek if taken
	sw r0, orga(gRandomDialogSeek) (gp)
	j NextTableEntry
	nop
@@RestoreOpCodes:

	lui v0, 0x9482	;lhu v0, 0x0000(a0)
	sh v0, (0x800b6394)
	j NextTableEntry
	sh.l r0, (0x800b6396)
	nop
		
SUB_RandomDialog:	;executes from game code

	lw at, orga(gRandomDialogSeek) (gp)
	sll at, at, 2
	lui t6, 0x8018
	addu t6, t6, at
	lw a0, 0xbb68(t6)
	lhu v0, 0x0000(a0)
	jr ra
	li at, 0x8	;restores original op code that was overriden
	nop
	
TBL_FUNC_RandomEngineColors:	;creates calls in game code to seek from the color table. Only randomizes in map screen

	lw v0, orga(gRandomEngineColorsFlag) (gp)
	beq v0, r0, (@@RestoreOpCodes)
	nop
	jal CheckMapScreenState
	li v1, 0x3
	bne v0, v1, (NextTableEntry)
	lw v0, orga(gRedEngineHookValue) (gp)
	sw v0, (0x80050268)
	lw v0, orga(gBlueEngineHookValue) (gp)
	sw.l v0, (0x80050290)
@@BeginSeek:
	lw v0, orga(gRandomEngineColorsSeek) (gp)
	addiu v0, v0, 1
	sw v0, orga(gRandomEngineColorsSeek) (gp)
	sll v1, v0, 2
	addu t0, v1, gp
	lw v1, orga(gRandomEngineColorsTable) (t0)
	beql v1, r0, (@@ResetSeekIfTaken)
	sw r0, orga(gRandomEngineColorsSeek) (gp)
@@ResetSeekIfTaken:
	b NextTableEntry
	nop
@@RestoreOpCodes:
	li v1, 0x3C09FF00	;lui t1, 0xff00
	sw v1, (0x80050268)
	li v1, 0x352900FF	;ori t1, t1, 0x00ff
	sw.l v1, (0x8005026C)
	li v1, 0x340CFFFF	;ori t4, r0, 0xffff
	j NextTableEntry
	sw.l v1, (0x80050290)
	nop
	
	
SUB_RedEngineRoutine:		;executes from game code, can't remember the registers free used so I am going off of old code

	lw at, (gRandomEngineColorsSeek)
	sll at, at, 2
	li.u t1, gRandomEngineColorsTable
	addu t1, t1, at
	jr ra
	lw.l t1, (gRandomEngineColorsTable)
	nop
	

SUB_BlueEngineRoutine:

	lw at, (gRandomEngineColorsSeek)
	sll at, at, 2
	li.u t4, gRandomEngineColorsTable
	addu t4, t4, at
	jr ra
	lw.l t4, (gRandomEngineColorsTable)
	nop
	
TBL_FUNC_RandomExpert:		;randomly selects expert mode at planet screen.

	lw v0, orga(gRandomExpertFlag) (gp)
	beq v0, r0, (NextTableEntry)
	nop
	jal CheckMapScreenState
	li v1, 0x3
	bne v1, v0, (NextTableEntry)	;end if not in map screen
		nop
		jal CheckPrevLives
		li t7, 1
		beq v0, t7, (@@CycleExpertFlag)		;if lives are equal, cycle, otherwise restore flag
			lw a0, orga(gPreviousExpertFlag) (gp)
			sw a0, (LOC_EXPERT_FLAG32)
			j NextTableEntry
			nop
@@CycleExpertFlag:
				lui at, 0x8017
				lw a0, 0xd868(at)	;LOC_EXPERT_FLAG32
				xori a0, a0, 1
				j NextTableEntry
				sw a0, 0xd868(at)
				nop
				
TBL_FUNC_OneHitKO:		;changes an op code to store zero to health when hit

	lw at, orga(gOneHitKOFlag) (gp)
	beq at, r0, (@@RestoreOpCode)
	lui t0, 0x800B
	li a0, 0xA0		;register r0
	b (NextTableEntry)
	sb a0, 0xfc55(t0)	;override op code
	nop
@@RestoreOpCode:
	li a0, 0xB9		
	b (NextTableEntry)
	sb a0, 0xfc55(t0)
	nop
	
TBL_FUNC_RandomMusic:

	lw at, orga(gRandomMusicFlag) (gp)
	beq at, r0, (@@RestoreOpCode)
	lui at, 0x8002		;top of address to code
	li v1, 0x240A		;new op code
	sh v1, 0xd488(at)
	li t0, gRandomMusicTable
	lw a0, orga(gRandomMusicSeek) (gp)	;load seek
	addiu a0, a0, 1		;add 1 to seek
	sw a0, orga(gRandomMusicSeek) (gp)	;store seek
	sll a0, a0, 2		;align
	addu t0, a0, t0		;get table address
	lw a0, 0x0000(t0) ;load first music ID
	sh a0, 0xd48A(at)	;store new ID (li t2, newID)
	bne a0, r0, (NextTableEntry)	;exit if valid ID
	nop
@@ResetEntry:
	lw a0, orga(gRandomMusicTable) (gp)
	sh a0, 0xd48a(at)
	b NextTableEntry
	sw r0, orga(gRandomMusicSeek) (gp)
	nop
@@RestoreOpCode:
	li a0, 0x97AA0026	;lhu t2, 0x0026(sp)
	b NextTableEntry
	sw a0, 0xd488(at)
	nop
	
TBL_FUNC_RandomColors:		;actively changes color of the map

	lw at, orga(gRandomColorsActiveFlag) (gp)
	beq at, r0, (NextTableEntry)
	nop
	jal GetLevelID
	li t0, 0xD
	beq t0, v0, (NextTableEntry)	;Zoness crashes on hardware for unknown reasons so skip
	li t0, 0x8
	beq t0, v0, (NextTableEntry)	;Aquas crashes on hardware for unknown reasons so skip
	lui t0, 0x8017
	lui t1, 0x8015
	lw a0, (LOC_POWER_ON_TIMER32)
	andi a1, a0, 0x16
	beq a1, r0, (@@CheckGreen1)
	lb a1, 0xE3BB(t0)	;reds
	addiu a1, a1, 1
	b (@@PlanetCheck)
	sb a1, 0xE3BB(t0)
	nop
@@CheckGreen1:
	lw a1, 0x7908(t1)	;current hits
	subu a2, a0, a1
	andi v0, a2, 0x20
	beq v0, r0, (@@CheckBlue1)
	nop
	lb a1, 0xE3BF(t0)	;greens
	addiu a1, a1, 1
	b (@@PlanetCheck)
	sb a1, 0xE3BF(t0)
	nop
@@CheckBlue1:
	addu a2, a0, a1
	andi v0, a2, 0x14
	beq v0, r0, (@@CheckLayer2Red)
	lb a1, 0xE3C3(t0)	;blues
	addiu a1, a1, 1
	b (@@PlanetCheck)
	sb a1, 0xE3C3(t0)
	nop
@@CheckLayer2Red:
	lw a1, 0xDC20(t0)
	andi v0, a1, 0x8
	beq v0, r0, (@@CheckLayer2Green)
	lb v0, 0xE3C7(t0)	;reds
	addiu v0, v0, -1
	b (@@PlanetCheck)
	sb v0, 0xE3C7(t0)
	nop
	
@@CheckLayer2Green:
	subu v0, a1, a0
	andi v0, v0, 0x12
	beq v0, r0, (@@CheckLayer2Blue)
	lb v0, 0xE3CB(t0)	;greens
	addiu v0, v0, 2
	b (@@PlanetCheck)
	sb v0, 0xE3CB(t0)
	nop
@@CheckLayer2Blue:

	lw a1, 0xDC20(t0)
	andi v0, a1, 0x6
	beq v0, r0, (@@PlanetCheck)
	lb v0, 0xE3CF(t0)	;blues
	addiu v0, v0, -2
	sb v0, 0xE3CF(t0)
@@PlanetCheck:
	jal CheckFoxState
	nop
	blez v0, (NextTableEntry)
	addiu v1, r0, 3
	bne v0, v1, (NextTableEntry)
	nop
	; lw a0, (GetLevelID)		;i think this might be crashing on hardware, so omit for now
	; addiu v1, r0, 0x8
	; beq a0, v1, (@@ZonessOpCodeWrite)
	; addiu v1, r0, 0xD
	; beq a0, v1, (@@AquasOpCodeWrite)
	; nop
	b (NextTableEntry)
	nop
; @@ZonessOpCodeWrite:		;overrides forced colors by map code
	; lui v1, 0x800b
	; addiu a0, r0, 0x36
	; b (NextTableEntry)
	; sh a0, 0x3dba(v1)
	; nop
; @@AquasOpCodeWrite:
	; lui v1, 0x801A
	; b (NextTableEntry)
	; sw r0, 0x0b80(v1)
	; nop
	
TBL_FUNC_ExtraStarWolfs:	;puts star wolfs in Sector Z, Y, Katina, Andross 2 and Bolse

	;todo if expert mode, spawn more?

	lw at, orga(gExtraStarWolfsFlag) (gp)
	beq at, r0, (@@MainMenuCheck)
	li v1, 1
	sw.u v1, (0x8016DB40)
	sw.l v1, (0x8016DB40)	;set wolf team flags to spawnable for game code
	sw.l v1, (0x8016DB44)
	sw.l v1, (0x8016DB48)
	sw.l v1, (0x8016DB4c)
	jal CheckMapScreenState
	li v1, 3
	beq v1, v0, (@@InMapScreen)
	li v1, 5
	beq v1, v0, (@@InMapScreen)
	nop
	lw a0, (LOC_ALIVE_TIMER32)
	li v1, 0x2
	beql a0, v1, (@@LevelChecks)
	sw r0, orga(gWolfsSpawnedFlag) (gp)	;reset flag if alive timer is 2. Fail safe for entering level and retrying / dead
@@LevelChecks:
	jal GetLevelID
	li v1, 0x12
	beq v1, v0, (@@OnSZ)
	li v1, 0x5
	beq v1, v0, (@@OnSY)
	li v1, 0x10
	beq v1, v0, (@@OnKatina)
	li v1, 0x9
	beq v1, v0, (@@OnTunnel)
	nop
	b (NextTableEntry)
	nop
	
@@InMapScreen:
	li v0, 0x15210049
	sw v0, (0x8002e858)	;restore op code
	sw r0, orga(gWolfsSpawnedFlag) (gp)
	li t0, 0x800C6A64	;sy assets
	li v0, 0x0093C0E0	;wolf assets from ROM pointer
	li v1, 0x00950880	;wolf assets from ROM end pointer
	sw v0, 0x0090(t0)	;store ROM entry in Star Wolf specific level data
	sw v1, 0x0094(t0)	;store ROM end entry in Star Wolf specific level data
	li t0, 0x800C66D4	;sz assets
	sw v0, 0x0090(t0)
	sw v1, 0x0094(t0)
	li t0, 0x800C6CC4	;tunnel assets
	sw v0, 0x0090(t0)
	b (NextTableEntry)
	sw v1, 0x0094(t0)
	nop

@@OnSZ:
	lw at, orga(gWolfsSpawnedFlag) (gp)
	beq at, r0, (@@SZNotSpawned)
	nop
	li t0, 0x8015AD14	;wolf 1 spot is targeting Falco
	li t1, 0x8015B008	;wolf 2 spot is targeting Slippy
	lui at, 0x8017
	lw a0, (0xD724) (at)	;grab Falco's health
	lw a1, (0xD728) (at)	;grab Slippy's health
	;lw a2, (0xD72C) (at)	;grab Peppy's health
	li v0, -1
	beq a0, r0, (@@SZFalcoDead)
	nop
	beq a1, r0, (@@SZSlippyDead)
	nop
	beq a0, v0, (@@SZFalcoDead)
	nop
	beq a1, v0, (@@SZSlippyDead)
	nop
	b (NextTableEntry)
	nop
	
@@SZFalcoDead:
	sh r0, (0x00E6) (t0)	;Change target of wolf enemy that was targetting Falco to Fox
	beq a1, r0, (@@SZSlippyDead)
	nop
	b (NextTableEntry)
	nop
@@SZSlippyDead:
	sh r0, (0x00E6) (t1)	;Change target of wolf enemy that was targetting Slippy to Fox
	b (NextTableEntry)
	nop
	
@@SZNotSpawned:
	lw a0, (0x80155798)	;get first missile timer
	li v0, 0x07F0
	bne v0, a0, (NextTableEntry)
	li v0, 1
	sw v0, orga(gWolfsSpawnedFlag) (gp)
	sw r0, (0x8002e858)	;remove branch in game code so wolf team can shoot
	li a0, 0x8015AD14
	li a1, 1
	jal SpawnSingleStarWolfRegularMode
	li a2, 5
	li a0, 0x8015B008
	li a1, 2
	jal SpawnSingleStarWolfRegularMode
	li a2, 6
	b (NextTableEntry)
	nop
	
@@OnSY:
	jal CheckFoxState
	li t1, 0x9
	beql t1, v0, (@@ContinueSYChecks)	;if fox state entering all range mode, unset flag
	sw r0, orga(gWolfsSpawnedFlag) (gp)
	
@@ContinueSYChecks:
	lw at, orga(gWolfsSpawnedFlag) (gp)
	beq at, r0, (@@SYNotSpawned)
	nop
	li t0, 0x8015AD14	;wolf 1 spot is targeting Falco
	li t1, 0x8015B008	;wolf 2 spot is targeting Slippy
	lui at, 0x8017
	lw a0, (0xD724) (at)	;grab Falco's health
	lw a1, (0xD728) (at)	;grab Slippy's health
	;lw a2, (0xD72C) (at)	;grab Peppy's health
	li v0, -1
	beq a0, r0, (@@FalcoDead)
	nop
	beq a1, r0, (@@SlippyDead)
	nop
	beq a0, v0, (@@FalcoDead)
	nop
	beq a1, v0, (@@SlippyDead)
	nop
	b (NextTableEntry)
	nop
	
@@FalcoDead:
	sh r0, (0x00E6) (t0)	;Change target of wolf enemy that was targetting Falco to Fox
	beq a1, r0, (@@SlippyDead)
	nop
	b (NextTableEntry)
	nop
@@SlippyDead:
	sh r0, (0x00E6) (t1)	;Change target of wolf enemy that was targetting Slippy to Fox
	b (NextTableEntry)
	nop
	
	
@@SYNotSpawned:
	li v0, 0x0200013A
	lui at, 0x8016
	lw a0, (0x5388) (at)	;check if one of the first two robots is alive
	bne v0, a0, (NextTableEntry)	;if not active, end
	li v0, 0x001D
	lh a0, (0x53D4) (at)
	bne v0, a0, (NextTableEntry)	;if not active state, end
	li v0, 1
	sw v0, orga(gWolfsSpawnedFlag) (gp)
	sw r0, (0x8002e858)	;remove branch in game code so wolf team can shoot
	li a0, 0x8015AD14
	li a1, 1
	jal SpawnSingleStarWolfRegularMode
	li a2, 5
	li a0, 0x8015B008
	li a1, 2
	jal SpawnSingleStarWolfRegularMode
	li a2, 6
	b (NextTableEntry)
	nop
	
	
@@OnKatina:
	lh a0, (0x80165430)
	li v0, 0x1670
	bne a0, v0, (NextTableEntry)	;end if UFO timer is not equal
	nop
	jal 0x8002af70	;spawn wolf team from game code
	nop
	b (NextTableEntry)
	nop
	
@@OnTunnel:
	lui at, 0x8016
	lw a0, (0x4F80) (at)
	li v0, 0x02000141
	bne a0, v0, (NextTableEntry)	;if AND2 not spawned, end
	lh a0, (0x5012) (at)
	li v0, 0x52
	bne a0, v0, (NextTableEntry)	;activate star wolf if AND2 is 52 frames from becoming active
	; li v0, 1
	; sw v0, orga(gWolfsSpawnedFlag) (gp)	;not needed for this level
	sw r0, (0x8002e858)	;remove branch in game code so wolf team can shoot
	li a0, 0x8015AD14
	li a1, 0
	jal SpawnSingleStarWolfRegularMode
	li a2, 4
	li a0, 0x8015B008
	li a1, 0
	jal SpawnSingleStarWolfRegularMode
	li a2, 7
	b (NextTableEntry)
	nop

@@MainMenuCheck:
	jal CheckIfMainMenu
	li t0, 0x3E8
	beq t0, v0, (@@ResetROMentry)
	nop
	b (NextTableEntry)
	nop
	

@@ResetROMentry:	;resets star wolf assets to load on levels that don't normally have them.
	li t0, 0x800C6A64	;sy assets
	sw r0, 0x0090(t0)
	sw r0, 0x0094(t0)
	li t0, 0x800C66D4	;sz assets
	sw r0, 0x0090(t0)
	sw r0, 0x0094(t0)
	li t0, 0x800C6CC4	;tunnel assets
	sw r0, 0x0090(t0)
	sw r0, 0x0094(t0)
	b (NextTableEntry)
	nop
	
NextTableEntry:		;store next entry and go back to loop

	lw v0, orga(gRandoSeekEntry) (gp)
	addiu v0, v0, 0x0001
	j RandoLoop
	sw v0, orga(gRandoSeekEntry) (gp)
	nop

ExitRandomizer:		;Restore stack, exit and continue regular game code

	lw ra, 0(sp)
	lw a0, 4(sp)
	lw s0, 8(sp)
	lw s1, 12(sp)
	lw s2, 16(sp)
	lw s3, 20(sp)
	lw s4, 24(sp)
	lw s5, 28(sp)
	lw s6, 32(sp)
	lw s7, 36(sp)
	jr ra
	addiu sp, sp, 40
	nop

.endregion