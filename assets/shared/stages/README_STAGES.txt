PSYCH ENGINE 0.7.3 - STAGE PORT
================================

Files created:
  gameboy.json / Gameboy.hx
  gameboy_new.json / GameboyNew.hx
  house-lime.json / HouseLime.hx
  red.json / Red.hx

INSTALLATION
------------
1. Copy the .json files into:
   assets/shared/stages/   (or your mod's stages/ folder)

2. Copy the .hx files into:
   source/states/stages/
   (next to the existing StageWeek1.hx, Spooky.hx, etc.)

3. Register them in PlayState.hx inside the switch (curStage) block:

   switch (curStage)
   {
       case 'stage': new states.stages.StageWeek1();
       // ... existing stages ...
       case 'gameboy': new states.stages.Gameboy();
       case 'gameboy_new': new states.stages.GameboyNew();
       case 'house-lime': new states.stages.HouseLime();
       case 'red': new states.stages.Red();
   }

4. Make sure the stage images exist under:
   assets/shared/images/stages/gameboy/
   assets/shared/images/stages/gameboy_new/
   assets/shared/images/stages/house-lime/
   assets/shared/images/stages/red/
   (and their subfolders: sun/, candel/, cherri/, etc.)

5. In song JSON charts, set:
   "stage": "gameboy"
   "stage": "gameboy_new"
   "stage": "house-lime"
   "stage": "red"

NOTES
-----
- gameboy & gameboy_new are marked as pixel stages (stageUI = "pixel")
- GF is hidden on gameboy, gameboy_new and house-lime
- red stage has many on-beat animated props
- Some animation prefix names may need tiny adjustments after testing
  (depends on the exact frame names inside the sprite XMLs)
- The original Codename scripts imported "data/scripts/pixel" – you may
  want a separate pixel UI script or rely on Psych's built-in pixel stage support

