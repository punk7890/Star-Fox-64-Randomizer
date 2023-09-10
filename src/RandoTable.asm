

	/* This file is used to store memory addresses of new randomizer functions. 
	Put your label of the new function in a new spot here. This should always be after GlobalPointer.asm in memory. */

.n64

.autoregion


gRandoSeekEntry:
.d32 0
gRandoTable:	;always leave a zero after the last valid entry
.d32 TBL_FUNC_InitLevelStartVars
.d32 TBL_FUNC_InitLevelEndVarsHOOK
.d32 TBL_FUNC_QuickScoreScreens
.d32 TBL_FUNC_MarathonMode
.d32 TBL_FUNC_ChoosePlanets
.d32 TBL_FUNC_RandomPlanets
.d32 TBL_FUNC_RandomItems
.d32 TBL_FUNC_BossRushMode
.d32 TBL_FUNC_RandomDeathItem
.d32 TBL_FUNC_RainbowBombs
.d32 TBL_FUNC_RandomPortraits
.d32 TBL_FUNC_RandomDialog
.d32 TBL_FUNC_RandomEngineColors
.d32 TBL_FUNC_RandomExpert
.d32 TBL_FUNC_OneHitKO
.d32 TBL_FUNC_RandomMusic
.d32 TBL_FUNC_RandomColors
.d32 TBL_FUNC_EnduranceMode
.d32 TBL_FUNC_ProtectTheTargetsMode
.d32 TBL_FUNC_ExtraStarWolfs
.d32 0


.endautoregion
;.close

