source ./user.tcl

puts "---------------User1 program example---------------"

namespace import user::*


#user::SendMessageNoReply 127.0.0.1 hello
#user::connect 127.0.0.1

puts "[user::SendMessage 127.0.0.1 "simulation request"]"

#puts "[user::CheckMessage 127.0.0.1 hello]"
#after 2000

#puts "[user::SendMessage 127.0.0.1 nihao]"
#puts "lalala"



user::disconnect

vwait forever