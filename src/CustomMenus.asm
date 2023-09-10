

	/* Custom menu functions go here. No idea how RSP stuff works, it just does. 
	   All custom functions here are calls from game code, as the randomizer is too far (early?) along main loop to render on-screen. */
	
	/* Calls to code.	*/
	@FUNC_GET_NEXT_RSP_FREE equ 0x800b4950		;gets next RSP area and signals a display list start
	@FUNC_RENDER_TEXT equ 0x8009cd90
	@FUNC_HEXTODEC equ 0x8008784c		;actually aligns text, not always needed
	@FUNC_RENDER_HEXTODEC equ 0x8009ba30	;renders hex value in a2 to decimal
	
	/* Pointers */
	@LOC_RSP_AREA equ 0x80133474
	
	/* RSP commands */
	@G_SETPRIMCOLOR equ 0xFA000000 
	
	/* misc defines for this file */
	@DEFAULT_TEXT_SIZE equ 1.0
	
	/* text alignment presets */
	@TOP_OF_SCREEN_A0 equ 0x5A
	@TOP_OF_SCREEN_A1 equ 0x10
	@BOTTOM_OF_SCREEN_A1 equ 0xDC
	@CENTER_A0 equ 0x30
	@CENTER_MENU_ITEM_1_A1 equ 0x2C
	@CENTER_MENU_ITEM_2_A1 equ 0x32
	@CENTER_MENU_ITEM_3_A1 equ 0x38
	@CENTER_MENU_ITEM_4_A1 equ 0x3E
	@CENTER_MENU_ITEM_5_A1 equ 0x44
	@CENTER_MENU_ITEM_6_A1 equ 0x4A
	@CENTER_MENU_ITEM_7_A1 equ 0x50
	@CENTER_MENU_ITEM_8_A1 equ 0x56
	@CENTER_MENU_ITEM_9_A1 equ 0x5C
	@CENTER_MENU_ITEM_10_A1 equ 0x62
	@CENTER_MENU_ITEM_11_A1 equ 0x68
	@CENTER_MENU_ITEM_12_A1 equ 0x6E
	@CENTER_MENU_ITEM_OFF_A0 equ 0xF4
	
	
.autoregion

SUB_MainMenuText:		;should be safe to use registers at - t7 whenever, just make sure its before / after text setups

	addiu sp, sp, -0x50
	sw ra, 0x004c(sp)
	sw fp, 0x0048(sp)
	sw s7, 0x0044(sp)
	sw s6, 0x0040(sp)
	sw s5, 0x003C(sp)
	sw s4, 0x0038(sp)
	sw s3, 0x0034(sp)
	sw s2, 0x0030(sp)
	sw s1, 0x002C(sp)
	sw s0, 0x0028(sp)
	SDC1 F20, 0x0020(sp)
	li s2, @LOC_RSP_AREA
	or a0, s2, r0
	jal @FUNC_GET_NEXT_RSP_FREE
	li a1, 0x53
	
	/* you can use starting here to the next end maker as a custom text render template for other menus. */
	
	li s6, @G_SETPRIMCOLOR	;rsp color command
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_CYAN			;text color
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE	;text size. anything lower than this renders poorly on hardware
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, GLOBAL_POINTER		;build date text
	sw t8, 0x0010(sp)
	li a0, 0x52		;pos 1 of text
	jal @FUNC_RENDER_TEXT
	li a1, 0xC6		;pos 2 of text
	
	/* end template marker */
	
	lw v0, orga(gDebugModeFlag) (gp)
	beq v0, r0, (@@SkipIfDebugOff)		;check if debug mode on
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
	lw a0, (LOC_POWER_ON_TIMER32)
	jal @FUNC_HEXTODEC
	or a2, a0, r0
	li a0, 0x20
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0xC6
	
@@SkipIfDebugOff:
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_YELLOW			;text color
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE	;text size
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, PressLtext		;press L text
	sw t8, 0x0010(sp)
	li a0, 0x32
	jal @FUNC_RENDER_TEXT
	li a1, 0x13
	li s6, @G_SETPRIMCOLOR	;rsp color command
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE			;text color
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE	;text size
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, UpDownText		;up down text
	sw t8, 0x0010(sp)
	li a0, 0x44
	jal @FUNC_RENDER_TEXT
	li a1, 0x20
	lw ra, 0x004c(sp)
	lw fp, 0x0048(sp)
	lw s7, 0x0044(sp)
	lw s6, 0x0040(sp)
	lw s5, 0x003C(sp)
	lw s4, 0x0038(sp)
	lw s3, 0x0034(sp)
	lw s2, 0x0030(sp)
	lw s1, 0x002C(sp)
	lw s0, 0x0028(sp)
	LDC1 F20, 0x0020(sp)
	jr ra
	addiu sp, sp, 0x50
	nop
	
SUB_RandomizerMenu:		;randomizer menu rendering and state checks

	addiu sp, sp, -0x50
	sw ra, 0x004c(sp)
	sw fp, 0x0048(sp)
	sw s7, 0x0044(sp)
	sw s6, 0x0040(sp)
	sw s5, 0x003C(sp)
	sw s4, 0x0038(sp)
	sw s3, 0x0034(sp)
	sw s2, 0x0030(sp)
	sw s1, 0x002C(sp)
	sw s0, 0x0028(sp)
	SDC1 F20, 0x0020(sp)
	li s2, @LOC_RSP_AREA
	or a0, s2, r0
	jal @FUNC_GET_NEXT_RSP_FREE
	li a1, 0x53
	jal CheckButtons
	li a0, 0
	andi a0, v1, BUTTON_R16		;check if R pressed to change color
	beq a0, r0, (@@CheckWhatMenu)
	
	/* check for user color */
	li t0, gRandomizerMenuColorTable
	lw a0, orga(gUserMenuColorSeek) (gp)
	addiu a0, a0, 1
	sw a0, orga(gUserMenuColorSeek) (gp)
	sll a0, a0, 2
	addu t0, a0, t0
	lwu a0, 0x0000(t0)		;load from table
	sw a0, orga(gUserMenuColorValue) (gp)
	beq a0, r0, (@@ResetColor)
	nop
	b (@@CheckWhatMenu)
	nop
@@ResetColor:
	sw r0, orga(gUserMenuColorSeek) (gp)
	lwu a0, orga(gRandomizerMenuColorTable) (gp)
	sw a0, orga(gUserMenuColorValue) (gp)
	/* end check */
	
@@CheckWhatMenu:		;add more menu branches here if more get added
	lw a0, orga(gCurrentRandomizerMenu) (gp)
	li v0, 1
	beq v0, a0, (RandomOptionsPage1)
	addiu v0, v0, 1
	beq v0, a0, (RandomOptionsPage2)
	addiu v0, v0, 1
	beq v0, a0, (SpecialModesPage1)
	addiu v0, v0, 1
	beq v0, a0, (RandomMiscPage1)
	addiu v0, v0, 1
	beq v0, a0, (RandomCreditsPage1)
	nop
	b (ExitRandomizerMenu)
	nop
	
RandomOptionsPage1:
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomizerPage1Text
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, @TOP_OF_SCREEN_A1
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RChangeColorText
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, @BOTTOM_OF_SCREEN_A1
	li s6, @G_SETPRIMCOLOR		;menu option 0 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomPlanetsText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_1_A1
	li s6, @G_SETPRIMCOLOR	;menu option 1 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, AllowSamePlanetsText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_2_A1
	li s6, @G_SETPRIMCOLOR		;menu option 2 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomItemsText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_3_A1
	li s6, @G_SETPRIMCOLOR		;menu option 3 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomEngineColorText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_4_A1
	li s6, @G_SETPRIMCOLOR		;menu option 4 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomExpertChanceText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_5_A1
	li s6, @G_SETPRIMCOLOR		;menu option 5 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomMusicText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_6_A1
	li s6, @G_SETPRIMCOLOR			;menu option 6 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomPortraitsText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_7_A1
	li s6, @G_SETPRIMCOLOR		;menu option 7 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomDialogText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_8_A1
	li s6, @G_SETPRIMCOLOR		;menu option 8 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomMapColorsText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_9_A1
	li s6, @G_SETPRIMCOLOR		;menu option 9 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomDeathItemText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_10_A1
	lw a0, orga(gMenuCursorValue) (gp)
	lw a1, orga(gRandomizerPage1MaxOptions) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@ButtonCheck)	;reset cursor on entry if cursor was over
	nop
	jal ResetRandomizerMenuCursors
	li a0, 2
@@ButtonCheck:
	jal CheckButtons
	li a0, 0
	andi a0, v1, BUTTON_D_PAD_UP16
	beq a0, r0, (@@CheckDownInput)		;check up pressed
	nop
	jal DecreaseCursorYLocation
	nop
	jal DecreaseCursorValue
	nop
	li.u a0, SFX_MOVE_CURSOR
	jal PlaySFX
	li.l a0, SFX_MOVE_CURSOR
	lw a0, orga(gMenuCursorValue) (gp)
	bne a0, r0, (@@CheckMenuOptionStates)		;reset cursor to top if up is pressed when already at the top
	nop
	jal ResetRandomizerMenuCursors
	li a0, 2
	b (@@CheckMenuOptionStates)
	nop
@@CheckDownInput:
	jal CheckButtons
	li a0, 0
	andi a0, v1, BUTTON_D_PAD_DOWN16
	beq a0, r0, (@@CheckMenuOptionStates)
	nop
	jal IncreaseCursorYLocation
	nop
	jal IncreaseCursorValue
	nop
	li.u a0, SFX_MOVE_CURSOR
	jal PlaySFX
	li.l a0, SFX_MOVE_CURSOR
	lw a0, orga(gMenuCursorValue) (gp)
	lw a1, orga(gRandomizerPage1MaxOptions) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@CheckMenuOptionStates)	;reset cursor based on max options in page
	nop
	jal ResetRandomizerMenuCursors
	li a0, 2
	b (@@CheckMenuOptionStates)
	nop
	
@@CheckMenuOptionStates:
	jal PrintCursor		;print cursor
	nop
	jal CheckButtons
	li a0, 0
	andi v0, v1, BUTTON_A16
	beq v0, r0, (@@RenderOnOffText)		;check if A pressed, if so continue and check where cursor was, if not, render on / off 
	li.u a0, SFX_CHANGE_OPTION
	jal PlaySFX
	li.l a0, SFX_CHANGE_OPTION
	lw a0, orga(gMenuCursorValue) (gp)		;based on menu cursor, check on / off states based where text was placed first.
	li v0, 0
	beq a0, v0, (@@RandomOptionsPage1Option0)
	li v0, 1
	beq a0, v0, (@@RandomOptionsPage1Option1)
	li v0, 2
	beq a0, v0, (@@RandomOptionsPage1Option2)
	li v0, 3
	beq a0, v0, (@@RandomOptionsPage1Option3)
	li v0, 4
	beq a0, v0, (@@RandomOptionsPage1Option4)
	li v0, 5
	beq a0, v0, (@@RandomOptionsPage1Option5)
	li v0, 6
	beq a0, v0, (@@RandomOptionsPage1Option6)
	li v0, 7
	beq a0, v0, (@@RandomOptionsPage1Option7)
	li v0, 8
	beq a0, v0, (@@RandomOptionsPage1Option8)
	li v0, 9
	beq a0, v0, (@@RandomOptionsPage1Option9)
	nop
	b (@@RenderOnOffText)
	nop
@@RandomOptionsPage1Option0:
	sw r0, orga(gMarathonModeFlag) (gp)
	sw r0, orga(gBossRushModeFlag) (gp)
	sw r0, orga(gProtectTheTargetsModeFlag) (gp)
	sw r0, orga(gSurvivalModeFlag) (gp)
	lw a0, orga(gRandomPlanetsFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gRandomPlanetsFlag) (gp)
	nop
@@RandomOptionsPage1Option1:
	sw r0, orga(gMarathonModeFlag) (gp)
	sw r0, orga(gBossRushModeFlag) (gp)
	lw a0, orga(gAllowSamePlanetsFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gAllowSamePlanetsFlag) (gp)
	nop
@@RandomOptionsPage1Option2:
	lw a0, orga(gRandomItemDropsFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gRandomItemDropsFlag) (gp)
	nop
@@RandomOptionsPage1Option3:
	lw a0, orga(gRandomEngineColorsFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gRandomEngineColorsFlag) (gp)
	nop
@@RandomOptionsPage1Option4:
	lw a0, orga(gRandomExpertFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gRandomExpertFlag) (gp)
	nop
@@RandomOptionsPage1Option5:
	lw a0, orga(gRandomMusicFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gRandomMusicFlag) (gp)
	nop
@@RandomOptionsPage1Option6:
	lw a0, orga(gRandomPortraitsFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gRandomPortraitsFlag) (gp)
	nop
@@RandomOptionsPage1Option7:
	lw a0, orga(gRandomDialogFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gRandomDialogFlag) (gp)
	nop
@@RandomOptionsPage1Option8:
	lw a0, orga(gRandomColorsActiveFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gRandomColorsActiveFlag) (gp)
	nop
@@RandomOptionsPage1Option9:
	lw a0, orga(gRandomDeathItemFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gRandomDeathItemFlag) (gp)
	nop
	
	
	
@@RenderOnOffText:

		li v0, gRandomPlanetsFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_1_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gAllowSamePlanetsFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_2_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gRandomItemDropsFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_3_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gRandomEngineColorsFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_4_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gRandomExpertFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_5_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gRandomMusicFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_6_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gRandomPortraitsFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_7_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gRandomDialogFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_8_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gRandomColorsActiveFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_9_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gRandomDeathItemFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_10_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		b (ExitRandomizerMenu)
		nop
		
RandomOptionsPage2:
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomizerPage2Text
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, @TOP_OF_SCREEN_A1
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RChangeColorText
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, @BOTTOM_OF_SCREEN_A1
	b (ExitRandomizerMenu)
	nop
SpecialModesPage1:
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomizerSpecialModesP1Text
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, @TOP_OF_SCREEN_A1
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RChangeColorText
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, @BOTTOM_OF_SCREEN_A1
	li s6, @G_SETPRIMCOLOR		;menu option 0 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, EnduranceModeText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_1_A1
	li s6, @G_SETPRIMCOLOR		;menu option 1 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, ProtectTheTargetsModeTimeText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_2_A1
	li s6, @G_SETPRIMCOLOR		;menu option 2 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, MarathonModeText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_3_A1
	li s6, @G_SETPRIMCOLOR		;menu option 3 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, BossRushModeText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_4_A1
	lw a0, orga(gMenuCursorValue) (gp)
	lw a1, orga(gRandomizerPage3MaxOptions) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@ButtonCheck)	;reset cursor on entry if cursor was over
	nop
	jal ResetRandomizerMenuCursors
	li a0, 2
@@ButtonCheck:
	jal CheckButtons
	li a0, 0
	andi a0, v1, BUTTON_D_PAD_UP16
	beq a0, r0, (@@CheckDownInput)		;check up pressed
	nop
	jal DecreaseCursorYLocation
	nop
	jal DecreaseCursorValue
	nop
	li.u a0, SFX_MOVE_CURSOR
	jal PlaySFX
	li.l a0, SFX_MOVE_CURSOR
	lw a0, orga(gMenuCursorValue) (gp)
	bne a0, r0, (@@CheckMenuOptionStates)		;reset cursor to top if up is pressed when already at the top
	nop
	jal ResetRandomizerMenuCursors
	li a0, 2
	b (@@CheckMenuOptionStates)
	nop
@@CheckDownInput:
	jal CheckButtons
	li a0, 0
	andi a0, v1, BUTTON_D_PAD_DOWN16
	beq a0, r0, (@@CheckMenuOptionStates)
	nop
	jal IncreaseCursorYLocation
	nop
	jal IncreaseCursorValue
	nop
	li.u a0, SFX_MOVE_CURSOR
	jal PlaySFX
	li.l a0, SFX_MOVE_CURSOR
	lw a0, orga(gMenuCursorValue) (gp)
	lw a1, orga(gRandomizerPage3MaxOptions) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@CheckMenuOptionStates)	;reset cursor based on max options in page
	nop
	jal ResetRandomizerMenuCursors
	li a0, 2
	b (@@CheckMenuOptionStates)
	nop
	
@@CheckMenuOptionStates:
	jal PrintCursor		;print cursor
	nop
	jal CheckButtons
	li a0, 0
	andi v0, v1, BUTTON_A16
	beq v0, r0, (@@RenderOnOffText)		;check if A pressed, if so continue and check where cursor was, if not, render on / off 
	li.u a0, SFX_CHANGE_OPTION
	jal PlaySFX
	li.l a0, SFX_CHANGE_OPTION
	lw a0, orga(gMenuCursorValue) (gp)		;based on menu cursor, check on / off states based where text was placed first.
	li v0, 0
	beq a0, v0, (@@RandomOptionsPage3Option0)
	li v0, 1
	beq a0, v0, (@@RandomOptionsPage3Option1)
	li v0, 2
	beq a0, v0, (@@RandomOptionsPage3Option2)
	li v0, 3
	beq a0, v0, (@@RandomOptionsPage3Option3)
	; li v0, 4
	; beq a0, v0, (@@RandomOptionsPage1Option4)
	; li v0, 5
	; beq a0, v0, (@@RandomOptionsPage1Option5)
	; li v0, 6
	; beq a0, v0, (@@RandomOptionsPage1Option6)
	; li v0, 7
	; beq a0, v0, (@@RandomOptionsPage1Option7)
	; li v0, 8
	; beq a0, v0, (@@RandomOptionsPage1Option8)
	; li v0, 9
	; beq a0, v0, (@@RandomOptionsPage1Option9)
	; li v0, 10
	; beq a0, v0, (@@RandomOptionsPage1Option10)
	; li v0, 11
	; beq a0, v0, (@@RandomOptionsPage1Option11)
	nop
	b (@@RenderOnOffText)
	nop
@@RandomOptionsPage3Option0:
	sw r0, orga(gMarathonModeFlag) (gp)
	sw r0, orga(gBossRushModeFlag) (gp)
	sw r0, orga(gProtectTheTargetsModeFlag) (gp)	;make conditional for this later
	lw a0, orga(gEnduranceModeFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gEnduranceModeFlag) (gp)
	nop
@@RandomOptionsPage3Option1:
	sw r0, orga(gRandomPlanetsFlag) (gp)	;make conditional for this later
	sw r0, orga(gMarathonModeFlag) (gp)	;make conditional for this later
	sw r0, orga(gBossRushModeFlag) (gp)	;make conditional for this later
	sw r0, orga(gEnduranceModeFlag) (gp)	;make conditional for this later
	lw a0, orga(gProtectTheTargetsModeFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gProtectTheTargetsModeFlag) (gp)
	nop
@@RandomOptionsPage3Option2:
	sw r0, orga(gRandomPlanetsFlag) (gp)
	sw r0, orga(gProtectTheTargetsModeFlag) (gp)	;make conditional for this later
	;sw r0, orga(gBossRushModeFlag) (gp)
	;sw r0, orga(gEnduranceModeFlag) (gp)
	lw a0, orga(gMarathonModeFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gMarathonModeFlag) (gp)
	nop
@@RandomOptionsPage3Option3:
	sw r0, orga(gProtectTheTargetsModeFlag) (gp)
	sw r0, orga(gEnduranceModeFlag) (gp)
	lw a0, orga(gBossRushModeFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gBossRushModeFlag) (gp)
	
@@RenderOnOffText:

		li v0, gEnduranceModeFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_1_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gProtectTheTargetsModeFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_2_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gMarathonModeFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_3_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gBossRushModeFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_4_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)

		b (ExitRandomizerMenu)
		nop
		
RandomMiscPage1:
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomizerMiscP1Text
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, @TOP_OF_SCREEN_A1
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RChangeColorText
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, @BOTTOM_OF_SCREEN_A1
	li s6, @G_SETPRIMCOLOR		;menu option 1 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, DebugModeText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_1_A1
	li s6, @G_SETPRIMCOLOR	;menu option 2 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RainbowBombsText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_2_A1
	li s6, @G_SETPRIMCOLOR		;menu option 3 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, OneHitKOText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_3_A1
	li s6, @G_SETPRIMCOLOR		;menu option 4 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, AllMedalsAndExpertText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_4_A1
	li s6, @G_SETPRIMCOLOR		;menu option 5 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, ChoosePlanetsText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_5_A1
	li s6, @G_SETPRIMCOLOR		;menu option 6 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, QuickScoreScreensText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_6_A1
	li s6, @G_SETPRIMCOLOR		;menu option 7 start
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, ExtraStarWolfsText
	sw t8, 0x0010(sp)
	li a0, @CENTER_A0
	jal @FUNC_RENDER_TEXT
	li a1, @CENTER_MENU_ITEM_7_A1
	lw a0, orga(gMenuCursorValue) (gp)
	lw a1, orga(gRandomizerPage4MaxOptions) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@ButtonCheck)	;reset cursor on entry if cursor was over
	nop
	jal ResetRandomizerMenuCursors
	li a0, 2
@@ButtonCheck:
	jal CheckButtons
	li a0, 0
	andi a0, v1, BUTTON_D_PAD_UP16
	beq a0, r0, (@@CheckDownInput)		;check up pressed
	nop
	jal DecreaseCursorYLocation
	nop
	jal DecreaseCursorValue
	nop
	li.u a0, SFX_MOVE_CURSOR
	jal PlaySFX
	li.l a0, SFX_MOVE_CURSOR
	lw a0, orga(gMenuCursorValue) (gp)
	bne a0, r0, (@@CheckMenuOptionStates)		;reset cursor to top if up is pressed when already at the top
	nop
	jal ResetRandomizerMenuCursors
	li a0, 2
	b (@@CheckMenuOptionStates)
	nop
@@CheckDownInput:
	jal CheckButtons
	li a0, 0
	andi a0, v1, BUTTON_D_PAD_DOWN16
	beq a0, r0, (@@CheckMenuOptionStates)
	nop
	jal IncreaseCursorYLocation
	nop
	jal IncreaseCursorValue
	nop
	li.u a0, SFX_MOVE_CURSOR
	jal PlaySFX
	li.l a0, SFX_MOVE_CURSOR
	lw a0, orga(gMenuCursorValue) (gp)
	lw a1, orga(gRandomizerPage4MaxOptions) (gp)
	sltu v0, a0, a1
	bne v0, r0, (@@CheckMenuOptionStates)	;reset cursor based on max options in page
	nop
	jal ResetRandomizerMenuCursors
	li a0, 2
	b (@@CheckMenuOptionStates)
	nop
	
@@CheckMenuOptionStates:
	jal PrintCursor		;print cursor
	nop
	jal CheckButtons
	li a0, 0
	andi v0, v1, BUTTON_A16
	beq v0, r0, (@@RenderOnOffText)		;check if A pressed, if so continue and check where cursor was, if not, render on / off 
	li.u a0, SFX_CHANGE_OPTION
	jal PlaySFX
	li.l a0, SFX_CHANGE_OPTION
	lw a0, orga(gMenuCursorValue) (gp)		;based on menu cursor, check on / off states based where text was placed first.
	li v0, 0
	beq a0, v0, (@@RandomOptionsPage4Option0)
	li v0, 1
	beq a0, v0, (@@RandomOptionsPage4Option1)
	li v0, 2
	beq a0, v0, (@@RandomOptionsPage4Option2)
	li v0, 3
	beq a0, v0, (@@RandomOptionsPage4Option3)
	li v0, 4
	beq a0, v0, (@@RandomOptionsPage4Option4)
	li v0, 5
	beq a0, v0, (@@RandomOptionsPage4Option5)
	li v0, 6
	beq a0, v0, (@@RandomOptionsPage4Option6)
	; li v0, 7
	; beq a0, v0, (@@RandomOptionsPage4Option7)
	; li v0, 8
	; beq a0, v0, (@@RandomOptionsPage4Option8)
	; li v0, 9
	; beq a0, v0, (@@RandomOptionsPage4Option9)
	; li v0, 10
	; beq a0, v0, (@@RandomOptionsPage4Option10)
	; li v0, 11
	; beq a0, v0, (@@RandomOptionsPage4Option11)
	nop
	b (@@RenderOnOffText)
	nop
	
@@RandomOptionsPage4Option0:
	lw a0, orga(gDebugModeFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gDebugModeFlag) (gp)
	nop
	b (ExitRandomizerMenu)
	nop
@@RandomOptionsPage4Option1:
	lw a0, orga(gRainbowBombsFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gRainbowBombsFlag) (gp)
	nop
	b (ExitRandomizerMenu)
	nop
@@RandomOptionsPage4Option2:
	lw a0, orga(gOneHitKOFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gOneHitKOFlag) (gp)
	nop
	b (ExitRandomizerMenu)
	nop
@@RandomOptionsPage4Option3:
	lw a0, orga(gUnlockAllMedalsAndExpertFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gUnlockAllMedalsAndExpertFlag) (gp)
	nop
@@RandomOptionsPage4Option4:
	sw r0, orga(gMarathonModeFlag) (gp)
	sw r0, orga(gBossRushModeFlag) (gp)
	sw r0, orga(gRandomPlanetsFlag) (gp)
	lw a0, orga(gEnablePlanetSelections) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gEnablePlanetSelections) (gp)
	nop
@@RandomOptionsPage4Option5:
	lw a0, orga(gQuickScoreScreensFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gQuickScoreScreensFlag) (gp)
	nop
@@RandomOptionsPage4Option6:
	lw a0, orga(gExtraStarWolfsFlag) (gp)
	xori a0, a0, 1
	b (@@RenderOnOffText)
	sw a0, orga(gExtraStarWolfsFlag) (gp)
	nop
	
@@RenderOnOffText:

		li v0, gDebugModeFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_1_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gRainbowBombsFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_2_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gOneHitKOFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_3_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gUnlockAllMedalsAndExpertFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_4_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gEnablePlanetSelections
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_5_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gQuickScoreScreensFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_6_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		li v0, gExtraStarWolfsFlag
		sw v0, orga(gOnOffLocationToRender) (gp)
		li a0, @CENTER_MENU_ITEM_OFF_A0
		sw a0, orga(gXposToRender) (gp)
		li a1, @CENTER_MENU_ITEM_7_A1
		jal PrintOnOffText
		sw a1, orga(gYposToRender) (gp)
		
		b (ExitRandomizerMenu)
		nop
		
RandomCreditsPage1:
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RandomizerCreditsP1Text
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, @TOP_OF_SCREEN_A1
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, RChangeColorText
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, @BOTTOM_OF_SCREEN_A1
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw t7, orga(gUserMenuColorValue) (gp)
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, CodedByText
	sw t8, 0x0010(sp)
	li a0, @TOP_OF_SCREEN_A0
	jal @FUNC_RENDER_TEXT
	li a1, 0x60
	b (ExitRandomizerMenu)
	nop
	
ExitRandomizerMenu:
	lw ra, 0x004c(sp)
	lw fp, 0x0048(sp)
	lw s7, 0x0044(sp)
	lw s6, 0x0040(sp)
	lw s5, 0x003C(sp)
	lw s4, 0x0038(sp)
	lw s3, 0x0034(sp)
	lw s2, 0x0030(sp)
	lw s1, 0x002C(sp)
	lw s0, 0x0028(sp)
	LDC1 F20, 0x0020(sp)
	jr ra
	addiu sp, sp, 0x50
	nop
	
SUB_InGameText:		;function for displaying in-game text whenever. Can use at-t7 and t8 registers.

	addiu sp, sp, -0x50
	sw ra, 0x004c(sp)
	sw fp, 0x0048(sp)
	sw s7, 0x0044(sp)
	sw s6, 0x0040(sp)
	sw s5, 0x003C(sp)
	sw s4, 0x0038(sp)
	sw s3, 0x0034(sp)
	sw s2, 0x0030(sp)
	sw s1, 0x002C(sp)
	sw s0, 0x0028(sp)
	SDC1 F20, 0x0020(sp)
	li s2, @LOC_RSP_AREA
	or a0, s2, r0
	jal @FUNC_GET_NEXT_RSP_FREE
	li a1, 0x53
	
	/* planet screen text check for choose planets */
	
	lw at, orga(gEnablePlanetSelections) (gp)
	beq at, r0, (@@Debugmodecheck)
	nop
	jal CheckMapScreenState
	li v1, 3
	bne v0, v1, (@@Debugmodecheck)
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
	li t8, ChoosePlanetsPlanetScreenText
	sw t8, 0x0010(sp)
	li a0, 0x12
	jal @FUNC_RENDER_TEXT
	li a1, 0x26
@@Debugmodecheck:
	lw v0, orga(gDebugModeFlag) (gp)
	beq v0, r0, (CheckEnduranceMode)		;go to endurance mode check
	nop
	/* debug mode section begin */
	
	jal CheckFoxState
	nop
	li v1, 0x1
	beq v0, v1, (@@DebugModeRenderInGame)
	li v1, 0x2
	beq v0, v1, (@@DebugModeRenderInGame)
	li v1, 0x3
	beq v0, v1, (@@DebugModeRenderInGame)
	li v1, 0x4
	beq v0, v1, (@@DebugModeRenderInGame)
	li v1, 0x5
	beq v0, v1, (@@DebugModeRenderInGame)
	li v1, 0x7
	beq v0, v1, (@@DebugModeRenderInGame)
	lb v0, (LOC_HAS_CONTROL_FLAG8)
	beq v0, r0, (@@CheckMapScreenState)	
	nop
@@DebugModeRenderInGame:
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_RED
	sw t7, 0x0004(s0)
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, DebugModeText
	sw t8, 0x0010(sp)
	li a0, 0xA
	jal @FUNC_RENDER_TEXT
	li a1, 0x8
	
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE
	sw t7, 0x0004(s0)
	jal CheckButtons
	li a0, 0
	or a2, v0, r0
	jal @FUNC_HEXTODEC
	or a0, v0, r0
	li a0, 0xA
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0xC6
	
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE
	sw t7, 0x0004(s0)
	lw a2, (LOC_ALIVE_TIMER32)
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	li a0, 0x112
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0xC6
	
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE
	sw t7, 0x0004(s0)
	lw a2, (LOC_ALLRANGEMODE_TIMER)
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	li a0, 0x112
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0xBE
	
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_BLUE
	sw t7, 0x0004(s0)
	lw a2, (LOC_CHECKPOINT_ALLRANGEMODE_FLAG)
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	li a0, 0x112
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0xB6
	
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_BLUE
	sw t7, 0x0004(s0)
	lw a2, (LOC_CHECKPOINT_HITS32)
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	li a0, 0x112
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0xAE
	
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_BLUE
	sw t7, 0x0004(s0)
	lw a2, (LOC_CHECKPOINT_SECTION_ID32)
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	li a0, 0x112
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0xA6
	
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE
	sw t7, 0x0004(s0)
	lw a2, (LOC_LEVEL_SECTION_ID32)
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	li a0, 0x112
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0x9E
	
	jal CheckButtons		;check for D-Pad Up press to store checkpoint
	li a0, 0x0
	addiu a0, r0, BUTTON_D_PAD_UP16		;d-pad up press check
	bne a0, v0, (@@ButtonPressCheck2)
	andi a0, v1, BUTTON_D_PAD_UP16		
	beq a0, r0, (@@ButtonPressCheck2)
	nop
	li.u a0, SFX_CHECKPOINT
	jal PlaySFX
	li.l a0, SFX_CHECKPOINT
	jal SaveCheckPoint
	nop
	b (@@CheckMapScreenState)
	nop
@@ButtonPressCheck2:
	addiu a0, r0, BUTTON_D_PAD_DOWN16		;d-pad down restart level or at checkpoint if set
	bne a0, v0, (@@ButtonPressCheck3)
	nop
	jal CheckFoxState
	nop
	addiu a0, r0, 6
	beq v0, a0, (@@SetDeathStateTimer)
	addiu a0, r0, 1
	beq v0, a0, (@@ButtonPressCheck3)
	addiu a0, r0, 0x01C8
	jal SetFoxState
	addiu a1, r0, 0x4
	li.u a0, SFX_COUNTDOWN_TIMER
	jal PlaySFX
	li.l a0, SFX_COUNTDOWN_TIMER
	jal CheckButtons
	addiu a0, r0, 0x0
	andi a0, v1, BUTTON_D_PAD_DOWN16		
	beq a0, r0, (@@ButtonPressCheck3)
	nop
@@SetDeathStateTimer:
	addiu a0, r0, 0x01F8
	jal SetFoxState
	addiu a1, r0, 0x2
	b (@@CheckMapScreenState)
	nop
@@ButtonPressCheck3:
	li a1, 1
	li a0, BUTTON_D_PAD_LEFT16		;d-pad left freeze frame advance
	beql a0, v0, (@@CheckFreezeFrameFlag)
	sw a1, orga(gDebugModeFreezeFrameFlag) (gp)
@@CheckFreezeFrameFlag:
	lw a1, orga(gDebugModeFreezeFrameFlag) (gp)
	beq a1, r0, (@@ButtonPressCheckResume)
	andi a0, v0, BUTTON_D_PAD_LEFT16
	beq a0, r0, (@@ButtonPressCheckResume)
	; andi a0, v1, BUTTON_D_PAD_LEFT16		
	; beq a0, r0, (@@ButtonPressCheckResume)
	nop
	jal DoSpecialState
	addiu a0, r0, 3
	andi a0, v1, BUTTON_D_PAD_LEFT16	
	beq a0, r0, (@@ButtonPressCheckResume)
	nop
	jal DoSpecialState
	addiu a0, r0,  2
	b (@@CheckMapScreenState)
	nop
@@ButtonPressCheckResume:
	addiu a0, r0, BUTTON_D_PAD_RIGHT16		;d-pad right resume from freeze
	bne a0, v0, (@@ButtonPressCheck4)
	andi a0, v1, BUTTON_D_PAD_RIGHT16		
	beq a0, r0, (@@ButtonPressCheck4)
	nop
	jal DoSpecialState
	addiu a0, r0, 2
	b (@@CheckMapScreenState)
	sw r0, orga(gDebugModeFreezeFrameFlag) (gp)
	nop
@@ButtonPressCheck4:
	; jal CheckButtons		;check for Z + D-Up to reset to planet screen
	; li a0, 0x0
	addiu a0, r0, BUTTON_Z16 + BUTTON_D_PAD_UP16
	bne a0, v0, (@@ButtonPressCheck5)
	andi a0, v1, BUTTON_D_PAD_UP16
	beq a0, r0, (@@ButtonPressCheck5)
	nop
	jal DoSoftReset
	addiu a0, r0, 4
	b (@@CheckMapScreenState)
	nop
@@ButtonPressCheck5:
	addiu a0, r0, BUTTON_Z16 + BUTTON_D_PAD_DOWN16		;check for Z + D-Down to reset title
	bne a0, v0, (@@ButtonPressCheck6)
	andi a0, v1, BUTTON_D_PAD_DOWN16
	beq a0, r0, (@@ButtonPressCheck6)
	nop
	jal DoSoftReset
	addiu a0, r0, 1
	b (@@CheckMapScreenState)
	nop
	
@@ButtonPressCheck6:

	addiu a0, r0, BUTTON_Z16 + BUTTON_D_PAD_LEFT16		;check for Z + D-Left to add bombs
	bne a0, v0, (@@ButtonPressCheck7)
	andi a0, v1, BUTTON_D_PAD_LEFT16
	beq a0, r0, (@@ButtonPressCheck7)
	nop
	lui at, 0x8017
	lb a0, 0xDC13(at)
	li v1, 9
	beql a0, v1, (@@CheckMapScreenState)
	sb v1, 0xDC13(at)
	addiu a0, a0, 1
	sb a0, 0xDC13(at)
	li.u a0, SFX_OBTAIN_BOMB
	jal PlaySFX
	li.l a0, SFX_OBTAIN_BOMB
	b (@@CheckMapScreenState)
	nop
@@ButtonPressCheck7:
	addiu a0, r0, BUTTON_Z16 + BUTTON_D_PAD_RIGHT16		;check for Z + C-Right to add life
	bne a0, v0, (@@ButtonPressCheck8)
	andi a0, v1, BUTTON_D_PAD_RIGHT16
	beq a0, r0, (@@ButtonPressCheck8)
	nop
	li.u a0, SFX_1UP
	jal PlaySFX
	li.l a0, SFX_1UP
	lui at, 0x8015
	lb a0, 0x7911(at)
	addiu a0, a0, 1
	sb a0, 0x7911(at)
	b (@@CheckMapScreenState)
	nop
	
@@ButtonPressCheck8:
	li a0, BUTTON_Z16 + BUTTON_R16 + BUTTON_L16		;speed up
	bne a0, v0, (@@ButtonPressCheck9)
	li a0, 0x0110
	jal SetFoxState
	lui a1, 0x42F0
	li.u a0, SFX_1UP
	jal PlaySFX
	li.l a0, SFX_1UP
	b (@@CheckMapScreenState)
	nop
	
@@ButtonPressCheck9:
	li a0, BUTTON_Z16 + BUTTON_R16		;add hypers
	bne a0, v0, (@@CheckMapScreenState)
	andi a0, v1, BUTTON_C_UP16
	beq a0, r0, (@@CheckMapScreenState)
	li a0, 2
	sb a0, (LOC_PLAYER_LASER8)
	li.u a0, SFX_OBTAIN_LASER
	jal PlaySFX
	li.l a0, SFX_OBTAIN_LASER
	b (@@CheckMapScreenState)
	nop
	
	
@@CheckMapScreenState:
	jal CheckMapScreenState
	li t7, 0x3
	beq v0, t7, (@@RenderLevelDebugText)
	li t7, 0x2
	beq v0, t7, (@@RenderLevelDebugText)
	li t7, 0x4
	beq v0, t7, (@@RenderLevelDebugText)
	li t7, 0x5
	beq v0, t7, (@@RenderLevelDebugText)
	nop
	b (CheckEnduranceMode)
	nop
@@RenderLevelDebugText:
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
	li t8, DebugLevelText
	sw t8, 0x0010(sp)
	li a0, 0x100
	jal @FUNC_RENDER_TEXT
	li a1, 0xB2
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE
	sw t7, 0x0004(s0)
	jal GetLevelID
	nop
	or a2, v0, r0
	jal @FUNC_HEXTODEC
	or a0, v0, r0
	li a0, 0x110
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0xBC
	
	/* debug mode section end */
	
CheckEnduranceMode:		;check if flag is on for rendering text. Logic is in EnduranceMode.asm
	lw at, orga(gEnduranceModeFlag) (gp)
	beq at, r0, (ProtectTheShipsCheck)
	lw at, orga(gEnduranceModeTimerDisplayFlag) (gp)
	beq at, r0, (ProtectTheShipsCheck)
	li t7, 0x7
	jal CheckFoxState
	nop
	beq v0, t7, (@@DisplayLevelTimer)
	li t7, 0x2
	beq v0, t7, (@@DisplayLevelTimer)
	lb v0, (LOC_HAS_CONTROL_FLAG8)
	bne v0, r0, (@@DisplayLevelTimer)
	nop
	b (@@DisplayTimeLeft)
	nop
@@DisplayLevelTimer:
	li s6, @G_SETPRIMCOLOR		;level timer text
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
	li t8, EnduranceModeLevelTimerText
	sw t8, 0x0010(sp)
	li a0, 0xB6
	jal @FUNC_RENDER_TEXT
	li a1, 0xE0
	li s6, @G_SETPRIMCOLOR		;timer
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	jal CheckIfExpert
	nop
	beq v0, r0, (@@NormalModeColors)		;level timer color checks
	lw a2, orga(gEnduranceModeLevelTimer) (gp)
	lw a0, orga(gEnduranceModePlanetTimerYellowExpert) (gp)
	blt a2, a0, (@@ExpertGreen)
	lw a0, orga(gEnduranceModePlanetTimerRedExpert) (gp)
	bgt a2, a0, (@@ExpertRed)
	lw a0, orga(gEnduranceModePlanetTimerYellowExpert) (gp)
	bgt a2, a0, (@@ExpertYellow)
	nop
	b (@@ExpertGreen)
	nop
@@NormalModeColors:
	lw a0, orga(gEnduranceModePlanetTimerYellowNormal) (gp)
	blt a2, a0, (@@ExpertGreen)
	lw a0, orga(gEnduranceModePlanetTimerRedNormal) (gp)
	bgt a2, a0, (@@ExpertRed)
	lw a0, orga(gEnduranceModePlanetTimerYellowNormal) (gp)
	bgt a2, a0, (@@ExpertYellow)
	nop
	b (@@ExpertGreen)
	nop
@@ExpertGreen:
	li.u t7, C_GREEN
	b (@@ChoosenColor)
	li.l t7, C_GREEN
	nop
@@ExpertYellow:
	li.u t7, C_YELLOW
	b (@@ChoosenColor)
	li.l t7, C_YELLOW
	nop
@@ExpertRed:
	li.u t7, C_RED
	b (@@ChoosenColor)
	li.l t7, C_RED
	nop
@@ChoosenColor:
	;li t7, C_WHITE		;change this for adding green, yellow and red based on nearing planet times
	sw t7, 0x0004(s0)
	;lw a2, orga(gEnduranceModeLevelTimer) (gp)
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	li a0, 0x106
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0xE0
@@DisplayTimeLeft:
	li s6, @G_SETPRIMCOLOR		;time left text
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
	li t8, EnduranceModeTimeLeftText
	sw t8, 0x0010(sp)
	li a0, 0x80
	jal @FUNC_RENDER_TEXT
	li a1, 0x8
	li s6, @G_SETPRIMCOLOR		;time left timer.
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw v0, orga(gEnduranceModeCurrentTimerGreenZone) (gp)
	lw a2, orga(gEnduranceModeCurrentTimer) (gp)
	bge a2, v0, (@@RenderGreenTimer)
	lw v0, orga(gEnduranceModeCurrentTimerYellowZone) (gp)
	bge a2, v0, (@@RenderYellowTimer)
	lw v0, orga(gEnduranceModeCurrentTimerRedZone) (gp)
	ble a2, v0, (@@RenderRedTimer)
	nop
	b (ProtectTheShipsCheck)
	nop
@@RenderGreenTimer:
	li.u t7, C_GREEN
	b (@@ResumeWithColor)
	li.l t7, C_GREEN
	nop
@@RenderYellowTimer:
	li.u t7, C_YELLOW
	b (@@ResumeWithColor)
	li.l t7, C_YELLOW
	nop
@@RenderRedTimer:
	li.u t7, C_RED
	b (@@ResumeWithColor)
	li.l t7, C_RED
	nop
@@ResumeWithColor:
	sw t7, 0x0004(s0)
	;lw a2, orga(gEnduranceModeCurrentTimer) (gp)
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	sll t1, v0, 3
	li t2, 0xB0
	subu a0, t2, t1
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0x11
ProtectTheShipsCheck:
	lw at, orga(gProtectTheTargetsModeFlag) (gp)
	beq at, r0, (BossRushRenderText)
	nop
	jal CheckFoxState
	li t7, 7
	beq v0, t7, (@@RenderProtectTheShipsText)
	lb at, (LOC_HAS_CONTROL_FLAG8)
	li t7, 1
	beq at, t7, (@@RenderProtectTheShipsText)
	nop
	b (BossRushRenderText)
	nop
	
@@RenderProtectTheShipsText:
	lw a2, (LOC_ALIVE_TIMER32)
	li at, 0x300
	blt a2, at, (@@RenderTimer)
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
	li t8, KattText
	sw t8, 0x0010(sp)
	li a0, 0x8
	jal @FUNC_RENDER_TEXT
	li a1, 0x36
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE	
	sw t7, 0x0004(s0)
	lhu a2, (0x8015BCA6)	;katthealth
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	li a0, 0x8
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0x3E
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
	li t8, BillText
	sw t8, 0x0010(sp)
	li a0, 0x8
	jal @FUNC_RENDER_TEXT
	li a1, 0x48
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE	
	sw t7, 0x0004(s0)
	lhu a2, (0x8015B9B2)	;billhealth
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	li a0, 0x8
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0x50
@@RenderTimer:
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
	li t8, EnduranceModeLevelTimerText
	sw t8, 0x0010(sp)
	li a0, 0xB6
	jal @FUNC_RENDER_TEXT
	li a1, 0xE0
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE	
	sw t7, 0x0004(s0)
	lw a2, (LOC_ALIVE_TIMER32)
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	li a0, 0x106
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0xE0
	
	
BossRushRenderText:
	lw at, orga(gBossRushModeFlag) (gp)
	beq at, r0, (NextOption)
	; lb v0, (LOC_HAS_CONTROL_FLAG8)
	; bne v0, r0, (@BeginRender)
	; lw v0, (LOC_SPECIAL_STATE)
	; li v1, 0x64
	; beq v0, v1, (@BeginRender)
	nop
	jal CheckFoxState
	nop
	li v1, 0x3
	beq v0, v1, (@BeginRender)
	li v1, 0x5
	beq v0, v1, (@BeginRender)
	li v1, 0x7
	beq v0, v1, (@BeginRender)
	li v1, 0x2
	beq v0, v1, (@BeginRender)
	li v1, 0x9
	beq v0, v1, (@BeginRender)
	nop
	jal CheckMapScreenState
	li v1, 3
	beq v0, v1, (@BRMDebugText)
	li v1, 5
	beq v0, v1, (@BRMDebugText)
	nop
	b (NextOption)
	nop
	
@BeginRender:
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
	li t8, BRMScoreText
	sw t8, 0x0010(sp)
	li a0, 0x6E
	jal @FUNC_RENDER_TEXT
	li a1, 0x8
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE	
	sw t7, 0x0004(s0)
	lw a2, orga(gTimerScoreToDisplay) (gp)	;score counter
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	sll v0, v0, 3
	li v1, 0x93
	subu a0, v1, v0
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0x11
	
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
	li t8, BRMTotalScoreText
	sw t8, 0x0010(sp)
	li a0, 0xC2
	jal @FUNC_RENDER_TEXT
	li a1, 0x8
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE	
	sw t7, 0x0004(s0)
	lw a2, orga(gTimerFinalScore) (gp)	;total score counter
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	sll v0, v0, 3
	li v1, 0xE7
	subu a0, v1, v0
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0x11
@BRMDebugText:
	lw v0, orga(gDebugModeFlag) (gp)
	beq v0, r0, (NextOption)
	nop
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_RED	
	sw t7, 0x0004(s0)
	lw a2, (LOC_PLAYER_HITS32)	;level hits
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	sll v0, v0, 3
	li v1, 0x93
	subu a0, v1, v0
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0x19
	
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_RED	
	sw t7, 0x0004(s0)
	lw a2, (LOC_PLAYER_TOTAL_HITS32)	;total score
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	sll v0, v0, 3
	li v1, 0x93
	subu a0, v1, v0
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0x21
	
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
	li t8, BRMLastVenomTimersDEBUG
	sw t8, 0x0010(sp)
	li a0, 0xCB
	jal @FUNC_RENDER_TEXT
	li a1, 0x30
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	li t7, C_WHITE	
	sw t7, 0x0004(s0)
	lw a2, orga(gLastTimerVenoms) (gp)	;last VE timers
	jal @FUNC_HEXTODEC
	or a0, a2, r0
	sll v0, v0, 3
	li v1, 0x130
	subu a0, v1, v0
	jal @FUNC_RENDER_HEXTODEC
	li a1, 0x38
	
	li s6, @G_SETPRIMCOLOR
	lw s0, 0x0000(s2)
	sw s6, 0x0000(s0)
	addiu t6, s0, 0x0008
	sw t6, 0x0000(s2)
	lw v0, orga(gTunnels2IsDoneFlag) (gp)
	beq v0, r0, (@@Tun2FlagOff)
	li t7, C_GREEN
	b (@@Resume)
	sw t7, 0x0004(s0)
@@Tun2FlagOff:
	li t7, C_RED
	sw t7, 0x0004(s0)
@@Resume:
	li at, @DEFAULT_TEXT_SIZE
	mtc1 at, f20
	mfc1 a2, f20
	mfc1 a3, f20
	li t8, BRMTunnelsFlagDEBUG
	sw t8, 0x0010(sp)
	li a0, 0xEE
	jal @FUNC_RENDER_TEXT
	li a1, 0x40
	
	
NextOption:
	b (ExitInGameText)
	nop

	
; @@FixPauseMenuOpCodes: for later

	; li v0, 0x0c021e04
	; sw v0, 0x8008b9e8
	; li v0, 0x0c021140
	; sw v0, (0x8008b9f0)
	; li v0, 0x0c02d091
	; sw v0, (0x8009eba4)
	; b @@Exit
	; nop
	
ExitInGameText:
	lw ra, 0x004c(sp)
	lw fp, 0x0048(sp)
	lw s7, 0x0044(sp)
	lw s6, 0x0040(sp)
	lw s5, 0x003C(sp)
	lw s4, 0x0038(sp)
	lw s3, 0x0034(sp)
	lw s2, 0x0030(sp)
	lw s1, 0x002C(sp)
	lw s0, 0x0028(sp)
	LDC1 F20, 0x0020(sp)
	j 0x8002a0d8		;returns to call that was replaced
	addiu sp, sp, 0x50
	
.endautoregion