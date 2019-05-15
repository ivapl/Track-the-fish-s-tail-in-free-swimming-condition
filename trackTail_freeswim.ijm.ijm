input = getDirectory("Input Directory");
suffix = ".avi";
processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], suffix))
			trackTail(input,list[i]);
			run("Close All");
		}
	}
	
function trackTail(input, file){
	open(input + file);
	run("Specify...", "width=100 height=100 x=88 y=122 slice=1");
	waitForUser("Pause", "Select region of fish"); // Ask for input ROI
	run("Duplicate...", "duplicate");
	run("Median...", "radius=3 stack");
	// THRESHOLD THE FISH
	setThreshold(50, 255);
	waitForUser("Pause", "Press CTRL + SHIFT + T then adjust the threshold to select the fish");
	t0 = getNumber("1st threshold", 50);
	t1 = getNumber("2nd threshold", 255);
	setThreshold(t0, t1);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Light");
	win = getTitle();
	
	// REMOVE THE EDGES BY PIXEL AREA
	minA = getNumber("Minimum area (pixel^2) of binarized object.", 0);
	maxA = toString(getNumber("Maximum area (pixel^2) of binarized object. Enter 0 for Inf.", 1000));

	if(maxA == 0){
		maxA = "Infinity";
		}
	
	run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks display clear stack");
	waitForUser("Pause", "Please check the output.");
	runagain = getNumber("Would you like to run again?", 0);
	
	if(runagain == 1){
		nagain = 1;
		while(nagain!=0){
			run("Close");
			selectWindow(win);
			minA = getNumber("Minimum area (pixel^2) of binarized object.", 0);
			maxA = toString(getNumber("Maximum area (pixel^2) of binarized object. Enter 0 for Inf.", 1000));
			run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks display clear stack");
			nagain = getNumber("Would you like to run again?", 0);
		}
		}
	
	// REMOVE THE EDGES MANUALLY
	edge = getNumber("How many edges you want to manually select?", 0);
	
	for(i = 0;i<edge;i++){
		waitForUser("Pause", "Draw ROI."); // Ask for input ROI
		run("Subtract...", "value=255 stack");
		}
	
	// SKELETONIZE THE IMAGE
	outfolder = replace(file, ".avi", "");
	output = input + "\\" + outfolder;
	if(File.exists(output) != 1){
		File.makeDirectory(output);
	}
	binarized_im = getTitle();
	
	for(s = 1; s <= nSlices; s++){
		selectWindow(binarized_im);
		setSlice(s); // start from first frame
		run("Duplicate...", "use"); // isolate the frame
		run("Skeletonize (2D/3D)");
		current_slice = getTitle();
		curr = replace(current_slice, ".avi", "");
		saveAs("Tiff", output + "\\" + toString(s) + ".tif");
		run("Close");
		}
}
