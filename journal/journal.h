#pragma once

#include <string_view>

namespace low_tide {

// One camp-journal note. A question, not a conclusion.
// Does not grade. No next-objective. No pass/fail.
class Journal {
 public:
  static constexpr int note_count() { return 1; }

  static constexpr std::string_view note() { return kNote; }

 private:
  static constexpr std::string_view kNote = "Was the path always there?";
};

}  // namespace low_tide
