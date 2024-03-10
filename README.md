<div align="center">
  <h1>xt-cooldowns</h1>
  <a href="https://dsc.gg/xtdev"> <img align="center" src="https://user-images.githubusercontent.com/101474430/233859688-2b3b9ecc-41c8-41a6-b2e3-a9f1aad473ee.gif"/></a><br>
</div>


# Features:
- Create cooldowns for any activities in your server
- Check if cooldowns are active using simple a callback
- Toggle cooldowns using a simple a callback
  - Cooldowns will disable automatically, allowing the activity to be usable again
- Global cooldown used to enable/disable ALL activties using the cooldown callbacks
- Grace period feature
  - Some servers have grace periods when the server starts up or is about to shutdown. Global cooldowns will auto enable/disable when the server starts and before it restarts for the lenght of time you set your grace period to be.
  - Ex: If 15 mins, all activites are diabled for 15 mins when the server starts up or is about to shut down
- Admin menu for cooldowns
  - Create new cooldowns (obviously not used unless the callback is implemented in the code to check that cooldown)
  - Toggle cooldowns
  - Toggle global cooldown
  - Change cooldown lengths (length edits save to the database when the server restarts)
- Discord Logs
  - New cooldown created
  - Cooldown toggled
  - Cooldown length changed

# Dependencies:
- [ox_lib](https://github.com/overextended/ox_lib/releases)
