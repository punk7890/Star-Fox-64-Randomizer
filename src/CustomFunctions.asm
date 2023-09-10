;Place useful functions and other checks here.

.n64

.autoregion		;should automatically move code after RandoSetups.asm without overwriting previous code

CheckIfMainMenu:  ;returns 0x3E8 in v0 if in main menu, otherwise 0

	lw v0, (0x801AEF94)
	li v1, 0x3E8
	bnel v1, v0, @@End
	li v0, 0

@@End:
	jr ra
	nop

CheckMapScreenState:	;v0=3 if selecting, 5 if confirm planet menu is on-screen

	lui v0, 0x801C
	jr ra
	lw v0, 0x37b4(v0)
	nop
	
AddToRandomizerMenuValue:		;simply adds to the current menu. If over max menus, resets.

	lw a0, orga(gCurrentRandomizerMenu) (gp)
	addiu a0, a0, 1
	lw a1, orga(gMaxRandomizerMenus) (gp)
	bgtl a0, a1, (@@End)
	li a0, 0
@@End:
	jr ra
	sw a0, orga(gCurrentRandomizerMenu) (gp)
	nop
	
CheckRandomizerMenu:		;checks what menu the player is in. If menu 0 or over valid menus, returns -1 in v0

	lw a0, orga(gCurrentRandomizerMenu) (gp)
	beql a0, r0, (@@End)
	li v0, -1
	lw a1, orga(gMaxRandomizerMenus) (gp)
	bgtl a0, a1, (@@End)
	li v0, -1
@@End:
	jr ra
	nop

EnableRandomizerMenu:		;places a call to override the main menu. Use "DisableRandomizerMenu" to restore.

	lw a0, orga(gRandomizerMenuHookValue) (gp)
	sw a0, (0x8017d410)
	sw r0, (0x8017d400)
	jr ra
	nop
	
DisableRandomizerMenu:		;restores the main menu

	li a0, 0x0C06206C		;restores op code overriden
	sw a0, (0x8017d410)
	li a0, 0x0C061FCD		;restores op code overriden
	sw a0, (0x8017d400)
	jr ra
	sw r0, orga(gCurrentRandomizerMenu) (gp)
	nop
	

KillLevelStoreFunction:		;kills the level selected function in game code so that randomized planets takes priority. 
			;There isn't a need to restore this as once the player isn't in the map screen and goes back to it later, it's re-loaded into memory.

	li v0, 0x03E00008 	;jr ra, nop
	sw v0, (FUNC_PLANET_SELECTED)	;location of function
	jr ra
	sw.l r0, (FUNC_PLANET_SELECTED+4)	;lower half of (at)
	nop

SeekToNewLevel:	
			;Adds +1 to gLevelListSeek for reading IDs from gLevelList if planet isn't invalid, otherwise resets seek entry.

	li at, LOC_LEVEL_ID32
	li t0, gLevelListSeek
	li t1, gLevelList
	lw a0, 0x0000(t0)		;load seek
	addiu a0, a0, 1
	sw a0, 0x0000(t0)
	addu t2, t1, a0
	lb v0, 0x0000(t2)		;load level from list
	li v1, 0xFFFFFFFF
	beq v0, v1, @@ResetSeekId	;checks if level ID invalid
		nop
		jr ra
		sw v0, 0x0000(at)	;LOC_LEVEL_ID32
		nop
@@ResetSeekId:
	lb v0, orga(gLevelList) (gp)
	sw v0, 0x0000(at)
	jr ra
	sw r0, orga(gLevelListSeek) (gp)
	nop

; LoadNewLevel:		;Loads actual level ID from gLevelList based on gLevelListSeek entry and stores it to LOC_LEVEL_ID32 so the game reads it. Also returns in v0 if needed.

	; li at, LOC_LEVEL_ID32
	; lw v0, orga(gLevelListSeek) (gp)
	; addu t0, v0, gp
	; lb v0, orga(gLevelList) (t0)
	; li v1, -1
	; beql v1, v0, (@@End)
	; lb v0, orga(gLevelList) (gp)	;if invalid level, load from first entry in list
; @@End:
	; jr ra
	; sw v0, 0x0000(at)
	; nop
		
StoreLevelID:		;simply stores a0 as the level ID when called. Skips if not valid.

	sltiu v0, a0, 0x0016
	beq v0, r0, (@@End)
	nop
	sw a0, (LOC_LEVEL_ID32)
@@End:
	jr ra
	nop

GetLevelID:		;returns in v0

	lw.u v0, (LOC_LEVEL_ID32)	
	jr ra
	lw.l v0, (LOC_LEVEL_ID32)
	nop
	
CheckSameLevels:		;checks if the player completed a level they are about to go into and stores a new ID from gLevelList to actual level memory location. Only checks 5 levels. There's very likely a better way to do this.

	li t7, -1
	lui t9, 0x8017
	lw a0, 0xe0a4(t9) ;LOC_LEVEL_ID32
	li t0, gPreviousLevelList
	li t8, gLevelList
	; or v0, r0, r0
	; li v1, gMaxLevelList	;max levels in list
	lb t1, 0x0000(t0)	;prevlevellist
	lb t2, 0x0001(t0)
	lb t3, 0x0002(t0)
	lb t4, 0x0003(t0)
	lb t5, 0x0004(t0)
@@Loop:
	lb a1, 0x0000(t8)	;regular level list
	beq a1, t7, (@@Exit)
	nop
	beq a0, t1, (@@Cycle)
	nop
	beq a0, t2, (@@Cycle)
	nop
	beq a0, t3, (@@Cycle)
	nop
	beq a0, t4, (@@Cycle)
	nop
	beq a0, t5, (@@Cycle)
	nop
	beq a1, a0, (@@Cycle)
	nop
	; blt v0, v1, (@@Cycle)
	; nop
	jr ra
	nop
	
@@Cycle:
	sw a1, 0xe0a4(t9)
	or a0, a1, r0
	b (@@Loop)
	addiu t8, t8, 1
@@Exit:
	jr ra
	nop
	
	
	
OrderPlanets:		;orders planets in planet screen based on the last completed planet and level ID. For whatever reason, these are different from actual level ID.

		/* Planet icon ID defines */
		@PLANET_METEO equ 0x0
		@PLANET_A6 equ 0x1
		@PLANET_BOLSE equ 0x2
		@PLANET_SECTORZ equ 0x3
		@PLANET_SECTORX equ 0x4
		@PLANET_SECTORY equ 0x5
		@PLANET_KATINA equ 0x6
		@PLANET_MACBETH equ 0x7
		@PLANET_ZONESS equ 0x8
		@PLANET_CORNERIA equ 0x9
		@PLANET_TITANIA equ 0xA
		@PLANET_AQUAS equ 0xB
		@PLANET_FORTUNA equ 0xC
		@PLANET_VENOM equ 0xD
		@PLANET_SOLOR equ 0xE

	lui t0, 0x8017
	lw a0, 0xD9B8(t0) ;LOC_NUM_PLANETS_COMPLETED32
	sll t2, a0, 2
	addu t2, t2, t0 	;t2 = planet completed icon ID location
	lw a1, 0xE0A4(t0) ;LOC_LEVEL_ID32
	li v0, 0x0
	bne v0, a1, (@@Meteo)
	li v0, @PLANET_CORNERIA
	sw v0, 0xDA00(t2)
@@Meteo:
	li v0, 0x1
	bne v0, a1, (@@SectorX)
	nop
	sw r0, 0xDA00(t2)
@@SectorX:
	li v0, 0x2
	bne v0, a1, (@@Area6)
	li v0, @PLANET_SECTORX
	sw v0, 0xDA00(t2)
@@Area6:
	li v0, 0x3
	bne v0, a1, (@@SectorY)
	li v0, @PLANET_A6
	sw v0, 0xDA00(t2)
@@SectorY:
	li v0, 0x5
	bne v0, a1, (@@Venom1Surface)
	li v0, @PLANET_SECTORY
	sw v0, 0xDA00(t2)
@@Venom1Surface:
	li v0, 0x6
	bne v0, a1, (@@Solor)
	li v0, @PLANET_VENOM
	sw v0, 0xDA00(t2)
@@Solor:
	li v0, 0x7
	bne v0, a1, (@@Zoness)
	li v0, @PLANET_SOLOR
	sw v0, 0xDA00(t2)
@@Zoness:
	li v0, 0x8
	bne v0, a1, (@@MacBeth)
	li v0, @PLANET_ZONESS
	sw v0, 0xDA00(t2)
@@MacBeth:
	li v0, 0xB
	bne v0, a1, (@@Titania)
	li v0, @PLANET_MACBETH
	sw v0, 0xDA00(t2)
@@Titania:
	li v0, 0xC
	bne v0, a1, (@@Aquas)
	li v0, @PLANET_TITANIA
	sw v0, 0xDA00(t2)
@@Aquas:
	li v0, 0xD
	bne v0, a1, (@@Fortuna)
	li v0, @PLANET_AQUAS
	sw v0, 0xDA00(t2)
@@Fortuna:
	li v0, 0xE
	bne v0, a1, (@@Katina)
	li v0, @PLANET_FORTUNA
	sw v0, 0xDA00(t2)
@@Katina:
	li v0, 0x10
	bne v0, a1, (@@Bolse)
	li v0, @PLANET_KATINA
	sw v0, 0xDA00(t2)
@@Bolse:
	li v0, 0x11
	bne v0, a1, (@@SectorZ)
	li v0, @PLANET_BOLSE
	sw v0, 0xDA00(t2)
@@SectorZ:
	li v0, 0x12
	bne v0, a1, (@@End)
	li v0, @PLANET_SECTORZ
	sw v0, 0xDA00(t2)
@@End:
	jr ra
	nop
	
CheckFoxState:	;returns a valid state in v0, otherwise returns -1.

	lw t0, (LOC_FOX_POINTER32)
	beq t0, r0, (@@End)
	li v0, -1
		lw v0, 0x01C8(t0)
		sltiu v1, v0, 0x000E
		beql v1, r0, (@@End)
		li v0, -1
@@End:
			jr ra
			nop
			
CheckFoxState2:		;returns state in v0. Pass memory address based on Fox pointer to check in a0 (16 bit).

	lw t0, (LOC_FOX_POINTER32)
	beq t0, r0, (@@End)
	li v0, -1
		addu a0, t0, a0
		lw v0, 0x0000(t0)
@@End:
		jr ra
		nop
			
SetFoxState:		;sets various Fox states. Pass 16bit address in a0, and value to write to location in a1 (32 bit store).

	lw t0, (LOC_FOX_POINTER32)
	beq t0, r0, (@@End)
	addu t0, a0, t0
	sw a1, 0x0000(t0)
@@End:
	jr ra
	nop
			
LoadPlayerInfoToGP:		;sets and stores various global player related information to global pointer. Best used with CheckFoxState and soft resets.

	li.u at, (LOC_PLAYER_LIVES8)
	lb a0, 0x7911(at)   ;lives
	lb a1, 0x791B(at)	;lasers
	lw a2, 0x7584(at)	 ;total hits
	lb a3, (LOC_PLAYER_BOMBS8)	;bombs
	sw a0, orga(gPreviousLives)(gp)
	sw a1, orga(gPreviousLasers)(gp)
	sw a2, orga(gPreviousTotalScore)(gp)
	sw a3, orga(gPreviousBombs)(gp)
	lw a0, (LOC_EXPERT_FLAG32)	;expert flag
	sw a0, orga(gPreviousExpertFlag) (gp)
	lw a0, (LOC_SUB_SECTION_FLAG32)
	sw a0, orga(gPreviousWarpFlag) (gp)
	jr ra
	nop
	
LoadPlayerInfoToGame:		;restores global player stats to main game

	lw a0, orga(gPreviousLives)(gp)
	lw a1, orga(gPreviousLasers)(gp)
	lw a2, orga(gPreviousTotalScore)(gp)
	lw a3, orga(gPreviousBombs)(gp)
	li.u at, (LOC_PLAYER_LIVES8)
	sb a0, 0x7911(at)   ;lives
	sb a1, 0x791B(at)	;lasers
	sw a2, 0x7584(at)	;total hits
	sb.u a3, (LOC_PLAYER_BOMBS8)
	sb.l a3, (LOC_PLAYER_BOMBS8)
	lw a0, (LOC_EXPERT_FLAG32)	;expert flag
	sw a0, orga(gPreviousExpertFlag) (gp)
	lw a0, orga(gPreviousWarpFlag) (gp)
	sw a0, (LOC_SUB_SECTION_FLAG32)
	jr ra
	nop
	
LoadPlayerInfoAsArguments:		;loads player info from Global Pointer into temp registers for comparing or checking values on call return.

	lw t0, orga(gPreviousLives)(gp) 	;lives in t0
	lw t1, orga(gPreviousLasers)(gp)	;lasers in t1
	lw t2, orga(gPreviousTotalScore)(gp)	;total score in t2
	lw t3, orga(gPreviousBombs)(gp)		;bombs in t3
	jr ra
	lw t4, orga(gPreviousLevel)(gp)		;previous level ID in t4
	nop
	
ClearPlayerFlagsAndStatsInGP:		;put all game related flags here for clearing. This gets read at the main menu and resets them

	li t7, -1
	sw t7, orga(gPreviousLevel) (gp)
	sw t7, orga(gPreviousLevelList) (gp)
	sw t7, orga(gPreviousLevelList4) (gp)
	sw t7, orga(gPreviousLevelList8) (gp)
	sw r0, orga(gRandomPlanetsDoneFlag) (gp)
	sw r0, orga(gPreviousWarpFlag) (gp)
	sw r0, orga(gPreviousTotalScore) (gp)
	sw r0, orga(gPreviousExpertFlag) (gp)
	lw at, orga(gEnduranceModeStartingTimer) (gp)
	sw at, orga(gEnduranceModeCurrentTimer) (gp)
	sw r0, orga(gEnduranceModePreviousHits) (gp)
	sw r0, orga(gDidQuickScoreScreensFlag) (gp)
	lw at, orga(gPreviousBombs) (gp)
	sw at, orga(gEnduranceModePreviousBombs) (gp)
	sw r0, orga(gRandomDeathItemInGameFlag) (gp)
	sw r0, orga(gMarathonModeAddToCompletedTimesFlag) (gp)
	sw r0, orga(gMarathonModeCompletedTimes) (gp)
	sw r0, orga(gMarathonModeSetPlanetActiveFlag) (gp)
	sw r0, orga(gWaitTimer) (gp)
	sw r0, orga(gPlayerLivesNotEqualFlag)(gp)
	sw r0, orga(gWolfsSpawnedFlag) (gp)
	sw r0, orga(gBRMAddToCompletedTimes) (gp)
	sw r0, orga(gBRMAddToCompletedTimesFlag) (gp)
	sw r0, orga(gPlayerLivesNotEqualFlagBRM) (gp)
	sw r0, orga(gTimerScore) (gp)
	sw r0, orga(gTimerActive) (gp)
	sw r0, orga(gTimerScoreToDisplay) (gp)
	sw r0, orga(gTimerFinalScore) (gp)
	sw r0, orga(gLastTimerVenoms) (gp)
	sw r0, orga(gLastAND2Timer) (gp)
	sw r0, orga(gTunnels2IsDoneFlag) (gp)
	sw r0, orga(gCornFlag) (gp)
	jr ra
	nop
	
DoSoftReset:		

	/* Resets to a given screen. Call with a0. 1 = title screen, 3, main menu (won't work in most cases), 4 = map screen, 5 = gameover. Erases everything the player did in main game. */

	;li a0, 0x4
	lw at, LOC_FOX_POINTER32
	beq at, r0, (@@SkipFoxCheck)
	nop
	sw r0, 0x01C8(at)	;fail safe for checks while in-game and using special states
@@SkipFoxCheck:
	sb r0, (LOC_HAS_CONTROL_FLAG8)	;set to zero for safety.
	sw a0, (0x801578a0)
	sh r0, (0x78a4) (at)
	sb.u r0, (0x8016d6a0) ;clears Mission Completed screen if it's on-screen
	jr ra
	sb.l r0, (0x8016d6a0)
	nop
	
DoSoftResetWithFlag:		;Same as above and sets gDidSoftReset to true

	;li a0, 0x4
	lw at, LOC_FOX_POINTER32
	beq at, r0, (@@SkipFoxCheck)
	nop
	sw r0, 0x01C8(at)	;fail safe for checks while in-game and using special states
@@SkipFoxCheck:
	sb r0, (LOC_HAS_CONTROL_FLAG8)	;set to zero for safety.
	sw a0, (0x801578a0)
	sh r0, (0x78a4) (at)
	sb r0, (0x8016d6a0) ;clears Mission Completed screen if it's on-screen
	li a0, 0x1
	jr ra
	sw a0, orga(gDidSoftReset) (gp)
	nop
	
CheckIfSoftReset:		;checks if a soft reset was done by the randomizer. Returns true in v0 if so.

	lw v0, orga(gDidSoftReset) (gp)
	bgel v0, 1, (@@End)
	li v0, 1
@@End:
	jr ra
	nop
	
UnsetFlagDidSoftReset: 	;simply unsets flag

	jr ra
	sw r0, orga(gDidSoftReset) (gp)
	nop
	
CheckPrevLives:		;checks actual lives and previous lives to see if they are equal. v0=1 if equal, otherwise 0.

	li v0, 0x0
	lw a0, orga(gPreviousLives)(gp)
	lb a1, (LOC_PLAYER_LIVES8)
	beql a0, a1, (@@End)
	li v0, 0x1
@@End:
	jr ra
	nop
	
CheckButtons: 

/* Checks button pressed and held. Returns held in v0, pressed in v1. Call with argument in a0.
a0 = Player ID. Player 1 (0x0) Player 2 (0x1) etc
*/

	li t0, (0x800D8E90)		;controller input addresses
	sll t1, a0, 2
	subu t1, t1, a0
	sll t1, t1, 1
	addu t1, t1, t0
	lhu v0, 0x0000(t1)
	jr ra
	lhu v1, 0x0018(t1)
	nop
	
PlaySFX:		;pass SFX ID in a0

	addiu sp, sp, -0x20
	sw ra, 0x001c(sp)
	li t0, 0x800c18bc
	sw t0, 0x0014(sp)
	li a1, 0x800c18a8
	li a2, 0x4
	li a3, 0x800c18b4
	jal 0x80019218
	sw a3, 0x0010(sp)
	lw ra, 0x001c(sp)
	jr ra
	addiu sp, sp, 0x20
	nop
	
	
SeekRandomItem:		;adds to seek ID. Returns -1 in v0 if invalid.

	
	lw v0, orga(gRandomItemDropsSeek) (gp)
	addiu v0, v0, 1
	sw v0, orga(gRandomItemDropsSeek) (gp)
	blt v0, 0x7, (@@Exit)		;valid number of items in table, if over return -1 and reset seek
	nop
	li v0, -1
	sw r0, orga(gRandomItemDropsSeek) (gp)
@@Exit:
	jr ra
	nop
	


LoadRandomItem:		;loads a random item from table in v0. If item isn't valid, returns -1. 

	lw v0, orga(gRandomItemDropsSeek) (gp)
	sll v0, v0, 2
	addu t0, v0, gp
	lw v0, orga(gRandomItemDropsTable) (t0)
	bltul v0, 0x142, (@@End)		;laser ID used for starting pos
		li v0, -1
		bgtul v0, 0x151, (@@End)	;wing repair is the last valid ID
		li v0, -1
@@End:
		jr ra
		nop
; LoadRandomItemFromPos:		;probably not needed. call with position in a0, item returns in v0

	; sll a0, a0, 2
	; addu t0, a0, gp
	; jr ra
	; lw v0, orga(gRandomItemDropsTable) (t0)
	; nop
	
UnlockExpert:		;make this reset to title screen if on once later

	li v0, 0x77777777
	sw v0, 0x8016e6e0
	sw.l v0, 0x8016e6e4
	sw.l v0, 0x8016e6e8
	jr ra
	sw.l v0, 0x8016e6ec
	nop
	
CheckIfExpert:		;returns 1 in v0 if so, else 0

	lw.u v0, (LOC_EXPERT_FLAG32)
	jr ra
	lw.l v0, (LOC_EXPERT_FLAG32)
	nop
	
SaveCheckPoint:		;creates a fake save position at foxes current pos when called. An actual checkpoint will erase this if collected before setting.

	lw t0, (LOC_FOX_POINTER32)
	beq t0, r0, (@@End)
	lw a0, (LOC_LEVEL_SECTION_ID32)	;grab current section ID
	sw a0, (LOC_CHECKPOINT_SECTION_ID32)	;save new section ID
	;lwu a1, 0x0144(t0)	;grab foxes pos
	lui at, 0x437A
	mtc1 at, f5
	lwc1 F4, 0x0144(t0)	;grab foxes pos
	sub.s f7, f4, f5
	swc1 f7, (LOC_CHECKPOINT_LEVEL_POS32)
	;sw a1, (LOC_CHECKPOINT_LEVEL_POS32)	;save pos to checkpoint pos
	lw a2, (LOC_PLAYER_HITS32)	;grab player level hits
	sw a2, (LOC_CHECKPOINT_HITS32) ;save player level hits
	lui at, 0x8015
	lw a0, 0x78F8(at)	;grab some sort of terrian ID and save it
	sw a0, 0x78FC(at)
	lbu a0, 0x74F4(at)	;grab ??? and save it
	lui at, 0x8017
	sb a0, 0x78C0(at)
	li v0, 0x8016D724
	li v1, 0x8016D744
	li a0, 0x8016D730
@@Loop:
	lw a1, 0x0000(v0)
	addiu v0, v0, 0x4
	addiu v1, v1, 0x4
	bne v0, a0, (@@Loop)
	sw a1, 0xFFFC(v1)
@@End:
	jr ra
	nop
	
DoSpecialState:		;does certain states like pause, freeze, resume or restart the level. Pass one of the values in a0 to this function.

;0x0 = reset level or restart at checkpoint, 0x2 resume, 0x3 softlock (set to 0x2 to resume), 0x64 pause screen. Don't use a reset level command in all range mode levels.

	sw.u a0, 0x8016D6C4
	jr ra
	sw.l a0, 0x8016D6C4
	nop
	
CheckSpecialState:		;returns state in v0

	lw.u v0, 0x8016D6C4
	jr ra
	lw.l v0, 0x8016D6C4
	nop
	
	/* Below is used only for custom menu related calls. */
	
PrintCursor:		;prints the cursor for menus based on gCursorStartingX and gCursorStartingY

	/* RSP commands */
	@G_SETPRIMCOLOR equ 0xFA000000 
	
	/* text define */
	@DEFAULT_TEXT_SIZE equ 1.0
	
	/* call define	*/
	@FUNC_RENDER_TEXT equ 0x8009cd90
	@FUNC_GET_NEXT_RSP_FREE equ 0x800b4950
	@LOC_RSP_AREA equ 0x80133474

	addiu sp, sp, -8
	sw ra, 0x0000(sp)
	li s2, @LOC_RSP_AREA
	or a0, s2, r0
	jal @FUNC_GET_NEXT_RSP_FREE
	li a1, 0x53
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, CursorText
	sw t8, 0x0010(sp)	;why is this storing outside of stack space??? I can't remember.
	lw a0, orga(gCursorStartingX) (gp)
	jal @FUNC_RENDER_TEXT
	lw a1, orga(gCursorStartingY) (gp)
	lw ra, 0x0000(sp)
	jr ra
	addiu sp, sp, 8
	nop

PrintOnOffText:		;prints on off text based on arguments. Store the location to the state to check to gOnOffLocationToRender and the X / Y pos to render in gXposToRender and gYposToRender before calling.

	addiu sp, sp, -8
	sw ra, 0x0000(sp)
	li s2, @LOC_RSP_AREA
	or a0, s2, r0
	jal @FUNC_GET_NEXT_RSP_FREE
	li a1, 0x53
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw v0, orga(gOnOffLocationToRender) (gp)
	beq v0, r0, (@@ToSize)		;was invalid so skipped
	nop
	lw v0, 0x0000(v0)
	beq v0, r0, (@@RenderOff)
	li t7, C_GREEN
	sw t7, 0x0004(s0)
	li t8, ONText
	sw t8, 0x0010(sp)
	b (@@ToSize)
	nop
@@RenderOff:
	li t7, C_RED
	sw t7, 0x0004(s0)
	li t8, OFFText
	sw t8, 0x0010(sp)
	b (@@ToSize)
	nop
@@ToSize:
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	lw a0, orga(gXposToRender) (gp)
	jal @FUNC_RENDER_TEXT
	lw a1, orga(gYposToRender) (gp)
	lw ra, 0x0000(sp)
	jr ra
	addiu sp, sp, 8
	nop
	
IncreaseCursorValue:		;simply increases gMenuCursorValue
	
	lw a1, orga(gMenuCursorValue) (gp)
	addiu a1, a1, 1
	jr ra
	sw a1, orga(gMenuCursorValue) (gp)
	nop

DecreaseCursorValue:		;decreases gMenuCursorValue and resets if negative
	
	lw a1, orga(gMenuCursorValue) (gp)
	addiu a1, a1, -1
	li v0, -1
	bnel v0, a1, (@@End)
	sw a1, orga(gMenuCursorValue) (gp)
	sw r0, orga(gMenuCursorValue) (gp)
@@End:
	jr ra
	nop
	
IncreaseCursorYLocation:		;increases cursor Y by 6
	
	lw a1, orga(gCursorStartingY) (gp)
	addiu a1, a1, 6
	jr ra
	sw a1, orga(gCursorStartingY) (gp)
	nop
	
DecreaseCursorYLocation:		;decreases cursor Y by -6
	
	lw a1, orga(gCursorStartingY) (gp)
	addiu a1, a1, -6
	jr ra
	sw a1, orga(gCursorStartingY) (gp)
	nop
	
ResetRandomizerMenuCursors:		;call with a0. a0=0 reset X, 1 = reset Y, 2 = reset both and cursor value

	li v0, 0
	beq a0, v0, (@@ResetX)
	li v0, 1
	beq a0, v0, (@@ResetY)
	li v0, 2
	beq a0, v0, (@@ResetBoth)
	nop
	b (@@End)
	nop
@@ResetX:
	lw a0, orga(gCursorStartingDefaultX) (gp)
	b (@@End)
	sw a0, orga(gCursorStartingX) (gp)
@@ResetY:
	lw a0, orga(gCursorStartingDefaultY) (gp)
	b (@@End)
	sw a0, orga(gCursorStartingY) (gp)
@@ResetBoth:
	sw r0, orga(gMenuCursorValue) (gp)
	lw a0, orga(gCursorStartingDefaultX) (gp)
	sw a0, orga(gCursorStartingX) (gp)
	lw a0, orga(gCursorStartingDefaultY) (gp)
	b (@@End)
	sw a0, orga(gCursorStartingY) (gp)
@@End:
	jr ra
	nop	
	

.endautoregion

