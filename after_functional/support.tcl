namespace eval support {}

# {\
#   {from {} to {} when {} about {} message {} command {}} \  <-full, empty
#   {from 2.1 to 1.1 message _ command try} \                 <-stop example
#   {from 1.1 to s.1 message __} \                            <-stop example
# }

proc from msg {
  return [::support::ifNotBlank $msg from]
}
proc to msg {
  return [::support::ifNotBlank $msg to]
}
proc when msg {
  return [::support::ifNotBlank $msg when]
}
proc about msg {
  return [::support::ifNotBlank $msg about]
}
proc command msg {
  return [::support::ifNotBlank $msg command]
}
proc support::message msg {
  return [::support::ifNotBlank $msg message]
}
proc support::contents msg {
  if {[support::ifNotBlank $msg from]     eq "" &&
      [support::ifNotBlank $msg to]       eq "" &&
      [support::ifNotBlank $msg when]     eq "" &&
      [support::ifNotBlank $msg about]    eq "" &&
      [support::ifNotBlank $msg command]  eq "" &&
      [support::ifNotBlank $msg message]  eq ""
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
