#pragma once

namespace low_tide
{

enum class Tide
{
  High,
  Low
};

// Colliding tide Clock can drop. Two phases. Default high.
class Clock
{
public:
  Tide tide() const { return tide_; }
  void drop() { tide_ = Tide::Low; }

private:
  Tide tide_ = Tide::High;
};

} // namespace low_tide
