// Launch scripts for spacecraft under FAR.
// version: 1.0
// Author: ithilelda
// Date: Jan. 6th, 2015

// Description: a sophisticated launch script that's specifically tuned for lighter rockets in the early game.
// These rockets usually have a very small payload and utilizes boosters in lower atmosphere.
// There are advantages of such rockets (mainly cost) but also challenges due to the uncontrollable nature of boosters.
// First, throttle control is implemented but not assumed to always work and dependable (to allow best result using liquid engines).
// Second, gravity turn is implemented in a way without depending on speed adjustment (getting faster without control). It is not optimal, but works.
// The final result is a spacecraft launched into lower Kerbin Orbit. Since the most
// efficient way is to launch into a lower orbit and Hoffman transfer later, I internally
// tune the script to launch into a stable orbit of slightly above 70 Km. (no customization here, sorry!)

//////////// setup code //////////////

clearscreen.
declare parameter dir. // numeric degrees on the compass to indicate launching direction. 0 means north, 90 is east, 180 is south, and 270 is west.
set ship:control:pilotmainthrottle to 0. // turn down the engines to 0 so that you don't have to do it all the time.

////////// end of setup /////////////

///////// functions ////////////

// detects if the current stage is depleted of fuel (ready to proceed to the next stage).
function stage_depletion {
	return stage:solidfuel = 0 and stage:liquidfuel = 0.
}

// detects if there is still fuel left on the ship. no fuel = no more functionality.
function rocket_depletion {
	return ship:solidfuel = 0 and ship:liquidfuel = 0.
}

// calculate current small g.
function small_g {
	return body:mu / (body:radius + altitude) ^ 2.
}

// the function to return the throttle required to reach a certain twr.
function throttle_for {
	declare parameter twr.
	declare ratio to 0.
	if ship:availablethrust <> 0 {
		set ratio to twr * mass * small_g() / ship:availablethrust.
	}
	return ratio.
}

// calculate time to the altitude of interest based on the instant vertical velocity.
function deltav_at_ap {
	declare r to body:radius + apoapsis.
	declare sma to (apoapsis + periapsis + 2 * body:radius) / 2.
	declare v1 to sqrt(body:mu * (2 / r - 1 / sma)).
	declare v2 to sqrt(body:mu / r).
	return v2 - v1.
}

// print out useful messages during each loop frame.
function print_message {
	clearscreen.
	print "Current ship mode is: " + ship_mode.
	print "Current Altitude is: " + round(altitude,2).
	print "Current Air speed is: " + round(airspeed,2).
	print "Current Ground speed is: " + round(groundspeed,2).
	print "Current Vertical speed is: " + round(verticalspeed,2).
	print "Estimated Apoapsis is: " + round(apoapsis,2).
	print "Estimated Periapsis is: " + round(periapsis,2).
	print "Estimated Time to arrive at Apoapsis is: " + round(eta:apoapsis,2).
	print "Estimated Semi Major Axis is: " + round((apoapsis + periapsis + 2 * body:radius) / 2,2).
	print "Delta V to achieve circular orbit at AP is: " + round(deltav_at_ap(),2).
}

///////// end of functions ///////////



// globals used in the loop.
declare mission_done to false.
declare ship_mode to 0.
declare ap_node to 0.
declare init_deltav to 0.
declare burn_time to 0.

// huge loop to trigger stage progress. Will end after reaching lower kerbin orbit or no more fuel left.
until rocket_depletion() or mission_done = true {
	if ship_mode = 0 { // the launching phase.
		lock throttle to 1.
		sas off.
		rcs off.
		lock steering to heading(dir, 90). // lock the steering to vertical up initially. we'll gradually turn later.
		stage. // launch off.
		set ship_mode to 1.
	}
	else if ship_mode = 1 { // The pitch over maneuver phase. We adjust the pitch angle based on the mass of the spacecraft.
		declare needed_pitch to max(30, 90 - sqrt(sqrt(170.67 * altitude))).
		lock steering to heading(dir, needed_pitch).
		lock throttle to 1.
		if airspeed > 50 { // air speed reaches 50 m/s, we start our gravity turn.
			set ship_mode to 2.
		}
	}
	else if ship_mode = 2 { // gravity turn phase. We aim at prograde to keep angle of attack at 0.
		lock steering to srfprograde.
		lock throttle to 1.
		if apoapsis > body:atm:height * 1.05 { // 5% above the atmosphere, just on the safe side.
			set ship_mode to 3.
		}
	}
	else if ship_mode = 3 { // maneuver node setup phase.
		set ap_node to node(time:seconds + eta:apoapsis, 0, 0, deltav_at_ap()).
		add ap_node.
		set init_deltav to ap_node:deltav.
		set burn_time to ap_node:deltav:mag / (ship:availablethrust / mass).
		set ship_mode to 4.
	}
	else if ship_mode = 4 { // the waiting to burn mode.
		lock throttle to 0.
		set warp to 2.
		if eta:apoapsis <= burn_time / 2 + 2 {
			set ship_mode to 5.
		}
	}
	else if ship_mode = 5 { // the actual burning mode.
		set warp to 0.
		lock throttle to 1.
		lock steering to lookdirup(ap_node:deltav, facing:topvector).
		if vdot(init_deltav, ap_node:deltav) < 0 {
			set mission_done to true.
		}
	}
	
	
	// utilities performed in each cycle.
	if stage_depletion() {
		stage.
		wait until stage:ready.
	}
	print_message().
	wait 0.2.
}

if rocket_depletion() {
	print "No more fuel left, can't progress further!".
}
else if mission_done = true {
	print "Reached lower Kerbin orbit! Congratulations!".
}
else {
	print "Unknown error! You shouldn't reach here! Check code for bugs.".
}
remove ap_node.
unlock steering.
unlock throttle.
print "program execution ends...".