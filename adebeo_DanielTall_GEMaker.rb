  require 'sketchup.rb'
  require 'extensions.rb'

  # Create the extension.
  ext = SketchupExtension.new 'Google Earth Maker','adebeo_DanielTall_GEMaker/adebeo_DanielTall_GEMaker.rb'

  # Attach some nice info.
  ext.creator     = 'adebeo, Inc.'
  ext.version     = '0.0.1'
  ext.copyright   = '2016 adebeo, Inc.'
  ext.description = 'create a kml file where corner of google map in sketchup are show!'

  #SKETCHUP_CONSOLE.show

  # Register and load the extension on startup.
  Sketchup.register_extension ext, true

=begin
0.0.0

=end