// Library script, please add once modifier when running.
// Mathematical helpers. All designed without side effects.
// version: 1.0
// Author: ithilelda
// Date: Jan. 6th, 2015


@lazyglobal off.


// import libraries.
run once ak_utils.


// the gravity acceleration constant at surfaces of any body.
// parameter is the name of the body.
function ak_g0 {
	parameter body_name.
	return body(body_name):mu / body(body_name):radius^2.
}

// returns the currently experienced gravitational acceleration.
function ak_g {
	return body:mu / (body:radius + altitude)^2.
}

// passing in a list of engines, and calculate the combined isp of them.
function ak_combined_isp {
	parameter engines.
	local ftisp to 0.
	local sumft to 0.
	for eng in engines {
		set ftisp to ftisp + eng:availablethrust / eng:isp.
		set sumft to sumft + eng:availablethrust.
	}
	return sumft / ftisp.
}

// calculate burn time needed to fulfill a certain deltav with currently active engines using maximum throttle.
function ak_min_burntime {
	parameter deltav.
	
	// first, we need to list all the currently active engines and combine their isp.
	local risp to ak_combined_isp(ak_active_eng()).
	
	// then we just plug in the formula.
	return ak_g0("kerbin") * mass * risp * (1 - constant:e ^ (-deltav / (ak_g0("kerbin") * risp)) / ship:availablethrust.
}

// the function to return the throttle required to reach a certain twr.
// about not clamping to 1: to allow later stages to report for error (not enough thrust etc).
// about checking for div-by-zero: putting INF where a number should be will terminate the script in an ugly way, so I check for that.
// rule of thumb: allow graceful errors to pass on, but stop ugly ones.
function ak_throttle_for {
	parameter twr.
	local ratio to 0.
	if ship:availablethrust <> 0 {
		set ratio to twr * mass * ak_g() / ship:availablethrust.
	}
	return ratio.
}

// function to calculate the semi major axis of current orbit.
function ak_sma {
	return (apoapsis + periapsis + 2 * body:radius) / 2.
}

//simple function to calculate the orbit period of vessels (small mass compared to planet body). The resulting unit is seconds.
function ak_vessel_period {
	return 2 * constant:pi * sqrt(ak_sma()^3 / body:mu).
}

// calculate the  minimum deltav needed to circularize the current suborbital trajectory into an orbit at ap.
function ak_deltav_to_orbit {
	local r to body:radius + apoapsis.
	local v1 to sqrt(body:mu * (2 / r - 1 / ak_sma())).
	local v2 to sqrt(body:mu / r).
	return v2 - v1.
}