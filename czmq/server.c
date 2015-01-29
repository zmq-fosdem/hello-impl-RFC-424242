#include <czmq.h>

#define request "Hello"
#define reply "Hello World"

int main (void)
{
    zsock_t *rep = zsock_new_rep ("tcp://*:6666");

    while(!zsys_interrupted) {
        char *string = zstr_recv (rep);
        if(streq(string,request)) {
            printf("Got '%s'!\n", request);
            zstr_send (rep, reply);
        }
        zstr_free (&string);
    }

    zsock_destroy (&rep);
    return 0;
}
