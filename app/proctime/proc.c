// gcc -shared -fPIC proc.c -o libptimelua.so

#include <time.h>

PUBLIC_API;
double clock_alternative() {
	struct timespec ts;
	clock_gettime( CLOCK_MONOTONIC_RAW, &ts );
	return ((double)ts.tv_sec ) + ((double)ts.tv_nsec) / 1000000000;
}