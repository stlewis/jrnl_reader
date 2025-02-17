# Journal Reader

This program is a TUI that wraps the excellent `jrnl` command-line journaling tool: [https://jrnl.sh](https://jrnl.sh).

If you don't know what that is, I encourage you to check it out! If you _do_ know what it is, you may be wondering why I bothered to create this project in the first place.

The simple answer is that I'm scratching my own itch here. I have _hundreds_ of journal entries, and I often want to browse through them, picking and choosing the ones I want to read at any given time. The tools `jrnl` provides for this are _fine_, but there's a lot of typing involved in loading up any given specific entry for viewing, passing it into a reader like `less`, and so on.

So -- I built this. It's a simple interface, containing a list of your journal entries on the left, and a reading panel on the right. Usage is both self-explanatory and detailed at the bottom of the screen when you start the program!

### Future Development

To be fair, since this is a silly pet project that I started purely for my own benefit and to play around with `ncurses` a bit, there's a very good chance that I won't add any further functionality to it. That said, if I add anything, it would be around searching/filtering entries by date or title.
