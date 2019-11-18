
#target Photoshop

// Get reference to document
var doc = app.activeDocument;
doc.displayDialogs = DialogModes.NO;

// Function used to export image (adjust as you want accoring to the manual)
function exportimage(group, name){

  // Set up options for saving
  var options = new ExportOptionsSaveForWeb();
    options.format = SaveDocumentType.PNG;
    options.PNG8 = false;
    options.transparency = true;

  // Export the layer
  doc.exportDocument(File(doc.path+"/"+group+"/"+name+".png"),ExportType.SAVEFORWEB, options);
}

// Hide all layers
for(var i = 0 ; i < doc.layers.length;i++) {
  doc.layers[i].visible = false;
}

// Iterate through all groups
var groupsAmount = doc.layerSets.length;
for(var i = 0; i < groupsAmount; i++) {

  // Show the group
  doc.layerSets[i].visible = true;

  // Iterate through layers in the group
  var images = doc.layerSets[i].layers;
  for (var j = 0; j < images.length; j++) {

    // Show the layer, export it, then hide it again
    doc.layerSets[i].visible = true;
    images[j].visible = true;
    exportimage(doc.layerSets[i].name, images[j].name);
    images[j].visible = false;
  }

  // Hide the group
  doc.layerSets[i].visible = false;
}

// Signify that things should be done
alert("Saving complete!");
