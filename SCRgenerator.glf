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

# GENERATE SCR COORDINATES
# -----------------------------------------------
# Initialize Arrays and variables
# (leaving more complicated geometry calcs to later)
set pi 3.1415926535897931
set sweep_angle_rad [expr {$pi/180*$::sweep_angle}]
set ramp_angle_rad [expr {$pi/180*$::ramp_angle}]
set theta [expr {atan(tan($ramp_angle_rad)*cos($sweep_angle_rad))}]
set ramp_width [expr {$::ramp_width*10.0}]      # units are mm
set ramp_height [expr {$::ramp_height*10.0}]    # units are mm
set upstream_widths 4
set downstream_widths 2

# create inlet lines
set line_segment [pw::SegmentSpline create]
$line_segment addPoint {0 0 0}
$line_segment addPoint [list 0 $ramp_width 0]
set forward_inlet [pw::Connector create]
$forward_inlet addSegment $line_segment
$forward_inlet setDimension 100
$forward_inlet setName "forward_inlet"
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint {0 0 0}
$line_segment addPoint [list [expr {$ramp_width*($upstream_widths + tan($sweep_angle_rad))}] 0 0]
set forward_right [pw::Connector create]
$forward_right addSegment $line_segment
$forward_right setDimension 100
$forward_right setName "forward_right"
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list 0 $ramp_width 0]
$line_segment addPoint [list [expr {$ramp_width*$upstream_widths}] $ramp_width 0]
set forward_left [pw::Connector create]
$forward_left addSegment $line_segment
$forward_left setDimension 100
$forward_left setName "forward_left"
unset line_segment

# create ramp lines
set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list [expr {$ramp_width*($upstream_widths + tan($sweep_angle_rad))}] 0 0]
$line_segment addPoint [list [expr {$ramp_width*$upstream_widths}] $ramp_width 0]
set ramp_base [pw::Connector create]
$ramp_base addSegment $line_segment
$ramp_base setDimension 100
$ramp_base setName "ramp_base"
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list [expr {$ramp_width*($upstream_widths + tan($sweep_angle_rad))}] 0 0]
$line_segment addPoint [list [expr {$ramp_width*($upstream_widths + tan($sweep_angle_rad)) + $ramp_height/tan($theta)}] 0 $ramp_height]
set ramp_right [pw::Connector create]
$ramp_right addSegment $line_segment
$ramp_right setDimension 100
$ramp_right setName "ramp_right"
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list [expr {$ramp_width*$upstream_widths}] $ramp_width 0]
$line_segment addPoint [list [expr {$ramp_width*$upstream_widths + $ramp_height/tan($theta)}] $ramp_width $ramp_height]
set ramp_left [pw::Connector create]
$ramp_left addSegment $line_segment
$ramp_left setDimension 100
$ramp_left setName "ramp_left"
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list [expr {$ramp_width*($upstream_widths + tan($sweep_angle_rad)) + $ramp_height/tan($theta)}] 0 $ramp_height]
$line_segment addPoint [list [expr {$ramp_width*$upstream_widths + $ramp_height/tan($theta)}] $ramp_width $ramp_height]
set ramp_top [pw::Connector create]
$ramp_top addSegment $line_segment
$ramp_top setDimension 100
$ramp_top setName "ramp_top"
unset line_segment

# create outlet lines
set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list [expr {$ramp_width*(($upstream_widths + $downstream_widths) + tan($sweep_angle_rad)) + $ramp_height/tan($theta)}] 0 $ramp_height]
$line_segment addPoint [list [expr {$ramp_width*(($upstream_widths + $downstream_widths) + tan($sweep_angle_rad)) + $ramp_height/tan($theta)}] $ramp_width $ramp_height]
set aft_outlet [pw::Connector create]
$aft_outlet addSegment $line_segment
$aft_outlet setDimension 100
$aft_outlet setName "aft_outlet"
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list [expr {$ramp_width*($upstream_widths + tan($sweep_angle_rad)) + $ramp_height/tan($theta)}] 0 $ramp_height]
$line_segment addPoint [list [expr {$ramp_width*(($upstream_widths + $downstream_widths) + tan($sweep_angle_rad)) + $ramp_height/tan($theta)}] 0 $ramp_height]
set aft_right [pw::Connector create]
$aft_right addSegment $line_segment
$aft_right setDimension 100
$aft_right setName "aft_right"
unset line_segment

set line_segment [pw::SegmentSpline create]
$line_segment addPoint [list [expr {$ramp_width*$upstream_widths + $ramp_height/tan($theta)}] $ramp_width $ramp_height]
$line_segment addPoint [list [expr {$ramp_width*(($upstream_widths + $downstream_widths) + tan($sweep_angle_rad)) + $ramp_height/tan($theta)}] $ramp_width $ramp_height]
set aft_left [pw::Connector create]
$aft_left addSegment $line_segment
$aft_left setDimension 100
$aft_left setName "aft_left"
unset line_segment

# copy and paste to create ceiling
pw::Application clearClipboard
set _CN(1) [pw::GridEntity getByName "forward_left"]
set _CN(2) [pw::GridEntity getByName "forward_inlet"]
set _CN(3) [pw::GridEntity getByName "forward_right"]
set _CN(4) [pw::GridEntity getByName "ramp_base"]
pw::Application setClipboard [list $_CN(4) $_CN(1) $_CN(2) $_CN(3)]

set _TMP(mode_1) [pw::Application begin Paste]
  set _TMP(PW_1) [$_TMP(mode_1) getEntities]
  set _TMP(mode_2) [pw::Application begin Modify $_TMP(PW_1)]
    pw::Entity transform [pwu::Transform translation [list 0 0 [expr {$ramp_height+2*$ramp_width}]]] [$_TMP(mode_2) getEntities]
  $_TMP(mode_2) end
  unset _TMP(mode_2)
$_TMP(mode_1) end
unset _TMP(mode_1)

unset _TMP(PW_1)
pw::Application clearClipboard
set _CN(5) [pw::GridEntity getByName "aft_right"]
set _CN(6) [pw::GridEntity getByName "aft_left"]
set _CN(7) [pw::GridEntity getByName "ramp_top"]
set _CN(8) [pw::GridEntity getByName "aft_outlet"]
pw::Application setClipboard [list $_CN(5) $_CN(6) $_CN(7) $_CN(8)]

set _TMP(mode_3) [pw::Application begin Paste]
  set _TMP(PW_2) [$_TMP(mode_3) getEntities]
  set _TMP(mode_4) [pw::Application begin Modify $_TMP(PW_2)]
    pw::Entity transform [pwu::Transform translation [list 0 0 [expr {2*$ramp_width}]]] [$_TMP(mode_4) getEntities]
  $_TMP(mode_4) end
  unset _TMP(mode_4)
$_TMP(mode_3) end
unset _TMP(mode_3)

unset _TMP(PW_2)
set _TMP(mode_5) [pw::Application begin Create]
  set _CN(9) [pw::GridEntity getByName "ramp_base-1"]
  set _CN(10) [pw::GridEntity getByName "forward_left-1"]
  set _TMP(PW_3) [pw::SegmentSpline create]
  set _CN(11) [pw::GridEntity getByName "aft_left-1"]
  set _CN(12) [pw::GridEntity getByName "ramp_top-1"]
  $_TMP(PW_3) addPoint [$_CN(9) getPosition -arc 1]
  $_TMP(PW_3) addPoint [$_CN(11) getPosition -arc 0]
  set _TMP(con_1) [pw::Connector create]
  $_TMP(con_1) addSegment $_TMP(PW_3)
  unset _TMP(PW_3)
  $_TMP(con_1) calculateDimension
$_TMP(mode_5) end
unset _TMP(mode_5)

set _TMP(mode_6) [pw::Application begin Create]
  set _CN(13) [pw::GridEntity getByName "con-1"]
  set _CN(14) [pw::GridEntity getByName "forward_right-1"]
  set _TMP(PW_4) [pw::SegmentSpline create]
  set _CN(15) [pw::GridEntity getByName "aft_right-1"]
  $_TMP(PW_4) addPoint [$_CN(9) getPosition -arc 0]
  $_TMP(PW_4) addPoint [$_CN(15) getPosition -arc 0]
  unset _TMP(con_1)
  set _TMP(con_2) [pw::Connector create]
  $_TMP(con_2) addSegment $_TMP(PW_4)
  unset _TMP(PW_4)
  $_TMP(con_2) calculateDimension
$_TMP(mode_6) end
unset _TMP(mode_6)

set _TMP(mode_7) [pw::Application begin Create]
  set _CN(16) [pw::GridEntity getByName "con-2"]
  set _CN(17) [pw::GridEntity getByName "forward_inlet-1"]
  set _TMP(PW_5) [pw::SegmentSpline create]
  $_TMP(PW_5) addPoint [$_CN(10) getPosition -arc 0]
  $_TMP(PW_5) addPoint [$_CN(2) getPosition -arc 1]
  unset _TMP(con_2)
  set _TMP(con_3) [pw::Connector create]
  $_TMP(con_3) addSegment $_TMP(PW_5)
  unset _TMP(PW_5)
  $_TMP(con_3) calculateDimension
$_TMP(mode_7) end
unset _TMP(mode_7)

set _TMP(mode_8) [pw::Application begin Create]
  set _CN(18) [pw::GridEntity getByName "con-3"]
  set _TMP(PW_6) [pw::SegmentSpline create]
  $_TMP(PW_6) addPoint [$_CN(17) getPosition -arc 0]
  $_TMP(PW_6) addPoint [$_CN(2) getPosition -arc 0]
  unset _TMP(con_3)
  set _TMP(con_4) [pw::Connector create]
  $_TMP(con_4) addSegment $_TMP(PW_6)
  unset _TMP(PW_6)
  $_TMP(con_4) calculateDimension
$_TMP(mode_8) end
unset _TMP(mode_8)

set _TMP(mode_9) [pw::Application begin Create]
  set _CN(19) [pw::GridEntity getByName "con-4"]
  set _TMP(PW_7) [pw::SegmentSpline create]
  set _CN(20) [pw::GridEntity getByName "ramp_right"]
  $_TMP(PW_7) addPoint [$_CN(9) getPosition -arc 0]
  $_TMP(PW_7) addPoint [$_CN(3) getPosition -arc 1]
  unset _TMP(con_4)
  set _TMP(con_5) [pw::Connector create]
  $_TMP(con_5) addSegment $_TMP(PW_7)
  unset _TMP(PW_7)
  $_TMP(con_5) calculateDimension
$_TMP(mode_9) end
unset _TMP(mode_9)

set _TMP(mode_10) [pw::Application begin Create]
  set _CN(21) [pw::GridEntity getByName "con-5"]
  set _TMP(PW_8) [pw::SegmentSpline create]
  set _CN(22) [pw::GridEntity getByName "ramp_left"]
  $_TMP(PW_8) addPoint [$_CN(9) getPosition -arc 1]
  $_TMP(PW_8) addPoint [$_CN(1) getPosition -arc 1]
  unset _TMP(con_5)
  set _TMP(con_6) [pw::Connector create]
  $_TMP(con_6) addSegment $_TMP(PW_8)
  unset _TMP(PW_8)
  $_TMP(con_6) calculateDimension
$_TMP(mode_10) end
unset _TMP(mode_10)

set _TMP(mode_10) [pw::Application begin Create]
  set _CN(23) [pw::GridEntity getByName "con-6"]
  set _TMP(PW_9) [pw::SegmentSpline create]
  $_TMP(PW_9) addPoint [$_CN(11) getPosition -arc 0]
  $_TMP(PW_9) addPoint [$_CN(22) getPosition -arc 1]
  unset _TMP(con_6)
  set _TMP(con_7) [pw::Connector create]
  $_TMP(con_7) addSegment $_TMP(PW_9)
  unset _TMP(PW_9)
  $_TMP(con_7) calculateDimension
$_TMP(mode_10) end
unset _TMP(mode_10)

set _TMP(mode_10) [pw::Application begin Create]
  set _CN(24) [pw::GridEntity getByName "con-7"]
  set _TMP(PW_10) [pw::SegmentSpline create]
  $_TMP(PW_10) addPoint [$_CN(15) getPosition -arc 0]
  $_TMP(PW_10) addPoint [$_CN(20) getPosition -arc 1]
  unset _TMP(con_7)
  set _TMP(con_8) [pw::Connector create]
  $_TMP(con_8) addSegment $_TMP(PW_10)
  unset _TMP(PW_10)
  $_TMP(con_8) calculateDimension
$_TMP(mode_10) end
unset _TMP(mode_10)

set _TMP(mode_10) [pw::Application begin Create]
  set _CN(25) [pw::GridEntity getByName "con-8"]
  set _TMP(PW_11) [pw::SegmentSpline create]
  set _CN(26) [pw::GridEntity getByName "aft_outlet-1"]
  $_TMP(PW_11) addPoint [$_CN(8) getPosition -arc 0]
  $_TMP(PW_11) addPoint [$_CN(15) getPosition -arc 1]
  unset _TMP(con_8)
  set _TMP(con_9) [pw::Connector create]
  $_TMP(con_9) addSegment $_TMP(PW_11)
  unset _TMP(PW_11)
  $_TMP(con_9) calculateDimension
$_TMP(mode_10) end
unset _TMP(mode_10)

set _TMP(mode_10) [pw::Application begin Create]
  set _CN(27) [pw::GridEntity getByName "con-9"]
  set _TMP(PW_12) [pw::SegmentSpline create]
  $_TMP(PW_12) addPoint [$_CN(11) getPosition -arc 1]
  $_TMP(PW_12) addPoint [$_CN(8) getPosition -arc 1]
  unset _TMP(con_9)
  set _TMP(con_10) [pw::Connector create]
  $_TMP(con_10) addSegment $_TMP(PW_12)
  unset _TMP(PW_12)
  $_TMP(con_10) calculateDimension
$_TMP(mode_10) end
unset _TMP(mode_10)

set _TMP(mode_10) [pw::Application begin Create]
  set _CN(28) [pw::GridEntity getByName "con-10"]
  set _TMP(PW_13) [pw::SegmentSpline create]
  $_TMP(PW_13) delete
  unset _TMP(PW_13)
$_TMP(mode_10) abort
unset _TMP(mode_10)
unset _TMP(con_10)
set _TMP(PW_14) [pw::Collection create]
$_TMP(PW_14) set [list $_CN(21) $_CN(24) $_CN(13) $_CN(16) $_CN(19) $_CN(28) $_CN(27) $_CN(25) $_CN(18) $_CN(23)]
$_TMP(PW_14) do setDimension 100
$_TMP(PW_14) delete
unset _TMP(PW_14)

pw::Application clearClipboard
# Use the actual spacing
set _TMP(INDEX) [lindex [$_CN(20) getSubConnectorRange 1] 0]
set _TMP(ACTUAL_SPACE) [pwu::Vector3 length [pwu::Vector3 subtract [$_CN(20) getXYZ $_TMP(INDEX)] [$_CN(20) getXYZ [expr {$_TMP(INDEX) + 1}]]]]
set _TMP(SPC_1) [pw::SpacingExplicit create]
$_TMP(SPC_1) setValue $_TMP(ACTUAL_SPACE)
unset _TMP(ACTUAL_SPACE)
unset _TMP(INDEX)
pw::Application setClipboard [list $_TMP(SPC_1)]
$_TMP(SPC_1) delete
unset _TMP(SPC_1)

set _TMP(AVG_SPACE) 0.0
set _TMP(COUNT) 0
set _TMP(mode_10) [pw::Application begin Paste]
  foreach _TMP(SPACE) [$_TMP(mode_10) getEntities] {
    set _TMP(AVG_SPACE) [expr {$_TMP(AVG_SPACE) + [$_TMP(SPACE) getValue]}]
    incr _TMP(COUNT)
  }
  if {$_TMP(COUNT) > 0} {
    set _TMP(AVG_SPACE) [expr {$_TMP(AVG_SPACE) / $_TMP(COUNT)}]
  }
  unset _TMP(COUNT)
  unset _TMP(SPACE)
$_TMP(mode_10) abort
unset _TMP(mode_10)

set _TMP(mode_10) [pw::Application begin Modify [list $_CN(3)]]
  set _TMP(PW_15) [$_CN(3) getDistribution 1]
  $_TMP(PW_15) setEndSpacing $_TMP(AVG_SPACE)
  unset _TMP(PW_15)
$_TMP(mode_10) end
unset _TMP(mode_10)
unset _TMP(AVG_SPACE)

set _TMP(AVG_SPACE) 0.0
set _TMP(COUNT) 0
set _TMP(mode_10) [pw::Application begin Paste]
  foreach _TMP(SPACE) [$_TMP(mode_10) getEntities] {
    set _TMP(AVG_SPACE) [expr {$_TMP(AVG_SPACE) + [$_TMP(SPACE) getValue]}]
    incr _TMP(COUNT)
  }
  if {$_TMP(COUNT) > 0} {
    set _TMP(AVG_SPACE) [expr {$_TMP(AVG_SPACE) / $_TMP(COUNT)}]
  }
  unset _TMP(COUNT)
  unset _TMP(SPACE)
$_TMP(mode_10) abort
unset _TMP(mode_10)

set _TMP(mode_10) [pw::Application begin Modify [list $_CN(10) $_CN(15) $_CN(14) $_CN(6) $_CN(5) $_CN(3) $_CN(1) $_CN(11)]]
  set _TMP(PW_16) [$_CN(3) getDistribution 1]
  $_TMP(PW_16) setEndSpacing $_TMP(AVG_SPACE)
  unset _TMP(PW_16)
  set _TMP(PW_17) [$_CN(1) getDistribution 1]
  $_TMP(PW_17) setEndSpacing $_TMP(AVG_SPACE)
  unset _TMP(PW_17)
  set _TMP(PW_18) [$_CN(5) getDistribution 1]
  $_TMP(PW_18) setBeginSpacing $_TMP(AVG_SPACE)
  unset _TMP(PW_18)
  set _TMP(PW_19) [$_CN(6) getDistribution 1]
  $_TMP(PW_19) setBeginSpacing $_TMP(AVG_SPACE)
  unset _TMP(PW_19)
  set _TMP(PW_20) [$_CN(10) getDistribution 1]
  $_TMP(PW_20) setEndSpacing $_TMP(AVG_SPACE)
  unset _TMP(PW_20)
  set _TMP(PW_21) [$_CN(14) getDistribution 1]
  $_TMP(PW_21) setEndSpacing $_TMP(AVG_SPACE)
  unset _TMP(PW_21)
  set _TMP(PW_22) [$_CN(15) getDistribution 1]
  $_TMP(PW_22) setBeginSpacing $_TMP(AVG_SPACE)
  unset _TMP(PW_22)
  set _TMP(PW_23) [$_CN(11) getDistribution 1]
  $_TMP(PW_23) setBeginSpacing $_TMP(AVG_SPACE)
  unset _TMP(PW_23)
$_TMP(mode_10) end
unset _TMP(mode_10)
unset _TMP(AVG_SPACE)

set _TMP(mode_10) [pw::Application begin Modify [list $_CN(21) $_CN(25) $_CN(24) $_CN(23) $_CN(19) $_CN(18) $_CN(28) $_CN(27)]]
  set _TMP(PW_24) [$_CN(18) getDistribution 1]
  $_TMP(PW_24) setEndSpacing 0.01
  unset _TMP(PW_24)
  set _TMP(PW_25) [$_CN(19) getDistribution 1]
  $_TMP(PW_25) setEndSpacing 0.01
  unset _TMP(PW_25)
  set _TMP(PW_26) [$_CN(21) getDistribution 1]
  $_TMP(PW_26) setEndSpacing 0.01
  unset _TMP(PW_26)
  set _TMP(PW_27) [$_CN(23) getDistribution 1]
  $_TMP(PW_27) setEndSpacing 0.01
  unset _TMP(PW_27)
  set _TMP(PW_28) [$_CN(24) getDistribution 1]
  $_TMP(PW_28) setEndSpacing 0.01
  unset _TMP(PW_28)
  set _TMP(PW_29) [$_CN(25) getDistribution 1]
  $_TMP(PW_29) setEndSpacing 0.01
  unset _TMP(PW_29)
  set _TMP(PW_30) [$_CN(27) getDistribution 1]
  $_TMP(PW_30) setBeginSpacing 0.01
  unset _TMP(PW_30)
  set _TMP(PW_31) [$_CN(28) getDistribution 1]
  $_TMP(PW_31) setEndSpacing 0.01
  unset _TMP(PW_31)
$_TMP(mode_10) end
unset _TMP(mode_10)

set _TMP(PW_32) [pw::DomainStructured createFromConnectors -reject _TMP(unusedCons) -solid [list $_CN(1) $_CN(25) $_CN(11) $_CN(2) $_CN(12) $_CN(7) $_CN(20) $_CN(10) $_CN(15) $_CN(26) $_CN(23) $_CN(14) $_CN(9) $_CN(24) $_CN(8) $_CN(27) $_CN(17) $_CN(19) $_CN(3) $_CN(5) $_CN(13) $_CN(18) $_CN(6) $_CN(22) $_CN(4) $_CN(28) $_CN(21) $_CN(16)]]
unset _TMP(unusedCons)
set _TMP(PW_33) [pw::BlockStructured createFromDomains -poleDomains _TMP(poleDoms) -reject _TMP(unusedDoms) $_TMP(PW_32)]
unset _TMP(unusedDoms)
unset _TMP(poleDoms)
unset _TMP(PW_33)
unset _TMP(PW_32)

pw::Application setCAESolver {CFD++} 3

set _DM(1) [pw::GridEntity getByName "dom-3"]
set _DM(2) [pw::GridEntity getByName "dom-10"]
set _DM(3) [pw::GridEntity getByName "dom-1"]
set _DM(4) [pw::GridEntity getByName "dom-2"]
set _DM(5) [pw::GridEntity getByName "dom-4"]
set _DM(6) [pw::GridEntity getByName "dom-5"]
set _DM(7) [pw::GridEntity getByName "dom-6"]
set _DM(8) [pw::GridEntity getByName "dom-7"]
set _DM(9) [pw::GridEntity getByName "dom-8"]
set _DM(10) [pw::GridEntity getByName "dom-9"]
set _DM(11) [pw::GridEntity getByName "dom-11"]
set _DM(12) [pw::GridEntity getByName "dom-12"]
set _DM(13) [pw::GridEntity getByName "dom-13"]
set _DM(14) [pw::GridEntity getByName "dom-14"]
set _DM(15) [pw::GridEntity getByName "dom-15"]
set _DM(16) [pw::GridEntity getByName "dom-16"]
set _BL(1) [pw::GridEntity getByName "blk-1"]
set _BL(2) [pw::GridEntity getByName "blk-2"]
set _BL(3) [pw::GridEntity getByName "blk-3"]
set _TMP(PW_77) [pw::BoundaryCondition getByName "Unspecified"]
set _TMP(PW_78) [pw::BoundaryCondition create]

set _TMP(PW_79) [pw::BoundaryCondition getByName "bc-2"]
unset _TMP(PW_78)
$_TMP(PW_79) setName "inlet"

$_TMP(PW_79) apply [list [list $_BL(3) $_DM(10)]]

set _TMP(PW_80) [pw::BoundaryCondition create]

set _TMP(PW_81) [pw::BoundaryCondition getByName "bc-3"]
unset _TMP(PW_80)
$_TMP(PW_81) setName "outlet"

$_TMP(PW_81) apply [list [list $_BL(2) $_DM(5)]]

set _TMP(PW_82) [pw::BoundaryCondition create]

set _TMP(PW_83) [pw::BoundaryCondition getByName "bc-4"]
unset _TMP(PW_82)
$_TMP(PW_83) setName "wall_no_slip"

$_TMP(PW_83) apply [list [list $_BL(1) $_DM(4)] [list $_BL(2) $_DM(6)] [list $_BL(3) $_DM(13)]]

set _TMP(PW_84) [pw::BoundaryCondition create]

set _TMP(PW_85) [pw::BoundaryCondition getByName "bc-5"]
unset _TMP(PW_84)
$_TMP(PW_85) setName "wall_top"

$_TMP(PW_85) apply [list [list $_BL(1) $_DM(3)] [list $_BL(2) $_DM(7)] [list $_BL(3) $_DM(14)]]

set _TMP(PW_86) [pw::BoundaryCondition create]

set _TMP(PW_87) [pw::BoundaryCondition getByName "bc-6"]
unset _TMP(PW_86)
$_TMP(PW_87) setName "wall_sides"

$_TMP(PW_87) apply [list [list $_BL(1) $_DM(8)] [list $_BL(1) $_DM(9)] [list $_BL(2) $_DM(11)] [list $_BL(2) $_DM(12)] [list $_BL(3) $_DM(15)] [list $_BL(3) $_DM(16)]]

unset _TMP(PW_77)
unset _TMP(PW_79)
unset _TMP(PW_81)
unset _TMP(PW_83)
unset _TMP(PW_85)
unset _TMP(PW_87)


# Zoom to geometry
pw::Display resetView

exit

}

# END SCRIPT