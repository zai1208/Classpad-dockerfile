FROM debian

RUN apt-get update --yes && apt-get upgrade --yes && apt-get install git gcc g++ libgmp-dev libmpfr-dev texinfo make curl xz-utils --yes

RUN export PREFIX="$HOME/opt/cross" && \
	export TARGET=sh4-elf && \
 	export PATH="$PREFIX/bin:$PATH"
RUN curl "https://sourceware.org/pub/binutils/snapshots/binutils-2.42.90.tar.xz" -O && \
	tar -xf binutils-2.42.90.tar.xz && \
   	cd binutils-2.42.90 && \
	mkdir build && \
	cd build && \
	../configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror && \
	make && \
	make install && \
	cd ../../

RUN git clone git://gcc.gnu.org/git/gcc.git && \
	cd gcc && \
	contrib/download_prerequisites && \
	mkdir build && \
	cd build && \
	../configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --with-multilib-list=m4-nofpu && \
	make all-gcc && \
	make all-target-libgcc && \
	make install-gcc && \
	make install-target-libgcc && \
	cd ../../
    
RUN git clone https://github.com/snailMath/hollyhock-2 && \
	cd hollyhock-2/sdk && \
	make && \
	cd ../../
 
ENV SDK_DIR=/hollyhock-2/sdk

RUN export PREFIX="/hollyhock-2/sdk/newlib" && \
	export PREFIX="$SDK_DIR/newlib" && \
 	export TARGET="sh-elf" && \
  	export TARGET_BINS="sh4-elf" && \
	git clone https://sourceware.org/git/?p=newlib-cygwin.git;a=commit;h=26f7004bf73c421c3fd5e5a6ccf470d05337b435 && \
	cd newlib-cygwin && \
	mkdir build-newlib && \
	cd build-newlib && \
	../newlib-VERSION/configure --target=$TARGET --prefix=$PREFIX CC_FOR_TARGET=${TARGET_BINS}-gcc AS_FOR_TARGET=${TARGET_BINS}-as LD_FOR_TARGET=${TARGET_BINS}-ld AR_FOR_TARGET=${TARGET_BINS}-ar RANLIB_FOR_TARGET=${TARGET_BINS}-ranlib && \
	make all && \
	make install

RUN echo "export SDK_DIR=${SDK_DIR}" >> ~/.bashrc
