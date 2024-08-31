FROM debian

RUN apt-get update --yes && apt-get upgrade --yes && apt-get install git gcc g++ libgmp-dev libmpfr-dev texinfo make curl xz-utils bzip2 libc6 libstdc++6 --yes

RUN export PREFIX="$HOME/opt/cross" && \
	export TARGET=sh4-elf && \
 	export PATH="$PREFIX/bin:$PATH"
RUN curl "https://sourceware.org/pub/binutils/snapshots/binutils-2.42.90.tar.xz" -O && tar -xf binutils-2.42.90.tar.xz && \
   	cd binutils-2.42.90 && \
	mkdir build && \
	cd build && \
	../configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror && \
	make && \
	make install && \
	cd ../../

RUN curl "https://mirrors.middlendian.com/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz" -O && tar -xf gcc-14.2.0.tar.xz && \
	cd gcc-14.2.0 && \
	contrib/download_prerequisites && \
	mkdir build && \
	cd build && \
	../configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --with-multilib-list=m4-nofpu && \
	make all-gcc && \
	make all-target-libgcc && \
	make install-gcc && \
	make install-target-libgcc && \
	cd ../../
    
RUN curl "https://github.com/SnailMath/hollyhock-2/archive/refs/heads/master.zip" -o hollyhock-2.zip && tar -xf hollyhock-2.zip && \
	cd hollyhock-2/sdk && \
	make && \
	cd ../../
 
ENV SDK_DIR=/hollyhock-2/sdk

RUN export PREFIX="/hollyhock-2/sdk/newlib" && \
	export PREFIX="$SDK_DIR/newlib" && \
 	export TARGET="sh-elf" && \
  	export TARGET_BINS="sh4-elf" && \
	curl "ftp://sourceware.org/pub/newlib/newlib-4.2.0.20211231.tar.gz" -o newlib-cygwin.tar.gz && tar -xf newlib-cygwin.tar.gz && \
	cd newlib-cygwin && \
	mkdir build-newlib && \
	cd build-newlib && \
	../newlib-VERSION/configure --target=$TARGET --prefix=$PREFIX CC_FOR_TARGET=${TARGET_BINS}-gcc AS_FOR_TARGET=${TARGET_BINS}-as LD_FOR_TARGET=${TARGET_BINS}-ld AR_FOR_TARGET=${TARGET_BINS}-ar RANLIB_FOR_TARGET=${TARGET_BINS}-ranlib && \
	make all && \
	make install

RUN echo "export SDK_DIR=${SDK_DIR}" >> ~/.bashrc
