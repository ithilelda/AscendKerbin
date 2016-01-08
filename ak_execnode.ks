// Library script, please add once modifier when running.
// Executing the next maneuver node in great precision. Everything is assumed to run in vaccuum!
// version: 1.0
// Author: ithilelda
// Date: Jan. 6th, 2015


@lazyglobal off.


// import the libraries.
run once ak_utils.
run once ak_math.


// pretty print of information.
function ak_printinfo {
	parameter nod.
	print "Arriving at node in: --- " + nod:eta + " seconds. ---" at(0,5).
	print "Remaining delta V to burn is: " + nod:deltav:mag at(0,7).
	print "There are " + ak_min_burntime(nod:deltav:mag) + " seconds left to burn." at(0,9).
}

// The major function that encloses all the work. Will remove node after execution.
function ak_execnode {
	clearscreen.
	local nd to nextnode. // please handle runtime error yourself...
	sas off.
	rcs on. // using rcs when available to help steer the ship faster <- more node accuracy.
	set ship:control:pilotmainthrottle to 0.
	
	print "==================================================".
	print "Executing the next available node..." at(7,1).
	print "==================================================".
	
	// turn and lock steering before main loop.
	lock steering to lookdirup(nd:deltav, facing:topvector).
	wait until facing:forevector * nd:deltav > 0.95. // wait until the forward direction of the ship aligns with the node's deltav direction.
	
	// calculate and store the minimum burn time required to finish this maneuver, and wait till then.
	local burn_time to ak_min_burntime(nd:deltav:mag).
	set warp to 3.
	wait until nd:eta <= burn_time / 2.
	set warp to 0.
	
	// finally we start burning.
	local exec_done to false.
	local dv0 to nd:deltav.
	local throt to 0.
	lock throttle to throt.
	until exec_done {
		ak_printinfo(nd).
		set throt to min(ak_min_burntime(nod:deltav:mag), 1).
		
		if dv0 * nd:deltav < 0 {
			lock throttle to 0.
			set exec_done to true.
		}
	}
	print "Execution complete...".
	unlock steering.
	unlock throttle.
	sas on.
	remove nd.
}