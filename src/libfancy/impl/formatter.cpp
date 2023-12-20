#include <iostream>

#include "fancy/fancy.hpp"

namespace fancy {

    VectorFormatter::VectorFormatter(const std::vector<int>& values) :  values_(values) {}

    std::string VectorFormatter::format() const  {
        return fmt::format("[{}]", fmt::join(values_, ", "));
    }

}
