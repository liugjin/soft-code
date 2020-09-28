/**
 * 主要的路由 跳转配置
 * 
 */
define('uRouter', ["Vue", "vue-router", "json!../setting.json", "underscore"], function (Vue, VueRouter, setting, _) {
    'use strict';
    var asyncComp = function (componentName) {
        return function (resolve) {
            require([componentName], resolve);
        };
    };

    var menu = []
    _.each(setting.menu, function (item) {
        if(item.children) {
            menu = menu.concat(item.children)
        } else {
            menu.push(item)
        }
    })

    menu.push({
        url: "*",
        path: "../views/404/index.js"
    })

    var routerList = _.map(menu, function (item) {
        return {
            path: item.url,
            component: asyncComp(item.path)
        }
    })

    routerList.unshift({
        path: "/",
        redirect: "/home"
    })

    var routers = new VueRouter({
        routes: routerList
    });

    return routers
});