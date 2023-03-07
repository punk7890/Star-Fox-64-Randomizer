;doesn't work

.n64
.create "Randomizer_Patch.z64", 0x00000000
.close
.open "sf64.z64", 892568
.region 4

	/* This file allows easy patching of new sizes if the randomizer ever reaches the current limit. Follow the instructions below if you would like to patch your rom with this method.
	
	1. Move your decompressed V1.0 ROM in this directory.
	2. Name the ROM sf64.z64
	3. Place armips.exe in this directory.
	4. Run Compile_Patch.bat (outputs file as Randomizer_Patch.z64)
	5. Run rn64crc.exe on Randomizer_Patch.z64 (https://www.smwcentral.net/?p=section&a=details&id=8799) on your built ROM. 	*/
	
.orga 0x55C78
	
	j 0x800c4830 ;places a jump to the below code
	
	/* The below code loads the randomizer from ROM and places it at 0x80400000
		In memory, this is loaded at 0x800c4830 */
		
.orga 0xC5430
	
	/* Change these defines values if ever needed */
	
	@RANDOMIZER_ROM_LOCATION equ 0x00EFB0B0 	;rom location of randomizer
	@RANDOMIZER_MEMORY_LOCATION equ 0x80400000	;memory location to put new rom segment (randomizer) = 0x80400000
	@RANDOMIZER_ROM_SIZE equ 0x00010000		;size from rom to load, change this if the randomizer every reaches this!
		
	addiu sp, sp, -0x18 ;game restores stack after it exits this call
	sw ra, 0x0014(sp)
	li a0, @RANDOMIZER_ROM_LOCATION
	li a1, @RANDOMIZER_MEMORY_LOCATION
	li a2, @RANDOMIZER_ROM_SIZE
	jal 0x80054710	;requests load
	nop
	lw ra, 0x0014(sp)
	jr ra
	nop
	
.orga 0x1EB44

	/* places jump to randomizer */
	
	j @RANDOMIZER_MEMORY_LOCATION
	
.orga 0xD9E90

	/* places into ROM entry table */
	
	.d32 @RANDOMIZER_ROM_LOCATION
	.d32 @RANDOMIZER_ROM_LOCATION
	.d32 @RANDOMIZER_ROM_LOCATION+@RANDOMIZER_ROM_SIZE

.endregion
.close
;.create "Randomizer_Patch.z64", 0x00000000
;.close