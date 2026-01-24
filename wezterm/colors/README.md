# Everforest for Wez's Terminal

| | Dark | Light |
|:-----:|:-----:|:-----:|
|Hard| ![dark-hard](https://user-images.githubusercontent.com/84289565/210184828-d03a1b9b-a6fc-426e-b92c-0c71e6d527c0.png) | ![light-hard](https://user-images.githubusercontent.com/84289565/210184836-3cdf3200-4379-47c0-93e9-b9ed8eb0a078.png) |
|Medium| ![dark-medium](https://user-images.githubusercontent.com/84289565/210184831-f9d5af8d-0f7d-4c83-b817-22dc2ce9e97b.png) | ![light-medium](https://user-images.githubusercontent.com/84289565/210184837-e85106e7-3c46-4024-a3b5-c0ce078ae538.png) |
|Soft| ![dark-soft](https://user-images.githubusercontent.com/84289565/210184833-661a4c75-a136-4b40-a99d-971e3f38d8e9.png) | ![light-soft](https://user-images.githubusercontent.com/84289565/210184839-d002046a-e43a-4062-b93b-2712a2300bb7.png) |

## Introduction
This is a port of the amazing [Everforest](https://github.com/sainnhe/everforest) theme to the also amazing [Wez's Terminal](https://github.com/wez/wezterm) emulator.

Please checkout their Github pages for more information.

## Instalation

1. Clone the repo into wezterm config directory:
```
mkdir -p $HOME/.config/wezterm/ && \
git clone https://github.com/frdwin/Everforest-Wezterm $HOME/.config/wezterm/colors
```

2. Change your WezTerm config to apply the theme:
```
return {
	[... your configuration ...]
	color_scheme_dirs = { "~/.config/wezterm/colors" },
	color_scheme = "Everforest Dark (Medium)",
}
```

### Options

Possible values for the color_scheme variable are:

* "Everforest Dark (Soft)"
* "Everforest Dark (Medium)"
* "Everforest Dark (Hard)"
* "Everforest Light (Soft)"
* "Everforest Light (Medium)"
* "Everforest Light (Hard)"
