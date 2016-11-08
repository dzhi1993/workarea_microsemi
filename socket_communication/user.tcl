source ./see.tcl

namespace eval ::user {}
namespace eval ::user::helpers {}

############################################################################
# Client ###################################################################
############################################################################

proc ::user::setGlobals {} {
  set ::chan {}
}

proc ::user::run {} {
  puts $::chan "from user to server message goodmorning"
  flush $::chan
  puts "Server responded: [gets $::chan]"
  puts "Awaiting instructions from server..."
  puts "What do you want to say?"
  while {1} {
    set input [::user::helpers::getInput]

    if {[::see::contents $input] eq ""} {
      set input [list from user to server command [lindex $input 0] message [lrange $input 1 end]]
    }
    if {$input eq "from user to server command help message {}"  ||
        $input eq "from user to server command ? message {}"     ||
        $input eq "from user to server command /? message {}"
    } then {
      ::user::helpers::displayHelp
    } else {
      puts $::chan [dict replace $input when [clock milliseconds]]
      flush $::chan
      puts [gets $::chan]
    }
  }
}

############################################################################
# Helpers ##################################################################
############################################################################

proc ::user::helpers::getInput {} {
  flush stdout
  set line [gets stdin]
  return $line
}
proc ::user::helpers::displayHelp {} {
  puts ""
  puts "############################ Help ############################"
  puts ""
  puts "command subcommand  do something specific"
  puts ""
  puts "COMMAND SUBCOMMANDS"
  puts ""
  puts "############################ end ############################"
  puts ""
}


############################################################################
# Run ######################################################################
############################################################################

set ::chan [socket 127.0.0.1 9900]
#fileevent stdin readable [list userInput]
::user::run
vwait forever
