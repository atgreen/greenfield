menuconfig: mconf
	./$< $(silent) $(Kconfig)

clean:
	rm -f *.o */*.o *~ mconf

lxdialog := lxdialog/checklist.o lxdialog/util.o lxdialog/inputbox.o
lxdialog += lxdialog/textbox.o lxdialog/yesno.o lxdialog/menubox.o

mconf: mconf.o zconf.tab.o $(lxdialog)
	gcc -g -o $@ mconf.o zconf.tab.o $(lxdialog) -lncurses

%.o: %.c
	gcc -c -g -DCURSES_LOC="<ncurses.h>" -DNCURSES_WIDECHAR=1 -DLOCALE -o $@ $<

