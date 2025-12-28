#ifndef BINOP_CORE_PLUGIN_H
#define BINOP_CORE_PLUGIN_H

#include <filesystem>

#include <binop/Core/Global.h>

namespace binop {

    /// Plugin - Base class for all plugins.
    class BINOP_CORE_EXPORT Plugin {
    public:
        virtual ~Plugin() = default;

    public:
        /// Returns the interface identifier of the plugin.
        virtual const char *iid() const = 0;

        /// Returns the key of the plugin.
        virtual const char *key() const = 0;

    public:
        std::filesystem::path path() const;
    };

    class StaticPlugin {
    public:
        using PluginInstanceFunction = Plugin *(*) ();

        constexpr StaticPlugin(PluginInstanceFunction i) : instance(i) {
        }

        PluginInstanceFunction instance = nullptr;

    public:
        BINOP_CORE_EXPORT static void registerStaticPlugin(const char *pluginSet,
                                                           StaticPlugin plugin);
    };

}

#define BINOP_EXPORT_PLUGIN(PLUGIN_NAME)                                                           \
    extern "C" BINOP_CORE_DECL_EXPORT binop::Plugin *binop_plugin_instance() {                     \
        static PLUGIN_NAME _instance;                                                              \
        return &_instance;                                                                         \
    }

#define BINOP_EXPORT_STATIC_PLUGIN(PLUGIN_NAME, PLUGIN_SET)                                        \
    struct initializer {                                                                           \
        initializer() {                                                                            \
            binop::StaticPlugin::registerStaticPlugin(                                             \
                PLUGIN_SET, binop::StaticPlugin([]() -> binop::Plugin * {                          \
                    static PLUGIN_NAME _instance;                                                  \
                    return &_instance;                                                             \
                }));                                                                               \
        }                                                                                          \
        ~initializer() {                                                                           \
        }                                                                                          \
    } dummy;

#endif // BINOP_CORE_PLUGIN_H
