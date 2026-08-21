#include "clock/clock.h"

int main() {
  low_tide::Clock clock;
  clock.drop();
  return clock.tide() == low_tide::Tide::Low ? 0 : 1;
}
