#include <binop/Core/Operator/OperatorPlugin.h>

#include "AddOperator.h"

namespace plugin {

    class AddOperatorPlugin : public binop::OperatorPlugin {
    public:
        AddOperatorPlugin() = default;
        ~AddOperatorPlugin() = default;

    public:
        const char *key() const override {
            return "binop.AddOperator";
        }

        std::unique_ptr<binop::Operator> create() override {
            return std::make_unique<AddOperator>();
        }
    };

}

BINOP_EXPORT_PLUGIN(plugin::AddOperatorPlugin)
