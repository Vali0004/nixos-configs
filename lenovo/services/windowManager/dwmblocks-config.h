//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/* Icon */       /* Command */                        /* Interval */  /* Signal */
	{ "^c#89b4fa^", "/etc/dwm/blocks/scripts/memory",    30, 1 },
	{ "^c#a6e3a1^", "/etc/dwm/blocks/scripts/cpu",       5,  2 },
	{ "^c#94e2d5^󰈀", "/etc/dwm/blocks/scripts/network",   5,  4 },
	{ "^c#f38ba8^", "printf '^d^ %s%%' \"$(pamixer --get-volume)\"", 0, 5 },
	{ "^c#94e2d5^", "/etc/dwm/blocks/scripts/battery", 5,  6 },
	{ "^c#94e2d5^", "/etc/dwm/blocks/scripts/playerctl", 5,  6 },
	{ "^c#cdd6f4^",  "date '+%b %d (%a) %I:%M:%S %p^d^'", 1,  7 },
};

//sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char delim[] = " | ";
static unsigned int delimLen = 5;