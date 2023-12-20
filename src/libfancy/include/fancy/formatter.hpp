#pragma once

#include <vector>
#include <fmt/format.h>
#include <fmt/ranges.h>


namespace fancy {

    class VectorFormatter {
    public:
        // Constructor
        VectorFormatter(const std::vector<int>& values);

        // Format the vector using fmt library
        std::string format() const;

    private:
        std::vector<int> values_;
    };

    template <typename T>
    class TemplateVectorFormatter {
    public:
        // Constructor
        TemplateVectorFormatter(const std::vector<T>& values) : values_(values) {}

        // Format the vector using fmt library
        std::string format() const {
            return fmt::format("[{}]", fmt::join(values_, ", "));
        }

    private:
        std::vector<T> values_;
    };
}
