
macro "Measure_YFP_Density"{
	
	//this macro works with Phantast plugin:
	//https://github.com/nicjac/PHANTAST-FIJI/wiki/PHANTAST-FIJI-plugin-tutorial
	

	//User customized variables
	
	sigmaValue=0.6;
	epsilonValue=0.02;
	BF=2;
	YFP=1;
	Autofl=3;
	AutothresholdMethod="Li";
	

	
	//Loop to process images in folder
	
	dir = getDirectory("Choose folder with ND2 files...");
	results = getDirectory("Choose folder to save results...");
	lista = getFileList(dir);
	setBatchMode(true);
	tableposition=0;
	for (i=0; i<lista.length; i++) {
		showProgress(i, lista.length);
		if (endsWith(lista[i],"nd2")==1) {//Image format
			run("Bio-Formats Importer", "open=[" + dir + lista[i] + "] color_mode=Composite view=[Hyperstack] stack_order=XYCZT");
			imagename = File.nameWithoutExtension();
			getVoxelSize(width, height, depth, unit);
			ORI=getImageID();//Get ID number of original image
			run("Duplicate...", "title=BF duplicate channels="+BF);
			run("32-bit");
			run("PHANTAST", "sigma="+sigmaValue+" epsilon="+epsilonValue+" selection");
			//Check if there is a selection
			if(selectionType!=-1){
				 run("Make Inverse");
				 roiManager("add");			
			}else{
				print("No empty spaces found in BF image "+imagename+".Selecting all image are");
				run("Select All");	
				roiManager("add");			
			}
			roiManager("select", roiManager("count")-1);
			getStatistics(areaCells);
			roiManager("rename", "BF_CellDensity");
	
			//Close BF image
			close("BF");
	
			//Activate Original image
	
			//Create copy of autofluorescence channel
			selectImage(ORI);
			run("Duplicate...", "title=Autofl duplicate channels="+Autofl);
			//Preprocess Autofluorescence image
			run("Gaussian Blur...", "sigma=1");
			run("Maximum...", "radius=1.5");
			//Create copy of YFP channel
			selectImage(ORI);
			run("Duplicate...", "title=YFP duplicate channels="+YFP);
			//Subtract Autofluorescence pre-processed channel to YFP channel
			imageCalculator("Subtract create", "YFP","Autofl");
			//Apply median filter to remove small bright objects and to smooth noise
			run("Median...", "radius=2");
			setAutoThreshold(AutothresholdMethod+" dark");
			run("Create Selection");
			roiManager("Add");
			roiManager("select", roiManager("count")-1);
			getStatistics(areaYFP);
			roiManager("rename", "YFP");
	
			//Save ROIs as ZIP
			roiManager("deselect");
			roiManager("save", results+imagename+"_ROIs.zip");
			roiManager("reset");
	
			//Create Result table
	
			setResult("Image", tableposition, imagename);
			setResult("Area Units ^2", tableposition, unit);
			setResult("Cell Area (BF)", tableposition, areaCells);
			setResult("YFP Area", tableposition, areaYFP);
			setResult("YFP/Cells Area Ratio", tableposition, areaYFP/areaCells);
			updateResults();
			tableposition++;
			
			//Close all opened images
			run("Close All");
	
			//Save Result table
			selectWindow("Results");
			saveAs("Results", results+"AreaResults.xls");
		}		
	}
	
	showMessage("Done, check your results table. You can find your results here: "+results);

}
