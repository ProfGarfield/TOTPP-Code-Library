# TOTPP-Code-Library
General Lua code for Civilization II Test of Time Patch Project

This repository contains Lua code for Civilization II Test of Time Patch Project scenario designers to use in their projects, and will give a bit of a preview on what I am working on.

The modules in the Lua folder are not meant to be changed by the scenario designer (of course, a designer may still have to in order to add a feature or fix a bug).  This folder is the lua folder in a Test of Time installation that I intend to use for 'development', so that I don't have to keep track of multiple copies of the same modules (there are also a couple modules that go into that folder by default).  If you are designing a scenario, you can put the modules directly into the scenario folder.  You don't have to tell your end users to put them into the lua folder (and, in fact, probably shouldn't tell them to put them there).

The LuaTestScenario folder is the folder that contains scenarios used to test the modules in the Lua folder, and also to provide examples on how to use the modules.  Lua files in these scenario folders are meant to be changed by the scenario designer.  You might find multiple scenario folders for the same module, one or two for usage examples and testing, and another 'blank' template, for example.

You might also find some extra stuff, or stuff that isn't working.  To make things easier for me, this is simply a mirror of two folders in a Test of Time installation on my computer.
