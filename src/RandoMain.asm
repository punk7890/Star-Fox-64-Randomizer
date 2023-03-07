		
		
		/* Main randomizer code and loop. Most main functions are here, larger functions are in other .asm files. */

.n64

.org 0x80410000		;main entry to function. Hardcoded to this offset.

.region 0x4000 ;increase this if need more space in the future


@@BeginRando:

	addiu sp, sp, -0x64 	;On entry, save stuff to stack
	sw ra, 0x0000(sp)
	sw at, 0x0004(sp)
	sw v0, 0x0008(sp)
	sw v1, 0x000c(sp)
	sw a0, 0x0010(sp)
	sw a1, 0x0014(sp)
	sw a2, 0x0018(sp)
	sw a3, 0x001c(sp)
	sw t0, 0x0020(sp)
	sw t1, 0x0024(sp)
	sw t2, 0x0028(sp)
	sw t3, 0x002c(sp)
	sw t4, 0x0030(sp)
	sw t5, 0x0034(sp)
	sw t6, 0x0038(sp)
	sw t7, 0x003c(sp)
	sw s0, 0x0040(sp)
	sw s1, 0x0044(sp)
	sw s2, 0x0048(sp)
	sw s3, 0x004c(sp)
	sw s4, 0x0050(sp)
	sw s5, 0x0054(sp)
	sw s6, 0x0058(sp)
	sw s7, 0x005c(sp)
	sw t8, 0x0060(sp)
	sw t9, 0x0064(sp)
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

	jal CheckFoxState		;check if Fox is still in spawning in state
	li t7, 0x1
	bne v0, t7, (NextTableEntry)
	nop
		lw v0, (LOC_ALIVE_TIMER32)		;check if second frame of entering level
		li v1, 0x2
		bne v0, v1, (NextTableEntry)
			nop
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
	
SUB_CustomEndScreenHook:	;level end screen custom function. Runs once (twice?) when on-screen. Can't remember all registers that are free to use, going off old code

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
	lw a2, orga(gBRMTimerScoreToDisplay) (gp)
	lui a3, 0x8015
	addu a2, a2, a3
	sw a2, 0xd9e0(a1)	;don't remember, some score related thing? Planet score?
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
					beq at, r0, (@@Continue3)
					nop
					jal CheckSameLevels
					nop
@@Continue3:						 ;check if in planet screen select menu
			bne t6, t7, (@@Exit)
				nop
				jal SeekToNewLevel
				nop
				lw at, orga(gAllowSamePlanetsFlag) (gp)
				beq at, r0, (@@Exit)
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
		b (NextTableEntry)
		sw.l v0, @LOC_ITEM_HOOK
		nop
		
@@IfRandomItemIsOn:		;create in-game hook for level item spawn checks

	lw v0, orga(gItemDropFunctionHookValue) (gp)
	sw.u v0, (@LOC_ITEM_HOOK)
	b NextTableEntry
	sw.l v0, (@LOC_ITEM_HOOK)
	nop
	
	
SUB_CustomItemDropFunction:

	/* custom call sent to game code to excute. Every map object about to load on-screen gets checked for a valid item ID. If it's an item, it grabs a new item from gRandomItemDropsTable. Hook is at 0x8005e588 */
	
	lh v0, 0x0010(s0) ;load item ID from current level data pointer
	li t3, gRandomItemDropsTable ;load wherever table is
@@ItemCheckLoop:
	lw t4, 0x0000(t3)		;load new item in t4 for checks
	beq t4, r0, (@@End)		;end if item loaded is zero
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
	jr ra
	lh v0, 0x0010(s0)
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
	b NextTableEntry
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
	
NextTableEntry:		;store next entry and go back to loop

	lw v0, orga(gRandoSeekEntry) (gp)
	addiu v0, v0, 0x0001
	j RandoLoop
	sw v0, orga(gRandoSeekEntry) (gp)
	nop

ExitRandomizer:		;Restore stack, exit and continue regular game code

	lw ra, 0x0000(sp)
	lw at, 0x0004(sp)
	lw v0, 0x0008(sp)
	lw v1, 0x000c(sp)
	lw a0, 0x0010(sp)
	lw a1, 0x0014(sp)
	lw a2, 0x0018(sp)
	lw a3, 0x001c(sp)
	lw t0, 0x0020(sp)
	lw t1, 0x0024(sp)
	lw t2, 0x0028(sp)
	lw t3, 0x002c(sp)
	lw t4, 0x0030(sp)
	lw t5, 0x0034(sp)
	lw t6, 0x0038(sp)
	lw t7, 0x003c(sp)
	lw s0, 0x0040(sp)
	lw s1, 0x0044(sp)
	lw s2, 0x0048(sp)
	lw s3, 0x004c(sp)
	lw s4, 0x0050(sp)
	lw s5, 0x0054(sp)
	lw s6, 0x0058(sp)
	lw s7, 0x005c(sp)
	lw t8, 0x0060(sp)
	lw t9, 0x0064(sp)
	jr ra
	addiu sp, sp, 0x64
	nop

.endregion