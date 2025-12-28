#include <binop/Core/Operator/OperatorPlugin.h>

#include "SubOperator.h"

namespace plugin {

    class SubOperatorPlugin : public binop::OperatorPlugin {
    public:
        SubOperatorPlugin() = default;
        ~SubOperatorPlugin() = default;

    public:
        const char *key() const override {
            return "binop.SubOperator";
        }

        std::unique_ptr<binop::Operator> create() override {
            return std::make_unique<SubOperator>();
        }
    };

}

BINOP_EXPORT_PLUGIN(plugin::SubOperatorPlugin)
