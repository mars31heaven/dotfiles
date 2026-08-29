# dotfiles

These are my personal dotfiles. They serve the only purpose of my, well, personal usage.

I'm currently using Arch Linux with Sway and Zsh. I use them in both a laptop and a desktop PC.

The install script differentiates part of the configuration, mainly because the laptop has battery and power management configuration that the PC doesn't, plus some changes in font size and hardware (CPU vendors differences).

Where necessary, there are secondary, machine-specific config files that are sourced into the main ones. Where not possible, there are simply two different files, one .pc and other .laptop, which are in turn symlinked to the .config directory for the programs to read them. There should't be many of these, though, and all of the rest remains the same between the two different machines.
