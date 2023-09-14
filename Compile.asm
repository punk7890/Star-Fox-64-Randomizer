;Compiles all code into binary. Include your code here.

.n64
.create "Randomizer.bin", 0x80400000

	.include "src/GlobalDefines.asm"	;new defines for useful memory locations go here
	.include "src/GlobalPointer.asm"	;new flags / rando values go here
	.include "src/RandoTable.asm"		;new function entries go here
	.include "src/RandoMain.asm"		;place new randomizer functions here. Entry point for this function is hardcoded to 0x80410000.
	.include "src/RandoSetups.asm"		;randomizer setups on main entry
	.include "src/EnduranceMode.asm"	;special mode
	.include "src/CustomShips.asm"		;custom ships for survival mode and protect the targets
	.include "src/ProtectTheTargetsMode.asm"	;custom mode for Katina.
	;.include "src/SurvivalMode.asm"
	.include "src/MarathonMode.asm"		;special mode where all planets can be completed in a single run
	.include "src/BossRushMode.asm"		;special mode
	.include "src/SpecialStage.asm"
	.include "src/CustomFunctions.asm"	;place your useful custom functions for quick calls here
	.include "src/CustomMenus.asm"		;custom menu related functions
	.include "src/CustomMenuText.asm"	;text for custom menus
	
	/* If needed for very large functions, place code below here. */
	
	
	/* end user created functions */
	
	.include "src/DummyFill.asm"		;marks the four bytes before size end
	