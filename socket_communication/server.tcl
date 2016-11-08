source ./see.tcl

namespace eval ::server {}
namespace eval ::server::help {}
namespace eval ::server::greet {}
namespace eval ::server::handle {}

################################################################################################################################################################
# SETUP #########################################################################################################################################################
################################################################################################################################################################

proc ::server::global {} {
	set ::clients {}
}

################################################################################################################################################################
# Handle #########################################################################################################################################################
################################################################################################################################################################


## ::server::handle::Client chan as channelword
#
# recieve a message in a particular channel. Evaluate it, and forward it onto
# the correct recipient.
#
# exmaple: {{from 1.1 to s.1 message 6 when 1458228695512}}
# sends to s.1: {from 1.1 to s.1 message 6 when 1458228695512}
#
proc ::server::handle::client chan {
  set msgs [gets $chan]

	foreach msg $msgs {
		set to [::see::to $msg]
		if {$to ne {}} {
			puts [lindex [dict get $::clients $to] 0] $msg
		}
	}
}


## sterilizeList msg as list
#
# extract lists so that we can route them
#
proc ::server::help::sterilizeList msg {
	set ret ""
	if {[llength $msg] == 1} {
		foreach message $msg {
			foreach m $message {
				set ret "$ret $m"
			}
		}
	} else {
		return $msg
	}
	return $ret
}

## ::server::handle::user chan as channel
#
# forward the user command appropriately.
#
proc ::server::handle::user chan {
  set msg [gets $chan]
  set name [::see::from $msg]
  puts "The user said: $msg"
	if {[::see::to $msg] eq "server" } {
		foreach key [dict keys $::clients] {
			if {$key ne "user"} {
				puts "SENDING:[lindex [dict get $::clients $key] 0] [list [dict replace $msg to $key]]"
				puts [lindex [dict get $::clients $key] 0] [dict replace $msg to $key]
			}
		}
	} else {
		set from [::see::from $msg]
		set to [::see::to $msg]
		puts "SENDING:[lindex [dict get $::clients $to] 0] [list $msg]"
		puts [lindex [dict get $::clients $to] 0] $msg
	}
	puts "SENDING: $chan message received"
	puts $chan "What would you like to say?"
	puts done
}


################################################################################################################################################################
# Accept #########################################################################################################################################################
################################################################################################################################################################


## ::server::accept chan as channel addr as word port as word
#
# meet new connections and record their details
#
proc ::server::accept {chan addr port} {
  set msg [gets $chan]
  set name [::see::from $msg]
	puts "Incoming msg: $msg"
 	if {$name eq "user"} {
		::server::greet::client $chan $name user
	} else {
		::server::greet::client $chan $name client $msg
  }
}

## ::server::handle::user chan as channel
#
# record details, respond, set up fileevent for each channgel.
#
proc ::server::greet::client {chan name handle {message ""}} {
	fconfigure $chan -buffering line
	puts $chan [list "from" "server" "to" $name "message" "you are $name your channel is $chan"]
	lappend ::clients $name $chan
	fileevent $chan readable [list ::server::handle::[set handle] $chan]
}


################################################################################################################################################################
# run #########################################################################################################################################################
################################################################################################################################################################


::server::global
socket -server ::server::accept 9900
vwait forever
