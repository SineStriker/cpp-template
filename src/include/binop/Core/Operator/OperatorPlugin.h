#ifndef BINOP_CORE_OPERATORPLUGIN_H
#define BINOP_CORE_OPERATORPLUGIN_H

#include <binop/Core/Plugin/Plugin.h>
#include <binop/Core/Operator/Operator.h>

namespace binop {

    class OperatorPlugin : public Plugin {
    public:
        OperatorPlugin() = default;
        ~OperatorPlugin() = default;

        const char *iid() const override {
            return "binop.OperatorPlugin";
        }

    public:
        virtual std::unique_ptr<Operator> create() = 0;
    };

}

#endif // BINOP_CORE_OPERATORPLUGIN_H
