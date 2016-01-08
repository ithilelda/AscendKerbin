// Library script, please add once modifier when running.
// Executing the next maneuver node in great precision.
// version: 1.0
// Author: ithilelda
// Date: Jan. 6th, 2015

@lazyglobal off.

// import the libraries.
run once ak_staging.
run once ak_math.

// pretty print of information.
function ak_printinfo {
	parameter nod.
	print "Estimated time to arrive at node is: " + nod:eta at(0,5).
	print "Remaining delta V to burn is: " + nod:deltav:mag at(0,7).
	print "Delta V left on the ship is: " + ak_deltav() at(0,9).
	
}


// The major function that encloses all the work.
function ak_execnode {
	clearscreen.
	delcare nd to nextnode. // please handle runtime error yourself...
	sas off.
	rcs on. // using rcs when available to help steer the ship faster <- more node accuracy.
	set ship:control:pilotmainthrottle to 0.
	
	print "==================================================".
	print "Executing the next available node..." at(7,1).
	print "==================================================".
	
	// turn and lock steering before main loop.
	lock steering to lookdirup(nd:deltav, facing:topvector).
	
	declare exec_done to false.
	declare mode to 0.
	until exec_done = true {
		ak_printinfo(nd).
		
		
	}
}