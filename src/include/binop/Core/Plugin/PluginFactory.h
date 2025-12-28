#ifndef BINOP_CORE_PLUGINFACTORY_H
#define BINOP_CORE_PLUGINFACTORY_H

#include <filesystem>
#include <vector>

#include <binop/Core/Plugin/Plugin.h>

namespace binop {

    /// PluginFactory - Manages plugin loading and lifecycle.
    ///
    /// Plugins:
    ///  - filesystem plugins: shared libraries loaded from registered directories per \c iid
    ///  - runtime plugins   : runtime class instances (not owned by PluginFactory)
    ///  - static plugins    : static class instances (not owned by PluginFactory)
    class BINOP_CORE_EXPORT PluginFactory {
    public:
        PluginFactory();
        virtual ~PluginFactory();

    public:
        static std::vector<std::string> staticPluginSets();
        static std::vector<StaticPlugin> staticPlugins(const char *pluginSet);
        static std::vector<Plugin *> staticInstances(const char *pluginSet);

    public:
        void addRuntimePlugin(Plugin *plugin);
        std::vector<Plugin *> runtimePlugins() const;

        void addPluginPath(const char *iid, const std::filesystem::path &path);
        void setPluginPaths(const char *iid, std::vector<std::filesystem::path> paths);
        std::vector<std::filesystem::path> pluginPaths(const char *iid) const;

    public:
        Plugin *plugin(const char *iid, const char *key) const;

        template <class T>
        inline T *plugin(const char *key) const;

    protected:
        class Impl;
        std::unique_ptr<Impl> _impl;

        explicit PluginFactory(Impl &impl);
    };

    template <class T>
    inline T *PluginFactory::plugin(const char *key) const {
        static_assert(std::is_base_of<Plugin, T>::value, "T should inherit from binop::Plugin");
        return static_cast<T *>(plugin(reinterpret_cast<T *>(0)->T::iid(), key));
    }

}

#endif // BINOP_CORE_PLUGINFACTORY_H
