#source ./support.tcl

namespace eval user {} {

	puts "------------------- User port -------------------"

	namespace export SendMessage CheckMessage connect disconnect SendMessageNoReply
	# Client #
	variable chanInit "Non-connection"
	variable ::chan $chanInit
	
	#//////////////////////////////////////////////////////////////////////
	# ::user::run 
	#
	# the main method of user client port, handle everything
	#//////////////////////////////////////////////////////////////////////


	#//////////////////////////////////////////////////////////////////////
	# ::user::helpers::getInput 
	#
	# this function is used to get user input in cmd
	#//////////////////////////////////////////////////////////////////////
	proc getInput {} {
		flush ;
		set line [gets stdin];
		return $line;
	}

	# TODO: User1 sends msg to client port and waiting reply from client
	proc SendMessage {serverAddress message} {
		variable ::chan;
		if {$::chan eq "Non-connection"} {
			set ::chan [connect $serverAddress];
		}
		#set sendMessage "$serverAddress $message"; 
		puts $::chan "$serverAddress $message";
		flush $::chan;
		
		set reply "";
		set LoopCounter 100;
		while {1} {
			set returnMessage [gets $::chan];
			if {$returnMessage ne ""} {
				puts $returnMessage;
				set reply "Pass";
				break;
			} elseif {$LoopCounter == 0} {
				set reply "Fail";
				break;
			}
			incr LoopCounter -1;
			after 100;
		}
		
		return $reply;
	}
	
	#/////////////////////////////////////////////////////////////////////////////
	#send message without reply
	#/////////////////////////////////////////////////////////////////////////////
	proc SendMessageNoReply {serverAddress message} {
		variable ::chan;
		if {$::chan eq "Non-connection"} {
			set ::chan [connect $serverAddress];
		}
		#set sendMessage "$serverAddress $message"; 
		puts $::chan "$serverAddress $message";
		flush $::chan;
	}
	
	# TODO: User1 sends polling message to client, this polling message will be further 
	# send to server and User2. Then User1 waiting reply from User2.
	proc CheckMessage {serverAddress message} {
	  #TODO: ignore message comfirmation from server. 
		#puts $::chan "$serverAddress $message";
		#flush $::chan;
		set returnMessage "";
		set LoopCounter 100;
		while {1} {
			set returnMessage [gets $::chan];
			if {$returnMessage ne ""} {
				break;
			} elseif {$LoopCounter == 0} {
				break;
			}
			incr LoopCounter -1;
			after 100;
		}
		return $returnMessage;
	}
	
	# Run #
	# exposed to outside
	proc connect {address} {
		set ::chan [socket $address 9900];
		#set ipAddress [lindex [fconfigure $chan -sockname] 0];
		puts $::chan "$address connecting";
		flush $::chan;
		
		puts "\[server]: [gets $::chan]";
		#fileevent stdin readable [list userInput]
		#vwait forever
		return $::chan
	}

	# close port #
	# 
	proc disconnect {} {
		#Todo: get the socket channel number created by socket protocol via host ip address
		variable chanInit;
		close $::chan
		set $::chan $chanInit;
	
	}

}
