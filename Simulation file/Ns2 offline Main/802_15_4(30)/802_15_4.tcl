# TCL file for simulating Wireless 802.15.4 (mobile)

#####################################
# Set values of the parameters
#####################################

set cbr_size 64  
set cbr_rate 11.0Mb
set x_dim 300  
set y_dim 300 
set num_col 5
set time_duration 25 
set start_time 10 
set extra_time 10
set flow_start_gap 0.0
set motion_start_gap 0.05
set num_node [lindex $argv 0] 
set num_flow [lindex $argv 1] 
set speed    [lindex $argv 2]  
set cbr_pckt_per_sec [lindex $argv 3]  
set factor [lindex $argv 4]
set cbr_interval [expr 1.0/$cbr_pckt_per_sec] ;# packet sent per second
set num_motion [expr int($num_node*rand()/2)]
set udp_src Agent/UDP; #using udp 
set udp_sink Agent/Null ; #so sink is null

if {$num_node >= 50} {
	set num_col [expr 2*$num_col]
}
set num_row [expr $num_node/$num_col]
puts "row : $num_row  col: $num_col"


#####################################
# Define options
#####################################
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy/802_15_4   ;# network interface type
set val(mac)            Mac/802_15_4               ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         100                        ;# max packet in ifq
set val(nn)             $num_node                  ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol

#####################################
# Energy parameters
#####################################
set val(energymodel_15)    EnergyModel     ;
set val(initialenergy_15)  100             ;# Initial energy in Joules

set val(idlepower_15) 712e-6			;#LEAP (802.11g) 
set val(rxpower_15) 35.28e-3			;#LEAP (802.11g)
set val(txpower_15) 31.32e-3			;#LEAP (802.11g)
set val(sleeppower_15) 144e-9			;#LEAP (802.11g)
#set val(transitionpower_11) 176.695e-3		;#LEAP (802.11g)	??????????????????????????????/
#set val(transitiontime_11) 2.36			;#LEAP (802.11g)

#
# Other Options
#
#SMac/802_15_4 set dataRate_ 11Mb
#SMac/802_15_4 set syncFlag_ 1
#SMac/802_15_4 set dutyCycle_ cbr_interval
#$ns_ puts-nam-traceall {# nam4wpan #}                   ;# inform nam that this is a trace file for wpan (special handling needed)

#Mac/802_15_4 wpanNam macType $para1  # added by pranesh
#Mac/802_15_4 wpanCmd verbose on
#Mac/802_15_4 wpanNam namStatus on                   ;# default = off (should be turned on before other 'wpanNam' commands can work)
#Mac/802_15_4 wpanNam ColFlashClr gold             ;# default = gold


#####################################
# Main Program
#####################################

set tr 802_15_4.tr
set nm 802_15_4.nam
set topo_file topo_802_15_4_$factor.txt

#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open $tr w]
set namtrace    [open $nm w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $x_dim $y_dim ;#trace all wireless communication in certain region

# set up topography object
set topofile   [open $topo_file "w"]

set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
Phy/WirelessPhy set CSThresh_ $dist(40m)
Phy/WirelessPhy set RXThresh_ $dist(40m)

set topo       [new Topography]
$topo load_flatgrid $x_dim $y_dim

#
# Create God
#
create-god $val(nn)

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

# configure node

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel [new $val(chan)] \
			 -topoInstance $topo \
			 -energyModel $val(energymodel_15) \
			 -idlePower $val(idlepower_15) \
			 -rxPower $val(rxpower_15) \
			 -txPower $val(txpower_15) \
          		 -sleepPower $val(sleeppower_15) \
			 -initialEnergy $val(initialenergy_15)\
			 -agentTrace ON \
			 -routerTrace OFF \
			 -macTrace ON \
			 -movementTrace OFF
			 #-transitionPower $val(transitionpower_11) \
			 #-transitionTime $val(transitiontime_11) \			

#####################################
# Node Creation
#####################################
puts "start node creation"			 
for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
#	$node_($i) random-motion 0		;# disable random motion
}
#puts "GRID topology"
set x_start [expr $x_dim/($num_col*2)];
set y_start [expr $y_dim/($num_row*2)];
set i 0;
while {$i < $num_row } {
#in same column
    for {set j 0} {$j < $num_col } {incr j} {
#in same row
	set m [expr $i*$num_col+$j];

	set x_pos [expr $x_start+$j*($x_dim/$num_col)];#grid settings
	set y_pos [expr $y_start+$i*($y_dim/$num_row)];#grid settings

	$node_($m) set X_ $x_pos;
	$node_($m) set Y_ $y_pos;
	$node_($m) set Z_ 0.0
#	puts "$m"
	puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
    }
    incr i;
}; 

puts "node creation complete"
for {set i 0} {$i < $val(nn)} { incr i } {
	$ns_ initial_node_pos $node_($i) 4
}
#
# Now produce some simple node movements
#
puts "no of nodes in motion $num_motion at speed $speed"
for {set i 1} {$i < [expr $num_motion+1] } {incr i} {
	set nd [expr int($num_node*rand())]
	set x_pos_new [expr int($x_dim*rand())] ;#random settings
	set y_pos_new [expr int($y_dim*rand())] ;#random settings
	$ns_ at [expr $start_time+$i*$motion_start_gap] "$node_($nd) setdest $x_pos_new $y_pos_new $speed"
	#puts -nonewline $topofile "$i x: [$node_($i) set X_] y: [$node_($i) set Y_] \n"
	puts -nonewline $topofile "$i Changed position: $nd x: $x_pos_new y: $y_pos_new \n"
}

#####################################
# Flow creation
#####################################
puts "num_flows is set $num_flow"
# Setup traffic flow between nodes
for {set i 0} {$i < $num_flow} {incr i} {
	set udp_($i) [new $udp_src]
	$udp_($i) set class_ $i
	set null_($i) [new $udp_sink]
	$udp_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}
} 

#
# RANDOM FLOW
#

# Creating udp_node & null_node
for {set i 0} {$i < $num_flow} {incr i} {
	set udp_node [expr int($num_node*rand())] ;# src node
	set null_node $udp_node
	while {$null_node==$udp_node} {
		set null_node [expr int($num_node*rand())] ;# dest node
	}
	$ns_ attach-agent $node_($udp_node) $udp_($i)
  	$ns_ attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "RANDOM:  Src: $udp_node Dest: $null_node\n"
}

# Connecting udp_node & null_node
for {set i 0} {$i < $num_flow } {incr i} {
     $ns_ connect $udp_($i) $null_($i)
}
# Creating packet generator (CBR) for source node
for {set i 0} {$i < $num_flow } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
}  

# Declaring packet generation time
for {set i 0} {$i < $num_flow } {incr i} {
     $ns_ at [expr $start_time+$i*$flow_start_gap] "$cbr_($i) start"
}
puts "flow creation complete"

#####################################
# Ending of the simulation
#####################################
#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at [expr $start_time+$time_duration] "$node_($i) reset";
}
$ns_ at [expr $start_time+$time_duration +$extra_time] "finish"
#$ns_ at 150.01 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at [expr $start_time+$time_duration +$extra_time] "$ns_ nam-end-wireless [$ns_ now]; puts \"NS Exiting...\"; $ns_ halt"

$ns_ at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
$ns_ at [expr $start_time+$time_duration] "puts \"end of simulation duration\""
proc finish {} {
    puts "finishing"
    global ns_ tracefd namtrace topofile nm
    $ns_ flush-trace
    close $tracefd
    close $namtrace
    close $topofile
   # exec nam 802_15_4.nam &
    exit 0
}

puts "Starting Simulation..."
$ns_ run
