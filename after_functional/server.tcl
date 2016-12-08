# source ./support.tcl

puts "------------------- Server port -------------------"

namespace eval server {

	namespace export start getMessage
	
	variable CurrentLinkedTable ""
	variable msgRecList  ""
	variable msgSendList  ""
	# Setup #
	proc createglobal {} {
		set clients {}
	}

	# Handle #
	#//////////////////////////////////////////////////////////////////////
	#
	# handle::Client chan as channelword
	#
	# recieve a message in a particular channel. Evaluate it, and forward it onto
	# the correct recipient.
	#
	# exmaple: {from 1.1 to s.1 message 6 when 13:34:50}
	# sends to s.1: {from 1.1 to s.1 message 6 when 13:34:50}
	#
	#//////////////////////////////////////////////////////////////////////
	proc handleClient chan {
		set msgs [gets $chan]

	}
	
	#//////////////////////////////////////////////////////////////////////
	# Expose to outside namespace for other porgram to get message.
	#//////////////////////////////////////////////////////////////////////
	#proc getMessage {msg} {
	#	return $msg;
	#}
	
	#//////////////////////////////////////////////////////////////////////
	# handle::user chan as channel
	#
	# forward the user command appropriately.
	#//////////////////////////////////////////////////////////////////////
	proc handleUser {chan} {
		set msg [gets $chan];
		puts "\[[lindex $msg 0]]: [lreplace $msg 0 0]";	
		#TODO: judge the message information, only the message from User1 can be sent to User2. (Done)
		#TODO: the message list can be grown (Done)
		
		#the funciton getMessage is a sample proc, you can replace it with your function which is User2's interface
		set response [getMessage [lreplace $msg 0 0]];
		
		#puts $chan "Here, you can puts the simulation results so that it can be sent back to client port."
		puts $chan [list {[server]: Message received} $response];
		puts Done
		#accept $chan
	}

	# Accept #
	#//////////////////////////////////////////////////////////////////////
	# accept chan as channel addr as word port as word
	#	
	# meet new connections and record their details
	#//////////////////////////////////////////////////////////////////////
	proc accept {chan addr port} {
		set msg [gets $chan];
		
		set PcName [lindex $msg 0];
		set PcChannel $chan;
		linkedTable "set $PcName $PcChannel";
		#set name [::support::from $msg]
		puts "\[$PcName]: [lindex $msg 1]";
		#[::server::greet::client $chan $name user]
		#if {$name eq "user"} {
		greetClient $chan $PcName [lindex $msg 1];
		#} else {
		#	::server::greet::client $chan $name client $msg
		#}
	}

	#///////////////////////////////////////////////////////////////////////////////////////////////
	# handle::user chan as channel
	# record details, respond, set up fileevent for each channgel.
	#
	# About fconfigure channelID -buffering newValue
	# (1) If newValue is full then the I/O system will buffer output until its internal buffer is full 
	# or until the flush command is invoked. 
	# (2) If newValue is line, then the I/O system will automatically flush output for the channel 
	# whenever a newline character is output. 
	# (3) If newValue is none, the I/O system will flush automatically after every output operation. 
	# (4) The default is for -buffering to be set to full except for channels that connect to 
	# terminal-like devices; for these channels the initial setting is line. 
	# (5) Additionally, stdin and stdout are initially set to line, and stderr is set to none.
	#
	#///////////////////////////////////////////////////////////////////////////////////////////////
	proc greetClient {chan name msg} {
		fconfigure $chan -buffering line;
		after 2000
		puts $chan "Message: \"$msg\" received";
		lappend clients $name $chan;
		# puts $::clients      #ex. user sock240
		#fileevent - execute a script or function when a channel becomes readable or writable
		fileevent $chan readable [handleUser $chan];
	}

	# run #
	#TODO: exposed to outside
	proc start {} {
		createglobal
		socket -server accept 9900
		vwait forever
	}

	# TODO: current linked
	
	proc linkedTable {commandlist} {
		#TODO: This function will be used to store the current connected socket channel
		#for instance: a list A {"host PC name1", "socket channel number1"}
		#["PC1", "sock001", "PC2", "sock002", "PC3", "sock003", "PC4", "sock004"]
		set valReturn "";
		variable CurrentLinkedTable;
		set type [lindex $commandlist 0];
		switch $type {
			"set" {
				set PcName [lindex $commandlist 1];
				set PcChannel [lindex $commandlist 2];
				set indexInputVal -1;
				for {set i 0} {$i < [llength $CurrentLinkedTable]} {incr i} {
					if {[lindex $CurrentLinkedTable $i] == $PcName} {
						#update pcname and pcchannel
						set indexInputVal [expr $i + 1];
						set mylist [lreplace $CurrentLinkedTable $indexInputVal $indexInputVal $PcChannel];
						set CurrentLinkedTable $mylist;
					}
				}
				if {$indexInputVal == -1} {
					#add new pcname and pcchannel
					lappend CurrentLinkedTable $PcName $PcChannel;
					}
				
			}
			"get" {
				set quest [lindex $commandlist 1];
				set inputVal [lindex $commandlist 2];
				set indexInputVal -1;
				for {set i 0} {$i < [llength $CurrentLinkedTable]} {incr i} {
					if {[lindex $CurrentLinkedTable $i] == $inputVal} {
						set indexInputVal $i;
					}
				}
				if {$indexInputVal != -1} {
					if {$quest eq "PcName"} {
						set valReturn [lindex $commandlist [expr $indexInputVal - 1]];
					} 
					elseif {$quest eq "PcChannel"} {
						set valReturn [lindex $commandlist [expr $indexInputVal + 1]];
					} 
				}
					return $valReturn
			}
			"remove" {
				set PcName [lindex $commandlist 1];
				#set PcChannel [lindex $commandlist 2];
				set idx [lsearch $CurrentLinkedTable $PcName];
				set mylist [lreplace $CurrentLinkedTable $idx [expr $idx + 1]];
				set CurrentLinkedTable $mylist
				break;
			}
		}
	}
	
}