Last Updated: 1/3/2016

SOFTWARE REQUIREMENTS
------------

reacTIVision 1.5 (http://reactivision.sourceforge.net/)
Processing 2.2.1 (https://processing.org/download/?processing)
TUIO Library for Processing (http://www.tuio.org/?processing)
Minim Library for Processing (http://code.compartmental.net/tools/minim/)
CL-Eye Platform Driver (https://codelaboratories.com/products/eye/)


USING THE PS3 EYE
------------

To use a PS3 eye with a computer you'll have to download and install the CL-Eye Driver. A copy has already been purchased for this project and is available in the Earsketch Tangibles Team folder on Google Drive.

Reactivision can only use one camera at a time, so if there is another camera connected to the computer, it must be disabled in the Device Manager.


CALIBRATION
------------

Almost every time the table is used it needs to be calibrated first. It's a pain.

If the table has been moved and the projection is not centered on the table's surface, adjust the small mirror by screwing or unscrewing the hooks that support it. It may be necessary to adjust other parts of the hardware, like the frame holding the projector. Unfortunately the current table is very sensitive to movement and we do the best we can.

To focus the camera, start by opening reacTIVision (make sure it's in tracking mode by pressing 't', you may need to adjust the gradient gate and tile size by pressing 'g' and using arrow keys) and placing a fiducial in each of the 4 corners of the table's surface as well as one in the middle. On the camera's lens, unscrew the tiny knob for the focus ring and turn it while watching the fiducials in the reacTIVision window until tracking is as consistent as possible in all corners. This is tricky, and it may end up favoring one side or the other but we try to minimize this.

To calibrate reacTIVision, first open up rectglr_calibration.pdf (packaged with reacTIVision). Then open reacTIVision and press 'c' to open calibration mode. Align the calibration grids by marking each intersection with on the table's surface (small, doughnut shaped things are best) and adjusting the corresponding point in reacTIVision to meet it.


RUNNING THE SKETCH
------------

ReacTIVision must be running in order for Processing to get information about block location. It doesn't matter if it's started before or after the Procesing sketch.

Assuming the table is calibrated, it should be good to go.

If the sketch crashes for any reason, it needs to be closed and re-run from Processing.
