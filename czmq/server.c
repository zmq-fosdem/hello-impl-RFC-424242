#include <czmq.h>

#define request "Hello"
#define reply "Hello World"

int main (void)
{
    zsock_t *rep = zsock_new_rep ("tcp://*:6666");

    while(!zsys_interrupted) {
        char *string = zstr_recv (rep);
        if(string != NULL && streq(string,request)) {
            zstr_send (rep, reply);
            printf("Somebody pinged me\n");
        }
        zstr_free (&string);
    }

    zsock_destroy (&rep);
    return 0;
}
