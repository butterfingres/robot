#include <API.h>
#include <main.h>
#include <helloWorld.h>

void autonomous(void) {}

void initializeIO(void) {}

void initialize(void) {}

void operatorControl(void) {
  for(;;) {
    helloWorld();
    wait(1000);
  }
}
