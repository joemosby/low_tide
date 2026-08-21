#include "clock/clock.h"

int main() {
  const low_tide::Clock clock;
  return clock.tide() == low_tide::Tide::High ? 0 : 1;
}
