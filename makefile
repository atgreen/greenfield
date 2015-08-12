all: 
	(cd menuconfig; make mconf)
	./menuconfig/mconf Kconfig

clean:
	-(cd menuconfig; make clean)
	-rm .config *~
