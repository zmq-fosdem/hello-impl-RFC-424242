#include <czmq.h>

#define request "Hello"
#define reply "Hello World"

int main (int argc, char** argv)
{
    if(argc == 2) printf("Connecting to %s\n", argv[1]);
    zsock_t *req = zsock_new_req ((argc == 2) ? argv[1] : "tcp://tcp://192.168.43.186:6666:6666");

    zstr_send (req, request);
    char *string = zstr_recv (req);
    printf("Received '%s'!\n", string);
    zstr_free (&string);

    zsock_destroy (&req);
    return 0;
}
