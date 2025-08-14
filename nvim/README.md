# My Neovim Config (made in 2025, prepared for 2026 and more)

_(requires Neovim 0.12 (nightly as I'm writing this file in 14th August 2025)_
<img width="3010" height="1878" alt="image" src="https://github.com/user-attachments/assets/5094099d-b523-4ba9-acac-d3abc939f85c" />

**Long story short**: I've came a veeeery very long journey of continously making my setup, beautiful, fancy and stunning. 
Where the more I was working each day... the less fancy my setup were becoming. And ultimately, since the launch of Neovim 0.12 Nightly with finally it's own package manager, it was a nice chance to make the decision to rewrite a config once again and make (kinda) minimalistic config setup that will gather:
- all of my 2 years experience of using Neovim in both work professionally and home with side projects&notes
- all of the plugins that were **ACTUALLY** useful and it would be hard for me to be as productive without them
- all of the settings and keymaps I've found useful

**Warning:** This is a hell of a personal config and it might not work for you as well, as it is working for me. Treat it more as an insipiration, rather than ready-to-use full-fledged universal setup (for that, just use distro like `LazyVim` or `NvChad` or `AstroNvim`)


There are couple of things you might consider controversial

# Native package manager `vim.pack` instead of `Lazy`
This config requires Neovim 0.12 (nightly) to work, because it uses native package manager called `vim.pack`. `Lazy` is absolutely awesome and it's one of the best package managers I've experienced and kudos to folke for it, but I do believe that ulimately people will be switching to native one, so I might just prepare for it already _(I'm writing this in 14th of August 2025)_

# One config file approach
I love the fact that the configuration is just a Lua file so I can abstract things to whatever amount of files I need or want and import them. Lazy package manager even uses it nicely to auto-scan `plugins/` directory to detect if you've added something new and it will install them automatically. But I've found one file to be a lot easier to edit quickly, since you can directly source it with `:source` (or `:so` in short) command, making the changes apply immidietally, without needing to restart Neovim. It makes editing your setup waaay way easier and faster and also forces you to be intentional about plugins you use. Ofc. with lazy package manager you could have 90+ plugins and still start and fully load Neovim in ~12ms, but I like to keep only those things I'm actually using ;) This way I don't have trash in my config
