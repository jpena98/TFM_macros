run("Duplicate...", "duplicate channels=4");
run("Smooth")
run("Auto Threshold", "method=Triangle white");
run("Create Selection");
roiManager("Add");
waitForUser("selecciona la orginial y dale a Okay");
run("Duplicate...", "title=dapi duplicate channels=1");
setOption("ScaleConversions", true);
run("8-bit");
run("Brightness/Contrast...");
waitForUser("Ajusta un pokito y dale OK");
roiManager("Select", 0);
run("Make Inverse");
run("Itcn ");
showMessage("Remember: uncheck detect dark peaks!!");
