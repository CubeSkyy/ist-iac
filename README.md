# ASM Tetris

Project for the Introduction to Computer Arquitectures (IAC) course in IST 2016/2017.

It is a simple tetris game that runs on the custom circuit simulator PEPE made by [DEI](https://dei.tecnico.ulisboa.pt/en).

## Running the game

Open simulator.jar and load the "jogo.cmod" file using the File>Load menu.

Click on the Simulation tab.

Double click on the Pepe Module in the circuit grid.

Load and compile the "Project2.asm" file (Using the icon with a folder and a green arrow)

Double click to open the following modules: Relogio1 (Clock1), Relogio2 (Clock2), Teclado (Keyboard), Pixelscreen

In the Pepe module, click the first icon to start the simulation.

Start both clocks.

The game is now running and the keyboard can be used to control the tetris pieces.

0 - Left
1 - Rotates Piece
2 - Right
5 - Speed up piece until it touches the bottom

## Future work

This was a very simplistic version of the game, running on a not so intuitive simulator.

In the future, features like initial/gameover screens, scores, game reset could be implemented.
