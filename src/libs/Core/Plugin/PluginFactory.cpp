#include "PluginFactory.h"

#include <utility>
#include <cstring>
#include <mutex>
#include <map>
#include <unordered_set>
#include <shared_mutex>

#ifdef _WIN32
#  include <Windows.h>
#else
#  include <dlfcn.h>
#endif

namespace fs = std::filesystem;

namespace binop {

    static void *openLibrary(const std::filesystem::path &path) {
#ifdef _WIN32
        return ::LoadLibraryW(path.wstring().c_str());
#else
        return ::dlopen(path.string().c_str(), RTLD_NOW);
#endif
    }

    static void *getLibrarySymbol(void *handle, const char *symbol) {
#ifdef _WIN32
        return (void *) ::GetProcAddress((HMODULE) handle, symbol);
#else
        return ::dlsym(handle, symbol);
#endif
    }

    static void closeLibrary(void *handle) {
#ifdef _WIN32
        ::FreeLibrary((HMODULE) handle);
#else
        ::dlclose(handle);
#endif
    }

    class BINOP_CORE_EXPORT PluginFactory::Impl {
    public:
        explicit Impl(PluginFactory *decl);
        virtual ~Impl();

        using Decl = PluginFactory;
        PluginFactory *_decl;

    public:
        void scanPlugins(const char *iid) const;

        std::map<std::string, std::vector<std::filesystem::path>, std::less<>> pluginPaths;
        std::unordered_set<Plugin *> runtimePlugins;
        mutable std::map<std::filesystem::path::string_type, void *, std::less<>> libraryInstances;
        mutable std::unordered_set<std::string> pluginsDirty;
        mutable std::map<std::string, std::map<std::string, Plugin *>, std::less<>> allPlugins;
        mutable std::shared_mutex plugins_mtx;
    };

    static bool isLibrary(const fs::path &path) {
#if defined(_WIN32)
        auto fileName = path.wstring();
        return fileName.size() >= 4 &&
               std::equal(fileName.end() - 4, fileName.end(), L".dll", [](wchar_t a, wchar_t b) {
                   return ::tolower(a) == ::tolower(b); //
               });
#elif defined(__APPLE__)
        auto fileName = path.string();
        return fileName.size() >= 6 &&
               std::equal(fileName.end() - 6, fileName.end(), L".dylib", [](char a, char b) {
                   return ::tolower(a) == ::tolower(b); //
               });
#else
        auto fileName = path.string();
        size_t soPos;
        if (fileName.size() >= 3 && (soPos = fileName.rfind(".so")) != std::string::npos) {
            // 检查 .so 后是否有版本号部分
            std::string_view suffix = std::string_view(fileName).substr(soPos + 3);
            if (suffix.empty()) {
                return true; // 仅有 .so，无版本号
            }
            return checkVersionSuffix(suffix); // 确保后缀全为数字
        }
        return false;
#endif
    }

    using StaticPluginMap = std::map<std::string, std::vector<StaticPlugin>>;

    static StaticPluginMap &getStaticPluginMap() {
        static StaticPluginMap staticPluginMap;
        return staticPluginMap;
    }

    void StaticPlugin::registerStaticPlugin(const char *pluginSet, StaticPlugin plugin) {
        auto &plugins = getStaticPluginMap()[pluginSet];

        // insert the plugin in the list, sorted by address, so we can detect
        // duplicate registrations
        static const auto comparator = [=](const StaticPlugin &p1, const StaticPlugin &p2) {
            using Less = std::less<decltype(plugin.instance)>;
            return Less{}(p1.instance, p2.instance);
        };
        auto pos = std::lower_bound(plugins.begin(), plugins.end(), plugin, comparator);
        if (pos == plugins.end() || pos->instance != plugin.instance)
            plugins.insert(pos, plugin);
    }

    PluginFactory::Impl::Impl(PluginFactory *decl) : _decl(decl) {
    }

    PluginFactory::Impl::~Impl() {
        // Unload all libraries
        for (const auto &item : std::as_const(libraryInstances)) {
            closeLibrary(item.second);
        }
    }

    void PluginFactory::Impl::scanPlugins(const char *iid) const {
        auto &plugins = allPlugins[iid];
        for (const auto &plugin : runtimePlugins) {
            if (strcmp(iid, plugin->iid()) == 0) {
                std::ignore = plugins.insert(std::make_pair(plugin->key(), plugin));
            }
        }

        auto it = pluginPaths.find(iid);
        if (it != pluginPaths.end()) {
            for (const auto &pluginPath : it->second) {
                for (const auto &entry : fs::directory_iterator(pluginPath)) {
                    const auto &entryPath = fs::canonical(entry.path());
                    if (libraryInstances.count(entryPath) || !isLibrary(entryPath)) {
                        continue;
                    }

                    void *handle = openLibrary(entryPath);
                    if (!handle) {
                        continue;
                    }

                    using PluginGetter = Plugin *(*) ();
                    auto getter = reinterpret_cast<PluginGetter>(
                        getLibrarySymbol(handle, "binop_plugin_instance"));
                    if (!getter) {
                        continue;
                    }

                    auto plugin = getter();
                    if (!plugin || strcmp(iid, plugin->iid()) != 0 ||
                        !plugins.insert(std::make_pair(plugin->key(), plugin)).second) {
                        continue;
                    }
                    libraryInstances[entryPath] = handle;
                }
            }
        }

        if (plugins.empty()) {
            allPlugins.erase(iid);
        }
    }

    PluginFactory::PluginFactory() : _impl(new Impl(this)) {
    }

    PluginFactory::~PluginFactory() = default;

    std::vector<std::string> PluginFactory::staticPluginSets() {
        auto &map = getStaticPluginMap();
        std::vector<std::string> pluginSets;
        pluginSets.reserve(map.size());
        for (const auto &item : map) {
            pluginSets.push_back(item.first);
        }
        return pluginSets;
    }

    std::vector<StaticPlugin> PluginFactory::staticPlugins(const char *pluginSet) {
        auto &map = getStaticPluginMap();
        auto it = map.find(pluginSet);
        if (it == map.end()) {
            return {};
        }
        return {it->second.begin(), it->second.end()};
    }

    std::vector<Plugin *> PluginFactory::staticInstances(const char *pluginSet) {
        auto &map = getStaticPluginMap();
        std::vector<Plugin *> instances;
        auto it = map.find(pluginSet);
        if (it == map.end()) {
            return {};
        }
        const auto &plugins = it->second;
        instances.reserve(plugins.size());
        for (StaticPlugin plugin : plugins)
            instances.push_back(plugin.instance());
        return instances;
    }

    void PluginFactory::addRuntimePlugin(Plugin *plugin) {
        auto &impl = *_impl.get();
        std::unique_lock<std::shared_mutex> lock(impl.plugins_mtx);
        impl.runtimePlugins.emplace(plugin);
        impl.pluginsDirty.insert(plugin->iid());
    }

    std::vector<Plugin *> PluginFactory::runtimePlugins() const {
        auto &impl = *_impl.get();
        std::shared_lock<std::shared_mutex> lock(impl.plugins_mtx);
        return {impl.runtimePlugins.begin(), impl.runtimePlugins.end()};
    }

    void PluginFactory::addPluginPath(const char *iid, const std::filesystem::path &path) {
        auto &impl = *_impl.get();
        if (!fs::is_directory(path)) {
            return;
        }
        std::unique_lock<std::shared_mutex> lock(impl.plugins_mtx);
        impl.pluginPaths[iid].push_back(fs::canonical(path));
        impl.pluginsDirty.insert(iid);
    }

    void PluginFactory::setPluginPaths(const char *iid, std::vector<std::filesystem::path> paths) {
        auto &impl = *_impl.get();
        std::unique_lock<std::shared_mutex> lock(impl.plugins_mtx);
        if (paths.empty()) {
            impl.pluginPaths.erase(iid);
        } else {
            std::vector<fs::path> realPaths;
            realPaths.reserve(paths.size());
            for (const auto &path : paths) {
                if (fs::is_directory(path)) {
                    realPaths.push_back(fs::canonical(path));
                }
            }
            impl.pluginPaths[iid] = realPaths;
        }
        impl.pluginsDirty.insert(iid);
    }

    std::vector<std::filesystem::path> PluginFactory::pluginPaths(const char *iid) const {
        auto &impl = *_impl.get();

        std::shared_lock<std::shared_mutex> lock(impl.plugins_mtx);
        auto it = impl.pluginPaths.find(iid);
        if (it == impl.pluginPaths.end()) {
            return {};
        }
        return {it->second.begin(), it->second.end()};
    }

    Plugin *PluginFactory::plugin(const char *iid, const char *key) const {
        auto &impl = *_impl.get();

        std::unique_lock<std::shared_mutex> lock(impl.plugins_mtx);
        if (impl.pluginsDirty.count(iid)) {
            impl.scanPlugins(iid);
        }

        auto it = impl.allPlugins.find(iid);
        if (it == impl.allPlugins.end()) {
            return nullptr;
        }

        const auto &pluginsMap = it->second;
        auto it2 = pluginsMap.find(key);
        if (it2 == pluginsMap.end()) {
            return nullptr;
        }
        return it2->second;
    }

    /*!
        \internal
    */
    PluginFactory::PluginFactory(Impl &impl) : _impl(&impl) {
    }

}