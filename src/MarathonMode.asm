.n64

.autoregion

	@LOC_TRAININGMODE_RINGS32 equ 0x8016dcf0
	
	;MacBeth may need testing when quick score screens is on


TBL_FUNC_MarathonMode:

	lw v0, orga(gMarathonModeFlag) (gp)
	beq v0, r0, (@@Exit)
	nop
		jal GetLevelID
		nop
		or s0, v0, r0	;move level ID in s0 for checks later
		jal CheckMapScreenState
		li v1, 5
		beq v0, v1, (@@PlanetScreenChecks)
		li v1, 3
		beq v0, v1, (@@PlanetScreenChecks)
		nop
@@InGameChecks:
	jal CheckFoxState
	nop
	or s1, v0, r0 ;move fox state in s1 for checks later
	li v1, -1
	beq s1, v1, (@@Exit)
	lb v0, (LOC_ENDSCREEN_FLAG8)
	addu v0, s1, v0
	li v1, 8
	beq v0, v1, (@@EndSceneChecks)	;add Fox state and end screen flag together to see if in end scene = 8 (fail safe check)
	li v1, 7
	beq s1, v1, (@@EndSceneChecks)	;check if only in end scene state
	nop
@@AliveChecks:
	; li v0, 1
	; sw v0, orga(gMarathonModeSetPlanetActiveFlag) (gp) ;only needed for training
	li v1, 0xA
	beq s0, v1, (@@TrainingModeAliveChecks)		;check if in training mode
	nop
	j NextTableEntry
	nop
	
@@TrainingModeAliveChecks:

	li v1, 0xFF38
	lhu at, (0x8020cac4)	;I think this checks if some object is loaded
	bne v1, at, (@@Exit)	;exit if not active in training
	li v1, 0x8003
	lhu at, (0x8015bbf4)	;checks if Star Wolf enemy is alive
	bne v1, at, (@@ContinueTrainingModeChecks1)
	li v1, 3
	sb v1, (0x8015bc14)	;give star wolf enemy +3 hits for killing
@@ContinueTrainingModeChecks1:

	lw a0, (LOC_ALIVE_TIMER32)
	li v1, 1
	bne a0, v1, (@@ContinueTrainingModeChecks2) ;check if first frame of level, if so go to timer checks. Set timer on if first frame
	li at, 1
	sw at, orga(gMarathonModeSetPlanetActiveFlag) (gp)
	li v0, 5
	sw.u v0, (LOC_KATINA_TIMER32)	;store minutes
	sw.l v0, (LOC_KATINA_TIMER32)
	sw.l r0, (LOC_KATINA_TIMER32 + 4)	;store seconds
	sw.l r0, (LOC_KATINA_TIMER32 + 8)	;store milliseconds
	li v0, 1
	sw.l v0, (LOC_KATINA_TIMER32 + 12)	;store active
	li v0, 1.0	;size of timer
	sw.l v0, (LOC_KATINA_TIMER32 + 20)	;store size
@@ContinueTrainingModeChecks2:

	lw v0, orga(gMarathonModeSetPlanetActiveFlag) (gp)
	beq v0, r0, (@@Exit)
	la at, LOC_KATINA_TIMER32
	lw v0, 0x0000(at)	;check if timer is still going
	bne v0, r0, (@@ContinueTrainingModeChecks3)
	lw v0, 0x0004(at)
	bne v0, r0, (@@ContinueTrainingModeChecks3)
	lw v0, 0x0008(at)
	bne v0, r0, (@@ContinueTrainingModeChecks3)
	nop
	jal DoSpecialState	;force freeze 
	li a0, 3
	li v0, 0x1
	sb v0, (LOC_ENDSCREEN_FLAG8)	;do score calculations
	lw a0, orga(gWaitTimer) (gp)
	addiu a0, a0, 1
	sw a0, orga(gWaitTimer) (gp)
	li v1, 0x60
	bne a0, v1, (@@Exit)	;wait x amount of time then do reset to map screen
	nop
	; jal LoadPlayerInfoToGP	;not needed as this gets handled in TBL_FUNC_InitLevelStartVars and SUB_CustomEndScreenHook if displaying end screen
	; nop
	jal DoSoftResetWithFlag
	li a0, 4
	jal DoSpecialState
	li a0, 2
	sw.u r0, (LOC_KATINA_TIMER32)
	sw.l r0, (LOC_KATINA_TIMER32)
	sw.l r0, (LOC_KATINA_TIMER32 + 4)
	sw.l r0, (LOC_KATINA_TIMER32 + 8)
	sw.l r0, (LOC_KATINA_TIMER32 + 12)
	sw.l r0, (LOC_KATINA_TIMER32 + 20)
	sw r0, orga(gMarathonModeSetPlanetActiveFlag) (gp)
	sw r0, orga(gWaitTimer) (gp)
	lw a0, orga(gMarathonModeCompletedTimes) (gp)	;only need to set this manually for training mode
	addiu a0, a0, 1
	sw a0, orga(gMarathonModeCompletedTimes) (gp)
	j NextTableEntry
	nop
@@ContinueTrainingModeChecks3:

	;checks if going into all range mode section for score count if player grabbed rings
	li v0, 9
	bne s1, v0, (@@Exit)	;exit if not changing to all range mode
	lw a0, (LOC_INTRO_OUTRO_TIMER32)
	li v1, 2
	bne a0, v1, (@@Exit)	;exit if timer not 2
	lw a0, (@LOC_TRAININGMODE_RINGS32)
	lw a1, (LOC_PLAYER_HITS32)
	addu a2, a1, a0
	sw a2, (LOC_PLAYER_HITS32)	;store new hits based on rings collected once
	j NextTableEntry
	nop
	
@@EndSceneChecks:

	sw r0, orga(gMarathonModeSetPlanetActiveFlag) (gp)
	li v0, 1
	sw v0, orga(gMarathonModeAddToCompletedTimesFlag) (gp)	;gets unset at planet screen for moving to next level
	li v1, 0x9
	beq s0, v1, (@@VETunnelsCheck)		;check if in tunnels
	li v1, 0xB
	beq s0, v1, (@@MacBethCheck)
	nop
	j NextTableEntry
	nop
	
@@MacBethCheck:

	lw t0, (LOC_FOX_POINTER32)
	lw at, orga(gQuickScoreScreensFlag) (gp)
	beq at, r0, (@@NotQuickMacBeth)
	nop
	beq t0, r0, (@@Exit)
	li v1, 0xB
	lw t1, 0x01D0(t0)
	beq t1, v1, (@@MacBethDoQuickEndPath1)
	li v1, 0x7
	lw t1, 0x01D0(t0)
	beq t1, v1, (@@MacBethDoQuickEndPath1) ;(@@MacBethDoQuickEndPath2)
	nop
	j NextTableEntry
	nop

@@NotQuickMacBeth:
	
	li v1, 0xB
	lw t1, 0x01D0(t0)
	beq t1, v1, (@@MacBethEndPath1)
	li v1, 0x7
	lw t1, 0x01D0(t0)
	beq t1, v1, (@@MacBethEndPath2)
	nop
	j NextTableEntry
	nop
	
@@MacBethEndPath1:
	
	lw a0, (LOC_INTRO_OUTRO_TIMER32)
	li v1, 0x470
	blt a0, v1, (@@Exit)
	; lw a0, orga(gWaitTimer) (gp)
	; addiu a0, a0, 1
	; sw a0, orga(gWaitTimer) (gp)
	; li v1, 0x120
	; bne a0, v1, (@@Exit)
	nop
	jal DoSoftResetWithFlag
	li a0, 4
	sw r0, orga(gWaitTimer) (gp)
	j NextTableEntry
	nop

@@MacBethEndPath2:
	
	lw a0, (LOC_INTRO_OUTRO_TIMER32)
	li v1, 0x880
	blt a0, v1, (@@Exit)
	; lw a0, orga(gWaitTimer) (gp)
	; addiu a0, a0, 1
	; sw a0, orga(gWaitTimer) (gp)
	; li v1, 0xA0
	; bne a0, v1, (@@Exit)
	nop
	jal DoSoftResetWithFlag
	li a0, 4
	sw r0, orga(gWaitTimer) (gp)
	j NextTableEntry
	nop
	
@@MacBethDoQuickEndPath1:

	lw a0, orga(gWaitTimer) (gp)
	addiu a0, a0, 1
	sw a0, orga(gWaitTimer) (gp)
	li v1, 0x40
	bne a0, v1, (@@Exit)	;this might need checking to see if this catches the correct score.
	nop
	jal DoSoftResetWithFlag
	li a0, 4
	sw r0, orga(gWaitTimer) (gp)
	j NextTableEntry
	nop
		
@@VETunnelsCheck:
	
	lw v0, (LOC_SUB_SECTION_FLAG32)
	bne v0, r0, (@@Exit)	;player is on Venom 2 tunnels so exit.
	la t0, 0x80164fce
	lh a0, 0x0000(t0) 
	li v1, 0x1F
	bne a0, v1, (@@Exit)	;check to see if Andross is in dying state
	lh a0, 0x0002(t0)
	li v1, 0x73
	beq a0, v1, (@@SoftResetEnd)	;if death timers are equal, do soft reset
	li v1, 0x72
	beq a0, v1, (@@SoftResetEnd)
	nop
	j NextTableEntry
	nop
	
@@SoftResetEnd:
	jal DoSpecialState	;force freeze 
	li a0, 3
	li v0, 0x1
	sb v0, (LOC_ENDSCREEN_FLAG8)	;do score calculations
	lw a0, orga(gWaitTimer) (gp)
	addiu a0, a0, 1
	sw a0, orga(gWaitTimer) (gp)
	li v1, 0xB0
	bne a0, v1, (@@Exit)	;wait x amount of time then do reset to map screen
	nop
	jal DoSoftResetWithFlag
	li a0, 4
	jal DoSpecialState
	li a0, 2
	sw r0, orga(gWaitTimer) (gp)
	j NextTableEntry
	nop
	
@@PlanetScreenChecks:

	jal KillLevelStoreFunction
	nop
	lw v0, orga(gMarathonModeAddToCompletedTimesFlag) (gp)
	beq v0, r0, (@@CheckLives)
	lw a0, orga(gMarathonModeCompletedTimes) (gp)
	addiu a0, a0, 1
	sw a0, orga(gMarathonModeCompletedTimes) (gp)	;add to completed times then unset flags
	sw r0, orga(gMarathonModeSetPlanetActiveFlag) (gp)
	sw r0, orga(gWaitTimer) (gp)
	sw r0, orga(gMarathonModeAddToCompletedTimesFlag) (gp)
@@CheckLives:
	jal @CheckPrevLivesAndResetCompletedTimes	;check if player retried
	nop
	la t0, gMarathonModeLevelList
	lw a0, orga(gMarathonModeCompletedTimes) (gp)
	addu t0, a0, t0
	lb a0, 0x0000(t0)	;get level based on completed times
	jal StoreLevelID	;store level
	nop
@@Exit:
	j NextTableEntry
	nop
	
	
	/* Sub functions */
	
@CheckPrevLivesAndResetCompletedTimes:

	lw a0, orga(gPlayerLivesNotEqualFlag) (gp)
	bne a0, r0, (@@End)
	lw v0, orga(gPreviousLives)(gp)
	lb v1, (LOC_PLAYER_LIVES8)
	sltu v0, v1, v0
	beq v0, r0, (@@End)
	lw a0, orga(gMarathonModeCompletedTimes) (gp)
	addiu a0, a0, -1
	sw a0, orga(gMarathonModeCompletedTimes) (gp)
	li v0, 1
	sw v0, orga(gPlayerLivesNotEqualFlag)(gp)	;Unsets in TBL_FUNC_InitLevelStartVars
@@End:
	jr ra
	nop


.endautoregion