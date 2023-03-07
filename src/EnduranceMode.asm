		
	
		/* Endurance mode main logic function */

.n64		
.autoregion

TBL_FUNC_EnduranceMode:
		lw at, orga(gEnduranceModeFlag) (gp)
		beq at, r0, (NextTableEntry)
		li t6, 1
		jal CheckMapScreenState	
		li t7, 3
		bne v0, t7, (@@InGameChecks)	;display timer in map screen
		nop
		sw t6, orga(gEnduranceModeTimerDisplayFlag) (gp)
		sw r0, orga(gEnduranceModePreviousHits) (gp)
		sw r0, orga(gEnduranceModeLevelTimer) (gp)
		sw r0, orga(gEnduranceModeLevelTimerEnableFlag) (gp)
		sw r0, orga(gEnduranceModeDoneScoreEndSceneFlag) (gp)
		sw r0, orga(gEnduranceModeDonePlanetTimerAddFlag) (gp)
@@InGameChecks:
		jal CheckFoxState
		li a0, 7
		bne a0, v0, (@@InGameChecks2)		;if in end scene, stop timer
		nop
		sw r0, orga(gEnduranceModeTimerEnabledFlag) (gp)
		sw r0, orga(gEnduranceModeLevelTimerEnableFlag) (gp)
		lw a0, orga(gEnduranceModeDoneScoreEndSceneFlag) (gp)
		beq a0, r0, (@@EndSceneScoreCalculate)
		nop
@@InGameChecks2:
		lui t5, 0x8015
		sb r0, 0x7911(t5)	;constantly set lives to 0
		sw r0, orga(gPreviousLives) (gp)	;and previous lives for randomizer logic if random planets is on
		lb v0, 0x789C(t5)		;check if player has control (LOC_HAS_CONTROL_FLAG8), stop timer if not
		bne v0, t6, (@@DisableTimers)
		nop
		sw t6, orga(gEnduranceModeTimerEnabledFlag) (gp)	;enable timers if have control
		sw t6, orga(gEnduranceModeLevelTimerEnableFlag) (gp)
		lw v0, orga(gEnduranceModeLevelTimer) (gp)
		addiu v0, v0, 1
		b (@@InGameChecks3)
		sw v0, orga(gEnduranceModeLevelTimer) (gp)
		nop
@@DisableTimers:
		sw r0, orga(gEnduranceModeTimerEnabledFlag) (gp)	;otherwise disable
		sw r0, orga(gEnduranceModeLevelTimerEnableFlag) (gp)
@@InGameChecks3:
		lui t4, 0x8017
		lw v0, 0xD6C4(t4)	;check if paused, stop timer if so (LOC_SPECIAL_STATE)
		li v1, 0x64
		bne v0, v1, (@@TimerAndScoreChecks)
		nop
		sw r0, orga(gEnduranceModeTimerEnabledFlag) (gp)
		sw r0, orga(gEnduranceModeLevelTimerEnableFlag) (gp)
		lw v0, orga(gEnduranceModeLevelTimer) (gp)
		addiu v0, v0, -1			;fix this wacky timer later
		sw v0, orga(gEnduranceModeLevelTimer) (gp)
@@TimerAndScoreChecks:
		lw v0, orga(gEnduranceModeTimerEnabledFlag) (gp)
		beq at, r0, (@@DoScoreChecks)
		lw a0, orga(gEnduranceModePreviousBombs) (gp)
		lb a1, 0xDC13(t4)	;check bombs, if used a bomb subtract from score
		beq a0, a1, (@@CurrentTimerCheck)
		lw a0, orga(gEnduranceModeCurrentTimer) (gp)
		sw a1, orga(gEnduranceModePreviousBombs) (gp)
@@BombSubtractCheck:
		jal CheckIfExpert		;bomb check if expert or not
		nop
		beq v0, r0, (@@NotExpertBombs)
		lw a1, orga(gEnduranceModeSubtractBombScoreExpert) (gp)
		subu a0, a0, a1
		b (@@CurrentTimerCheck)
		sw a0, orga(gEnduranceModeCurrentTimer) (gp)
		nop
@@NotExpertBombs:
		lw a1, orga(gEnduranceModeSubtractBombScoreNormal) (gp)
		subu a0, a0, a1
		b (@@CurrentTimerCheck)
		sw a0, orga(gEnduranceModeCurrentTimer) (gp)
		nop
@@CurrentTimerCheck:
		lw v0, orga(gEnduranceModeTimerDisplayFlag) (gp)
		beq v0, r0, (NextTableEntry)
		lw v0, orga(gEnduranceModeTimerEnabledFlag) (gp)
		beq v0, r0, (NextTableEntry)
		lw a0, orga(gEnduranceModeCurrentTimer) (gp)
		;maybe add a level timer check and a planet check to slow down the timer
		addiu a1, a0, -1
		blez a1, (@@StoreZeroIfMinus)	;store zero to timer if negative and kill fox
		sw a1, orga(gEnduranceModeCurrentTimer) (gp)
		b (@@DoScoreChecks)
		nop
@@StoreZeroIfMinus:
		sw r0, orga(gEnduranceModeTimerEnabledFlag) (gp)
		sw r0, orga(gEnduranceModeCurrentTimer) (gp)
		sw r0, orga(gEnduranceModeTimerDisplayFlag) (gp)
		li a0, 0x01C8
		jal SetFoxState		;kill fox
		li a1, 0x4
		b (NextTableEntry)
		nop
@@DoScoreChecks:
		lw a0, orga(gEnduranceModePreviousHits) (gp)
		lw a1, 0x7908(t5)		;load current and prev hits to compare
		beq a0, a1, (NextTableEntry)	;end if equal
		or a3, r0, r0
@@DoLoopUntilEqual:		;probably a better way to get the difference
		addiu a0, a0, 1
		beq a1, a0, (@@DoScoreChecks2)
		addiu a3, a3, 1
		b (@@DoLoopUntilEqual)
		nop
@@DoScoreChecks2:		;laser checks
		;add level timer check here and if end scene for adding to score at end. That might go in end screen vars though
		lw a0, orga(gEnduranceModeCurrentTimer) (gp)
		sw a1, orga(gEnduranceModePreviousHits) (gp)
		lb v0, 0x791B(t5)	;check lasers
		li v1, 0
		beq v0, v1, (@@FinalStores)
		li v1, 1
		beq v0, v1, (@@DuelLasers)
		li v1, 2
		beq v0, v1, (@@HyperLasers)
		nop
		b (@@FinalStores)
		nop

@@DuelLasers:	
		jal CheckIfExpert		;laser check if expert or not
		nop
		beq v0, r0, (@@DuelLasersNotExpert)
		lw a1, orga(gEnduranceModeAddIfDualLaserScoreExpert) (gp)
		addu a1, a1, a3
		addu a1, a1, a0
		b (@@FinalStores)
		sw a1, orga(gEnduranceModeCurrentTimer) (gp)
		nop
@@DuelLasersNotExpert:
		lw a1, orga(gEnduranceModeAddIfDualLaserScoreNormal) (gp)
		addu a1, a1, a3
		addu a1, a1, a0
		b (@@FinalStores)
		sw a1, orga(gEnduranceModeCurrentTimer) (gp)
		nop
@@HyperLasers:
		jal CheckIfExpert		;laser check if expert or not
		nop
		beq v0, r0, (@@HyperLasersNotExpert)
		lw a1, orga(gEnduranceModeAddIfHyperLaserScoreExpert) (gp)
		addu a1, a1, a3
		addu a1, a1, a0
		b (@@FinalStores)
		sw a1, orga(gEnduranceModeCurrentTimer) (gp)
		nop
@@HyperLasersNotExpert:
		lw a1, orga(gEnduranceModeAddIfHyperLaserScoreNormal) (gp)
		addu a1, a1, a3
		addu a1, a1, a0
		b (@@FinalStores)
		sw a1, orga(gEnduranceModeCurrentTimer) (gp)
		nop
@@FinalStores:
		jal CheckIfExpert		;check if expert or not for final score math
		nop
		beq v0, r0, (@@ScoreNotExpert)
		lw a2, orga(gEnduranceModeRegularScoreTimesExpert) (gp)
		mult a3, a2
		mflo a3
		addu a1, a3, a0
		;addu a1, a2, a1
		;if not 1, maybe only then multiple and just add a static value to 1
		b (NextTableEntry)
		sw a1, orga(gEnduranceModeCurrentTimer) (gp)
		nop
@@ScoreNotExpert:
		lw a2, orga(gEnduranceModeRegularScoreTimesNormal) (gp)
		mult a3, a2
		mflo a3
		addu a1, a3, a0
		;addu a1, a2, a1
		b (NextTableEntry)
		sw a1, orga(gEnduranceModeCurrentTimer) (gp)
		nop
@@EndSceneScoreCalculate:
		lw a0, orga(gEnduranceModePreviousHits) (gp)
		lw a1, (LOC_PLAYER_HITS32)
		bltl a0, a1, (NextTableEntry)		;if score counted down, set flag.
		sw t6, orga(gEnduranceModeDoneScoreEndSceneFlag) (gp)	
		beq a0, a1, (NextTableEntry)
		or a3, r0, r0
@@DoLoopUntilEqual2:
		addiu a0, a0, 1
		beq a1, a0, (@@EndSceneExpertChecks)
		addiu a3, a3, 1
		b (@@DoLoopUntilEqual2)
		nop
@@EndSceneExpertChecks:
		jal CheckIfExpert
		nop
		beq v0, r0, (@@ScoreNotExpertEndScreen)
		lw a2, orga(gEnduranceModeRegularScoreTimesExpert) (gp)
		mult a3, a2
		mflo a3
		addu a1, a3, a0
		sw a1, orga(gEnduranceModeCurrentTimer) (gp)
		b (NextTableEntry)
		sw t6, orga(gEnduranceModeDoneScoreEndSceneFlag) (gp)
		nop
@@ScoreNotExpertEndScreen:
		lw a2, orga(gEnduranceModeRegularScoreTimesNormal) (gp)
		mult a3, a2
		mflo a3
		addu a1, a3, a0
		sw a1, orga(gEnduranceModeCurrentTimer) (gp)
		b (NextTableEntry)
		sw t6, orga(gEnduranceModeDoneScoreEndSceneFlag) (gp)
		nop

.endautoregion