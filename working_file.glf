# Pointwise V17.3 Journal file - Sun Mar 22 19:34:58 2015

package require PWI_Glyph 2.17.3

pw::Application setUndoMaximumLevels 5

set _DM(1) [pw::GridEntity getByName "dom_base"]
set _DM(2) [pw::GridEntity getByName "dom_left"]
set _DM(3) [pw::GridEntity getByName "dom_top"]
set _DM(4) [pw::GridEntity getByName "dom_ramp_top"]
set _DM(5) [pw::GridEntity getByName "dom_ramp_right"]
set _DM(6) [pw::GridEntity getByName "dom_inlet"]
set _DM(7) [pw::GridEntity getByName "dom_right"]
set _DM(8) [pw::GridEntity getByName "dom_outlet"]
set _DM(9) [pw::GridEntity getByName "dom_ramp"]
set _TMP(PW_23) [pw::BlockUnstructured createFromDomains -reject _TMP(unusedDoms) -voids _TMP(voidBlocks) -baffles _TMP(baffleFaces) [concat [list] [list $_DM(1) $_DM(2) $_DM(3) $_DM(4) $_DM(5) $_DM(6) $_DM(7) $_DM(8) $_DM(9)]]]
unset _TMP(unusedDoms)
unset _TMP(PW_23)
pw::Application markUndoLevel {Assemble Blocks}

set _BL(1) [pw::GridEntity getByName "blk-1"]
set _TMP(mode_6) [pw::Application begin UnstructuredSolver [list $_BL(1)]]
  set _TMP(ENTS) [pw::Collection create]
$_TMP(ENTS) set [list $_BL(1)]
  $_BL(1) setUnstructuredSolverAttribute TRexMaximumLayers 30
  $_TMP(ENTS) delete
  unset _TMP(ENTS)
  set _TMP(PW_24) [pw::TRexCondition getByName {Unspecified}]
  set _TMP(PW_25) [pw::TRexCondition getByName {wall}]
  set _TMP(PW_26) [pw::TRexCondition getByName {sides}]
  set _TMP(PW_27) [pw::TRexCondition getByName {top}]
  $_TMP(PW_26) apply [list [list $_BL(1) $_DM(7) Same] [list $_BL(1) $_DM(8) Same] [list $_BL(1) $_DM(2) Same] [list $_BL(1) $_DM(6) Opposite]]
  $_TMP(PW_26) apply [list [list $_BL(1) $_DM(5) Opposite]]
  $_TMP(PW_27) apply [list [list $_BL(1) $_DM(3) Opposite]]
  $_TMP(PW_25) apply [list [list $_BL(1) $_DM(1) Opposite] [list $_BL(1) $_DM(9) Same] [list $_BL(1) $_DM(4) Same]]
$_TMP(mode_6) end
unset _TMP(mode_6)
pw::Application markUndoLevel {Solve}

set _TMP(mode_7) [pw::Application begin UnstructuredSolver [list $_BL(1)]]
  set _TMP(ENTS) [pw::Collection create]
$_TMP(ENTS) set [list $_BL(1)]
  $_BL(1) setUnstructuredSolverAttribute BoundaryDecay 0.995
  $_TMP(ENTS) delete
  unset _TMP(ENTS)
$_TMP(mode_7) end
unset _TMP(mode_7)
pw::Application markUndoLevel {Solve}

set _TMP(mode_8) [pw::Application begin UnstructuredSolver [list $_BL(1)]]
  $_TMP(mode_8) run Initialize
$_TMP(mode_8) end
unset _TMP(mode_8)
pw::Application markUndoLevel {Solve}

set _TMP(mode_9) [pw::Application begin UnstructuredSolver [list $_BL(1)]]
$_TMP(mode_9) abort
unset _TMP(mode_9)
unset _TMP(PW_24)
unset _TMP(PW_25)
unset _TMP(PW_26)
unset _TMP(PW_27)
set _TMP(PW_28) [pw::BoundaryCondition getByName "Unspecified"]
set _TMP(PW_29) [pw::BoundaryCondition create]
pw::Application markUndoLevel {Create BC}

set _TMP(PW_30) [pw::BoundaryCondition getByName "bc-2"]
unset _TMP(PW_29)
$_TMP(PW_30) setName "inlet"
pw::Application markUndoLevel {Name BC}

set _TMP(PW_31) [pw::BoundaryCondition create]
pw::Application markUndoLevel {Create BC}

set _TMP(PW_32) [pw::BoundaryCondition getByName "bc-3"]
unset _TMP(PW_31)
$_TMP(PW_32) setName "outlet"
pw::Application markUndoLevel {Name BC}

set _TMP(PW_33) [pw::BoundaryCondition create]
pw::Application markUndoLevel {Create BC}

set _TMP(PW_34) [pw::BoundaryCondition getByName "bc-4"]
unset _TMP(PW_33)
$_TMP(PW_34) setName "no-slip"
pw::Application markUndoLevel {Name BC}

set _TMP(PW_35) [pw::BoundaryCondition create]
pw::Application markUndoLevel {Create BC}

set _TMP(PW_36) [pw::BoundaryCondition getByName "bc-5"]
unset _TMP(PW_35)
set _TMP(PW_37) [pw::BoundaryCondition create]
pw::Application markUndoLevel {Create BC}

set _TMP(PW_38) [pw::BoundaryCondition getByName "bc-6"]
unset _TMP(PW_37)
$_TMP(PW_36) setName "slip"
pw::Application markUndoLevel {Name BC}

$_TMP(PW_38) setName "right_side"
pw::Application markUndoLevel {Name BC}

$_TMP(PW_30) apply [list [list $_BL(1) $_DM(6)]]
pw::Application markUndoLevel {Set BC}

$_TMP(PW_32) apply [list [list $_BL(1) $_DM(8)]]
pw::Application markUndoLevel {Set BC}

$_TMP(PW_34) apply [list [list $_BL(1) $_DM(1)] [list $_BL(1) $_DM(9)] [list $_BL(1) $_DM(4)]]
pw::Application markUndoLevel {Set BC}

$_TMP(PW_36) apply [list [list $_BL(1) $_DM(3)] [list $_BL(1) $_DM(5)] [list $_BL(1) $_DM(2)]]
pw::Application markUndoLevel {Set BC}

$_TMP(PW_38) apply [list [list $_BL(1) $_DM(7)]]
pw::Application markUndoLevel {Set BC}

unset _TMP(PW_28)
unset _TMP(PW_30)
unset _TMP(PW_32)
unset _TMP(PW_34)
unset _TMP(PW_36)
unset _TMP(PW_38)
