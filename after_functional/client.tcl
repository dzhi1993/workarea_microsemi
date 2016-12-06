#source ./support.tcl

namespace eval client {
	
	# This is the interface of namespace
	namespace export start

	# Setup #
	proc setup {} {
		#make a db or whatever.
		#::repo::create $::myname
	}

	proc setGlobals {} {
		set ::chan {}
		set ::myname {}
	}

	# Client #
	proc run {} {
		set msg ""
		set sendmsg ""
		set introduction "from"
		lappend introduction [::client::helpers::getMyName]
		lappend introduction "to"
		lappend introduction "server"
		lappend introduction "message"
		lappend introduction "goodmorning"
		puts $::chan $introduction

		flush $::chan
		::client::set::up
		puts "Server responded: [gets $::chan]"
		puts "Awaiting instructions from server..."

		while {1} {
			set msg [::client::getsMsg [gets $::chan]]
			puts "received: $msg"
			set sendmsg [::client::explore $msg]
			::client::sendMsg $sendmsg
		}
	}

	proc ::client::getsMsg {message} {
		set x yes
		set msg $message

		while {$x} {
			fconfigure $::chan -blocking 0
			gets $::chan message

			if {$message eq ""} {
				set x no
			} else {
				lappend msg $message
			}

		}
		fconfigure $::chan -blocking 1
		return $msg
	}

	proc sendMsg {sendmsg} {
		if {$sendmsg ne ""} {
			#puts "sending: $sendmsg"
			puts $::chan $sendmsg
			flush $::chan
		}
	}

	# Interpret #
	proc explore msg {
		return [::client::interpret $msg]
	}

	proc interpret msg {
		#return "this is where you send call other modules etc."
		puts "from [support::from $msg]"
		puts "to [support::to $msg]"
		puts "about [support::about $msg]"
		puts "when [support::when $msg]"
		puts "command [support::command $msg]"
		puts "message [support::message $msg]"
		return [list [list from $::myname to user command "hello" message "world"]]
	}

	# Helpers #
	proc helpers::getMyName {} {
		puts "What is my name?"
		flush stdout
		set ::myname [gets stdin]
		return $::myname
	}

	# Run #
	# expose to outside
	proc start {address} {
		setGlobals
		set chan [socket $address 9900]
		run
	}
	

	# {\
	#   {from {} to {} when {} about {} message {} command {}} \  <-full, empty
	#   {from 2.1 to 1.1 message _ command try} \                 <-stop example
	#   {from 1.1 to s.1 message __} \                            <-stop example
	# }

	proc support::from msg {
		return [support::ifNotBlank $msg from]
	}
	proc support::to msg {
		return [support::ifNotBlank $msg to]
	}
	proc support::when msg {
		return [support::ifNotBlank $msg when]
	}
	proc support::about msg {
		return [support::ifNotBlank $msg about]
	}
	proc support::command msg {
		return [support::ifNotBlank $msg command]
	}
	proc support::message msg {
		return [support::ifNotBlank $msg message]
	}
	proc support::contents msg {
		if {[::support::ifNotBlank $msg from]     eq "" &&
				[::support::ifNotBlank $msg to]       eq "" &&
				[::support::ifNotBlank $msg when]     eq "" &&
				[::support::ifNotBlank $msg about]    eq "" &&
				[::support::ifNotBlank $msg command]  eq "" &&
				[::support::ifNotBlank $msg message]  eq ""
		} then {
			return
		}
		return [dict keys $msg]
	}

	proc support::ifNotBlank {msg key} {
		if {[dict exists $msg $key]} {
			return [dict get $msg $key]
		}
		return
	}
	
	
}