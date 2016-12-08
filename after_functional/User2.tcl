#/////////////////////////////////////////////////////////////////
#
# Function getMessage {msg} {} This function is used to be called 
# by server to pass the message from server to User2
#
#/////////////////////////////////////////////////////////////////
proc getMessage {msg} {
	puts "\[User2]: message \"$msg\" received.";
	set response "simulation results";
	return $response;
}


source ./server.tcl

puts "---------------User2 program example---------------"

namespace import server::*

server::start

