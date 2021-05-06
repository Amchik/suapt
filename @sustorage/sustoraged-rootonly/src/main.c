#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/un.h>
#include <sys/socket.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>

#include "include/printing.h"

#define sa(sock) (struct sockaddr*)&sock
#define TIMEOUT 1

static char* SOCKET_PATH = "/run/sustorage.socket";

static int self;
static struct sockaddr_un sock;

static bool alive = false;

static char pwd[1024];
static unsigned int pwdlen = 0;

void* Loop() {
  const char protov = '1';
  const char notfound = 'n';
  int fd;
  socklen_t len;
  ssize_t nread;
  char buff[256];
  if (!alive)
    alive = true;
  else
    return(0);
  p_info("Server started");
  while (alive) {
    len = sizeof(sock);
    fd = accept(self, sa(sock), &len);
    if (fd < 0) {
      sleep(TIMEOUT);
      continue;
    }
    p_debug("Accepted socket 0x%X", fd);
    bool done = false;
    while (1) {
      if (done) break;
      char c;
      nread = read(fd, &c, 1);
      if (nread < 1) {
NULNREAD:
        continue;
      }
      switch (c) {
      case 'v':
        write(fd, &protov, 1);
        break;
      case 'u':
        nread = read(fd, buff, sizeof(buff));
        if (nread < 1)
          goto NULNREAD;
        if (buff[255] != '\0')
          buff[255] = '\0';
        if (pwdlen < 1 || strcmp(buff, "root") != 0) {
          write(fd, &notfound, 1);
          if (pwdlen > 0)
            p_warn("Returning 'n' to socket 0x%X due request not root");
          break;
        }
        write(fd, pwd, pwdlen + 1);
        done = true;
        break;
      case 'p':
        nread = read(fd, pwd + 1, sizeof(pwd) - 1);
        pwd[1023] = '\0';
        pwdlen = strlen(pwd + 1);
        p_info("New password accepted");
        done = true;
        break;
      default:
        done = true;
        break;
      }
    }
  }
  return(0);
}

void _terminate(int signal) {
  p_info("Stopping server due signal %d...", signal);
  close(self);
  unlink(SOCKET_PATH);
  exit(0);
}

int main(int argc, char** argv) {
  // getting socket path
  if (argc == 2) {
    SOCKET_PATH = argv[1];
  }
  p_info("Creating socket at %s", SOCKET_PATH);
  // provide signal handlers
  signal(SIGINT, _terminate);
  signal(SIGQUIT, _terminate);
  signal(SIGTERM, _terminate);
  // initing base consts
  pwd[0] = 'p';
  // creating socket...
  sock.sun_family = AF_UNIX;
  strncpy(sock.sun_path, SOCKET_PATH, sizeof(sock.sun_path));
  self = socket(AF_UNIX, SOCK_STREAM, 0);
  if (self < 0
      || bind(self, sa(sock), sizeof(sock)) < 0
      || listen(self, 1) < 0) {
    p_error("Failed to create socket. errno #%d: %s", errno, strerror(errno));
    exit(1);
  }
  // running loop...
  Loop();
  // exiting after successefull failed thread
  return 0;
}
