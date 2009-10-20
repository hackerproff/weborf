# Weborf
# Copyright (C) 2008  Salvo "LtWorf" Tomaselli
# 
# Weborf is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

CC=gcc
#DEFS=-Ddebug
OFLAGS=-O3
#-pedantic -Wextra
CFLAGS=-Wall $(DEFS) $(ARCHFLAGS)  -Wformat
LDFLAGS=-lpthread
#ARCHFLAGS=-m64


MANDIR=/usr/share/man/
BINDIR=/usr/bin/
DAEMONDIR=/etc/init.d/
CONFDIR=/etc/
CGIDIR=/usr/lib/cgi-bin/

all: weborf

weborf: listener.o queue.o instance.o mystring.o utils.o base64.o buffered_reader.c
	$(CC) $(LDFLAGS) $(ARCHFLAGS) $(OFLAGS) $+ -o $@

%.c: %.h

debug: listener.o queue.o instance.o mystring.o utils.o base64.o buffered_reader.o
	$(CC) -g $(LDFLAGS) $(ARCHFLAGS) $+ -o $@

clean: 
	rm -f *.o weborf debug *.orig *~ *.gz

purge: uninstall
	rm -f $(CONFDIR)/weborf.conf

source: clean style
	cd ..; tar cvzf weborf-`date +\%F | tr -d -`.tar.gz weborf/

style:
	astyle --style=kr *c *h

installdirs:
	install -d $(DESTDIR)/$(BINDIR)/
	install -d $(DESTDIR)/$(MANDIR)/man1
	install -d $(DESTDIR)/$(MANDIR)/man5
	install -d $(DESTDIR)/$(DAEMONDIR)
	install -d $(DESTDIR)/$(CGIDIR)

install: uninstall installdirs
	# Gzip the manpages
	gzip -9 -c weborf.1 > weborf.1.gz
	gzip -9 -c weborf.conf.5 > weborf.conf.5.gz

	# Install everything
	install -m 644 weborf.1.gz $(DESTDIR)/$(MANDIR)/man1/
	install -m 644 weborf.conf.5.gz $(DESTDIR)/$(MANDIR)/man5/
	install -m 755 weborf $(DESTDIR)/$(BINDIR)/
	install -m 755 cgi_py_weborf.py $(DESTDIR)/$(CGIDIR)/cgi_py_weborf.py
	install -m 755 weborf.daemon $(DESTDIR)/$(DAEMONDIR)/weborf

	#Use in case of debian package makefile
	#install -m 755 weborf.daemon debian/weborf-daemon.init

	#Comment the following line in case of debian package
	if  ! test -e $(DESTDIR)/$(CONFDIR)/weborf.conf; then install -m 644 weborf.conf $(DESTDIR)/$(CONFDIR)/; fi

uninstall:
	rm -f $(DESTDIR)/$(MANDIR)/man5/weborf.conf.5.gz
	rm -f $(DESTDIR)/$(MANDIR)/man1/weborf.1.gz
	rm -f $(DESTDIR)/$(BINDIR)/weborf
	rm -f $(DESTDIR)/$(DAEMONDIR)/weborf
	rm -f $(DESTDIR)/$(CGIDIR)/py_weborf

memcheck: debug
	valgrind --track-origins=yes --tool=memcheck --leak-check=yes --leak-resolution=high --show-reachable=yes --num-callers=20 --track-fds=yes ./debug || echo "Valgrind doesn't appear to be installed on this system"

moo:
	echo Questo Makefile ha i poteri della supermucca
