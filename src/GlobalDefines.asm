;Global memory locations and function pointers for quick accessing.

.n64

/* Useful memory locations */

	.definelabel LOC_FOX_POINTER32, 0x8016E0F0	;memory location for the current pointer to Fox. Changes between red/blue engine levels
		;current pointer + 0x01C8 is Fox's current state. 32 bit values below are the states:
		;1 = spawning in / reset
		;2 = intro scene
		;3 = has control
		;4 = dying
		;5 = uturn
		;6 = dead
		;7 = completed level scene
		;9 = changing to all range mode
	.definelabel LOC_SPECIAL_STATE, 0x8016D6C4 	;0x1 = reset level or restart at checkpoint (crashes on hardware), 0x2 resume, 0x3 softlock (set to 0x2 to resume), 0x64 pause
	.definelabel LOC_POWER_ON_TIMER32, 0x800C18C0		;a simple incremental timer since power on
	.definelabel LOC_ALIVE_TIMER32, 0x8016dc20 			;incremental timer since player spawned. resets if died.
	.definelabel LOC_NUM_PLANETS_COMPLETED32, 0x8016d9b8	;num planets completed by game code, randomizer completed times will be elsewhere
	.definelabel LOC_EXPERT_FLAG32, 0x8016d868	;flag for expert mode. 1 if on.
	.definelabel LOC_SUB_SECTION_FLAG32, 0x8016e0ec 	;flag that determines sub section of level, like warps and tunnel 2
	.definelabel LOC_LEVEL_ID32, 0x8016e0a4		;level id the game only reads while in-game, or before selecting a planet
	.definelabel LOC_PLAYER_BOMBS8, 0x8016DC13
	.definelabel LOC_PLAYER_LIVES8, 0x80157911	;player lives
	.definelabel LOC_PLAYER_LASER8, 0x8015791B
	.definelabel LOC_PLAYER_HITS32, 0x80157908	;current level hits
	.definelabel LOC_PLAYER_TOTAL_HITS32, 0x80157584
	.definelabel LOC_LEVEL_SECTION_ID32, 0x8016DC38 ;current section of the level
	.definelabel LOC_CHECKPOINT_HITS32, 0x8015790C ;location that saved your current level hits after collecting a checkpoint
	.definelabel LOC_CHECKPOINT_LEVEL_POS32, 0x8016DB20 ;position saved to checkpoint
	.definelabel LOC_CHECKPOINT_SECTION_ID32, 0x8016DB10	;level section ID saved to checkpoint
	.definelabel LOC_HAS_CONTROL_FLAG8, 0x8015789C ;does player have control flag. 1=yes, 0=no
	.definelabel LOC_INTRO_OUTRO_TIMER32, 0x8016D8F0	;timer that counts up when fox states are 0x2 and 0x7
	.definelabel LOC_ENDSCREEN_FLAG8, 0x8016D6A0
	
	.definelabel LOC_MAP_DATA_POINTER32, 0x8016E180
	
/* Functions from game code below here */

	.definelabel FUNC_PLANET_SELECTED, 0x8019C1D8		;Only loaded in planet screen.
	
/* Button defines */

	.definelabel BUTTON_D_PAD_UP16, 0x0800
	.definelabel BUTTON_D_PAD_DOWN16, 0x0400
	.definelabel BUTTON_D_PAD_LEFT16, 0x0200
	.definelabel BUTTON_D_PAD_RIGHT16, 0x0100
	.definelabel BUTTON_L16, 0x0020
	.definelabel BUTTON_R16, 0x0010
	.definelabel BUTTON_C_UP16, 0x0008
	.definelabel BUTTON_C_DOWN16, 0x0004
	.definelabel BUTTON_C_LEFT16, 0x0002
	.definelabel BUTTON_C_RIGHT16, 0x0001
	.definelabel BUTTON_START16, 0x1000
	.definelabel BUTTON_Z16, 0x2000
	.definelabel BUTTON_B16, 0x4000
	.definelabel BUTTON_A16, 0x8000
	
/* Misc stuff */

	.definelabel C_RED, 0xFF0000FF
	.definelabel C_GREEN, 0x00FF00FF
	.definelabel C_BLUE, 0x0000FFFF
	.definelabel C_YELLOW, 0xFFFF00FF
	.definelabel C_CYAN, 0x00FFFFFF
	.definelabel C_PURPLE, 0xFF00FFFF
	.definelabel C_WHITE, 0xFFFFFFFF
	.definelabel C_BLACK, 0x000000FF
	.definelabel SFX_MOVE_CURSOR, 0x49000002
	.definelabel SFX_CHANGE_OPTION, 0x49000038
	.definelabel SFX_CHECKPOINT, 0x4900000F
	.definelabel SFX_OBTAIN_LASER, 0x49000004
	.definelabel SFX_OBTAIN_BOMB, 0x49000005
	.definelabel SFX_OBTAIN_SILVER_RING, 0x4900000E
	.definelabel SFX_OBTAIN_STAR, 0x4900000D
	.definelabel SFX_1UP, 0x49000024
	.definelabel SFX_ERROR, 0x4900000A ;unused SFX
	.definelabel SFX_COUNTDOWN_TIMER, 0x4900002A
	.definelabel SFX_PEPPER_STEEP_BILL, 0x000000FF	;this is one steep bill
	.definelabel SFX_PEPPER_WHAT, 0x49000033