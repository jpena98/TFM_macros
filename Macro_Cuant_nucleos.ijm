

input=getDirectory("Choose folder with images to process");
results=getDirectory("Choose folder to save results");

////Para crear directorio automáticamente inicio
//results = input+"Results"+File.separator;
//File.makeDirectory(results);
////crear directorio automático fin

lista = getFileList(input);
archivos=lengthOf(lista);


run("Bio-Formats Macro Extensions");// llama a la extensiones de bioformats


for (j=0; j<archivos; j++) {//inicio del bucle para procesar imágenes en carpeta
	setBatchMode(false);//Para que el procesamiento sea visible
	Ext.setId(input+lista[j]);
	Ext.getCurrentFile(archivo);
	Ext.getSeriesCount(series);
		for (s=0; s<series; s++) {
			Ext.setSeries(s);
			Ext.getSeriesName(imagen_actual);
			run("Bio-Formats Importer", "open=["+archivo+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT series_"+s+1);
			myname=getTitle();

			
			//myimagename=File.name;
			//print(myimagename);
			//rename("ORI");
			
			//Detección de nucleos
			
			run("Duplicate...", "title=DAPI duplicate channels=1");
			selectWindow("DAPI");
			run("Smooth");
			
			//Edición de núcleos detectados
			
			selectWindow(myname);
			roiManager("show all with labels");
			

			setBatchMode(true);//para no ver el procesamiento
			//Crear contadores de células
	
			TotalNuclei=roiManager("count");
			for (i = 0; i < TotalNuclei; i++) {
				
				roiManager("Select", i);
				roiManager("rename", "N-"+i+1);
				
				Stack.setChannel(2);
				roiManager("Select", i);
				List.setMeasurements;
				myMeanIntensityGreen=List.getValue("Mean");
				
				Stack.setChannel(3);
				roiManager("Select", i);
				List.setMeasurements;
				myMeanIntensityRed=List.getValue("Mean");
			
				if (myMeanIntensityGreen>600 && myMeanIntensityRed<400) {
					GreenPositive++;
					roiManager("Select", i);
					roiManager("Set Color", "green");
					roiManager("Set Line Width", 2);
				}else if (myMeanIntensityRed>400 && myMeanIntensityGreen<600 ) {
					RedPositive++;
					roiManager("Set Color", "red");
					roiManager("Set Line Width", 2);
				}else if(myMeanIntensityRed>400 && myMeanIntensityGreen>600 ) {
					DoublePositive++;
					roiManager("Set Color", "white");
					roiManager("Set Line Width", 2);
				}else if(myMeanIntensityRed<400 && myMeanIntensityGreen<600 ) {
					Negative++;
					roiManager("Set Color", "blue");
					roiManager("Set Line Width", 0);
				}
			
			
				
			}
			
				//Crear tabla de resultado de recuento
			
			run("Clear Results");

			if (isOpen("TempResults")){Table.rename("TempResults", "Results"); }
			
			fila=nResults;	
			setResult("Nombre de Imagen", fila, myname);
			setResult("Total Nucleos detectados", fila, TotalNuclei);
			setResult("Total Dobles", fila, DoublePositive);
			setResult("Solo Verdes", fila, GreenPositive);
			setResult("Solo Rojas", fila, RedPositive);
			setResult("Negativas", fila, Negative);
			updateResults();

			Table.rename("Results", "TempResults"); 

			//Guardar resultados

				//Guardar elementos del roi manager

				roiManager("deselect");
				roiManager("save", results+myname+"-ROIs.zip");
				roiManager("reset");

			//Cerrar todas las imágenes abiertas

			run("Close All");

		}
}

//Guardar tabla de resultados

if (isOpen("TempResults")){Table.rename("TempResults", "Results"); }
saveAs("results", results+"Resultados.xls");
saveAs("text", results+"Resultados.txt");

waitForUser("Análisis hecho! Revisa tus resultados en "+results);



				
			
