# ===============================================
# Swept Compression Ramp Generator
# ===============================================
# Written by Kevin Holst
#

# Load Pointwise Glyph package and Tk
package require PWI_Glyph
pw::Script loadTk

pw::Application reset

# SCR GUI INFORMATION
# -----------------------------------------------
# first set default values
set sweep_angle 0
set ramp_angle 20
set ramp_height 3
set ramp_width 7.2

wm title . "Swept Compression Ramp Generator"
grid [ttk::frame .c -padding "5 5 5 5"] -column 0 -row 0 -sticky nwes
grid columnconfigure . 0 -weight 1; grid rowconfigure . 0 -weight 1
grid [ttk::labelframe .c.label_frame -padding "5 5 5 5" -text "Swept Compression Ramp Grid Generator"]

# sweep angle information (btw, I have no idea what "te" is for)
grid [ttk::label .c.label_frame.sweep_angle_label -text "Sweep Angle (deg)"] -column 1 -row 1 -sticky e
grid [ttk::entry .c.label_frame.sweep_angle_entry -width 5 -textvariable sweep_angle] -column 2 -row 1 -sticky e
grid [ttk::frame .c.label_frame.sweep_angle_te] -column 3 -row 1 -sticky e

# ramp_angle information
grid [ttk::label .c.label_frame.ramp_angle_label -text "Ramp Angle (deg)"] -column 1 -row 2 -sticky e
grid [ttk::entry .c.label_frame.ramp_angle_entry -width 5 -textvariable ramp_angle] -column 2 -row 2 -sticky e
grid [ttk::frame .c.label_frame.ramp_angle_te] -column 3 -row 2 -sticky e

# ramp_height information
grid [ttk::label .c.label_frame.ramp_height_label -text "Ramp Height (cm)"] -column 1 -row 3 -sticky e
grid [ttk::entry .c.label_frame.ramp_height_entry -width 5 -textvariable ramp_height] -column 2 -row 3 -sticky e
grid [ttk::frame .c.label_frame.ramp_height_te] -column 3 -row 3 -sticky e

# ramp_width information
grid [ttk::label .c.label_frame.ramp_width_label -text "Ramp Width (cm)"] -column 1 -row 4 -sticky e
grid [ttk::entry .c.label_frame.ramp_width_entry -width 5 -textvariable ramp_width] -column 2 -row 4 -sticky e
grid [ttk::frame .c.label_frame.ramp_width_te] -column 3 -row 4 -sticky e

# GO button!
grid [ttk::button .c.label_frame.gob -text "CREATE" -command generate_scr] -column 4 -row 1 -sticky e
foreach w [winfo children .c.label_frame] {grid configure $w -padx 10 -pady 10}
focus .c.label_frame.sweep_angle_entry
::tk::PlaceWindow . widget
bind . <Return> {generate_scr}

proc generate_scr {} {


#### Old drawing... kept it because it took a while to make...
# (1)      (2)  (3)                            (4)
# _______________________________________________
#             \   \
#              \   \
#               \   \
#                \   \
#                 \   \
#                  \   \
# __________________\___\________________________
# (0=0,0,0)        (7)  (6)                    (5)


#               (3)    (6)                   (4,5)
#                ________________________________ 
#               /      /
#              /      /
# ____________/______/
# (0,1)     (2)    (7)

# SCR INPUTS
# -----------------------------------------------
#

# Set defaults
# -----------------------------------------------
pw::Connector setCalculateDimensionMethod Spacing
pw::Connector setCalculateDimensionSpacing 10.0
pw::DomainUnstructured setDefault BoundaryDecay 0.995
pw::DomainUnstructured setDefault TRexMaximumLayers 30
pw::TRexCondition setAutomaticWallSpacing 0.001
pw::Application setCAESolver {CFD++} 3


# GENERATE SCR COORDINATES
# -----------------------------------------------
# Initialize Arrays and variables
# (leaving more complicated geometry calcs to later)
set pi 3.1415926535897931
set sweep_angle_rad [expr {$pi/180*$::sweep_angle}]
set ramp_angle_rad [expr {$pi/180*$::ramp_angle}]
set theta [expr {atan(tan($ramp_angle_rad)*cos($sweep_angle_rad))}]
# length units are mm
set ramp_width [expr {$::ramp_width*10.0}]
set ramp_height [expr {$::ramp_height*10.0}]
set upstream_widths 2
set downstream_widths 1
set height_widths 1.5
set side_widths 1.5
set min_spacing 2.0

## ramp face
# (2) ______________________ (3)
#    |                      |
#    |                      |
#    |                      |
#    |                      |
# (1)|______________________|(4)

# Set up points of interest
set outlet_x [expr {($upstream_widths + $downstream_widths + tan($sweep_angle_rad))*$ramp_width + $ramp_height/tan($theta)}]
set ramp_point_1 [list [expr {$ramp_width*$upstream_widths}] $ramp_width 0]
set ramp_point_2 [list [expr {$ramp_width*$upstream_widths + $ramp_height/tan($theta)}] $ramp_width $ramp_height]
set ramp_point_3 [list [expr {$ramp_width*($upstream_widths + tan($sweep_angle_rad)) + $ramp_height/tan($theta)}] 0 $ramp_height]
set ramp_point_4 [list [expr {$ramp_width*($upstream_widths + tan($sweep_angle_rad))}] 0 0]
set outlet_point_2 [list $outlet_x $ramp_width $ramp_height]
set outlet_point_3 [list $outlet_x 0 $ramp_height]
set outlet_point_4 [list $outlet_x 0 0]

# -----------------------------------------------
# create ramp
# -----------------------------------------------

puts "Creating connectors"

set line_segment [pw::SegmentSpline create]
$line_segment addPoint $ramp_point_1
$line_segment addPoint $ramp_point_4
set ramp_base [pw::Connector create]
$ramp_base addSegment $line_segment
$ramp_base setName "ramp_base"
$ramp_base setDimensionFromSpacing $min_spacing
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint $ramp_point_4
$line_segment addPoint $ramp_point_3
set ramp_right [pw::Connector create]
$ramp_right addSegment $line_segment
$ramp_right setName "ramp_right"
set distribution [$ramp_right getDistribution 1]
	$distribution setBeginSpacing $min_spacing
	$distribution setEndSpacing 2.0
unset distribution
$ramp_right setDimensionFromDistribution
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint $ramp_point_1
$line_segment addPoint $ramp_point_2
set ramp_left [pw::Connector create]
$ramp_left addSegment $line_segment
$ramp_left setName "ramp_left"
set distribution [$ramp_left getDistribution 1]
	$distribution setBeginSpacing $min_spacing
	$distribution setEndSpacing 2.0
unset distribution
$ramp_left setDimensionFromDistribution
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint $ramp_point_2
$line_segment addPoint $ramp_point_3
set ramp_top [pw::Connector create]
$ramp_top addSegment $line_segment
$ramp_top calculateDimension
$ramp_top setName "ramp_top"
$ramp_top setDimensionFromSpacing 2.0
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint $ramp_point_2
$line_segment addPoint $outlet_point_2
set ramp_top_left [pw::Connector create]
$ramp_top_left addSegment $line_segment
$ramp_top_left setName "ramp_top_left"
set distribution [$ramp_top_left getDistribution 1]
	$distribution setBeginSpacing 2.0
	$distribution setEndSpacing 2.0
unset distribution
$ramp_top_left setDimensionFromDistribution
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint $ramp_point_3
$line_segment addPoint $outlet_point_3
set ramp_top_right [pw::Connector create]
$ramp_top_right addSegment $line_segment
$ramp_top_right setName "ramp_top_right"
set distribution [$ramp_top_right getDistribution 1]
	$distribution setBeginSpacing 2.0
	$distribution setEndSpacing 2.0
unset distribution
$ramp_top_right setDimensionFromDistribution
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint $ramp_point_4
$line_segment addPoint $outlet_point_4
set ramp_right_base [pw::Connector create]
$ramp_right_base addSegment $line_segment
$ramp_right_base calculateDimension
$ramp_right_base setName "ramp_right_base"
set distribution [$ramp_right_base getDistribution 1]
	$distribution setBeginSpacing $min_spacing
	$distribution setEndSpacing 2.0
unset distribution
$ramp_right_base setDimensionFromDistribution
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint $outlet_point_2
$line_segment addPoint $outlet_point_3
set ramp_top_outlet [pw::Connector create]
$ramp_top_outlet addSegment $line_segment
$ramp_top_outlet setDimensionFromSpacing 2.0
$ramp_top_outlet setName "ramp_top_outlet"
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint $outlet_point_3
$line_segment addPoint $outlet_point_4
set ramp_right_outlet [pw::Connector create]
$ramp_right_outlet addSegment $line_segment
$ramp_right_outlet calculateDimension
$ramp_right_outlet setName "ramp_right_outlet"
unset line_segment

# -----------------------------------------------
# create overall box
# -----------------------------------------------
set top_z [expr {$ramp_height + $height_widths*$ramp_width}]
set left_y $ramp_width
set right_y [expr {-$side_widths*$ramp_width}]


# inlet region

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list 0 $left_y 0]
$line_segment addPoint [list 0 $right_y 0]
set inlet_base [pw::Connector create]
$inlet_base addSegment $line_segment
$inlet_base setName "inlet_base"
$inlet_base calculateDimension
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list 0 $ramp_width 0]
$line_segment addPoint [list 0 $ramp_width $top_z]
set inlet_left [pw::Connector create]
$inlet_left addSegment $line_segment
$inlet_left setName "inlet_left"
$inlet_left calculateDimension
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list 0 $right_y 0]
$line_segment addPoint [list 0 $right_y $top_z]
set inlet_right [pw::Connector create]
$inlet_right addSegment $line_segment
$inlet_right setName "inlet_right"
$inlet_right calculateDimension
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list 0 $left_y $top_z]
$line_segment addPoint [list 0 $right_y $top_z]
set inlet_top [pw::Connector create]
$inlet_top addSegment $line_segment
$inlet_top setName "inlet_top"
$inlet_top calculateDimension
unset line_segment


# outlet region

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list $outlet_x 0 0]
$line_segment addPoint [list $outlet_x $right_y 0]
set outlet_base [pw::Connector create]
$outlet_base addSegment $line_segment
$outlet_base setName "outlet_base"
$outlet_base calculateDimension
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list $outlet_x $ramp_width $ramp_height]
$line_segment addPoint [list $outlet_x $ramp_width $top_z]
set outlet_left [pw::Connector create]
$outlet_left addSegment $line_segment
$outlet_left setName "outlet_left"
$outlet_left calculateDimension
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list $outlet_x $right_y 0]
$line_segment addPoint [list $outlet_x $right_y $top_z]
set outlet_right [pw::Connector create]
$outlet_right addSegment $line_segment
$outlet_right setName "outlet_right"
$outlet_right calculateDimension
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list $outlet_x $left_y $top_z]
$line_segment addPoint [list $outlet_x $right_y $top_z]
set outlet_top [pw::Connector create]
$outlet_top addSegment $line_segment
$outlet_top setName "outlet_top"
$outlet_top calculateDimension
unset line_segment


# sides

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list 0 $left_y 0]
$line_segment addPoint $ramp_point_1
set left_base [pw::Connector create]
$left_base addSegment $line_segment
$left_base setName "left_base"
set distribution [$left_base getDistribution 1]
	$distribution setBeginSpacing 10.0
	$distribution setEndSpacing 0.5
unset distribution
$left_base setDimensionFromDistribution
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list 0 $left_y $top_z]
$line_segment addPoint [list $outlet_x $left_y $top_z]
set left_top [pw::Connector create]
$left_top addSegment $line_segment
$left_top setName "left_top"
$left_top calculateDimension
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list 0 $right_y 0]
$line_segment addPoint [list $outlet_x $right_y 0]
set right_base [pw::Connector create]
$right_base addSegment $line_segment
$right_base setName "right_base"
$right_base calculateDimension
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list 0 $right_y $top_z]
$line_segment addPoint [list $outlet_x $right_y $top_z]
set right_top [pw::Connector create]
$right_top addSegment $line_segment
$right_top setName "right_top"
$right_top calculateDimension
unset line_segment


#
# create domains
#
puts "Creating domains"

set dom_inlet [pw::DomainUnstructured createFromConnectors -reject _TMP(unusedCons)  [list $inlet_base $inlet_left $inlet_top $inlet_right]]
$dom_inlet setName "dom_inlet"

set dom_left [pw::DomainUnstructured createFromConnectors -reject _TMP(unusedCons)  [list $inlet_left $left_base $left_top $ramp_left $ramp_top_left $outlet_left]]
$dom_left setName "dom_left"

set dom_right [pw::DomainUnstructured createFromConnectors -reject _TMP(unusedCons)  [list $inlet_right $right_base $right_top $outlet_right]]
$dom_right setName "dom_right"

set dom_top [pw::DomainUnstructured createFromConnectors -reject _TMP(unusedCons)  [list $inlet_top $right_top $left_top $outlet_top]]
$dom_top setName "dom_top"

set dom_base [pw::DomainUnstructured createFromConnectors -reject _TMP(unusedCons)  [list $inlet_base $right_base $left_base $outlet_base $ramp_base $ramp_right_base]]
$dom_base setName "dom_base"

set dom_outlet [pw::DomainUnstructured createFromConnectors -reject _TMP(unusedCons)  [list $outlet_base $outlet_right $outlet_left $outlet_top $ramp_right_outlet $ramp_top_outlet]]
$dom_outlet setName "dom_outlet"

set dom_ramp [pw::DomainUnstructured createFromConnectors -reject _TMP(unusedCons)  [list $ramp_base $ramp_right $ramp_left $ramp_top]]
$dom_ramp setName "dom_ramp"

set dom_ramp_top [pw::DomainUnstructured createFromConnectors -reject _TMP(unusedCons)  [list $ramp_top $ramp_top_outlet $ramp_top_left $ramp_top_right]]
$dom_ramp_top setName "dom_ramp_top"

set dom_ramp_right [pw::DomainUnstructured createFromConnectors -reject _TMP(unusedCons)  [list $ramp_right $ramp_top_right $ramp_right_base $ramp_right_outlet]]
$dom_ramp_right setName "dom_ramp_right"

#
# set up TREX domains
#
puts "Setting up TREX domains"

set _DM(1) [pw::GridEntity getByName "dom_inlet"]
set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(1)]]
  set _CN(1) [pw::GridEntity getByName "inlet_right"]
  set _CN(2) [pw::GridEntity getByName "inlet_base"]
  set _CN(3) [pw::GridEntity getByName "inlet_left"]
  set _CN(4) [pw::GridEntity getByName "inlet_top"]
  set _TMP(PW_82) [pw::TRexCondition getByName {Unspecified}]
  set _TMP(PW_83) [pw::TRexCondition create]
  set _TMP(PW_84) [pw::TRexCondition getByName {bc-2}]
  unset _TMP(PW_83)
  $_TMP(PW_84) setName {wall}
  $_TMP(PW_84) setType {Wall}
  $_TMP(PW_84) apply [list [list $_DM(1) $_CN(2) Same]]
  set _TMP(PW_85) [pw::TRexCondition create]
  set _TMP(PW_86) [pw::TRexCondition getByName {bc-3}]
  unset _TMP(PW_85)
  $_TMP(PW_86) setType {AdjacentGrid}
  $_TMP(PW_86) setName {sides}
  $_TMP(PW_86) apply [list [list $_DM(1) $_CN(1) Same] [list $_DM(1) $_CN(3) Opposite]]
  set _TMP(PW_87) [pw::TRexCondition create]
  set _TMP(PW_88) [pw::TRexCondition getByName {bc-4}]
  unset _TMP(PW_87)
  $_TMP(PW_88) setName {top}
  $_TMP(PW_88) apply [list [list $_DM(1) $_CN(4) Opposite]]
  set _TMP(ENTS) [pw::Collection create]
$_TMP(ENTS) set [list $_DM(1)]
  $_DM(1) setUnstructuredSolverAttribute TRexPushAttributes True
  $_TMP(ENTS) delete
  unset _TMP(ENTS)
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(1)]]
  set _TMP(ENTS) [pw::Collection create]
$_TMP(ENTS) set [list $_DM(1)]
  $_DM(1) setUnstructuredSolverAttribute BoundaryDecay 0.5
  $_TMP(ENTS) delete
  unset _TMP(ENTS)
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(1)]]
  $_TMP(mode_10) run Initialize
  $_TMP(PW_86) setType {Match}
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(1)]]
  $_TMP(mode_10) run Initialize
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

unset _TMP(PW_82)
unset _TMP(PW_84)
unset _TMP(PW_86)
unset _TMP(PW_88)
set _DM(2) [pw::GridEntity getByName "dom_right"]
set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(2)]]
  set _TMP(ENTS) [pw::Collection create]
$_TMP(ENTS) set [list $_DM(2)]
  $_DM(2) setUnstructuredSolverAttribute TRexPushAttributes True
  $_TMP(ENTS) delete
  unset _TMP(ENTS)
  set _CN(5) [pw::GridEntity getByName "right_base"]
  set _CN(6) [pw::GridEntity getByName "right_top"]
  set _CN(7) [pw::GridEntity getByName "outlet_right"]
  set _TMP(PW_89) [pw::TRexCondition getByName {Unspecified}]
  set _TMP(PW_90) [pw::TRexCondition getByName {wall}]
  set _TMP(PW_91) [pw::TRexCondition getByName {sides}]
  set _TMP(PW_92) [pw::TRexCondition getByName {top}]
  $_TMP(PW_90) apply [list [list $_DM(2) $_CN(5) Opposite]]
  $_TMP(PW_91) apply [list [list $_DM(2) $_CN(1) Same] [list $_DM(2) $_CN(7) Opposite]]
  $_TMP(PW_92) apply [list [list $_DM(2) $_CN(1) Same] [list $_DM(2) $_CN(7) Opposite] [list $_DM(2) $_CN(6) Same]]
  $_TMP(PW_91) apply [list [list $_DM(2) $_CN(1) Same] [list $_DM(2) $_CN(7) Opposite]]
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(2)]]
  set _TMP(ENTS) [pw::Collection create]
$_TMP(ENTS) set [list $_DM(2)]
  $_DM(2) setUnstructuredSolverAttribute BoundaryDecay 0.5
  $_TMP(ENTS) delete
  unset _TMP(ENTS)
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(2)]]
  $_TMP(mode_10) run Initialize
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

unset _TMP(PW_89)
unset _TMP(PW_90)
unset _TMP(PW_91)
unset _TMP(PW_92)
set _DM(3) [pw::GridEntity getByName "dom_left"]
set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(3)]]
  set _CN(8) [pw::GridEntity getByName "outlet_left"]
  set _CN(9) [pw::GridEntity getByName "ramp_left"]
  set _CN(10) [pw::GridEntity getByName "left_base"]
  set _CN(11) [pw::GridEntity getByName "ramp_top_left"]
  set _CN(12) [pw::GridEntity getByName "left_top"]
  set _TMP(PW_93) [pw::TRexCondition getByName {Unspecified}]
  set _TMP(PW_94) [pw::TRexCondition getByName {wall}]
  set _TMP(PW_95) [pw::TRexCondition getByName {sides}]
  set _TMP(PW_96) [pw::TRexCondition getByName {top}]
  $_TMP(PW_94) apply [list [list $_DM(3) $_CN(10) Same] [list $_DM(3) $_CN(9) Same] [list $_DM(3) $_CN(11) Same]]
  $_TMP(PW_95) apply [list [list $_DM(3) $_CN(3) Opposite] [list $_DM(3) $_CN(8) Same]]
  $_TMP(PW_96) apply [list [list $_DM(3) $_CN(12) Opposite]]
  $_TMP(mode_10) run Initialize
  set _TMP(ENTS) [pw::Collection create]
$_TMP(ENTS) set [list $_DM(3)]
  $_DM(3) setUnstructuredSolverAttribute TRexPushAttributes True
  $_TMP(ENTS) delete
  unset _TMP(ENTS)
  $_TMP(mode_10) run Initialize
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

unset _TMP(PW_93)
unset _TMP(PW_94)
unset _TMP(PW_95)
unset _TMP(PW_96)
set _DM(4) [pw::GridEntity getByName "dom_ramp_right"]
set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(4)]]
  set _CN(13) [pw::GridEntity getByName "ramp_right_outlet"]
  set _CN(14) [pw::GridEntity getByName "ramp_right_base"]
  set _CN(15) [pw::GridEntity getByName "ramp_top_right"]
  set _CN(16) [pw::GridEntity getByName "ramp_right"]
  set _TMP(PW_97) [pw::TRexCondition getByName {Unspecified}]
  set _TMP(PW_98) [pw::TRexCondition getByName {wall}]
  set _TMP(PW_99) [pw::TRexCondition getByName {sides}]
  set _TMP(PW_100) [pw::TRexCondition getByName {top}]
  $_TMP(PW_98) apply [list [list $_DM(4) $_CN(14) Opposite]]
  $_TMP(PW_99) apply [list [list $_DM(4) $_CN(16) Same] [list $_DM(4) $_CN(13) Same]]
  $_TMP(PW_100) apply [list [list $_DM(4) $_CN(15) Same]]
  set _TMP(ENTS) [pw::Collection create]
$_TMP(ENTS) set [list $_DM(4)]
  $_DM(4) setUnstructuredSolverAttribute TRexPushAttributes True
  $_TMP(ENTS) delete
  unset _TMP(ENTS)
  $_TMP(mode_10) run Initialize
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(4)]]
$_TMP(mode_10) abort
unset _TMP(mode_10)
unset _TMP(PW_97)
unset _TMP(PW_98)
unset _TMP(PW_99)
unset _TMP(PW_100)
set _DM(5) [pw::GridEntity getByName "dom_outlet"]
set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(5)]]
  set _TMP(ENTS) [pw::Collection create]
$_TMP(ENTS) set [list $_DM(5)]
  $_DM(5) setUnstructuredSolverAttribute TRexPushAttributes True
  $_TMP(ENTS) delete
  unset _TMP(ENTS)
  set _CN(17) [pw::GridEntity getByName "outlet_top"]
  set _CN(18) [pw::GridEntity getByName "outlet_base"]
  set _CN(19) [pw::GridEntity getByName "ramp_top_outlet"]
  set _TMP(PW_101) [pw::TRexCondition getByName {Unspecified}]
  set _TMP(PW_102) [pw::TRexCondition getByName {wall}]
  set _TMP(PW_103) [pw::TRexCondition getByName {sides}]
  set _TMP(PW_104) [pw::TRexCondition getByName {top}]
  $_TMP(PW_102) apply [list [list $_DM(5) $_CN(18) Same] [list $_DM(5) $_CN(19) Same]]
  $_TMP(PW_103) apply [list [list $_DM(5) $_CN(7) Same] [list $_DM(5) $_CN(8) Opposite] [list $_DM(5) $_CN(13) Same]]
  $_TMP(PW_104) apply [list [list $_DM(5) $_CN(17) Opposite]]
  set _TMP(ENTS) [pw::Collection create]
$_TMP(ENTS) set [list $_DM(5)]
  $_DM(5) setUnstructuredSolverAttribute BoundaryDecay 0.5
  $_TMP(ENTS) delete
  unset _TMP(ENTS)
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

set _TMP(mode_10) [pw::Application begin UnstructuredSolver [list $_DM(5)]]
  $_TMP(mode_10) run Initialize
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Solve}

unset _TMP(PW_101)
unset _TMP(PW_102)
unset _TMP(PW_103)
unset _TMP(PW_104)

puts "Initializing block. Could take a while."

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

puts "Setting boundary conditions"

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

puts "DONE!"

# Zoom to geometry
pw::Display resetView +Y

exit

}

# END SCRIPT

