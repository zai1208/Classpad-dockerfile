FROM debian

RUN apt-get update --yes && apt-get upgrade --yes && apt-get install git gcc g++ libgmp-dev libmpfr-dev texinfo --yes

RUN export PREFIX="$HOME/opt/cross" && \
	export TARGET=sh4-elf && \
 	export PATH="$PREFIX/bin:$PATH" && \
  	git clone --depth 1 git://sourceware.org/git/binutils-gdb.git && \
   	cd binutils-gdb && \
	mkdir build && \
	cd build && \
	../configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror && \
	make && \
	sudo make install && \
	cd ../../

RUN git clone git://gcc.gnu.org/git/gcc.git && \
	cd gcc && \
	contrib/download_prerequisites && \
	mkdir build && \
	cd build && \
	../configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --with-multilib-list=m4-nofpu && \
	make all-gcc && \
	make all-target-libgcc && \
	sudo make install-gcc && \
	sudo make install-target-libgcc && \
	cd ../../
    
RUN git clone https://github.com/snailMath/hollyhock-2 && \
	cd hollyhock-2/sdk && \
	make && \
	cd ../../

RUN export PREFIX="/hollyhock-2/sdk/newlib" && \
	export TARGET="sh4-elf" && \
	git clone https://github.com/diddyholz/newlib-cp2 && \
	cd newlib-cp2 && \
	mkdir build && \
	cd build && \
	../configure --target=$TARGET --prefix=$PREFIX && \
	make all && \
	make install

ENV SDK_DIR=/hollyhock-2/sdk
