# U

A little game made for the birthday of a friend

Make the slimes go as far as you can! They will produce energy to power your macros so that you can help them go even further!

Run the game : while in the U directory, run `v run .` (you need to install v first: https://github.com/vlang/v)

Keybinds:
- click on a slime, drag your mouse towards the direction you want it to go and release the mouse to make the slime move if the movement is valid (if there is no red indications/shapes). It costs energy
- P : toggles macro mode. When in macro mode if you click when all the indicators are green, it will execute the selected macro.
- Scroll : when in macro mode, you can select a different macro by scrolling up and down.
- Esc : quits and saves
- Backspace : Resets the map. Be careful!

In the macromaker: ( `v run macromaker/macromaker.v` ):
- Drag and drop to select a move
- click on a tile to make it change of mode (red: needs empty tile, green: needs a slime, grey: does not care)
- Esc: quit and save the macro (you will need to rename the two files (look at the folder to see how to rename them) it produces and them put them in the saves_macro/ folder)
