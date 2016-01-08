// Circularizing suborbital trajectories into oribits.
// version: 1.0
// Author: ithilelda
// Date: Jan. 6th, 2015

// Description: automatically calculates and handles necessary circularizing events.
// No parameters needed, since we are just raising the pe to match ap.
// Will take all remaining stages into consideration, so that burn time calculation
// is always correct, eliminating the error cases where the previous powerful stage
// depletes before burn is finished and the later weak stage cannot keep up.


/////////// setup code //////////////

clearscreen.
set ship:control:pilotmainthrottle to 0. // turn down the engines to 0 so that you don't have to do it all the time.

////////// end of setup /////////////


///////////// functions /////////////

///////// end of functions //////////