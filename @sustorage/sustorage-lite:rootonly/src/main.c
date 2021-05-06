#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/un.h>
#include <sys/socket.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

#define sa(sock) (struct sockaddr*)&sock

int main(int argc, char** argv) {
  // print debug information
  bool debug = getenv("SOCK_DEBUG") != 0;
  // allow interactive
  bool interactive = getenv("SOCK_STDIN") != 0;
  // get socket path
  char* SOCK_PATH = "/run/sustorage.socket";
  char* _;
  if ((_ = getenv("SOCK_PATH")) != 0) {
    SOCK_PATH = _;
  }
  // prepare socket
  struct sockaddr_un sock;
  sock.sun_family = AF_UNIX;
  strncpy(sock.sun_path, SOCK_PATH, sizeof(sock.sun_path));
  int fd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (fd < 0
      || connect(fd, sa(sock), sizeof(sock)) < 0) {
    printf("ERRNO%d\n", errno);
    if (debug) {
      puts(strerror(errno));
    }
    return(1);
  }
  // getting password
  ssize_t nread;
  char c = 'v';
  char buff[1024];
  write(fd, &c, 1);
  nread = read(fd, buff, sizeof(buff));
  if (nread < 1 || buff[0] != '1') {
    puts("E1");
    close(fd);
    if (debug) {
      puts("Protocol version must be 1");
    }
    return(2);
  }
  if (argc < 2) {
    _ = "uroot";
    write(fd, _, strlen(_) + 1);
    nread = read(fd, buff, sizeof(buff));
    if (buff[0] == 'p') {
      puts(buff + 1);
      close(fd);
      return(0);
    } else if (!interactive) {
      puts("N1");
      close(fd);
      return(3);
    } else {
      char* pwd = getpass("Password: ");
      if (!pwd || pwd[0] == '\0' || pwd[0] == '\n') {
        puts("E2");
        if (debug)
          puts("User input");
        return(4);
      }
      buff[0] = 'p';
      strncpy(buff + 1, pwd, sizeof(buff) - 2);
      write(fd, buff, sizeof(buff));
      puts(buff + 1);
      return(0);
    }
  } else {
    buff[0] = 'p';
    strncpy(buff + 1, argv[1], sizeof(buff) - 2);
    write(fd, buff, sizeof(buff));
    puts(buff + 1);
  }
}
