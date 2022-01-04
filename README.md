# mg-gol
gol in asm

Software Used:
1) DOSbox - for compiling/linking/running the game
2) Visual Studio Code - easier user interface to code asm

NOTE: Need DOSBOX to run the game and type: gol_mg.exe

************************************************************************************************************
************************************************************************************************************


Welcome to my Game of Life!

In honor of John Conway, creator of Game of Life, this project is an appreciation for his contributions.

The rules of Game of Life are as follows:
1) Any living cell with 2 or 3 neighbors will continue to live on.
2) Any living cell with less than or greater than rule #1 will die.
3) Any dead cell with neighbor of "EXACTLY" 3 will turn alive.



My Game Description:

    My game will let the user set up the initial configuration of the world of game of life using the
    mouse click or drag. After finishing the initial setup, the "right" click  will let the user leave
    the input mode and could start playing the game by either pressing "space" to see the next generation,
    "backspace" to remove all cells and restart from the beginning, "enter" to summon the mouse again and
    add more cells even if the game has already started. I let the user to play around as much as he/she
    can and just hit "esc" to leave the game.

    At exit, the user can either load to get back from where he/she left off using "l", restart the game
    with empty cell using "r", or quit to the command line using "esc" again.



These list of instructions are also listed in the title screen and exit screen:

   At title screen:
   ** any key to start the game

   At input page:
   ** Left Mouse Click - to put one pixel in  the screen
   ** Left Mouse Drag  - to drag the pointer to put pixel at a faster rate
   ** Right Click      - to LEAVE input mode and hide the mouse  ******VERY IMPORTANT******

   At game/generation page:
   ** Space Bar        - to proceed to the next generation
   ** Enter Key        - to summon the mouse to be able to input more cells
   ** Backspace        - to remove all cells from the screen and start new
   ** Esc              - to proceed to exit screen
   ** "s" button       - to save the game into a file
   
   At exit page:
   ** "l" button twice - to load the game from where you left of during the game
   ** "r" button twice - to restart the game at empty screen
   ** Esc 	       - to leave the game

**  Extra:
    I noticed a lot of cell positions where they either remain constant or keeps moving
    repeatedly at same position, but one position particularly stood out to me which
    moves constantly in a straight direction and will never die!!
          
    Moving Cell:
     O 
    OO
    O O
