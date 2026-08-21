#include "clock/clock.h"

int main() {
  low_tide::Clock clock;
  if (clock.tide() != low_tide::Tide::High) {
    return 1;
  }

  clock.drop();
  if (clock.tide() != low_tide::Tide::Low) {
    return 1;
  }

  return 0;
}
