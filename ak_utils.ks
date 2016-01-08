// Library script, please add once modifier when running.
// Misc. utility script collection.
// version: 1.0
// Author: ithilelda
// Date: Jan. 6th, 2015


@lazyglobal off.


// get a list of currently active engines in the current vessel.
function ak_active_eng {
	list engines in engs.
	local ac_engs to list().
	for eng in engs {
		if eng:ignition {
			ac_engs:add(eng).
		}
	}
	return ac_engs.
}