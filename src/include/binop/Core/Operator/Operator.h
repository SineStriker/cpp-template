#ifndef BINOP_CORE_OPERATOR_H
#define BINOP_CORE_OPERATOR_H

#include <string>

namespace binop {

    /// Operator - Base class for all operators.
    class Operator {
    public:
        virtual ~Operator() = default;

        /// Get operator name.
        virtual std::string name() const = 0;

        /// Get operator sign.
        virtual std::string sign() const = 0;

        /// Calculate the result of the operator.
        /// @param a The first operand.
        /// @param b The second operand.
        /// @return The result of the operator.
        virtual std::string calc(const std::string &a, const std::string &b) const = 0;
    };

}

#endif // BINOP_CORE_OPERATOR_H
