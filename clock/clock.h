#pragma once

namespace low_tide {

// Tide is a door / moving floor. Two phases only. Clock drops it.
// Place owns what it looks like. Radios stay quiet.
enum class Tide {
  High,
  Low,
};

class Clock {
 public:
  Tide tide() const { return tide_; }

  // High becomes low. Already low stays low.
  void drop() { tide_ = Tide::Low; }

 private:
  Tide tide_ = Tide::High;
};

}  // namespace low_tide
