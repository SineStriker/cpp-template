#include "SubOperator.h"

#include <string>

namespace plugin {

    std::string SubOperator::calc(const std::string &a, const std::string &b) const {
        int num_a = std::atoi(a.c_str());
        int num_b = std::atoi(b.c_str());
        return std::to_string(num_a - num_b);
    }

}