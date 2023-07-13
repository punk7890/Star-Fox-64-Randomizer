

	/* Used for reseting values when at the main menu, and determining what randomizer menu the player is in. */

.n64

.autoregion

RandoSetups:

	li.u gp, (GLOBAL_POINTER) 		;No idea how to properly use all 64kb of global pointer space with this compiler, so it's limited to 32kb. Make sure the location to gp doesn't change.
	;li.l gp, (GLOBAL_POINTER)
	sw r0, orga(gRandoSeekEntry)(gp) 	;reset table entry on re-entry to randomizer
	addiu sp, sp, -0x4
	sw ra, 0x0000(sp)
	lw v0, orga(gUnlockAllMedalsAndExpertFlag) (gp)		;put expert unlock somewhere else later
	beq v0, r0, (@@Continue)
	nop
	jal UnlockExpert
	nop
@@Continue:
	lw at, orga(gCrashHandlerHookCreated) (gp)
	bne at, r0, (@@MainMenuChecks)
	li v0, 0x08001FE3		;force crash handler screen if game crashes
	sw v0, (0x80007E58)
	li v0, 1
	sw v0, orga(gCrashHandlerHookCreated) (gp)
@@MainMenuChecks:	

/* check if at main menu then reset in-game randomizer flags and other variables if so */

	jal CheckIfMainMenu		;check if in main menu
	li t7, 0x3E8
	bne v0, t7, (@@Exit)
	lw v0, orga(gMainMenuTextHookValue) (gp)
		sw v0, (0x8018996c)		;store menu text hook at end of main menu loop in code
		lw v0, orga(gInGameTextHookValue) (gp)
		sw v0, (0x8009f0d8)		;stores hook value to create a routine for in-game text
		li at, 0x8002BC9C
		li v0, 0x27bdffe0
		sw v0, 0x0000(at)		;Protect the Targets mode restores
		li v0, 0xafb00018
		sw v0, 0x0004(at)		;Protect the Targets mode restores
		lui at, 0x8003	
		li v0, 0x27bdffa8
		sw v0, 0xAD10(at)	;Protect the Targets mode restores
		li v0, 0xafbf0054
		sw v0, 0xAD14(at)	;Protect the Targets mode restores
		li at, 0x8002e858
		li v0, 0x15210049
		sw v0, 0x0000(at)	;Protect the Targets mode restores
		li at, 0x800AD69F	;Protect the Targets mode restores
		li v1, 2
		sb v1, 0x0000(at)	;Protect the Targets mode restores
		jal ClearPlayerFlagsAndStatsInGP	;clears player stats and randomizer flags at main menu
		nop
		jal CheckButtons
		li a0, 0
		andi a0, v1, BUTTON_L16		;check if L pressed
		beq a0, r0, (@@LoadPlayerInfo)
		nop
			jal AddToRandomizerMenuValue
			nop
			jal CheckRandomizerMenu
			li t7, -1
		beq v0, t7, (@@DisableMenu)		;disable menu if over valid menu IDs
		nop
				jal EnableRandomizerMenu
				nop
					b @@LoadPlayerInfo
					nop
@@DisableMenu:
		jal DisableRandomizerMenu
		nop
		b @@LoadPlayerInfo
		nop
@@LoadPlayerInfo:
		jal LoadPlayerInfoToGame	;always leave at bottom
		nop
		
@@Exit:
	lw ra, 0x0000(sp)	
	jr ra
	addiu sp, sp, 0x4
	nop

.endautoregion

