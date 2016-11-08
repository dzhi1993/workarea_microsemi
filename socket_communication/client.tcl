source ./see.tcl

namespace eval ::client {}
namespace eval ::client::set {}
namespace eval ::client::main {}
namespace eval ::client::actions {}
namespace eval ::client::record {}
namespace eval ::client::find {}
namespace eval ::client::helpers {}

############################################################################
# Setup ####################################################################
############################################################################

proc ::client::set::up {} {
  #make a db or whatever.
  #::repo::create $::myname
}

proc ::client::set::globals {} {
  set ::chan {}
  set ::myname {}
}


############################################################################
# Client ###################################################################
############################################################################


proc ::client::run {} {
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

proc ::client::sendMsg {sendmsg} {
  if {$sendmsg ne ""} {
    #puts "sending: $sendmsg"
    puts $::chan $sendmsg
    flush $::chan
  }
}


############################################################################
# Interpret ################################################################
############################################################################

proc ::client::explore msg {
  return [::client::interpret $msg]
}

proc ::client::interpret msg {
  #return "this is where you send call other modules etc."
  puts "from [::see::from $msg]"
  puts "to [::see::to $msg]"
  puts "about [::see::about $msg]"
  puts "when [::see::when $msg]"
  puts "command [::see::command $msg]"
  puts "message [::see::message $msg]"
  return [list [list from $::myname to user command "hello" message "world"]]
}


############################################################################
# Helpers ##################################################################
############################################################################


proc ::client::helpers::getMyName {} {
  puts "What is my name?"
  flush stdout
  set ::myname [gets stdin]
  return $::myname
}

############################################################################
# Run ######################################################################
############################################################################


::client::set::globals
set ::chan [socket 127.0.0.1 9900]
::client::run
