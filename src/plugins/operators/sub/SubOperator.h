#ifndef BINOP_SUBOPERATOR_H
#define BINOP_SUBOPERATOR_H

#include <binop/Core/Operator/Operator.h>

namespace plugin {

    class SubOperator : public binop::Operator {
    public:
        SubOperator() = default;
        ~SubOperator() = default;

    public:
        std::string name() const override {
            return "Sub";
        }

        std::string sign() const override {
            return "-";
        }

        std::string calc(const std::string &a, const std::string &b) const override;
    };

}

#endif // BINOP_SUBOPERATOR_H
