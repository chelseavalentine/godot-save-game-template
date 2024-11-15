## Godot basic template: Saving game data

This repo is a barebones example with logic to save game data in Godot, including Callables!

Whether you have a game that involves player input, or a game that has a lot of simulated/autonomous movement, this will help you save all the things.


## What are the main components of the project?

### GameSaver.gd

Holds all of the main logic for saving and loading the game data. If you want to plug the game-saving logic into an existing project, you would just copy the data/ directory over to your project and add the safe_resource_loader add-on.

This project also uses the GameSaver and ObjectFinder as global classes.

### Dynamic/moving game node example: Robot.gd

Dynamic nodes are game nodes that are dynamically added to the game at runtime.

In this example, robots get automatically generated and eat either the cake or the cookie. If neither are in-stock, then the robots wait.

### Static game node example: Food.gd

Static nodes are fixed part of the scene. We use the cake and cookie as food in the example here.

Food gets eaten and then respawns after some seconds, ready for another robot to eat it.


### Sources

A special thanks to the contributors who released free art to OpenGameArt. The assets used in this project are as follows:

* [Pixel robot sprite animations](https://opengameart.org/content/pixel-robot)
* [Chocolate cake](https://opengameart.org/content/16x16-pixel-cake)
* [Cookie](https://opengameart.org/content/cookie-2)
