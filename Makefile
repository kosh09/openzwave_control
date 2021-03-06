#
# Makefile for OpenzWave Control Panel application
# Greg Satz

# GNU make only

.SUFFIXES:	.cpp .o .a .s

CC     := $(CROSS_COMPILE)gcc      #C컴파일러를 gcc로 지정해준다.
CXX    := $(CROSS_COMPILE)g++      #C++컴파일러를 g++로 지정해준다.
LD     := $(CROSS_COMPILE)g++      #ld 프로세스를 g++로 지정해준다.
AR     := $(CROSS_COMPILE)ar rc    #AR 옵션을 rc를 주도록 한다.
RANLIB := $(CROSS_COMPILE)ranlib   #RANLIB 프로세스를 ranlib로 돌려준다.

DEBUG_CFLAGS    := -Wall -Wno-unknown-pragmas -Wno-inline -Wno-format -g -DDEBUG -ggdb -O0
RELEASE_CFLAGS  := -Wall -Wno-unknown-pragmas -Werror -Wno-format -O3 -DNDEBUG

DEBUG_LDFLAGS	:= -g

# Change for DEBUG or RELEASE
CFLAGS	:= -c $(DEBUG_CFLAGS)
LDFLAGS	:= $(DEBUG_LDFLAGS)

OPENZWAVE := ../open-zwave/
LIBMICROHTTPD := -L/usr/local/lib/ -lmicrohttpd

INCLUDES := -I $(OPENZWAVE)/cpp/src -I $(OPENZWAVE)/cpp/src/command_classes/ \
	-I $(OPENZWAVE)/cpp/src/value_classes/ -I $(OPENZWAVE)/cpp/src/platform/ \
	-I $(OPENZWAVE)/cpp/src/platform/unix -I $(OPENZWAVE)/cpp/tinyxml/ \
	-I /usr/local/include/

# Remove comment below for gnutls support
#GNUTLS := -lgnutls

# for Linux uncomment out next three lines
LIBZWAVE := $(wildcard $(OPENZWAVE)/*.a)
LIBUSB := -ludev
LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB) -lresolv

# for Mac OS X comment out above 2 lines and uncomment next 5 lines
#ARCH := -arch i386 -arch x86_64
#CFLAGS += $(ARCH)
#LIBZWAVE := $(wildcard $(OPENZWAVE)/cpp/lib/mac/*.a)
LIBUSB := -framework IOKit -framework CoreFoundation
LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB) $(ARCH) -lresolv

%.o : %.cpp
	$(CXX) $(CFLAGS) $(INCLUDES) -o $@ $<

%.o : %.c
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<

all: defs ozwcp


#defs:
#ifeq ($(LIBZWAVE),)
#
#endif

ozwcp.o: ozwcp.h webserver.h $(OPENZWAVE)/cpp/src/Options.h $(OPENZWAVE)/cpp/src/Manager.h \
	$(OPENZWAVE)/cpp/src/Node.h $(OPENZWAVE)/cpp/src/Group.h \
	$(OPENZWAVE)/cpp/src/Notification.h $(OPENZWAVE)/cpp/src/platform/Log.h

webserver.o: webserver.h ozwcp.h $(OPENZWAVE)/cpp/src/Options.h $(OPENZWAVE)/cpp/src/Manager.h \
	$(OPENZWAVE)/cpp/src/Node.h $(OPENZWAVE)/cpp/src/Group.h \
	$(OPENZWAVE)/cpp/src/Notification.h $(OPENZWAVE)/cpp/src/platform/Log.h

ozwcp:	ozwcp.o webserver.o zwavelib.o $(LIBZWAVE)
	$(LD) -o $@ $(LDFLAGS) ozwcp.o webserver.o zwavelib.o $(LIBS)

dist:	ozwcp
	rm -f ozwcp.tar.gz
	tar -c --exclude=".svn" -hvzf ozwcp.tar.gz ozwcp config/ cp.html cp.js openzwavetinyicon.png README

clean:
	rm -f ozwcp *.o
