![Showcase](./kamyil_nvim.png "Showcase")


# Intro
My personal rewrite of my previously battle-tested extended config based on Astronvim
But this time, it's rewritten from scratch with help of [nvim_kickstart](https://github.com/nvim-lua/kickstart.nvim) project
which allows you to write your own config from scratch but with little hinting comments making this process way way faster

This config is ready to be cloned and ready to go 

---


# Update (6th May 2025)

**TL:DR;** Config changed A LOT, but for a good reasons. I just need to clean it up a little bit, after testing plugins and how they will work out in practice. Some of them work great, but some of them
I didn't really found them useful. Setup is still fast, because they're lazy loaded, but expect cleaning commits in near future

This config went through looooots and loooooots of changes, since I'm experimenting all the time with new plugins and ways to make work 
more pleasing, more enjoyable (and in result - more productive)
If you're looking at this README after a long while, you will notice even the looks change a lot
My setup currently is definitely way more minimal. I've found less-vibrant colors and less-fancy backgrounds to be more focus-friendly and non-distracting.
And my go-to is Kanagawa theme

I've also changed the way I'm switching between files. I've replaced barbar with harpoon, since barbar was opening a tab for every single buffer I've opened
which required manual tab clearing too often for me. In Harpoon I can go to buffers for temporary quick edits, but if I want some file to be easly accessable via keypress (cuz f.e. I'm working on it intensively), 
then I add it to Harpoon List via Alt+A. You can edit the Harpoon List via Alt+E shortcut and there you can easly assign each file to each Alt+1/2/3/4/5 slot shortcut

I've also replaced Telescope with Snacks.picker (together with other Snacks plugins), because I found it faster and more reliable in bigger projects
+makes whole experience more consistent, since those plugins are working within Snacks ecosystem

I've also get rid of tmux in favor of Wezterm and I'm focusing mostly to integrate them well (since Wezterm has full CLI API and it also allows to have config in Lua) 
But this config will also work great with Tmux, since I don't plan (nor want to) remove TMUX integration, so you can feel safe about it

Generally config as for now is definitely way less fancy, but I still recommend you to give it a try :) I'm daily-driving it at both work and personal projects, so I proritize
stability, speed and work, distract-free environment and it's serving me very very well. You may found something useful here for your config as well

---


# Built with... 
This config is built with these things in mind:
- it has to be **reliable! (no.1)** (it has to be working for 100% since I'm using it in work as well. So no crashes or bugs allowed)
- it has to be **blazingly fast** (startup time need to be as low as possible [current ~80ms on M1 Pro] and each action needs to be instant - lags and slows are not allowed) 
- it has to be **reduced to absolute necessity** - each addition has to have meaningful purpose.

# Features
- It's fast (~80ms startup time on M1 Pro)
- It obviously has syntax-highlighting with treeparser and Mason for installing LSPs
- It uses snacks.picker for running Search through multiple things like files, words, colorschemes etc. Just check `<Space>F`
- It's using `harpoon`, for managing tabs. Use Alt+A to add file to harpoon list, Alt+E to edit them, and use Alt+1/2/3/4/5... to switch between files
  Just use Alt+1/2/3/4... to move betwen them and Space+C to close the current one
  It's also configured to contain git status numbers of the file, but it can be disabled in the config
- It's using `neo-tree.nvim` since it's the easiest and most pratical filetree currently
- It's using `lazy.nvim` for installing and lazly loading plugins (which also allows to very easly add plugins, by adding a file to `plugins/` folder)
- It has `LazyGit` integrated by hitting `<Space>gg`(git-git) for most practical git usage
- It has `obsidian.nvim` integrated for notes (and also has <Space>ss for creating local per-opened-project scratchpad) 

# Extending it
Since it's based on [nvim_kickstart](https://github.com/nvim-lua/kickstart.nvim) project, you will find a lot of similarities here
(like keymaps or other references to original kickstart like `original_kickstart_init_lua_for_ref.lua`) 
it is easy to configure and extend
