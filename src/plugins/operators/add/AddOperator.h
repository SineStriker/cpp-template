#ifndef BINOP_ADDOPERATOR_H
#define BINOP_ADDOPERATOR_H

#include <binop/Core/Operator/Operator.h>

namespace plugin {

    class AddOperator : public binop::Operator {
    public:
        AddOperator() = default;
        ~AddOperator() = default;

    public:
        std::string name() const override {
            return "Add";
        }

        std::string sign() const override {
            return "+";
        }

        std::string calc(const std::string &a, const std::string &b) const override;
    };

}

#endif // BINOP_ADDOPERATOR_H
