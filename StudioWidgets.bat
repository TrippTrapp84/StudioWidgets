git clone https://github.com/TrippTrapp84/StudioWidgets ./StudioWidgets
cd StudioWidgets/src
move Require.lua ..
move WidgetLibrary ..
cd ..
rmdir src
rmdir /s /q images
rmdir /s /q .git
del LICENSE
del README.md